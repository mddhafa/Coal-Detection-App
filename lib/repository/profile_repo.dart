import 'dart:convert';

import 'package:coalmobile_app/data/model/response/profile_response_model.dart';
import 'package:coalmobile_app/services/service_http.dart';

class ProfileRepository {
  final ServiceHttp _serviceHttp;

  ProfileRepository(this._serviceHttp);

  // Future<ProfileResponseModel> getProfile() async {
  //   try {
  //     final response = await _serviceHttp.getWithToken("profile");

  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       return ProfileResponseModel.fromMap(jsonResponse);
  //     } else {
  //       throw Exception(
  //         "Gagal mengambil profil: ${response.statusCode} ${response.body}",
  //       );
  //     }
  //   } catch (e) {
  //     throw Exception("Terjadi kesalahan saat mengambil profil: $e");
  //   }
  // }

  Future<ProfileResponseModel> getProfile() async {
    final response = await _serviceHttp.getWithToken("profile");

    if (response.statusCode == 200) {
      return ProfileResponseModel.fromJson(response.body);
    } else {
      throw Exception("Failed load profile");
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updatedData) async {
    try {
      final response = await _serviceHttp.putWithToken(
        "profile/update",
        updatedData,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          "Gagal memperbarui profil: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat memperbarui profil: $e");
    }
  }
}
