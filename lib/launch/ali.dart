import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/modpacks/installation.dart';
import 'package:ntlauncher/staticcfg.dart';
import 'package:ntlauncher/assetpath.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class AuthLibInjector {
  static String yggdrasilRoot = "${apiRoot}reimu";
  static String? aliPath;

  static Future<String?> getAliPath() async {
    if (aliPath != null) {
      return aliPath;
    }
    var dl = await _ALIdl.download();
    if (!dl) {
      return null;
    }
    aliPath = _ALIdl.aliPath;
    return aliPath;
  }

  static Future<List<String>?> getLaunchArgs() async {
    var args = <String>[];
    await getAliPath();
    if (aliPath == null) {
      return null;
    }
    args.add("-javaagent:$aliPath=$yggdrasilRoot");
    var prefetched = await prefetchYggdrasilMeta();
    if (prefetched == null) {
      Log.error.log("Auth server is unreachable; launching game without auth!");
      return [];
    }
    // args.add("-Dauthlibinjector.yggdrasil.prefetched=$prefetched");
    return args;
  }

  static Future<String?> prefetchYggdrasilMeta() async {
    // make request to yggdrasilRoot and base64 encode response
    Response res;
    try {
      res = await http.get(Uri.parse(yggdrasilRoot));
      if (res.statusCode != 200) {
        return null;
      }
    } catch (e) {
      return null;
    }
    var body = res.body;
    var encoded = base64Encode(body.codeUnits);
    return encoded;
  }
}

class _ALIdl {
  static String basePath = path.dirname(Platform.resolvedExecutable);
  static String aliPath = path.join(basePath, "authlib-injector.jar");

  static Future<bool> _downloadGithubRelease(
      String repo, String version, String assetFileName) async {
    var url =
        "https://github.com/$repo/releases/download/v$version/$assetFileName";
    // download file from url
    var success = await downloadFile(url, aliPath);
    if (!success) {
      return false;
    }
    return true;
  }

  static Future<bool> download() async {
    if (await isInstalled()) {
      return true;
    }
    var result = await _downloadGithubRelease(
      authlibInjectorRepo,
      authlibInjectorVersion,
      "authlib-injector-$authlibInjectorVersion.jar",
    );
    return result;
  }

  static Future<bool> isInstalled() async {
    var file = File(aliPath);
    return await file.exists();
  }
}
