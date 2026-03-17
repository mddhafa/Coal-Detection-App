import 'dart:convert';

import 'package:coalmobile_app/presentation/kelola%20user/bloc/kelola_user_bloc.dart';
import 'package:coalmobile_app/repository/kelolauser_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ServiceHttp {
  final String baseUrl = 'http://10.0.2.2:3000/api/';
  // final String baseUrl = 'http://192.168.18.15:3000/api/';
  final storage = FlutterSecureStorage();

  //get
  Future<http.Response> getWithToken(String endPoint) async {
    final token = await storage.read(key: 'authToken');
    return http.get(
      Uri.parse('$baseUrl$endPoint'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  //post
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
     try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  Future<http.Response> postWithToken(
    String endPoint,
    Map<String, dynamic> body,
  ) async {
    final token = await storage.read(key: 'authToken');

    print("TOKEN SENT: $token");

    if (token == null) {
      throw Exception("Token tidak ditemukan. User belum login.");
    }

    final url = Uri.parse('$baseUrl$endPoint');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      return response;
    } catch (e) {
      throw Exception('Failed to post data with token: $e');
    }
  }

  //put
  Future<http.Response> putWithToken(
    String endPoint,
    Map<String, dynamic> body,
  ) async {
    final token = await storage.read(key: 'authToken');
    final url = Uri.parse('$baseUrl$endPoint');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to put data: $e');
    }
  }

  //delete
  Future deleteWithToken(String url) async {
    final token = await storage.read(key: 'authToken');
    final response = await http.delete(
      Uri.parse(baseUrl + url),
      headers: {
        "Content-Type": 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }
}
