import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'bbox.dart';

class YoloTfliteDetector {
  final String assetPath;
  final int inputSize; // 640
  final List<String> labels;

  late final Interpreter _interpreter;
  late final List<int> _inputShape;
  late final List<int> _outputShape;

  // confidence & nms
  final double confThreshold;
  final double iouThreshold;

  YoloTfliteDetector({
    required this.assetPath,
    required this.labels,
    this.inputSize = 640,
    this.confThreshold = 0.25,
    this.iouThreshold = 0.45,
  });

  Future<void> load() async {
    final options = InterpreterOptions()..threads = 4;
    _interpreter = await Interpreter.fromAsset(assetPath, options: options);

    _inputShape = _interpreter.getInputTensor(0).shape;
    _outputShape = _interpreter.getOutputTensor(0).shape;

    // ignore: avoid_print
    print('TFLite inputShape=$_inputShape outputShape=$_outputShape');
  }

  void close() => _interpreter.close();

  /// Proses 1 frame CameraImage -> list bbox dalam koordinat preview.
  Future<List<BBox>> detect(
    CameraImage image, {
    required int previewW,
    required int previewH,
  }) async {
    // 1) YUV420 -> RGB image
    final rgb = _yuv420ToImage(image);

    // 2) Letterbox ke 640x640 (dan simpan param scale/padding)
    final letter = _letterbox(rgb, inputSize, inputSize);

    // 3) Siapkan input Float32 sesuai layout model (NHWC atau NCHW)
    final input = _makeInputTensor(letter.image);

    // 4) Siapkan output buffer
    final outLen = _outputShape.reduce((a, b) => a * b);
    final output = Float32List(outLen);

    // 5) Run inference
    _run(input, output);

    // 6) Decode output (support beberapa layout)
    final boxes640 = _decodeToBoxesIn640(output);

    // 7) NMS
    final nmsBoxes = _nms(boxes640, iouThreshold);

    // 8) Map bbox dari 640-letterbox -> preview size
    final mapped = _mapBoxesToPreview(
      nmsBoxes,
      previewW: previewW,
      previewH: previewH,
      scale: letter.scale,
      padX: letter.padX,
      padY: letter.padY,
      srcW: rgb.width,
      srcH: rgb.height,
    );

    return mapped;
  }

  // ---------------------------
  // Inference helpers
  // ---------------------------

  void _run(Float32List input, Float32List output) {
    // tflite_flutter menerima typed buffer + shape; paling aman pakai nested list via reshape sederhana
    _interpreter.run(input.reshape(_inputShape), output.reshape(_outputShape));
  }

