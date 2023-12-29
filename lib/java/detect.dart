import 'dart:io';
import 'package:ntlauncher/logger.dart';
import 'package:path/path.dart' as ppath;

class JavaDetector {
  static final List<String> winPaths = [
    "C:\\Program Files\\Java\\*",
    "C:\\Program Files\\AdoptOpenJDK\\*",
    "C:\\Program Files\\Zulu\\*",
    "C:\\Program Files\\Common Files\\Oracle\\Java\\*",
    "C:\\ProgramData\\Oracle\\Java\\*",
  ];

  static final List<String> macPaths = [
    "/Library/Java/JavaVirtualMachines/*",
    "/System/Library/Java/JavaVirtualMachines/*",
    "/opt/homebrew/opt/openjdk",
    "/usr/local/opt/openjdk",
  ];

  static final List<String> winPossibleBinaries = [
    "bin/java",
    "javapath/java",
  ];

  static final List<String> macPossibleBinaries = [
    "Contents/Home/bin/java",
    "bin/java",
  ];

  static Future<List<String>> winFindBinaries() async {
    var paths = await Future.wait(winPaths.map((e) => matchPaths(e)));
    return paths
        .expand((e) => e)
        .map((e) => winPossibleBinaries.map((b) => ppath.join(e, "$b.exe")))
        .expand((e) => e)
        .where((e) => File(e).existsSync())
        .toList();
  }

  static Future<List<String>> macFindBinaries() async {
    var paths = await Future.wait(macPaths.map((e) => matchPaths(e)));
    return paths
        .expand((e) => e)
        .map((e) => macPossibleBinaries.map((b) => ppath.join(e, b)))
        .expand((e) => e)
        .where((e) => File(e).existsSync())
        .toList();
  }

  static Future<List<String>> matchPaths(String path) async {
    var parts = path.split("*");
    var dirp = parts[0];
    var rest = parts.sublist(1).join("*");

    var dir = Directory(dirp);
    if (!(await dir.exists())) return [];
    // read dir
    var paths = await dir
        .list()
        .map((e) {
          // check if its a directory
          if (e is! Directory) return null;
          return e.path;
        })
        .where((e) => e != null)
        .map((e) => e!)
        .toList();

    // invoke for each path
    var result = await Future.wait(paths.map(
        (e) async => rest == "" ? [e] : await matchPaths(ppath.join(e, rest))));

    // flatten result
    return result.expand((e) => e).toList();
  }

  static Future<List<String>> findBinaries() async {
    if (Platform.isWindows) {
      return await winFindBinaries();
    } else if (Platform.isMacOS) {
      // return await macFindBinaries();
      Log.error.log(
          "MacOS is not supported yet; you can find java binaries manually");
      return [];
    } else {
      return [];
    }
  }
}
