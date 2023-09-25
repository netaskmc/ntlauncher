enum AuthType { offline, netask }

class AuthDisplayDescriptor {
  AuthDisplayDescriptor({
    required this.type,
    required this.nickname,
  });

  AuthType type;
  String nickname;
}

class AuthDisplay {
  AuthDisplay({
    this.descriptor,
  });

  AuthDisplayDescriptor? descriptor;

  bool isLoggedIn() {
    return descriptor != null;
  }
}

// ignore: non_constant_identifier_names
final EXAMPLE_AUTH_DISPLAY = AuthDisplay(
  descriptor: AuthDisplayDescriptor(
    type: AuthType.netask,
    nickname: "Mlntcandy",
  ),
);
