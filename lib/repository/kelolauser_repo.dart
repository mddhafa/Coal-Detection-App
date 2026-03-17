import 'dart:convert';

import 'package:coalmobile_app/data/model/response/kelolauser_response_model.dart';
import 'package:coalmobile_app/services/service_http.dart';
import 'package:dartz/dartz.dart';

class KelolauserRepo {
  final ServiceHttp _serviceHttp;

  KelolauserRepo(this._serviceHttp);

  Future<Map<String, dynamic>> addUser(Map<String, dynamic> userData) async {
    try {
      final response = await _serviceHttp.postWithToken("admin/add", userData);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return {
          "success": true,
          "message": jsonResponse['message'] ?? 'User berhasil ditambahkan',
        };
      } else {
        final jsonResponse = json.decode(response.body);
        return {
          "success": false,
          "message": jsonResponse['message'] ?? 'Gagal menambahkan user',
        };
      }
    } catch (e) {
      return {"success": false, "message": 'Terjadi kesalahan: $e'};
    }
  }

  Future<Either<String, KelolaUsersResponseModel>> getUsers() async {
    try {
      final response = await _serviceHttp.getWithToken("admin/get");
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final usersResponse = KelolaUsersResponseModel.fromMap(jsonResponse);
        return Right(usersResponse);
      } else {
        final jsonResponse = json.decode(response.body);
        return Left(jsonResponse['message'] ?? 'Gagal mengambil data user');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  Future<Either<String, Datum>> getUserById(int id) async {
    try {
      final response = await _serviceHttp.getWithToken("admin/get/$id");
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final userResponse = Datum.fromMap(jsonResponse['data']);
        return Right(userResponse);
      } else {
        final jsonResponse = json.decode(response.body);
        return Left(jsonResponse['message'] ?? 'Gagal mengambil data user');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _serviceHttp.putWithToken(
        "admin/update/$id",
        userData,
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return {
          "message": jsonResponse['message'] ?? 'User berhasil diperbarui',
        };
      } else {
        final jsonResponse = json.decode(response.body);
        return {"message": jsonResponse['message'] ?? 'Gagal memperbarui user'};
      }
    } catch (e) {
      return {"message": 'Terjadi kesalahan: $e'};
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await _serviceHttp.postWithToken("admin/delete/$id", {});
      if (response.statusCode == 200) {
        print('User berhasil dihapus');
      } else {
        final jsonResponse = json.decode(response.body);
        print(jsonResponse['message'] ?? 'Gagal menghapus user');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }
}