  // Buat input Float32. Umumnya YOLO export TFLite memakai NHWC: [1,640,640,3]
  Float32List _makeInputTensor(img.Image image640) {
    final isNHWC =
        _inputShape.length == 4 &&
        _inputShape[1] == inputSize &&
        _inputShape[3] == 3;
    final isNCHW =
        _inputShape.length == 4 &&
        _inputShape[1] == 3 &&
        _inputShape[2] == inputSize;

    final pixels = Float32List(inputSize * inputSize * 3);

    if (isNHWC) {
      int pIndex = 0;
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final px = image640.getPixel(x, y);
          pixels[pIndex++] = px.r / 255.0;
          pixels[pIndex++] = px.g / 255.0;
          pixels[pIndex++] = px.b / 255.0;
        }
      }
      return pixels;
    }

    // NCHW
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final idx = y * inputSize + x;
        final px = image640.getPixel(x, y);
        pixels[idx] = px.r / 255.0;
        pixels[inputSize * inputSize + idx] = px.g / 255.0;
        pixels[2 * inputSize * inputSize + idx] = px.b / 255.0;
      }
    }
    return pixels;
  }

  // Decode output jadi bbox dalam koordinat 640x640 (sebelum mapping balik)
  // Support bentuk umum:
  // - [1, D, N]  (mis. [1,7,34000] atau [1,84,8400])
  // - [1, N, D]
  List<_RawBox> _decodeToBoxesIn640(Float32List output) {
    final shape = _outputShape;
    if (shape.length != 3) {
      // kalau output bukan 3D, butuh penyesuaian (jarang untuk YOLO)
      return [];
    }

    final b = shape[0];
    final a = shape[1];
    final c = shape[2];
    if (b != 1) return [];

    // Tentukan mana yang D (dim fitur) dan mana N (jumlah kandidat)
    // Heuristik: D biasanya kecil (<= 200), N besar (>= 1000)
    late int D, N;
    late bool isDN; // true kalau layout [1, D, N]
    if (a <= 200 && c >= 1000) {
      D = a;
      N = c;
      isDN = true;
    } else if (c <= 200 && a >= 1000) {
      D = c;
      N = a;
      isDN = false; // [1, N, D]
    } else {
      // fallback: anggap [1, D, N]
      D = a;
      N = c;
      isDN = true;
    }

    // Format YOLO yang sering:
    // [x, y, w, h, obj/conf, class1..classK] => D = 5 + K
    // K = D - 5 (kalau D>=6)
    final k = max(0, D - 5);

    final result = <_RawBox>[];

    for (int i = 0; i < N; i++) {
      double x, y, w, h, conf;
      if (isDN) {
        x = output[_idxDN(0, i, D, N)];
        y = output[_idxDN(1, i, D, N)];
        w = output[_idxDN(2, i, D, N)];
        h = output[_idxDN(3, i, D, N)];
        conf = output[_idxDN(4, i, D, N)];
      } else {
        x = output[_idxND(i, 0, N, D)];
        y = output[_idxND(i, 1, N, D)];
        w = output[_idxND(i, 2, N, D)];
        h = output[_idxND(i, 3, N, D)];
        conf = output[_idxND(i, 4, N, D)];
      }

      if (conf < confThreshold) continue;

      int classId = 0;
      double classProb = 1.0;

      if (k > 0) {
        // cari class prob tertinggi
        double best = -1;
        int bestId = 0;
        for (int ci = 0; ci < k; ci++) {
          final v =
              isDN
                  ? output[_idxDN(5 + ci, i, D, N)]
                  : output[_idxND(i, 5 + ci, N, D)];
          if (v > best) {
            best = v;
            bestId = ci;
          }
        }
        classId = bestId;
        classProb = best;
      }

      final score = conf * classProb;
      if (score < confThreshold) continue;

      // Banyak export YOLO output x,y,w,h di skala 0..640 (atau 0..1). Kita handle dua-duanya.
      // Jika nilai kecil (<=2), asumsi 0..1 -> skala ke 640.
      if (x <= 2 && y <= 2 && w <= 2 && h <= 2) {
        x *= inputSize;
        y *= inputSize;
        w *= inputSize;
        h *= inputSize;
      }

      final x1 = x - w / 2;
      final y1 = y - h / 2;
      final x2 = x + w / 2;
      final y2 = y + h / 2;

      result.add(
        _RawBox(
          x1: x1.clamp(0, inputSize.toDouble()),
          y1: y1.clamp(0, inputSize.toDouble()),
          x2: x2.clamp(0, inputSize.toDouble()),
          y2: y2.clamp(0, inputSize.toDouble()),
          score: score,
          classId: classId,
        ),
      );
    }

    // sort by score desc
    result.sort((a, b) => b.score.compareTo(a.score));
    return result;
  }

  int _idxDN(int d, int n, int D, int N) => d * N + n; // [D,N] flattened
  int _idxND(int n, int d, int N, int D) => n * D + d; // [N,D] flattened

  List<_RawBox> _nms(List<_RawBox> boxes, double iouTh) {
    final picked = <_RawBox>[];
    for (final b in boxes) {
      bool keep = true;
      for (final p in picked) {
        if (b.classId != p.classId) continue; // NMS per-class
        final iou = _iou(b, p);
        if (iou > iouTh) {
          keep = false;
          break;
        }
      }
      if (keep) picked.add(b);
      if (picked.length >= 50) break; // limit
    }
    return picked;
  }

  double _iou(_RawBox a, _RawBox b) {
    final xx1 = max(a.x1, b.x1);
    final yy1 = max(a.y1, b.y1);
    final xx2 = min(a.x2, b.x2);
    final yy2 = min(a.y2, b.y2);

    final w = max(0.0, xx2 - xx1);
    final h = max(0.0, yy2 - yy1);
    final inter = w * h;

    final areaA = max(0.0, a.x2 - a.x1) * max(0.0, a.y2 - a.y1);
    final areaB = max(0.0, b.x2 - b.x1) * max(0.0, b.y2 - b.y1);
    final union = areaA + areaB - inter;

    if (union <= 0) return 0;
    return inter / union;
  }

  List<BBox> _mapBoxesToPreview(
    List<_RawBox> boxes640, {
    required int previewW,
    required int previewH,
    required double scale,
    required int padX,
    required int padY,
    required int srcW,
    required int srcH,
  }) {
    final out = <BBox>[];

    // 640-letterbox -> src image
    for (final b in boxes640) {
      // remove padding
      final x1 = (b.x1 - padX) / scale;
      final y1 = (b.y1 - padY) / scale;
      final x2 = (b.x2 - padX) / scale;
      final y2 = (b.y2 - padY) / scale;

      // clamp to original image
      final ox1 = x1.clamp(0.0, srcW.toDouble());
      final oy1 = y1.clamp(0.0, srcH.toDouble());
      final ox2 = x2.clamp(0.0, srcW.toDouble());
      final oy2 = y2.clamp(0.0, srcH.toDouble());

      // map to preview size (CameraPreview biasanya aspect ratio sama dengan image)
      final px1 = ox1 * previewW / srcW;
      final py1 = oy1 * previewH / srcH;
      final px2 = ox2 * previewW / srcW;
      final py2 = oy2 * previewH / srcH;

      final label =
          (b.classId >= 0 && b.classId < labels.length)
              ? labels[b.classId]
              : 'cls${b.classId}';

      out.add(
        BBox(
          x1: px1,
          y1: py1,
          x2: px2,
          y2: py2,
          score: b.score,
          classId: b.classId,
          label: label,
        ),
      );
    }

    return out;
  }

  // ---------------------------
  // Image preprocessing
  // ---------------------------

  _LetterboxResult _letterbox(img.Image src, int dstW, int dstH) {
    final srcW = src.width;
    final srcH = src.height;

    final r = min(dstW / srcW, dstH / srcH);
    final newW = (srcW * r).round();
    final newH = (srcH * r).round();

    final resized = img.copyResize(
      src,
      width: newW,
      height: newH,
      interpolation: img.Interpolation.linear,
    );

    final padX = ((dstW - newW) / 2).round();
    final padY = ((dstH - newH) / 2).round();

    // background 114 ala YOLO
    final canvas = img.Image(width: dstW, height: dstH);
    img.fill(canvas, color: img.ColorRgb8(114, 114, 114));

    img.compositeImage(canvas, resized, dstX: padX, dstY: padY);

    return _LetterboxResult(image: canvas, scale: r, padX: padX, padY: padY);
  }

  // Konversi CameraImage (YUV420) ke RGB image (pakai rumus standar)
  img.Image _yuv420ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final yRowStride = image.planes[0].bytesPerRow;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final out = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      final yRow = yRowStride * y;
      final uvRow = uvRowStride * (y >> 1);

      for (int x = 0; x < width; x++) {
        final yIndex = yRow + x;

        final uvIndex = uvRow + (x >> 1) * uvPixelStride;
        final yp = yPlane[yIndex] & 0xFF;
        final up = uPlane[uvIndex] & 0xFF;
        final vp = vPlane[uvIndex] & 0xFF;

        // YUV -> RGB
        final yf = yp.toDouble();
        final uf = (up - 128).toDouble();
        final vf = (vp - 128).toDouble();

        int r = (yf + 1.402 * vf).round();
        int g = (yf - 0.344136 * uf - 0.714136 * vf).round();
        int b = (yf + 1.772 * uf).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        out.setPixelRgba(x, y, r, g, b, 255);
      }
    }
    return out;
  }
}

