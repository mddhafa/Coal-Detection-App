// import 'dart:async';
// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import 'package:coalmobile_app/bbox/bbox_painter.dart';
// import 'package:coalmobile_app/bbox/yolo_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// class CameraPage extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   const CameraPage({super.key, required this.cameras});

//   @override
//   State<CameraPage> createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
//   CameraController? _controller;
//   bool _ready = false;
//   String? _error;

//   bool _isProcessing = false;
//   int _frameCount = 0;
//   bool _isStreaming = false;
//   bool _modelReady = false;

//   late Interpreter _interpreter;
//   late List<int> _inputShape;
//   late List<int> _outputShape;

//   List<DetBox> _boxes640 = [];
//   final List<String> _labels = ['coal', 'gangue', 'objects'];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _boot();
//     // printModelInfo();
//   }

//   Future<void> _loadModel() async {
//     if (_modelReady) return;
//     try {
//       print('LOADING MODEL...');
//       _interpreter = await Interpreter.fromAsset(
//         'assets/models/best_float32.tflite',
//         options: InterpreterOptions()..threads = 4,
//       );

//       _inputShape = _interpreter.getInputTensor(0).shape;
//       _outputShape = _interpreter.getOutputTensor(0).shape;
//       print('YOLO_MODEL inputShape=$_inputShape outputShape=$_outputShape');

//       _modelReady = true;
//       if (mounted) setState(() {});
//       print('MODEL READY!');
//     } catch (e, st) {
//       print('LOAD MODEL ERROR: $e');
//       print(st);
//       _showSnack('Gagal load model: $e');
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _controller?.dispose();
//     if (_modelReady) _interpreter.close();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final c = _controller;
//     if (c == null) return;

//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused) {
//       c.dispose();
//       _controller = null;
//       _ready = false;
//       setState(() {});
//     } else if (state == AppLifecycleState.resumed) {
//       _boot();
//     }
//   }

//   Future<void> _boot() async {
//     setState(() {
//       _ready = false;
//       _error = null;
//     });

//     final ok = await _ensureCameraPermission();
//     if (!ok) {
//       setState(
//         () =>
//             _error =
//                 'Permission kamera ditolak. Buka Settings dan Allow Camera.',
//       );
//       return;
//     }

//     if (widget.cameras.isEmpty) {
//       setState(() => _error = 'Tidak ada kamera terdeteksi.');
//       return;
//     }

//     final cam = widget.cameras.firstWhere(
//       (c) => c.lensDirection == CameraLensDirection.back,
//       orElse: () => widget.cameras.first,
//     );

//     final configs = <_CamCfg>[
//       _CamCfg(res: ResolutionPreset.low, fmt: null, name: 'medium + default'),
//       _CamCfg(res: ResolutionPreset.low, fmt: null, name: 'low + default'),

//       // Redmi sering lebih stabil nv21
//       _CamCfg(
//         res: ResolutionPreset.medium,
//         fmt: ImageFormatGroup.nv21,
//         name: 'medium + nv21',
//       ),
//       _CamCfg(
//         res: ResolutionPreset.low,
//         fmt: ImageFormatGroup.nv21,
//         name: 'low + nv21',
//       ),

//       // kalau perlu banget yuv420
//       _CamCfg(
//         res: ResolutionPreset.medium,
//         fmt: ImageFormatGroup.yuv420,
//         name: 'low + yuv420',
//       ),
//     ];

//     String? lastErr;
//     bool cameraOk = false;

//     for (final cfg in configs) {
//       lastErr = await _tryInit(cam, cfg);
//       if (lastErr == null) {
//         cameraOk = true;
//         break; // <-- JANGAN return
//       }
//     }

//     if (!cameraOk) {
//       setState(() => _error = 'Gagal init kamera: $lastErr');
//       return;
//     }

//     // Kamera sudah OK -> sekarang load model
//     await _loadModel();
//   }

//   Future<String?> _tryInit(CameraDescription cam, _CamCfg cfg) async {
//     try {
//       await _controller?.dispose();
//       _controller = null;

