import 'dart:convert';
import 'dart:developer';
import 'package:coalmobile_app/data/model/response/recaps_response_model.dart';
import 'package:dartz/dartz.dart';
import 'package:coalmobile_app/services/service_http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MonitoringRepo {
  final ServiceHttp _serviceHttp;
  final storage = FlutterSecureStorage();

  MonitoringRepo(this._serviceHttp);

  // ===============================
  // GENERATE DAILY RECAP
  // ===============================
  Future<Either<String, String>> generateDailyRecap() async {
    try {
      final response = await _serviceHttp.postWithToken(
        "recaps/generate-daily",
        {},
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        log("Daily recap generated");
        return Right(jsonResponse['message']);
      } else {
        return Left(jsonResponse['message'] ?? "Failed generate daily recap");
      }
    } catch (e) {
      log("Error: $e");
      return Left("Error generate daily recap");
    }
  }

  // ===============================
  // GENERATE WEEKLY RECAP
  // ===============================
  Future<Either<String, String>> generateWeeklyRecap() async {
    try {
      final response = await _serviceHttp.postWithToken(
        "recaps/generate-weekly",
        {},
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        log("Weekly recap generated");
        return Right(jsonResponse['message']);
      } else {
        return Left(jsonResponse['message'] ?? "Failed generate weekly recap");
      }
    } catch (e) {
      log("Error: $e");
      return Left("Error generate weekly recap");
    }
  }

  // ===============================
  // GENERATE MONTHLY RECAP
  // ===============================
  Future<Either<String, String>> generateMonthlyRecap() async {
    try {
      final response = await _serviceHttp.postWithToken(
        "recaps/generate-monthly",
        {},
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        log("Monthly recap generated");
        return Right(jsonResponse['message']);
      } else {
        return Left(jsonResponse['message'] ?? "Failed generate monthly recap");
      }
    } catch (e) {
      log("Error: $e");
      return Left("Error generate monthly recap");
    }
  }

  Future<Either<String, RecapsResponseModel>> getDailyRecap() async {
    try {
      final response = await _serviceHttp.getWithToken('recaps/daily');

      if (response.statusCode == 200) {
        log("Daily recap generated");
        final jsonResponse = json.decode(response.body);

        final recap = RecapsResponseModel.fromMap(jsonResponse);

        return Right(recap); // masukkan ke dalam List
      } else {
        return Left("Failed to retrieve recaps");
      }
    } catch (e) {
      log("Error: $e");
      return Left("Error retrieving recaps");
    }
  }

  Future<Either<String, RecapsResponseModel>> getWeeklyRecap() async {
    try {
      final response = await _serviceHttp.getWithToken('recaps/weekly');

      if (response.statusCode == 200) {
        log("Weekly recap generated");
        final jsonResponse = json.decode(response.body);

        final recap = RecapsResponseModel.fromMap(jsonResponse);

        return Right(recap); // masukkan ke dalam List
      } else {
        return Left("Failed to retrieve recaps");
      }
    } catch (e) {
      log("Error: $e");
      return Left("Error retrieving recaps");
    }
  }

  Future<Either<String, RecapsResponseModel>> getMonthlyRecap() async {
    try {
      final response = await _serviceHttp.getWithToken('recaps/monthly');

      if (response.statusCode == 200) {
        log("Monthly recap generated");
        final jsonResponse = json.decode(response.body);

        final recap = RecapsResponseModel.fromMap(jsonResponse);

        return Right(recap); // masukkan ke dalam List
      } else {
        return Left("Failed to retrieve recaps");
      }
    } catch (e) {
      log("Error: $e");
      return Left("Error retrieving recaps");
    }
  }
}
