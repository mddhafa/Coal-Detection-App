class BBox {
  final double x1, y1, x2, y2; // dalam koordinat preview (pixel)
  final double score;
  final int classId;
  final String label;

  const BBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.score,
    required this.classId,
    required this.label,
  });
}
