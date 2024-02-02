import 'dart:io';

import 'package:ntlauncher/java/core/args.dart';
import 'package:ntlauncher/java/core/log.dart';
import 'package:ntlauncher/java/core/runner.dart';
import 'package:ntlauncher/launch/ali.dart';
import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/modpacks/modpack.dart';
import 'package:ntlauncher/providers/auth.dart';

class Launch {
  static final List<Function(bool running)> _listeners = [];

  static void addListener(Function(bool running) listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function(bool running) listener) {
    _listeners.remove(listener);
  }

  static Process? __process;

  static bool get isRunning => __process != null;

  static Process? get _process => __process;
  static set _process(Process? value) {
    __process = value;
    for (var listener in _listeners) {
      listener(isRunning);
    }
  }

  static Future<void> stop() async {
    if (_process == null) return;
    _process!.stdin.writeln("\u0004");
    await _process!.exitCode;
  }

  static Future<void> launch(Modpack modpack) async {
    var auth = AuthHolder.auth;
    if (auth == null) {
      Log.error.log("Can't launch - You are not logged in.");
      return;
    }
    var aliArgs = await AuthLibInjector.getLaunchArgs();
    if (aliArgs == null) {
      Log.error.log(
          "Can't launch - Failed to get authlib-injector args. Check your internet connection.");
      return;
    }
    _process = await CoreRunner.start(
      CoreLaunchArgs(
        dir: modpack.path,
        version: modpack.coreVersion,
        session: auth.toGameSession(),
        memoryLimits: modpack.memoryLimits,
        jvmArgs: [
          ...aliArgs,
        ],
        gameArgs: [
          "--versionType NeTaskLauncher",
        ],
      ),
      (message) {
        if (message is CoreGameLog) {
          Log.info.log(message.message);
        } else if (message is CoreError) {
          Log.error.log(message.message);
          // } else if (message is CoreLog) {
        } else {
          Log.debug.log(message.message);
        }
      },
    );
    _process!.exitCode.then((value) => _process = null);
  }
}
