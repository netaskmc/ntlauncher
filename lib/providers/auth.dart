import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ntlauncher/java/core/session.dart';
import 'package:ntlauncher/staticcfg.dart';
import 'package:ntlauncher/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;

enum AuthType { offline, netask }

const authBaseURL = apiRoot;

class AuthDisplayDescriptor {
  AuthDisplayDescriptor({
    required this.type,
    required this.nickname,
    required this.headIconUrl,
  });

  AuthType type;
  String nickname;
  String headIconUrl;
}

class AuthAPI {
  static String? clientToken;
  static String? accessToken;

  static Future<dynamic> request(String method, dynamic body) async {
    http.Response response;
    try {
      response = await http.post(
        Uri.parse("${authBaseURL}reimu/ntl"),
        body: json.encode({
          "method": method,
          "payload": body,
        }),
        headers: {
          "Content-Type": "application/json",
        },
      );
    } catch (e) {
      Log.error.log("Failed to send request to auth - $e");
      return null;
    }
    if (response.statusCode != 200) {
      Log.error.log(
          "Failed to send request to auth - ${response.statusCode}: ${response.body}");
      return null;
    }
    var res = json.decode(response.body);
    if (res["error"] != null) {
      Log.error.log(
          "Failed to send request to auth - ${res["error"]}: ${res["errorMessage"]}");
      return null;
    }
    return res;
  }

  static Future<bool> initFlow() async {
    var pkg = await PackageInfo.fromPlatform();
    var res = await request("loginRequest", {
      "launcherAgent": "NeTask Launcher ${pkg.version} (flutter)",
      "operatingSystem": {
        "name": Platform.operatingSystem,
        "version": Platform.operatingSystemVersion,
      },
    });
    if (res == null) return false;
    clientToken = res["clientToken"];
    accessToken = res["accessToken"];
    return true;
  }

  static Future<Auth?> checkFlowOnce() async {
    var res = await request("loginRequestCheck", {
      "clientToken": clientToken,
      "accessToken": accessToken,
    });
    if (res == null) return null;
    if (res["success"] == true) {
      var data = res["data"];

      return Auth.netask(data);
    }
    return null;
  }

