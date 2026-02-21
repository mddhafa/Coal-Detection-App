import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';

import 'package:coalmobile_app/data/model/request/login_request_model.dart';
import 'package:coalmobile_app/data/model/response/login_response_model.dart';
import 'package:coalmobile_app/services/service_http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Authrepo {
  final ServiceHttp _serviceHttp;
  final Storage = FlutterSecureStorage();

  Authrepo(this._serviceHttp);

  Future<Either<String, AuthResponseModel>> login(
    LoginRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttp.post(
        "login",
        requestModel.toMap(),
      );
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        final loginResponse = AuthResponseModel.fromMap(jsonResponse);
        await Storage.write(
          key: "authToken",
          value: loginResponse.user!.token,
        );
        await Storage.write(
          key: "userRole",
          value: loginResponse.user!.role,
        );
        log("Login successful: ${loginResponse.message}");
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
}
