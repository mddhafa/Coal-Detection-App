// import 'dart:math';
// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// class LetterboxResult {
//   final Uint8List rgb; // RGB 640x640
//   final double scale;
//   final int padX;
//   final int padY;
//   final int srcW;
//   final int srcH;

//   LetterboxResult({
//     required this.rgb,
//     required this.scale,
//     required this.padX,
//     required this.padY,
//     required this.srcW,
//     required this.srcH,
//   });
// }

// class DetBox {
//   final double x1, y1, x2, y2;
//   final double score;
//   final int cls;
//   DetBox(this.x1, this.y1, this.x2, this.y2, this.score, this.cls);
// }

// // ---------- 1) YUV420 -> RGB bytes ----------
// Uint8List yuv420ToRgbBytes(CameraImage image) {
//   final w = image.width;
//   final h = image.height;

//   final yPlane = image.planes[0];
//   final uPlane = image.planes[1];
//   final vPlane = image.planes[2];

//   final yBytes = yPlane.bytes;
//   final uBytes = uPlane.bytes;
//   final vBytes = vPlane.bytes;

//   final yRowStride = yPlane.bytesPerRow;
//   final uvRowStride = uPlane.bytesPerRow;
//   final uvPixelStride = uPlane.bytesPerPixel ?? 1;

//   final out = Uint8List(w * h * 3);
//   int o = 0;

//   for (int y = 0; y < h; y++) {
//     final yRow = yRowStride * y;
//     final uvRow = uvRowStride * (y >> 1);

//     for (int x = 0; x < w; x++) {
//       final yIndex = yRow + x;
//       final uvIndex = uvRow + (x >> 1) * uvPixelStride;

//       final yp = yBytes[yIndex] & 0xFF;
//       final up = (uBytes[uvIndex] & 0xFF) - 128;
//       final vp = (vBytes[uvIndex] & 0xFF) - 128;

//       int r = (yp + 1.402 * vp).round();
//       int g = (yp - 0.344136 * up - 0.714136 * vp).round();
//       int b = (yp + 1.772 * up).round();

//       if (r < 0) r = 0;
//       if (g < 0) g = 0;
//       if (b < 0) b = 0;
//       if (r > 255) r = 255;
//       if (g > 255) g = 255;
//       if (b > 255) b = 255;

//       out[o++] = r;
//       out[o++] = g;
//       out[o++] = b;
//     }
//   }
//   return out;
// }

// // ---------- 2) Letterbox -> 640 ----------
// LetterboxResult letterboxTo640({
//   required Uint8List rgb,
//   required int srcW,
//   required int srcH,
//   int dst = 640,
// }) {
//   final scale = min(dst / srcW, dst / srcH);
//   final newW = (srcW * scale).round();
//   final newH = (srcH * scale).round();

//   final padX = ((dst - newW) / 2).round();
//   final padY = ((dst - newH) / 2).round();

//   final out = Uint8List(dst * dst * 3);
//   for (int i = 0; i < out.length; i += 3) {
//     out[i] = 114;
//     out[i + 1] = 114;
//     out[i + 2] = 114;
//   }

//   for (int y = 0; y < newH; y++) {
//     final sy = (y / scale).floor().clamp(0, srcH - 1);
//     for (int x = 0; x < newW; x++) {
//       final sx = (x / scale).floor().clamp(0, srcW - 1);
//       final srcIdx = (sy * srcW + sx) * 3;
//       final dstIdx = ((y + padY) * dst + (x + padX)) * 3;

//       out[dstIdx] = rgb[srcIdx];
//       out[dstIdx + 1] = rgb[srcIdx + 1];
//       out[dstIdx + 2] = rgb[srcIdx + 2];
//     }
//   }

//   return LetterboxResult(
//     rgb: out,
//     scale: scale,
//     padX: padX,
//     padY: padY,
//     srcW: srcW,
//     srcH: srcH,
//   );
// }

// // ---------- 3) Build nested input/output for TFLite ----------
// List makeInputNHWC(Float32List inputFlat) {
//   int idx = 0;
//   return [
//     List.generate(640, (_) {
//       return List.generate(640, (_) {
//         final px = [
//           inputFlat[idx++].toDouble(),
//           inputFlat[idx++].toDouble(),
//           inputFlat[idx++].toDouble(),
//         ];
//         return px;
//       });
//     }),
//   ];
// }

// List makeOutput3D(Float32List outFlat) {
//   // [1,7,34000]
//   int idx = 0;
//   return [
//     List.generate(7, (_) {
//       final row = List<double>.filled(34000, 0);
//       for (int i = 0; i < 34000; i++) row[i] = outFlat[idx++].toDouble();
//       return row;
//     }),
//   ];
// }

// // ---------- 4) Decode YOLOv8 output [1,7,34000] ----------
// List<DetBox> decodeYolo7xN(Float32List outFlat, {double confTh = 0.25}) {
//   const N = 34000;
//   double get(int d, int n) => outFlat[d * N + n];

//   final boxes = <DetBox>[];

//   for (int n = 0; n < N; n++) {
//     final x = get(0, n);
//     final y = get(1, n);
//     final w = get(2, n);
//     final h = get(3, n);

//     final score = get(4, n); // skor final
//     final clsF = get(5, n); // class id (0/1/2)
//     // final extra = get(6, n);   // biasanya tidak dipakai

//     if (score < confTh) continue;