  static Future<Auth?> checkFlowUntilSuccess(int timeoutSeconds) async {
    bool timedOut = false;
    Future.delayed(Duration(seconds: timeoutSeconds)).then((value) {
      timedOut = true;
    });
    while (true) {
      var res = await checkFlowOnce();
      if (res != null) return res;
      if (timedOut) return null;
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  static Future<Auth?> validateSession(bool refresh) async {
    var res = await request("validateSession", {
      "clientToken": clientToken,
      "accessToken": accessToken,
      "refresh": refresh,
    });
    if (res == null) return null;
    if (res["success"] != true) return null;
    return Auth.netask(res["data"]);
  }

  static Future<bool> invalidateSession() async {
    var res = await request("invalidateSession", {
      "clientToken": clientToken,
      "accessToken": accessToken,
    });
    if (res == null) return false;
    if (res["success"] != true) return false;
    return true;
  }

  static Future<void> launchAuthPage() async {
    var data = jsonEncode({
      "clTok": clientToken,
    });
    // base64 encode json data
    var encodedData = base64Encode(utf8.encode(data));
    await launchUrlString("$authBaseURL/id/launcherLogin/$encodedData");
  }
}

enum AuthValidState {
  unknown,
  checking,
  valid,
  invalid,
}

class Auth {
  AuthType type;
  String nickname;
  String uuid;
  String? avatar;

  String? clientToken;
  String? accessToken;

  AuthValidState validState = AuthValidState.unknown;

  Auth({
    required this.type,
    required this.nickname,
    required this.uuid,
    this.avatar,
  });

  AuthDisplayDescriptor getDescriptor() {
    var headUrl = "${authBaseURL}api/skinrender/$uuid/head";
    if (type == AuthType.offline) {
      headUrl = "${authBaseURL}api/skinrender/@$nickname/head";
    }
    if (avatar != null) {
      headUrl = avatar!;
    } else {
      headUrl += "?t=${DateTime.now().millisecondsSinceEpoch}";
    }
    // Log.debug.log("Head icon url: $headUrl");
    return AuthDisplayDescriptor(
      type: type,
      nickname: nickname,
      headIconUrl: headUrl,
    );
  }

  void copyToSelf(Auth other) {
    type = other.type;
    nickname = other.nickname;
    uuid = other.uuid;
    avatar = other.avatar;
    clientToken = other.clientToken;
    accessToken = other.accessToken;
  }

  void _passTokens() {
    AuthAPI.clientToken = clientToken;
    AuthAPI.accessToken = accessToken;
  }

  void _grabTokens() {
    clientToken = AuthAPI.clientToken;
    accessToken = AuthAPI.accessToken;
  }

  Future<bool> validateSession() async {
    validState = AuthValidState.checking;
    if (type == AuthType.offline) {
      validState = AuthValidState.valid;
      return true;
    }
    _passTokens();
    var res = await AuthAPI.validateSession(true);
    if (res == null) {
      validState = AuthValidState.invalid;
      return false;
    }
    copyToSelf(res);
    validState = AuthValidState.valid;
    return true;
  }

  Future<bool> invalidateSession() async {
    if (type == AuthType.offline) {
      return true;
    }
    _passTokens();
    var res = await AuthAPI.invalidateSession();
    return res;
  }

  factory Auth.offline(String nickname) {
    // hashcode of nickname to uuid
    var uuid = nickname.hashCode.toRadixString(16);
    // fyi: hashcode in dart is a special 32-bit int, generated by
    // a simple algorithm, which is used to compare objects.
    // so it's probably not right to use it as a uuid, but it does
    // vary enough for this purpose, and who cares anyway

    // fill uuid to 32 chars
    while (uuid.length < 32) {
      uuid = "0$uuid";
    }
    // add dashes
    uuid =
        "${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-${uuid.substring(20, 32)}";

    var auth = Auth(
      type: AuthType.offline,
      nickname: nickname,
      uuid: uuid,
    );
    auth.validState = AuthValidState.valid;
    Log.debug.log("Created offline auth: '${auth.nickname}' (${auth.uuid})");
    return auth;
  }

  static Future<Auth?> netask(dynamic data) async {
    var auth = Auth(
      type: AuthType.netask,
      nickname: data["nickname"],
      uuid: data["uuid"],
      avatar: data["avatar"],
    );
    auth._grabTokens();
    auth.validState = AuthValidState.valid;
    return auth;
  }

  String serialize() {
    return jsonEncode({
      "type": type.index,
      "nickname": nickname,
      "uuid": uuid,
      "clientToken": clientToken,
      "accessToken": accessToken,
      "avatar": avatar,
    });
  }

  static Auth? deserialize(String? data) {
    if (data == null) return null;
    var json = jsonDecode(data);
    var type = AuthType.values[json["type"]];
    var nickname = json["nickname"];
    var uuid = json["uuid"];
    var clientToken = json["clientToken"];
    var accessToken = json["accessToken"];
    var avatar = json["avatar"];
    if (type == AuthType.offline) {
      return Auth.offline(nickname);
    }
    var auth = Auth(
      type: type,
      nickname: nickname,
      uuid: uuid,
      avatar: avatar,
    );
    auth.clientToken = clientToken;
    auth.accessToken = accessToken;
    return auth;
  }

  GameSession toGameSession() {
    return GameSession(
      nickname,
      uuid,
      accessToken ?? "",
    );
  }
}

class AuthHolder {
  static Auth? auth;
}

class AuthManager with ChangeNotifier {
  Auth? get auth => AuthHolder.auth;
  set auth(Auth? a) => AuthHolder.auth = a;
  static const _storage = FlutterSecureStorage();

  bool get isLoggedIn => auth != null;

  AuthManager() {
    load();
  }

  Future<void> doNeTaskLogin(Function(String)? onError) async {
    var flowSuccess = await AuthAPI.initFlow();
    if (!flowSuccess) {
      Log.error.log("Failed to init auth flow.");
      onError?.call("Failed to init auth flow.");
      return;
    }
    await AuthAPI.launchAuthPage();
    auth = await AuthAPI.checkFlowUntilSuccess(60);
    if (auth == null) {
      Log.error.log("Failed to login with NeTask ID.");
      onError?.call("Failed to login with NeTask ID.");
      return;
    }
    notifyListeners();
    save();
  }

  Future<void> doOfflineLogin(String nickname) async {
    auth = Auth.offline(nickname);
    notifyListeners();
    save();
  }

  Future<void> save() async {
    if (auth == null) return;
    var authJson = auth!.serialize();
    await AuthManager._storage.write(key: "auth", value: authJson);
  }

  Future<void> load() async {
    var authJson = await AuthManager._storage.read(key: "auth");
    // Log.debug.log("Loaded auth: $authJson");
    if (authJson == null) return;
    auth = Auth.deserialize(authJson);
    notifyListeners();
    await auth!.validateSession();
    notifyListeners();
  }

  Future<void> logout() async {
    if (auth == null) return;

    var success = await auth!.invalidateSession();
    if (!success) {
      Log.error.log("Failed to invalidate session. Continuing anyway.");
    }
    auth = null;
    notifyListeners();
  }
}
