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
    fetchRemote()
        .then((_) => Future.wait(_remote.map((e) => e.checkStatus())))
        .then((_) => notifyListeners());
  }

  Future<void> fetchRemote() async {
    Log.info.log("Fetching remote modpacks...");
    try {
      var response = await http.get(Uri.parse("${remoteRoot}index.json"));
      List<dynamic> json = jsonDecode(response.body);
      remote = json.map((e) => Modpack(meta: ModpackMeta.fromJson(e))).toList();
    } catch (e) {
      Log.error.log("Failed to fetch remote modpacks: $e");
    }
    Log.info.log("Fetched ${remote.length} remote modpacks.");
    notifyListeners();
  }
}
