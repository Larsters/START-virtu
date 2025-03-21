import 'package:flutter/material.dart';

class DebugController extends ChangeNotifier {
  static final DebugController _instance = DebugController._internal();

  factory DebugController() {
    return _instance;
  }

  DebugController._internal();

  bool _forceHarvestTime = false;

  bool get forceHarvestTime => _forceHarvestTime;

  void toggleHarvestTime() {
    _forceHarvestTime = !_forceHarvestTime;
    notifyListeners();
  }
}
