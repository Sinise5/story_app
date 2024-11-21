import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:story_app/services/preferences_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;

  bool _isPasswordVisibleRegis = false;

  bool get isPasswordVisibleRegis => _isPasswordVisibleRegis;

  bool _hasCheckedLogin = false;

  bool get hasCheckedLogin => _hasCheckedLogin;

  String _errorLogin = '';

  String get errorLogin => _errorLogin;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    const url = 'https://story-api.dicoding.dev/v1/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      _isLoading = false;
      notifyListeners();
      debugPrint(json.decode(response.body)['message'].toString());
      _errorLogin = (json.decode(response.body)['message'].toString());
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (!responseData['error']) {
          final token = responseData['loginResult']['token'];
          debugPrint('token $token');
          await _saveToken(token);
          _isLoggedIn = true;
          notifyListeners();
        } else {
          _isLoggedIn = false;
          throw 'Login failed: ${responseData['message']}';
        }
      } else {
        _isLoggedIn = false;
        throw 'Failed to connect to the server';
      }
    } catch (error) {
      _isLoading = false;
      _isLoggedIn = false;
      notifyListeners();
      throw 'Login error: $error'; // Menangani error koneksi atau kesalahan lain
    }
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void togglePasswordVisibilityRegis() {
    _isPasswordVisibleRegis = !_isPasswordVisibleRegis;
    notifyListeners();
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://story-api.dicoding.dev/v1/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['message']; // Sukses
      } else {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? 'Registration failed';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> checkLoginStatus() async {
    if (_hasCheckedLogin) return;

    _hasCheckedLogin = true;
    notifyListeners();

    final token = await PreferencesService.getToken();
    _isLoggedIn = token != null;

    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final preferencesService = PreferencesService();
    await preferencesService.saveToken(token);
    await preferencesService.isLoggedIn();
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final preferencesService = PreferencesService();
    await preferencesService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
