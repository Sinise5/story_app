import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://story-api.dicoding.dev/v1';

  static Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['loginResult']['token'];
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<List<dynamic>> fetchStories(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stories'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['listStory']; // Mengembalikan list cerita
    } else {
      throw Exception('Failed to load stories');
    }
  }

  static Future<void> addStory(File image, String description, String token,
      double lat, double lon) async {
    final formData = FormData.fromMap({
      'description': description,
      'photo': await MultipartFile.fromFile(image.path),
      'lat': lat,
      'lon': lon,
    });

    final dio = Dio();
    //dio.options.headers['Authorization'] = 'Bearer $token';
    dio.options.headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    };
    try {
      final response = await dio.post("$baseUrl/stories", data: formData);

      if (response.statusCode != 200) {
        throw Exception('Failed to upload story');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Tangani error 401
        debugPrint(
            "Error: Unauthorized (401). Token mungkin salah atau kedaluwarsa.");
      } else {
        debugPrint("Error uploading story: ${e.message}");
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
    }
  }
}
