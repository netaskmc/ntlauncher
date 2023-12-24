import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;

class AssetPath {
  static String get _assetSystemPath => path.join(
      path.dirname(Platform.resolvedExecutable), 'data', 'flutter_assets');
  /*
  * Checks if asset is available as a file and if not, moves it into a temporary directory
  */
  static Future<String> getPath(String asset) async {
    var systemPath = await _systemPath(asset);
    if (systemPath != null) {
      return systemPath;
    }
    return await _tempPath(asset);
  }

  static Future<String?> _systemPath(String asset) async {
    // check if asset is available as a file
    var assetPath = path.join(_assetSystemPath, asset);
    var assetFile = File(assetPath);
    if (await assetFile.exists()) {
      return assetPath;
    }
    return null;
  }

  static Future<String> _tempPath(String asset) async {
    // get temp dir
    var tempDir = await Directory.systemTemp.createTemp();
    var temp = tempDir.path;
    // load asset from assets
    var data = await rootBundle.load(asset);
    // write to temp dir
    var fileName = path.basename(asset);
    var newPath = path.join(temp, fileName);
    await File(path.join(temp, newPath))
        .writeAsBytes(data.buffer.asUint8List());
    return newPath;
  }
}
