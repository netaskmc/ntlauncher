import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ntlauncher/default_settings.dart';
import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/modpacks/modpack.dart';
import 'package:http/http.dart' as http;
import 'package:ntlauncher/providers/settings.dart';
import 'package:ntlauncher/staticcfg.dart';
import 'package:path/path.dart' as path;

class ModpackManager with ChangeNotifier {
  static String basePath =
      path.join(path.dirname(Platform.resolvedExecutable), "modpacks");

  List<Modpack> _remote = [];
  List<Modpack> get remote => _remote;

  List<Modpack> _local = [];
  List<Modpack> get local => _local;

  List<Modpack> get allPacks {
    // remove duplicates by id, preferring local over remote
    var packs = [...local, ...remote];
    var ids = <String>{};
    var result = <Modpack>[];
    for (var pack in packs) {
      if (ids.contains(pack.id)) continue;
      ids.add(pack.id);
      result.add(pack);
    }
    return result;
  }

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

    loadLocal().then((_) => fetchRemote()).then((_) => checkStatus());
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

  Future<void> loadLocal() async {
    Log.info.log("Loading local modpacks...");
    var dir = Directory(basePath);
    if (!(await dir.exists())) {
      return;
    }
    var contents = await dir.list().toList();
    for (var item in contents) {
      if (item is! Directory) continue;
      var metaFile = File(path.join(item.path, "ntmeta.json"));
      if (!(await metaFile.exists())) continue;
      var meta = ModpackMeta.fromJson(jsonDecode(await metaFile.readAsString()),
          isRemote: false);
      _local.add(Modpack(meta: meta, manager: this));
    }
  }

  Future<void> checkStatus() async {
    Log.debug.log("Checking modpack statuses...");
    await Future.wait(_local.map((e) async {
      try {
        _remote.firstWhere((element) => element.id == e.id);
        await e.checkStatus();
      } catch (err) {
        e.status = ModpackInstallStatus.onlyLocal;
      }
    }));
    await Future.wait(_remote.map((e) async {
      if (e.status == ModpackInstallStatus.incompatible) return;
      try {
        var same = _local.firstWhere((element) => element.id == e.id);
        if (e.meta.packVersion != same.meta.packVersion) {
          same.status = ModpackInstallStatus.updateAvailable;
          if (Settings.getSetting(
              "general.autoupdate", DefaultSettings.autoUpdate)) {
            same.update();
          }
        } else {
          same.status = ModpackInstallStatus.installed;
        }
      } catch (err) {
        Log.debug.log("Caught error while checking status of $e: $err");
        e.status = ModpackInstallStatus.notInstalled;
      }
    }));
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
      return allPacks.firstWhere((e) => e.id == id);
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
    bool complete = false;
    mp.install().then((_) => complete = true);
    while (true) {
      if (complete) break;
      await Future.delayed(const Duration(milliseconds: 250));
      notifyListeners();
    }
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
    bool complete = false;
    mp.update().then((_) => complete = true);
    while (true) {
      if (complete) break;
      await Future.delayed(const Duration(milliseconds: 250));
      notifyListeners();
    }
    notifyListeners();
  }
}
