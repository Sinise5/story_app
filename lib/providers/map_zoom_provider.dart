import 'package:flutter/material.dart';

class MapZoomProvider extends ChangeNotifier {
  double _currentZoom = 13.0; // Default zoom level

  double get currentZoom => _currentZoom;

  double? latitude;
  double? longitude;

  double? get haslatitude => latitude;

  double? get haslongitude => longitude;

  void setLocation(double lat, double lon) {
    latitude = lat;
    longitude = lon;

    notifyListeners(); // Memicu UI untuk diperbarui
  }

  void setZoom(double zoom) {
    _currentZoom = zoom;
    notifyListeners();
  }

  void zoomIn() {
    _currentZoom += 1;
    notifyListeners();
  }

  void zoomOut() {
    _currentZoom -= 1;
    notifyListeners();
  }
}
