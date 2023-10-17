import 'dart:io';

import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/modpacks/manager.dart';
import 'package:path/path.dart' as path;

enum ModpackInstallStatus {
  unknown,
  notInstalled,
  installed,
  onlyLocal,
  updateAvailable,
  updating,
}

class ModpackMeta {
  String name;
  String author;
  String id;
  String? icon;
  String packVersion;
  String mcVersion;
  String forgeVersion;
  String pwVersion;
  int modCount;

  ModpackMeta({
    required this.name,
    required this.author,
    required this.id,
    this.icon,
    required this.packVersion,
    required this.mcVersion,
    required this.forgeVersion,
    required this.pwVersion,
    required this.modCount,
  });

  factory ModpackMeta.fromJson(Map<String, dynamic> json) {
    return ModpackMeta(
      name: json['name'],
      author: json['author'],
      id: json['id'],
      icon: json['icon'],
      packVersion: json['versions']['pack'],
      mcVersion: json['versions']['mc'],
      forgeVersion: json['versions']['forge'],
      pwVersion: json['versions']['pw'],
      modCount: json['modCount'],
    );
  }
}

class Modpack {
  ModpackMeta meta;
  late String id;
  ModpackInstallStatus status = ModpackInstallStatus.unknown;

  Modpack({required this.meta}) {
    id = meta.id;
  }

  Future<void> checkStatus() async {
    Log.debug.log("Checking status of modpack $id...");
    if (await Directory(path.join(ModpackManager.basePath, id)).exists()) {
      status = ModpackInstallStatus.installed;
      Log.debug.log("Modpack $id is installed.");
    } else {
      status = ModpackInstallStatus.notInstalled;
      Log.debug.log("Modpack $id is not installed.");
    }
  }
}
