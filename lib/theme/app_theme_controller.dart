import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppThemeController extends ChangeNotifier {
  AppTheme _current = AppTheme.deepOrange;
  AppTheme get current => _current;

  void setTheme(AppTheme t) {
    if (_current == t) return;
    _current = t;
    notifyListeners();
  }
}

// <<< instância global que o app inteiro pode usar
final appThemeController = AppThemeController();
