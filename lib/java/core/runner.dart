import 'dart:convert';
import 'dart:io';

import 'package:ntlauncher/assetpath.dart';
import 'package:ntlauncher/java/core/args.dart';
import 'package:ntlauncher/java/core/log.dart';
import 'package:ntlauncher/java/manager.dart';
import 'package:ntlauncher/logger.dart';

typedef LogCallback = void Function(CoreMsg message);

class CoreRunner {
  static get _javaPath => JavaManager.javaPath;

  static String? _corePath;

  static Future<void> _generateCorePath() async {
    if (_corePath != null) {
      return;
    }
    var p = await AssetPath.getPath("assets/artifacts/ntlcore.jar");
    _corePath = p;
  }

  static Future<Process> _run(CoreArgs args, LogCallback? logCallback) async {
    await _generateCorePath();
    Log.debug.log("Running core with args: ${args.toJson()}");
    Log.debug.log("Core path: $_corePath");
    var process = await Process.start(_javaPath, [
      "-jar",
      "-Xmx256M",
      _corePath!,
      args.toJson(),
    ]);

    process.stdout.transform(utf8.decoder).listen(_handleOutput(logCallback));

    process.stderr.transform(utf8.decoder).listen(_handleOutput(logCallback));

    return process;
  }

  static Future<int> execute(
    CoreArgs args,
    LogCallback? logCallback,
  ) async {
    var process = await _run(args, logCallback);
    return await process.exitCode;
  }

  static Future<Process> start(
    CoreArgs args,
    LogCallback? logCallback,
  ) async {
    var process = await _run(args, logCallback);
    return process;
  }

  static Function(String) _handleOutput(LogCallback? logCallback) => (msg) {
        // Log.debug.log("Core: ${msg.trimRight()}");
        if (logCallback == null) {
          return;
        }
        var m = CoreMsg.fromRaw(msg.trimRight());
        logCallback(m);
      };
}