//     int cls = clsF.round();
//     if (cls < 0) cls = 0;
//     if (cls > 2) cls = 2; // karena kamu punya 3 class

//     // kadang bbox dinormalisasi 0..1 → scale ke 640
//     double xx = x, yy = y, ww = w, hh = h;
//     if (xx <= 2 && yy <= 2 && ww <= 2 && hh <= 2) {
//       xx *= 640;
//       yy *= 640;
//       ww *= 640;
//       hh *= 640;
//     }

//     final x1 = (xx - ww / 2).clamp(0.0, 640.0);
//     final y1 = (yy - hh / 2).clamp(0.0, 640.0);
//     final x2 = (xx + ww / 2).clamp(0.0, 640.0);
//     final y2 = (yy + hh / 2).clamp(0.0, 640.0);

//     boxes.add(DetBox(x1, y1, x2, y2, score, cls));
//   }

//   boxes.sort((a, b) => b.score.compareTo(a.score));
//   return boxes;
// }

// double iou(DetBox a, DetBox b) {
//   final xx1 = max(a.x1, b.x1);
//   final yy1 = max(a.y1, b.y1);
//   final xx2 = min(a.x2, b.x2);
//   final yy2 = min(a.y2, b.y2);

//   final w = xx2 - xx1;
//   final h = yy2 - yy1;
//   if (w <= 0 || h <= 0) return 0;

//   final inter = w * h;
//   final areaA = (a.x2 - a.x1) * (a.y2 - a.y1);
//   final areaB = (b.x2 - b.x1) * (b.y2 - b.y1);
//   return inter / (areaA + areaB - inter);
// }

// List<DetBox> nms(List<DetBox> boxes, {double iouTh = 0.45}) {
//   final picked = <DetBox>[];
//   for (final b in boxes) {
//     bool keep = true;
//     for (final p in picked) {
//       if (b.cls != p.cls) continue;
//       if (iou(b, p) > iouTh) {
//         keep = false;
//         break;
//       }
//     }
//     if (keep) picked.add(b);
//     if (picked.length >= 50) break;
//   }
//   return picked;
// }

// List<DetBox> decodeYoloFromOut3d(List out3d, {double confTh = 0.25}) {
//   // out3d: [1][7][34000]
//   final d = out3d[0] as List;
//   final boxes = <DetBox>[];

//   for (int n = 0; n < 34000; n++) {
//     final x = (d[0][n] as num).toDouble();
//     final y = (d[1][n] as num).toDouble();
//     final w = (d[2][n] as num).toDouble();
//     final h = (d[3][n] as num).toDouble();

//     final score = (d[4][n] as num).toDouble();
//     final clsF = (d[5][n] as num).toDouble();
//     // d[6][n] biasanya extra/unused

//     if (score < confTh) continue;

//     int cls = clsF.floor();
//     if (cls < 0) cls = 0;
//     if (cls > 2) cls = 2; // kamu punya 3 class

//     print('clsF sample=${clsF}');

//     // handle normalized 0..1 -> 640
//     double xx = x, yy = y, ww = w, hh = h;
//     if (xx <= 2 && yy <= 2 && ww <= 2 && hh <= 2) {
//       xx *= 640;
//       yy *= 640;
//       ww *= 640;
//       hh *= 640;
//     }

//     final x1 = (xx - ww / 2).clamp(0.0, 640.0);
//     final y1 = (yy - hh / 2).clamp(0.0, 640.0);
//     final x2 = (xx + ww / 2).clamp(0.0, 640.0);
//     final y2 = (yy + hh / 2).clamp(0.0, 640.0);

//     boxes.add(DetBox(x1, y1, x2, y2, score, cls));

//     if (score > 0.5) {
//       print(
//         'DEBUG score=$score clsF=$clsF extra=${(d[6][n] as num).toDouble()}',
//       );
//       break;
//     }
//   }

//   boxes.sort((a, b) => b.score.compareTo(a.score));
//   return boxes;
// }

// // ---------- 5) Full inference helper ----------
// List<DetBox> runYoloOnFrame({
//   required Interpreter interpreter,
//   required CameraImage image,
//   double confTh = 0.25,
//   double iouTh = 0.45,
// }) {
//   // 1) CameraImage (YUV420) -> RGB bytes
//   final rgb = yuv420ToRgbBytes(image);

//   // 2) Letterbox -> 640x640
//   final lb = letterboxTo640(rgb: rgb, srcW: image.width, srcH: image.height);

//   // 3) RGB bytes -> Float32 input (NHWC), normalize 0..1
//   final inputFlat = Float32List(1 * 640 * 640 * 3);
//   for (int i = 0; i < lb.rgb.length; i++) {
//     inputFlat[i] = lb.rgb[i] / 255.0;
//   }

//   // 4) Buat input nested list (NHWC)
//   final input4d = makeInputNHWC(inputFlat);

//   // 5) BUAT OUTPUT nested list yang akan diisi oleh TFLite
//   // outputShape kamu: [1,7,34000]
//   final out3d = [List.generate(7, (_) => List<double>.filled(34000, 0.0))];

//   // 6) Inference
//   interpreter.run(input4d, out3d);

//   // 7) Decode langsung dari out3d (bukan outFlat)
//   final raw = decodeYoloFromOut3d(out3d, confTh: confTh);
//   return nms(raw, iouTh: iouTh);
// }
