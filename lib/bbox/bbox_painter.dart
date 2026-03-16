// import 'package:flutter/material.dart';
// import 'package:coalmobile_app/bbox/yolo_utils.dart'; // DetBox

// class BBoxPainter extends CustomPainter {
//   final List<DetBox> boxes; // bbox masih koordinat 640x640
//   final List<String> labels; // nama class
//   final double scoreMin; // filter tampilan

//   BBoxPainter({required this.boxes, required this.labels, this.scoreMin = 0.0});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 3;

//     final tp = TextPainter(textDirection: TextDirection.ltr);

//     // Karena bbox kita 640x640, kita skala ke size widget preview
//     final sx = size.width / 640.0;
//     final sy = size.height / 640.0;

//     for (final b in boxes) {
//       if (b.score < scoreMin) continue;

//       final x1 = b.x1 * sx;
//       final y1 = b.y1 * sy;
//       final x2 = b.x2 * sx;
//       final y2 = b.y2 * sy;

//       paint.color = Colors.greenAccent;
//       canvas.drawRect(Rect.fromLTRB(x1, y1, x2, y2), paint);

//       final label =
//           (b.cls >= 0 && b.cls < labels.length) ? labels[b.cls] : 'cls${b.cls}';
//       final text = '$label ${(b.score * 100).toStringAsFixed(1)}%';

//       tp.text = TextSpan(
//         text: text,
//         style: const TextStyle(
//           color: Colors.white,
//           backgroundColor: Colors.black87,
//           fontSize: 14,
//         ),
//       );
//       tp.layout();

//       final oy = (y1 - tp.height).clamp(0.0, size.height);
//       tp.paint(canvas, Offset(x1, oy));
//     }
//   }

//   @override
//   bool shouldRepaint(covariant BBoxPainter oldDelegate) => true;
// }
