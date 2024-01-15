import 'dart:async';
import 'dart:convert';

import 'package:ntlauncher/java/core/args.dart';
import 'package:ntlauncher/java/core/log.dart';
import 'package:ntlauncher/java/core/runner.dart';
import 'package:ntlauncher/java/manager.dart';
import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/modpacks/manager.dart';
import 'package:ntlauncher/modpacks/modpack.dart';
import 'package:ntlauncher/staticcfg.dart';
import 'package:path/path.dart' as path;
// import 'package:http/http.dart' as http;
import 'dart:io';

const pwBootstrapUrl =
    "https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar";

enum InstallationStage {
  none,
  pack,
  // modLoader,
  game,
  done,
}

Future<bool> downloadFile(String url, String path) async {
  Log.info.log("Downloading file at URL $url to $path");
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      return false;
    }
    final file = File(path);
    await file.create(recursive: true);
    await response.pipe(file.openWrite());
    client.close();
  } catch (e) {
    Log.error.log("Failed to download file at URL $url to $path - $e");
    return false;
  }
  Log.info.log("Successfully downloaded file at URL $url to $path");
  return true;
}

class InstallationProgressDistibution {
  double pack;
  double modLoader;
  double game;

  InstallationProgressDistibution({
    this.pack = 1,
    this.modLoader = 1,
    this.game = 1,
  }) {
    if (pack + modLoader + game != 1) {
      var f = pack + modLoader + game;

      pack = pack / f;
      modLoader = modLoader / f;
      game = game / f;
    }
  }

  static final defaultDist = InstallationProgressDistibution(
    pack: 0.4,
    modLoader: 0,
    game: 0.6,
  );
}

class Installation {
  String id;
  Modpack get modpack => manager.modpackById(id)!;
  String get packPath => modpack.path;

  ModpackManager manager;

  double packProgress = 0;
  double modLoaderProgress = 0;
  double gameProgress = 0;
  String progressDetails = "Initializing...";

  InstallationStage stage = InstallationStage.none;

  JavaInstance? javaInstance;

  Installation({required this.id, required this.manager}) {
    if (manager.modpackById(id) == null) {
      throw Exception("Modpack not found.");
    }
  }

  InstallationProgressDistibution progDist =
      InstallationProgressDistibution.defaultDist;

  double get progress {
    return (packProgress * progDist.pack +
        modLoaderProgress * progDist.modLoader +
        gameProgress * progDist.game);
  }

  Future<bool> initInstall() async {
    var res = await install();
    if (!res) {
      await selfPurge();
    }
    return res;
  }

  Future<bool> install() async {
    if (stage != InstallationStage.none) {
      return false;
    }
    Log.info.log("Initializing installation of modpack $id...");
    javaInstance = await JavaInstance.fromPath(JavaManager.javaPath);
    if (javaInstance == null) {
      Log.error.log("Failed to install modpack $id: Java not found.");
      return false;
    }
    stage = InstallationStage.game;
    var game = await installGame();
    if (!game) return false;
    stage = InstallationStage.pack;
    var pw = await installPackwizBootstrap();
    if (!pw) return false;
    var pack = await installPack();
    if (!pack) return false;
    Log.info.log("Successfully finished installation of modpack $id.");
    progressDetails = "Finishing up...";
    var meta = await writeMeta();
    if (!meta) return false;
    stage = InstallationStage.done;
    return true;
  }

  Future<bool> initUpdatePack(String newVersion) async {
    progDist = InstallationProgressDistibution(pack: 1, modLoader: 0, game: 0);
    var res = await updatePack(newVersion);
    if (!res) {
      // await selfPurge();
    }
    stage = InstallationStage.done;
    progDist = InstallationProgressDistibution.defaultDist;
    return res;
  }

  Future<bool> updatePack(String newVersion) async {
    if (stage != InstallationStage.none) {
      return false;
    }
    javaInstance = await JavaInstance.fromPath(JavaManager.javaPath);
    if (javaInstance == null) {
      Log.error.log("Failed to update modpack $id: Java not found.");
      return false;
    }
    stage = InstallationStage.pack;
    var pack = await installPack();
    if (!pack) return false;
    Log.info.log("Successfully finished updating modpack $id.");
    progressDetails = "Finishing up...";
    modpack.meta.packVersion = newVersion;
    var meta = await writeMeta();
    if (!meta) return false;
    return true;
  }

