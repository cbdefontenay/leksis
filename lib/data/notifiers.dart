import 'package:flutter/material.dart';
import 'package:leksis/models/word_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier<int>(0);
ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.system,
);
ValueNotifier<String> themeColorNotifier = ValueNotifier<String>('default');

Future<void> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
  themeModeNotifier.value = ThemeMode.values[themeIndex];
  themeColorNotifier.value = prefs.getString('themeColor') ?? 'default';
}

Future<void> saveThemeMode(ThemeMode themeMode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('themeMode', themeMode.index);
}

Future<void> saveThemeColor(String color) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('themeColor', color);
  themeColorNotifier.value = color;
}

final ValueNotifier<List<Word>> learnedWordsNotifier = ValueNotifier([]);
final ValueNotifier<List<Word>> notLearnedWordsNotifier = ValueNotifier([]);
