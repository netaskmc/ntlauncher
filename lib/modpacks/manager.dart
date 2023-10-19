import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/modpacks/modpack.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

const String remoteRoot =
    "https://raw.githubusercontent.com/netaskmc/modpacks/main/";

class ModpackManager with ChangeNotifier {
  static String basePath =
      path.join(path.dirname(Platform.resolvedExecutable), "modpacks");

  List<Modpack> _remote = [];
  List<Modpack> get remote => _remote;

  List<Modpack> _local = [];
  List<Modpack> get local => _local;

  String? _selectedModpackId;

  set local(List<Modpack> value) {
    _local = value;
    notifyListeners();
  }

  set remote(List<Modpack> value) {
    _remote = value;
    notifyListeners();
  }

  ModpackManager() {
    Log.debug.log("ModpackManager base path: $basePath");

    fetchRemote().then((_) => checkStatus());
  }

  Future<void> fetchRemote() async {
    Log.info.log("Fetching remote modpacks...");
    try {
      var response = await http.get(Uri.parse("${remoteRoot}index.json"));
      List<dynamic> json = jsonDecode(response.body);
      remote = json
          .map((e) => Modpack(
                meta: ModpackMeta.fromJson(e),
                manager: this,
              ))
          .toList();
    } catch (e) {
      Log.error.log("Failed to fetch remote modpacks: $e");
    }
    Log.info.log("Fetched ${remote.length} remote modpacks.");
    notifyListeners();
  }

  Future<void> checkStatus() async {
    Log.debug.log("Checking modpack statuses...");
    await Future.wait(_remote.map((e) => e.checkStatus()));
    notifyListeners();
  }

  void selectModpack(String id) {
    _selectedModpackId = id;
    notifyListeners();
  }

  Modpack? get selectedModpack {
    if (_selectedModpackId == null) return null;
    return modpackById(_selectedModpackId!);
  }

  bool isSelected(Modpack mp) {
    return mp.id == _selectedModpackId;
  }

  Modpack? modpackById(String id) {
    try {
      return [...remote, ...local].firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> install(String modpackId) async {
    Modpack? mp = modpackById(modpackId);
    if (mp == null) {
      Log.error.log("Failed to install modpack $modpackId: not found.");
      return;
    }
    await mp.install();
    notifyListeners();
  }

  Future<void> uninstall(String modpackId) async {
    Modpack? mp = modpackById(modpackId);
    if (mp == null) {
      Log.error.log("Failed to uninstall modpack $modpackId: not found.");
      return;
    }
    await mp.uninstall();
    notifyListeners();
  }

  Future<void> update(String modpackId) async {
    Modpack? mp = modpackById(modpackId);
    if (mp == null) {
      Log.error.log("Failed to update modpack $modpackId: not found.");
      return;
    }
    await mp.update();
    notifyListeners();
  }
}
