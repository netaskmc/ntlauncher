import 'dart:convert';
import 'dart:io';

import 'package:launcher_core/helpers.dart';
import 'package:launcher_core/launcher.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

typedef ProgressCallback = void Function(
    {required String type,
    required int task,
    required int total,
    String? name});

class Handler {
  Launcher client;
  MinecraftVersion? version;

  Future<bool> checkJava() async {
    final version = await Process.run("java", ["-version"]);
    if (version.exitCode != 0) return false;
    client.log(
        "debug", 'Found java: ${version.stdout} ${version.stderr.toString()}');
    return true;
  }

  Future<void> download(String url, String directory, String name, bool retry,
      String type, ProgressCallback? callback) async {
    // create directory if it doesn't exist
    final dir = Directory(directory);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final file = File(p.join(directory, name));

    var bytes = <int>[];
    var totalBytes = 0;

    // we need to track the bytes received so we can display the download progress
    // make the request
    final request =
        await http.Client().send(http.Request('GET', Uri.parse(url)));
    totalBytes = request.contentLength ?? 0;

    final subscription = request.stream.listen((bytes) {
      bytes.addAll(bytes);
      client.log("debug", "Downloading... ${bytes.length}/$totalBytes bytes");
      if (callback != null) {
        callback(type: type, task: bytes.length, total: totalBytes, name: name);
      }
    });

    subscription.onError((e) async {
      // check if we have a 404 error
      if (e is http.ClientException) {
        if (e.message.contains("404")) {
          client.log("error", "Failed to download $url: 404 Not Found");
          return;
        }
      }
      client.log("error", "Failed to download $url: $e");
      if (retry) {
        client.log("info", "Retrying download...");
        await download(url, directory, name, false, type, callback);
        return;
      }
      throw Exception("Failed to download $url: $e");
    });

    subscription.onDone(() {
      client.log("debug", "Downloaded $url");
    });

    // await the request to finish
    await subscription.asFuture();

    // write the bytes to the file
    await file.writeAsBytes(bytes);
  }

  Future<bool> checkSum(String hash, String path) async {
    // read file to bytes
    final file = File(path);
    final bytes = await file.readAsBytes();

    // create hash
    final digest = sha1.convert(bytes);

    // compare hash
    return digest.toString() == hash;
  }

  Future<MinecraftVersion> getVersion() async {
    final versionJsonPath = client.options.overrides?.versionJson ??
        p.join(client.options.directory!,
            "${client.options.version.version}.json");

    // check if version json exists
    final versionJson = File(versionJsonPath);
    if (await versionJson.exists()) {
      version = MinecraftVersion.fromJson(
          jsonDecode(await versionJson.readAsString()));
      return version!;
    }

    final manifest = p.join(
        client.options.overrides!.url!.meta!, 'mc/game/version_manifest.json');
    final cache =
        '${client.options.cache ?? "${client.options.root}/cache"}/json';

    try {
      // download version manifest
      final request = await http.Client().get(Uri.parse(manifest));
      if (request.statusCode == 200) {
        // check if cache directory exists
        final cacheDir = Directory(cache);
        if (!cacheDir.existsSync()) {
          cacheDir.createSync(recursive: true);
          client.log("debug", "Cache directory created: $cache");
        }
        // write version manifest to cache
        final manifestFile = File("$cache/version_manifest.json");
        await manifestFile.writeAsString(request.body);
        client.log("debug", "Cached version_manifest.json");
      }
      throw Exception(
          "Failed to download version manifest: ${request.statusCode}");
    } catch (e) {
      // check if version manifest cache exists
      final manifestFile = File("$cache/version_manifest.json");
      if (!await manifestFile.exists()) {
        throw Exception("Failed to download, and there's no cache: $e");
      }
    }
    final manifestFile = File("$cache/version_manifest.json");
    final parsed = jsonDecode(await manifestFile.readAsString());

    try {
      for (final desired in parsed.versions as List<dynamic>) {
        if (desired.id != client.options.version.version) continue;
        final versionJson = await http.Client().get(Uri.parse(desired.url));

        await File(versionJsonPath).writeAsString(versionJson.body);
        client.log("debug", "Cached $versionJsonPath");
        version = MinecraftVersion.fromJson(jsonDecode(versionJson.body));
        return version!;
      }
    } catch (e) {
      final versionJson = File(versionJsonPath);
      if (!await versionJson.exists()) {
        throw Exception("Failed to download, and there's no cache: $e");
      }
      final cached = jsonDecode(await versionJson.readAsString());
      version = MinecraftVersion.fromJson(cached);
      return version!;
    }

    throw Exception("Failed to find version ${client.options.version.version}");
  }

  Future<void> getJar() async {
    await download(
        version!.downloads["client"]["url"],
        client.options.directory!,
        '${client.options.version.custom ?? client.options.version.version}.jar',
        true,
        'version-jar',
        null);
    File(p.join(client.options.directory!,
            '${client.options.version.version}.json'))
        .writeAsString(jsonEncode(version));
    client.log("debug", "Downloaded version jar and wrote version json");
  }

  Future<void> getAssets(ProgressCallback? progressCallback) async {
    final assetDirectory = p.normalize(client.options.overrides?.assetRoot ??
        p.join(client.options.root, "assets"));
    if (!await Directory(assetDirectory).exists()) {
      await Directory(assetDirectory).create(recursive: true);
    }
    final assetId =
        client.options.version.custom ?? client.options.version.version;
    if (!await File(p.join(assetDirectory, "indexes", '$assetId.json'))
        .exists()) {
      await download(
          version!.assetIndex["url"],
          p.join(assetDirectory, "indexes"),
          '$assetId.json',
          true,
          'asset-json',
          progressCallback);
      client.log("debug", "Downloaded asset index");
    }
    final index = jsonDecode(
        await File(p.join(assetDirectory, "indexes", '$assetId.json'))
            .readAsString());

    if (progressCallback != null) {
      progressCallback(type: 'assets', task: 0, total: index["objects"].length);
    }

    var counter = 0;
    await Future.wait(
        (index["objects"] as Map<String, dynamic>).keys.map((asset) async {
      final hash = index["objects"][asset]["hash"];
      final subhash = hash.substring(0, 2);
      final subAsset = p.join(assetDirectory, "objects", subhash);

      final file = File(p.join(subAsset, hash));
      if (!await file.exists() || !await checkSum(hash, file.path)) {
        await download(
            '${client.options.overrides!.url!.resource!}/$subhash/$hash',
            subAsset,
            hash,
            true,
            'assets',
            null);
      }
      counter++;
      if (progressCallback != null) {
        progressCallback(
            type: 'assets', task: counter, total: index["objects"].length);
      }
    }));

    if (isLegacy()) {
      if (await Directory(p.join(assetDirectory, "legacy")).exists()) {
        client.log("debug",
            'The \'legacy\' directory is no longer used as Minecraft looks for the resouces folder regardless of what is passed in the assetDirecotry launch option. I\'d recommend removing the directory (${p.join(assetDirectory, 'legacy')})');
      }
      final legacyDirectory = p.join(client.options.root, "resources");
    }
  }

  bool isLegacy() {
    return version?.assets == 'legacy' || version?.assets == 'pre-1.6';
  }

  Handler(this.client);
}
