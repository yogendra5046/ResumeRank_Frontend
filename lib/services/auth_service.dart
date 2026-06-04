import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          "https://resumerankappbackend-production.up.railway.app/v1",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static const String _tokenKey = "auth_token";
  static const String _userKey = "user_data";

  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await _dio.post(
        "/auth/register",
        data: {"email": email, "password": password, "full_name": name},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint("Registration error: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      debugPrint("Registration error: $e");
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final userData = response.data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(userData));
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("Login error: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }
}
