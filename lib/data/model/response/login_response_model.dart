import 'dart:convert';

class AuthResponseModel {
  final String? message;
  final int? statuscode;
  final User? user;

  AuthResponseModel({this.message, this.statuscode, this.user});

  factory AuthResponseModel.fromJson(String str) =>
      AuthResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AuthResponseModel.fromMap(Map<String, dynamic> json) =>
      AuthResponseModel(
        message: json['message'],
        statuscode: json['statuscode'],
        user: json['user'] != null ? User.fromMap(json['user']) : null,
      );

  Map<String, dynamic> toMap() => {
    'message': message,
    'statuscode': statuscode,
    'user': user,
  };
}

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? token;
  final String? role;

  User({this.id, this.name, this.email, this.token, this.role});

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    token: json['token'],
    role: json['role'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'token': token,
    'role': role,
  };
}
