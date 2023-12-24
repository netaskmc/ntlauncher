import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/ui/settings_pages.dart';
import 'package:path/path.dart' as path;

class TypedSetting<T> {
  final String id;
  final T value;

  TypedSetting(this.id, this.value);
}

class Settings {
  static final String _settingsPath = path.join(
      path.dirname(Platform.resolvedExecutable), "ntlaunchercfg.json");

  static Map<String, dynamic> _settings = {};

  static Future<Map<String, dynamic>> loadSettings() async {
    Log.debug.log("Loading settings from $_settingsPath");
    File file = File(_settingsPath);
    if (await file.exists()) {
      String contents = await file.readAsString();
      _settings = jsonDecode(contents);
      Log.debug.log("Loaded settings");
      print(_settings);
      return _settings;
    }
    Log.debug.log("No settings file found, skipping");
    return _settings;
  }

  static Timer? _saveSettingsTimer;

  static Future<void> saveSettings() async {
    // to not spam io operations, we need to debounce this.
    // we can't use a future because we need to cancel it when a new save is requested
    // so we use a timer

    // if there's a save already scheduled, cancel it
    if (_saveSettingsTimer != null) {
      _saveSettingsTimer!.cancel();
    }

    // schedule a new save
    _saveSettingsTimer = Timer(const Duration(seconds: 3), () async {
      _saveSettingsTimer = null;
      Log.debug.log("Saving settings to $_settingsPath");
      File file = File(_settingsPath);
      await file.writeAsString(jsonEncode(_settings));
      Log.debug.log("Saved settings");
    });
  }

  static T? getSettingOrNull<T>(String id, T defaultValue) {
    String tyId = typedId(id, defaultValue);

    if (_settings.containsKey(tyId)) {
      return fromTypedId(tyId).value;
    }

    return null;
  }

  static T getSetting<T>(String id, T defaultValue) {
    return getSettingOrNull(id, defaultValue) ?? defaultValue;
  }

  static void setSetting<T>(String id, T value) {
    String tyId = typedId(id, value);
    dynamic serializedValue = treatValue(value);
    if (serializedValue == _settings[tyId]) {
      return;
    }
    _settings[tyId] = serializedValue;
    Log.debug.log("Set setting $tyId to $serializedValue");
    saveSettings();
  }

  static String typedId(String id, dynamic defaultValue) {
    String type = defaultValue.runtimeType.toString();
    // remove type parameters
    type = type.replaceAll(RegExp(r"<.*>"), "");
    return "$id:$type";
  }

  static TypedSetting fromTypedId(String tyId) {
    List<String> parts = tyId.split(":");
    String id = parts[0];
    String type = parts[1];

    return switch (type) {
      "String" => TypedSetting(id, _settings[tyId] as String),
      "int" => TypedSetting(id, _settings[tyId] as int),
      "double" => TypedSetting(id, _settings[tyId] as double),
      "bool" => TypedSetting(id, _settings[tyId] as bool),
      "DoubleNum" => TypedSetting(
          id,
          DoubleNum.deserialize(
              [_settings[tyId][0].toDouble(), _settings[tyId][1].toDouble()])),
      _ => throw Exception("Unknown type $type"),
    };
  }

  static bool exists(String id, dynamic defaultValue) {
    return _settings.containsKey(typedId(id, defaultValue));
  }

  static dynamic treatValue(dynamic value) {
    if (value.runtimeType.toString().startsWith("DoubleNum")) {
      return (value as DoubleNum).serialize();
    }
    return value;
  }
}

class SettingsManager with ChangeNotifier {
  static Map<String, dynamic> get settings => Settings._settings;

  SettingsManager() {
    _loadSettings();
  }

  static void _loadSettings() async {
    await Settings.loadSettings();
  }

  static void saveSettings() async {
    await Settings.saveSettings();
  }

  dynamic getSettingQuietly(String id, dynamic defaultValue) {
    return Settings.getSetting(id, defaultValue);
  }

  T getSetting<T>(String id, T defaultValue) {
    return Settings.getSetting(id, defaultValue);
  }

  void _setSettingQuietly(String id, dynamic value) {
    Settings.setSetting(id, value);
  }

  void setSetting(String id, dynamic value) {
    _setSettingQuietly(id, value);
    notifyListeners();
  }
}
