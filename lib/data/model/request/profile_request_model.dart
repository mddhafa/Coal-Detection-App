import 'dart:convert';

class LoginRequestModel {
  final String? email;
  final String? name;
  final String? phone;

  LoginRequestModel({this.email, this.name, this.phone});

  factory LoginRequestModel.fromJson(String str) =>
      LoginRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoginRequestModel.fromMap(Map<String, dynamic> json) =>
      LoginRequestModel(
        email: json["email"],
        name: json["name"],
        phone: json["phone"],
      );

  Map<String, dynamic> toMap() => {
    "email": email,
    "name": name,
    "phone": phone,
  };
}
