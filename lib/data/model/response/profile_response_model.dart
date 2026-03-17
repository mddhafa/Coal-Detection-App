import 'dart:convert';

class ProfileResponseModel {
  final String message;
  final User data;

  ProfileResponseModel({required this.message, required this.data});

  factory ProfileResponseModel.fromJson(String str) =>
      ProfileResponseModel.fromMap(json.decode(str));

  factory ProfileResponseModel.fromMap(Map<String, dynamic> json) {
    return ProfileResponseModel(
      message: json["message"],
      data: User.fromMap(json["data"]),
    );
  }
}

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;

  User({this.id, this.name, this.email, this.role, this.phone});

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    role: json['role'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
  };
}
