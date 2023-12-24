import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/modpacks/modpack.dart';

class Compatibility {
  static bool isCompatible(ModpackMeta meta) {
    if (versionIsLargerOrEqual(meta.mcVersion, "1.16")) {
      return true;
    } else {
      return false;
    }
  }

  static bool versionIsLargerOrEqual(String version1, String version2) {
    var v1 = version1.split(".");
    var v2 = version2.split(".");

    if (v1.length > v2.length) {
      var zeros = v1.length - v2.length;
      for (var i = 0; i < zeros; i++) {
        v2.add("0");
      }
    } else if (v2.length > v1.length) {
      var zeros = v2.length - v1.length;
      for (var i = 0; i < zeros; i++) {
        v1.add("0");
      }
    }

    for (var i = 0; i < v1.length; i++) {
      var n1 = int.parse(v1[i]);
      var n2 = int.parse(v2[i]);
      if (n1 > n2) {
        Log.debug.log("$version1 is larger than $version2, $n1 > $n2");
        return true;
      } else if (n1 < n2) {
        return false;
      }
    }
    return true;
  }
}
