import 'package:flutter/material.dart';
import 'package:ntlauncher/logger.dart';

class TypedSetting<T> {
  final String id;
  final T value;

  TypedSetting(this.id, this.value);
}

class SettingsManager with ChangeNotifier {
  Map<String, dynamic> _settings = {};
  Map<String, dynamic> get settings => _settings;

  SettingsManager() {
    _loadSettings();
  }

  void _loadSettings() async {}

  void saveSettings() async {}

  dynamic getSettingQuietly(String id, dynamic defaultValue) {
    String tyId = typedId(id, defaultValue);

    if (_settings.containsKey(tyId)) {
      return fromTypedId(tyId).value;
    }

    return defaultValue;
  }

  dynamic getSetting(String id, dynamic defaultValue) {
    String tyId = typedId(id, defaultValue);

    if (_settings.containsKey(tyId)) {
      return fromTypedId(tyId).value;
    }

    _setSettingQuietly(id, defaultValue);
    return defaultValue;
  }

  void _setSettingQuietly(String id, dynamic value) {
    String tyId = typedId(id, value);
    _settings[tyId] = value;
    Log.debug.log("Set setting $tyId to $value");
    saveSettings();
  }

  void setSetting(String id, dynamic value) {
    _setSettingQuietly(id, value);
    notifyListeners();
  }

  String typedId(String id, dynamic defaultValue) {
    return "$id:${defaultValue.runtimeType.toString()}";
  }

  TypedSetting fromTypedId(String tyId) {
    List<String> parts = tyId.split(":");
    String id = parts[0];
    String type = parts[1];

    return switch (type) {
      "String" => TypedSetting(id, settings[tyId] as String),
      "int" => TypedSetting(id, settings[tyId] as int),
      "double" => TypedSetting(id, settings[tyId] as double),
      "bool" => TypedSetting(id, settings[tyId] as bool),
      _ => throw Exception("Unknown type $type"),
    };
  }
}