//       final c = CameraController(
//         cam,
//         cfg.res,
//         enableAudio: false,
//         imageFormatGroup: cfg.fmt, // boleh null (default)
//       );

//       // timeout biar tidak stuck selamanya
//       await c.initialize().timeout(const Duration(seconds: 10));

//       // kalau berhasil
//       _controller = c;
//       setState(() {
//         _ready = true;
//         _error = null;
//       });

//       // ignore: avoid_print
//       print('Camera OK with config: ${cfg.name}');
//       return null;
//     } catch (e) {
//       // ignore: avoid_print
//       print('Camera FAIL config=${cfg.name} err=$e');
//       return e.toString();
//     }
//   }

//   Future<bool> _ensureCameraPermission() async {
//     final status = await Permission.camera.status;
//     if (status.isGranted) return true;

//     final result = await Permission.camera.request();
//     return result.isGranted;
//   }

//   void _showSnack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Future<void> _starStream() async {
//     if (!_modelReady) {
//       _showSnack('Model belum siap');
//       return;
//     }

//     final c = _controller;
//     if (c == null) return;
//     if (!c.value.isInitialized) return;

//     if (_isStreaming) return;
//     _isStreaming = true;
//     _frameCount = 0;

//     await c.startImageStream((CameraImage image) async {
//       _frameCount++;

//       final boxes = runYoloOnFrame(interpreter: _interpreter, image: image);

//       // proses 1 dari 4 frame saja biar ringan
//       if (_frameCount % 24 == 0) setState(() => _boxes640 = boxes);
//       if (_isProcessing) return;
//       _isProcessing = true;

//       try {
//         final boxes = runYoloOnFrame(
//           interpreter: _interpreter,
//           image: image,
//           confTh: 0.15,
//           iouTh: 0.45,
//         );

//         final counts = <int, int>{};
//         for (final b in boxes) {
//           counts[b.cls] = (counts[b.cls] ?? 0) + 1;
//         }
//         print('class counts=$counts');

//         if (mounted) {
//           setState(() {
//             _boxes640 = boxes;
//           });
//         }
//         print('det=${boxes.length}');
//       } catch (e) {
//         print('inference error: $e');
//       } finally {
//         _isProcessing = false;
//       }
//     });

//     if (mounted) setState(() {});
//   }

//   Future<void> _stopStream() async {
//     final c = _controller;
//     if (c == null) return;
//     if (!_isStreaming) return;

//     try {
//       await c.stopImageStream();
//     } catch (_) {}

//     _isStreaming = false;
//     _isProcessing = false;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = _controller;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Camera Preview'),
//         actions: [
//           IconButton(
//             onPressed: _boot,
//             icon: const Icon(Icons.refresh),
//             tooltip: 'Retry init camera',
//           ),
//         ],
//       ),
//       body: Center(
//         child:
//             _error != null
//                 ? Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Text(
//                     _error!,
//                     style: const TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//                 : !_ready || c == null
//                 ? const Text('Loading camera...')
//                 : AspectRatio(
//                   aspectRatio: c.value.aspectRatio,
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       CameraPreview(c),
//                       IgnorePointer(
//                         child: CustomPaint(
//                           painter: BBoxPainter(
//                             boxes: _boxes640,
//                             labels: _labels,
//                             scoreMin: 0.25,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(12),
//         child: ElevatedButton.icon(
//           onPressed:
//               (!_ready || c == null || !_modelReady)
//                   ? null
//                   : (_isStreaming ? _stopStream : _starStream),
//           icon: Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
//           label: Text(
//             !_modelReady
//                 ? 'Loading Model...'
//                 : (_isStreaming ? 'Stop Stream' : 'Start Stream'),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _CamCfg {
//   final ResolutionPreset res;
//   final ImageFormatGroup? fmt;
//   final String name;
//   _CamCfg({required this.res, required this.fmt, required this.name});
// }

// extension ReshapeFloat32 on Float32List {
//   Object reshape(List<int> shape) =>
//       this; // biasanya cukup untuk tflite_flutter
// }
