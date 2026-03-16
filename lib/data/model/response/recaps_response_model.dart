import 'dart:convert';

class RecapsResponseModel {
  final String status;
  final List<Datum>? data;

  RecapsResponseModel({required this.status, required this.data});

  factory RecapsResponseModel.fromJson(String str) =>
      RecapsResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RecapsResponseModel.fromMap(Map<String, dynamic> json) =>
      RecapsResponseModel(
        status: json["status"],
        data:
            json["data"] == null
                ? []
                : List<Datum>.from(json["data"]!.map((x) => Datum.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
    "status": status,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
  };
}

class Datum {
  final int id;
  final String periodType;
  final int? day;
  final int? week;
  final int? month;
  final int year;
  final int total_coal;
  final int total_gangue;
  final int total_objects;
  final DateTime createdAt;

  Datum({
    required this.id,
    required this.periodType,
    required this.day,
    required this.week,
    required this.month,
    required this.year,
    required this.total_coal,
    required this.total_gangue,
    required this.total_objects,
    required this.createdAt,
  });

  factory Datum.fromMap(Map<String, dynamic> json) => Datum(
    id: json["id"],
    periodType: json["period_type"],
    day: json["day"],
    week: json["week"],
    month: json["month"],
    year: json["year"],
    total_coal: json["total_coal"],
    total_gangue: json["total_gangue"],
    total_objects: json["total_objects"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "period_type": periodType,
    "day": day,
    "week": week,
    "month": month,
    "year": year,
    "total_coal": total_coal,
    "total_gangue": total_gangue,
    "total_objects": total_objects,
    "created_at": createdAt.toIso8601String(),
  };
}
