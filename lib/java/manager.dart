import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:ntlauncher/assetpath.dart';
import 'package:ntlauncher/default_settings.dart';
import 'package:ntlauncher/java/detect.dart';
import 'package:ntlauncher/providers/settings.dart';
import 'package:path/path.dart' as path;

class JavaInstance {
  final String path;
  final String version;
  final String vendor;
  final String arch;

  const JavaInstance({
    required this.path,
    required this.version,
    required this.arch,
    required this.vendor,
  });

  static Future<JavaInstance?> fromPath(String path) async {
    if (JavaCheck.classpath == null) {
      await JavaCheck.generateClasspath();
    }
    if (!(await File(path).exists())) {
      return null;
    }
    // run java -cp <classpath> JavaCheck
    ProcessResult result =
        await Process.run(path, ["-cp", JavaCheck.classpath!, "JavaCheck"]);
    print(result.stderr);
    if (result.exitCode != 0) {
      return null;
    }
    // example output:
    // os.arch=amd64
    // java.version=17.0.3
    // java.vendor=Oracle Corporation

    List<String> lines =
        (result.stdout as String).split("\n").map((e) => e.trim()).toList();
    String? arch;
    String? version;
    String? vendor;

    for (String line in lines) {
      List<String> parts = line.split("=");
      if (parts.length != 2) {
        continue;
      }
      String value = parts[1];

      switch (parts[0]) {
        case "os.arch":
          arch = value;
          break;
        case "java.version":
          version = value;
          break;
        case "java.vendor":
          vendor = value;
          break;
      }
    }

    if (arch == null || version == null || vendor == null) {
      return null;
    }

    return JavaInstance(
      path: path,
      arch: arch,
      version: version,
      vendor: vendor,
    );
  }
}

class JavaCheck {
  static String? classpath;

  static Future<void> generateClasspath() async {
    if (classpath != null) {
      return;
    }
    var p = await AssetPath.getPath("assets/artifacts/JavaCheck.class");
    classpath = path.dirname(p);
  }
}

class JavaManager {
  static String get javaPath =>
      Settings.getSetting("java.path", DefaultSettings.javaPath);
  static set javaPath(String value) => Settings.setSetting("java.path", value);

  static Future<List<JavaInstance>> findInstances() async {
    var binaries = await JavaDetector.findBinaries();
    var instances =
        await Future.wait(binaries.map((e) => JavaInstance.fromPath(e)));

    return instances.where((e) => e != null).map((e) => e!).toList();
  }
}
