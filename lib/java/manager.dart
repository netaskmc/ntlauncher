import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
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
}

class JavaCheck {
  static String? classpath;

  static Future<void> generateClasspath() async {
    // get temp dir
    Directory tempDir = await Directory.systemTemp.createTemp();
    // load JavaCheck.class from assets
    ByteData data = await rootBundle.load("assets/javacheck/JavaCheck.class");
    // write to temp dir
    await File(path.join(tempDir.path, "JavaCheck.class"))
        .writeAsBytes(data.buffer.asUint8List());
  }
}

Future<JavaInstance?> javaInstanceFromPath(String path) async {
  if (JavaCheck.classpath == null) {
    await JavaCheck.generateClasspath();
  }
  if (!(await File(path).exists())) {
    return null;
  }
  // run java -cp <classpath> JavaCheck
  ProcessResult result =
      await Process.run(path, ["-cp", JavaCheck.classpath!, "JavaCheck"]);
  if (result.exitCode != 0) {
    return null;
  }
  // example output:
  // os.arch=amd64
  // java.version=17.0.3
  // java.vendor=Oracle Corporation

  List<String> lines = (result.stdout as String).split("\n");
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

class JavaManager {}
