import 'package:flutter/material.dart';

class LifecycleObserver extends WidgetsBindingObserver {
  final Future<bool> Function() onBackPressed;

  LifecycleObserver({required this.onBackPressed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      debugPrint('back');
    }
  }
}
