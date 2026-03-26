import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingThemeMode { light, dark, sepia }
enum ReadingAlignment { left, center }

class ReadingPreferencesController extends ChangeNotifier {
  double fontSize = 18;
  double lineSpacing = 1.5;
  String fontFamily = 'Roboto';
  ReadingThemeMode themeMode = ReadingThemeMode.light;
  ReadingAlignment alignment = ReadingAlignment.left;

  static const _keyFontSize = 'reading_font_size';
  static const _keyLineSpacing = 'reading_line_spacing';
  static const _keyFontFamily = 'reading_font_family';
  static const _keyThemeMode = 'reading_theme_mode';
  static const _keyAlignment = 'reading_alignment';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    fontSize = prefs.getDouble(_keyFontSize) ?? 18;
    lineSpacing = prefs.getDouble(_keyLineSpacing) ?? 1.5;
    fontFamily = prefs.getString(_keyFontFamily) ?? 'Roboto';

    themeMode = ReadingThemeMode.values[
    prefs.getInt(_keyThemeMode) ?? 0];

    alignment = ReadingAlignment.values[
    prefs.getInt(_keyAlignment) ?? 0];

    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    fontSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, value);
    notifyListeners();
  }

  Future<void> setLineSpacing(double value) async {
    lineSpacing = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLineSpacing, value);
    notifyListeners();
  }

  Future<void> setFontFamily(String value) async {
    fontFamily = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFontFamily, value);
    notifyListeners();
  }

  Future<void> setThemeMode(ReadingThemeMode value) async {
    themeMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, value.index);
    notifyListeners();
  }

  Future<void> setAlignment(ReadingAlignment value) async {
    alignment = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAlignment, value.index);
    notifyListeners();
  }
}

final readingPreferencesController =
ReadingPreferencesController();
