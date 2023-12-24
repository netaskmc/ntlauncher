import 'dart:io';
import 'package:path/path.dart' as ppath;

class JavaDetector {
  static final List<String> windowsPaths = [
    "C:\\Program Files\\Java\\*",
    "C:\\Program Files\\AdoptOpenJDK\\*",
    "C:\\Program Files\\Zulu\\*",
    "C:\\Program Files (x86)\\Java\\*",
  ];

  static Future<List<String>> winFindBinaries() async {
    var paths = await Future.wait(windowsPaths.map((e) => matchPaths(e)));
    return paths
        .expand((e) => e)
        .map((e) => ppath.join(e, "bin/java.exe"))
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
    } else {
      return [];
    }
  }
}
