import 'dart:io';

import 'package:ntlauncher/default_settings.dart';
import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/modpacks/compatibility.dart';
import 'package:ntlauncher/modpacks/installation.dart';
import 'package:ntlauncher/modpacks/manager.dart';
import 'package:ntlauncher/providers/settings.dart';
import 'package:ntlauncher/ui/settings_pages.dart';
import 'package:path/path.dart' as ppath;

enum ModpackInstallStatus {
  unknown,
  notInstalled,
  installed,
  onlyLocal,
  updateAvailable,
  updating,
  incompatible,
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

  bool isRemote;

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
    this.isRemote = true,
  });

  factory ModpackMeta.fromJson(Map<String, dynamic> json,
      {bool isRemote = true}) {
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
      isRemote: isRemote,
    );
  }
}

class Modpack {
  ModpackMeta meta;
  late String id;
  ModpackInstallStatus status = ModpackInstallStatus.unknown;
  Installation? installation;

  ModpackManager manager;

  Modpack({required this.meta, required this.manager}) {
    id = meta.id;
    if (!Compatibility.isCompatible(meta)) {
      status = ModpackInstallStatus.incompatible;
      Log.debug.log("Modpack $id is incompatible.");
    }
  }

  Future<void> checkStatus() async {
    if (status == ModpackInstallStatus.incompatible) return;
    Log.debug.log("Checking status of modpack $id...");
    if (await Directory(path).exists() &&
        await File(ppath.join(path, "ntmeta.json")).exists()) {
      status = ModpackInstallStatus.onlyLocal;
      Log.debug.log("Modpack $id is installed.");
    } else {
      status = ModpackInstallStatus.notInstalled;
      Log.debug.log("Modpack $id is not installed.");
    }
  }

  Future<void> install() async {
    installation = Installation(id: id, manager: manager);
    status = ModpackInstallStatus.updating;
    var success = await installation!.initInstall();
    if (!success) {
      Log.error.log("Failed to install modpack $id.");
      installation = null;
      status = ModpackInstallStatus.notInstalled;
      return;
    }
    status = ModpackInstallStatus.installed;
    Log.info.log("Successfully installed modpack $id.");
    installation = null;
  }

  Future<void> uninstall() async {
    Log.info.log("Uninstalling modpack $id...");
    if (status == ModpackInstallStatus.notInstalled) {
      Log.error.log("Failed to uninstall modpack $id: not installed.");
      return;
    }
    // delete directory
    var path = ppath.join(ModpackManager.basePath, id);
    try {
      await Directory(path).delete(recursive: true);
    } catch (e) {
      Log.error.log("Failed to uninstall modpack $id: $e");
      return;
    }
    status = ModpackInstallStatus.notInstalled;
    Log.info.log("Successfully uninstalled modpack $id.");
  }

  Future<void> update() async {
    Log.info.log("Updating modpack $id...");

    ModpackMeta? remoteMeta;
    try {
      remoteMeta =
          manager.remote.firstWhere((element) => element.id == id).meta;
    } catch (e) {
      Log.error.log("Tried to update modpack $id; however, its new version "
          "was not found.");
      return;
    }

    installation = Installation(id: id, manager: manager);
    status = ModpackInstallStatus.updating;

    var success = await installation!.initUpdatePack(remoteMeta.packVersion);
    if (!success) {
      Log.error.log("Failed to update modpack $id.");
      installation = null;
      status = ModpackInstallStatus.updateAvailable;
      return;
    }
    status = ModpackInstallStatus.installed;
    installation = null;
    Log.info.log("Successfully updated modpack $id.");
  }

  String get path => ppath.join(ModpackManager.basePath, id);

  String get coreVersion {
    var f = meta.forgeVersion;
    var m = meta.mcVersion;
    return "$m-forge-$f";
  }

  (int, int) get memoryLimits {
    var pack = Settings.getSetting(
      "modpacks.$id.jvm_ram",
      Settings.getSetting(
        "general.jvm_ram",
        DefaultSettings.memory,
      ),
    );

    return (pack.first.toInt(), pack.second.toInt());
  }
}
