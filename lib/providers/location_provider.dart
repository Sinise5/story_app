import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationProvider with ChangeNotifier {
  LatLng _currentLocation = LatLng(0, 0);
  double _currentZoom = 15.0;
  List<dynamic> _searchResults = [];
  List<LatLng> _markers = [];

  LatLng get currentLocation => _currentLocation;
  double get currentZoom => _currentZoom;
  List<dynamic> get searchResults => _searchResults;
  List<LatLng> get markers => _markers;

  Future<void> getCurrentLocation2() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permissions are denied.");
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();  // Notifikasi perubahan ke UI
    } catch (e) {
      throw Exception("Failed to get location: $e");
    }
  }

  void updateLocation(LatLng newLocation) {
    _currentLocation = newLocation;
    notifyListeners();  // Notifikasi perubahan lokasi ke UI
  }

  Future<void> getCurrentLocation() async {
    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers = [_currentLocation];
      notifyListeners();
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  void setZoom(double zoom) {
    _currentZoom = zoom;
    notifyListeners();
  }

  Future<void> searchAddress(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}',
        ),
      );

      if (response.statusCode == 200) {
        _searchResults = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error during search: $e");
    }
  }

  void selectAddress(double lat, double lon) {
    _currentLocation = LatLng(lat, lon);
    _markers = [_currentLocation];
    _searchResults = [];
    notifyListeners();
  }

  void updateMarkerPosition(LatLng newPosition) {
    _currentLocation = newPosition;
    _markers = [newPosition];
    notifyListeners();
  }
}
