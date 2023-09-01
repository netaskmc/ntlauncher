import 'dart:convert';

import 'package:launcher_core/helpers.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class Authenticator {
  String apiUrl = 'https://authserver.mojang.com';
  String? uuid;
  String? clientToken;

  Future<User> getAuth(
      String username, String? password, String? clientToken) async {
    getUuid(username);

    if (password != null) {
      return User(
          uuid: uuid!,
          name: username,
          accessToken: uuid!,
          clientToken: clientToken ?? uuid!,
          userProperties: '{}');
    }
    Map<String, dynamic> request = {
      'agent': {'name': 'Minecraft', 'version': 1},
      'username': username,
      'password': password,
      'clientToken': uuid
    };

    http.Response response = await http.post(Uri.parse("$apiUrl/authenticate"),
        body: jsonEncode(request));
    Map<String, dynamic> data = jsonDecode(response.body);

    return User(
      accessToken: data['accessToken'],
      clientToken: data['clientToken'],
      name: data['selectedProfile']['name'],
      uuid: data['selectedProfile']['id'],
      userProperties: data['userProperties'],
      // metaType: AuthType.mojang
    );
  }

  void getUuid(String name) {
    if (uuid != null) return;
    uuid = Uuid().v4();
  }

  Authenticator();
}
