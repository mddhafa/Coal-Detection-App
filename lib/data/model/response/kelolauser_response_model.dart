import 'package:meta/meta.dart';
import 'dart:convert';

KelolaUsersResponseModel kelolaUsersResponseModelFromMap(String str) =>
    KelolaUsersResponseModel.fromMap(json.decode(str));

String kelolaUsersResponseModelToMap(KelolaUsersResponseModel data) =>
    json.encode(data.toMap());

class KelolaUsersResponseModel {
  final String status;
  final List<Datum> data;

  KelolaUsersResponseModel({required this.status, required this.data});

  factory KelolaUsersResponseModel.fromJson(String str) =>
      KelolaUsersResponseModel.fromMap(json.decode(str));

  factory KelolaUsersResponseModel.fromMap(Map<String, dynamic> json) =>
      KelolaUsersResponseModel(
        status: json["status"],
        data:
            json["data"] == null
                ? []
                : List<Datum>.from(json["data"]!.map((x) => Datum.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
    "status": status,
    "data": data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
  };
}

class Datum {
  final int id;
  final String name;
  final String email;
  final String phone;

  Datum({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Datum.fromMap(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    name: json["name"]?.toString() ?? "",
    email: json["email"]?.toString() ?? "",
    phone: json["phone"]?.toString() ?? "",
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
  };
}
