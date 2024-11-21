import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:story_app/models/story.dart';

import '../services/api_service.dart';

class StoryProvider with ChangeNotifier {
  List<Story> _stories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Story> get stories => _stories;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int _page = 1;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  bool _hasCameraPermission = false;
  bool _hasStoragePermission = false;
  bool _haslocationPermission = false;
  bool _hasphotosPermission = false;
  bool isPermissionRequestInProgress = false;

  bool get hasCameraPermission => _hasCameraPermission;

  bool get hasStoragePermission => _hasStoragePermission;

  bool get hasLocationPermission => _haslocationPermission;

  bool get hasphotosPermission => _hasphotosPermission;

  Future<void> fetchStories(
      {bool refresh = false, required String token}) async {
    if (refresh) {
      _stories = [];
      _page = 1;
      _hasMore = true;
      notifyListeners();
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    final url =
        'https://story-api.dicoding.dev/v1/stories?page=$_page&size=10&location=0';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> storiesData = data['listStory'];

        if (storiesData.isEmpty) {
          _hasMore = false;
        } else {
          _stories.addAll(
              storiesData.map((story) => Story.fromJson(story)).toList());
          _page++;
        }
      } else {
        throw Exception('Failed to load stories');
      }
    } catch (error) {
      debugPrint('Error fetching stories: $error');
      throw Exception('Failed to load stories');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Story? getStoryById(String id) {
    return stories.firstWhereOrNull((story) => story.id == id);
  }

  Future<bool> addStory(File image, String description, String token,
      double? lat, double? lon) async {
    try {
      await ApiService.addStory(
          image, description, token, lat ?? 0.0, lon ?? 0.0);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error uploading story: $e');
      return false;
    }
  }

  Future<void> requestPermissions() async {
    if (isPermissionRequestInProgress) {
      return;
    }

    isPermissionRequestInProgress = true;
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.photosAddOnly.request();
    final locationStatus = await Permission.location.request();
    final photosStatus = await Permission.photos.request();

    _hasCameraPermission = cameraStatus.isGranted;
    _hasStoragePermission = storageStatus.isGranted;
    _haslocationPermission = locationStatus.isGranted;
    _hasphotosPermission = photosStatus.isGranted;

    isPermissionRequestInProgress = false;
    notifyListeners();
  }

  bool get hasAllPermissions =>
      _hasCameraPermission &&
      _hasStoragePermission &&
      _haslocationPermission &&
      _hasphotosPermission;
}
