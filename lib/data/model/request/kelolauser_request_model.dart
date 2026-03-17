import 'dart:convert';

class KelolaUserRequestModel {
  final String? email;
  final String? name;
  final String? phone;
  final String? password;

  KelolaUserRequestModel({this.email, this.name, this.phone, this.password});

  factory KelolaUserRequestModel.fromJson(String str) =>
      KelolaUserRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory KelolaUserRequestModel.fromMap(Map<String, dynamic> json) =>
      KelolaUserRequestModel(
        email: json["email"],
        name: json["name"],
        phone: json["phone"],
        password: json["password"],
      );

  Map<String, dynamic> toMap() => {
    "email": email,
    "name": name,
    "phone": phone,
    "password": password,
  };
}
