import 'dart:convert';
import 'dart:developer';
import 'package:coalmobile_app/data/model/request/register_request_model.dart';
import 'package:dartz/dartz.dart';

import 'package:coalmobile_app/data/model/request/login_request_model.dart';
import 'package:coalmobile_app/data/model/response/login_response_model.dart';
import 'package:coalmobile_app/services/service_http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Authrepo {
  final ServiceHttp _serviceHttp;
  final storage = FlutterSecureStorage();

  Authrepo(this._serviceHttp);

  Future<Either<String, AuthResponseModel>> login(
    LoginRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttp.post("login", requestModel.toMap());
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        final loginResponse = AuthResponseModel.fromMap(jsonResponse);
        await storage.write(key: "authToken", value: loginResponse.token);
        // final savedToken = await Storage.read(key: "authToken");
        await storage.write(key: "userRole", value: loginResponse.user!.role);
        log("Login successful: ${loginResponse.message}");
        log("Token saved: ${loginResponse.token}");
        log("Logged in as role: ${loginResponse.user!.role}");
        return Right(loginResponse);
      } else {
        log("Login failed: ${jsonResponse['message']}");
        return Left(jsonResponse['message'] ?? "Login failed");
      }
    } catch (e) {
      log("Error in login: $e");
      return Left("An error occurred while logging in.");
    }
  }

  Future<Either<String, AuthResponseModel>> register(
    RegisterRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttp.post(
        'register',
        requestModel.toMap(),
      );

      log("Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      if (response.body.isEmpty) {
        return Left('Server mengembalikan body kosong');
      }

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        final registerResponse = AuthResponseModel.fromMap(jsonResponse);
        return Right(registerResponse);
      } else {
        return Left(jsonResponse['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      return Left('Terjadi kesalahan saat registrasi: $e');
    }
  }
}
