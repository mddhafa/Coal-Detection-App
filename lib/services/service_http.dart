import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ServiceHttp {
  final String baseUrl = 'http://10.0.2.2:3000/api/';
  final Storage = FlutterSecureStorage();

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
    final token = await Storage.read(key: 'authToken');
    final url = Uri.parse('$baseUrl$endPoint');
    try {
      final response = await http.post(
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
      throw Exception('Failed to post data with token: $e');
    }
  }
}