  Future<bool> writeMeta() async {
    dynamic meta = {
      "id": id,
      "name": modpack.meta.name,
      "author": modpack.meta.author,
      "icon": modpack.meta.icon,
      "versions": {
        "pack": modpack.meta.packVersion,
        "mc": modpack.meta.mcVersion,
        "forge": modpack.meta.forgeVersion,
        "pw": modpack.meta.pwVersion,
      },
      "modCount": modpack.meta.modCount,
    };
    try {
      await File(path.join(packPath, "ntmeta.json"))
          .writeAsString(jsonEncode(meta));
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> installPackwizBootstrap() async {
    if (stage != InstallationStage.pack) {
      return false;
    }
    // download packwiz-installer-bootstrap.jar and save it to packPath
    progressDetails = "Downloading Packwiz Installer...";
    return await downloadFile(
        pwBootstrapUrl, path.join(packPath, "packwiz-installer-bootstrap.jar"));
  }

  Future<bool> installPack() async {
    if (stage != InstallationStage.pack) {
      return false;
    }
    // run packwiz-installer-bootstrap.jar
    // java -jar packwiz-installer-bootstrap.jar <url to packwiz index> -g
    // we need to stream the output of this command to track the progress
    // ignore everything except: (x/y) <step string>
    final pwIndex = "$remoteRoot$id/pack.toml";
    final args = [
      "-jar",
      path.join(packPath, "packwiz-installer-bootstrap.jar"),
      pwIndex,
      "-g"
    ];
    Log.info.log("Running packwiz-installer-bootstrap.jar with args $args");
    final process = await Process.start(JavaManager.javaPath, args,
        workingDirectory: packPath);
    final stdout = process.stdout;
    final stderr = process.stderr;
    try {
      stdout.transform(const Utf8Decoder()).listen((event) {
        var lines = event.split("\n");
        for (var line in lines) {
          if (line.isEmpty) continue;
          Log.info.log("packwiz-installer-bootstrap: $line");
          // (x/y) <step string>
          if (line.startsWith("(") && line.contains(")")) {
            var parts = line.split(")");
            var step = parts.sublist(1).join(")");
            var progress = parts[0].substring(1);
            var progressParts = progress.split("/");
            var current = int.parse(progressParts[0]);
            var total = int.parse(progressParts[1]);
            packProgress = current / total;
            progressDetails = step;
          } else {
            progressDetails = line;
          }
        }
      });
      stderr.transform(const Utf8Decoder()).listen((event) {
        Log.info.log("packwiz-installer-bootstrap: $event");
      });
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        Log.error.log(
            "packwiz-installer-bootstrap exited with non-zero exit code $exitCode");
        return false;
      }
    } catch (e) {
      Log.info.log("PW ERROR: $e");
    }

    return true;
  }

  Future<bool> selfPurge() async {
    try {
      await Directory(packPath).delete(recursive: true);
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> installGame() async {
    if (stage != InstallationStage.game) {
      return false;
    }

    Log.info.log("Installing game and modloader for modpack $id...");

    int code = await CoreRunner.execute(
      CoreInstallArgs(dir: packPath, version: modpack.coreVersion),
      (message) {
        if (message is CoreProgress) {
          if (message.asPair.$2 != 0) {
            gameProgress = message.asFraction;
          }
          progressDetails = message.toString();
        } else if (message is CoreError) {
          Log.error.log(
              "(ntlcore) Error trying to install game/modloader for modpack $id"
              ": ${message.message}");
        } else if (message is CoreLog) {
          Log.info.log("ntlcore: ${message.message}");
          progressDetails = message.message;
        } else {
          Log.debug.log("ntlcore: ${message.message}");
        }
      },
    );
    modLoaderProgress = 1;

    return code == 0;
  }
}
