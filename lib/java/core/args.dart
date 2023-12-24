import 'dart:convert';

import 'package:ntlauncher/java/core/session.dart';

enum CoreAction {
  install,
  launch,
}

class CoreArgs {
  final String dir;
  final CoreAction action;

  get _action => action.name;

  const CoreArgs(this.dir, this.action);

  Map<String, dynamic> toMap() => {
        'dir': dir,
        'action': _action,
      };

  String toJson() => jsonEncode(toMap());
}

class CoreInstallArgs extends CoreArgs {
  final String version;

  const CoreInstallArgs({
    required String dir,
    required this.version,
  }) : super(dir, CoreAction.install);

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['installDetails'] = {
      'version': version,
    };
    return map;
  }
}

class CoreLaunchArgs extends CoreArgs {
  final String version;
  final (int, int) memoryLimits;
  final List<String>? jvmArgs;
  final List<String>? gameArgs;
  final GameSession session;

  const CoreLaunchArgs({
    required String dir,
    required this.version,
    this.memoryLimits = (2048, 4096),
    this.jvmArgs = const [],
    this.gameArgs = const [],
    required this.session,
  }) : super(dir, CoreAction.launch);

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['launchDetails'] = {
      'version': version,
      'minMemory': memoryLimits.$1,
      'maxMemory': memoryLimits.$2,
      'session': {
        'username': session.username,
        'uuid': session.uuid,
        'token': session.token,
      },
      'jvmArgs': jvmArgs,
      'gameArgs': gameArgs,
    };
    return map;
  }
}