// ---------------------------
// Small helper structs
// ---------------------------

class _LetterboxResult {
  final img.Image image;
  final double scale;
  final int padX;
  final int padY;

  _LetterboxResult({
    required this.image,
    required this.scale,
    required this.padX,
    required this.padY,
  });
}

class _RawBox {
  final double x1, y1, x2, y2;
  final double score;
  final int classId;

  _RawBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.score,
    required this.classId,
  });
}

// Simple reshape helper (tflite_flutter butuh nested/list-like sesuai shape)
extension _ReshapeFloat32 on Float32List {
  Object reshape(List<int> shape) {
    if (shape.length == 1) return this;
    // tflite_flutter di banyak kasus menerima typed list + shape dari tensor,
    // tapi beberapa versi butuh nested list. Kita buat nested minimal untuk 4D/3D.
    if (shape.length == 4) {
      final b = shape[0], h = shape[1], w = shape[2], c = shape[3];
      int idx = 0;
      return List.generate(b, (_) {
        return List.generate(h, (_) {
          return List.generate(w, (_) {
            final row = List<double>.filled(c, 0);
            for (int k = 0; k < c; k++) row[k] = this[idx++].toDouble();
            return row;
          });
        });
      });
    }
    if (shape.length == 3) {
      final b = shape[0], a = shape[1], c = shape[2];
      int idx = 0;
      return List.generate(b, (_) {
        return List.generate(a, (_) {
          final row = List<double>.filled(c, 0);
          for (int k = 0; k < c; k++) row[k] = this[idx++].toDouble();
          return row;
        });
      });
    }
    return this;
  }
}
