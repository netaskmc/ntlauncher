enum OS { windows, macos, linux, unknown }

class MinecraftVersion {
  /// Actual version. (e.g. 1.16.5)
  String version;

  /// Minecraft version type. (e.g. release, snapshot, old_beta, old_alpha)
  String type;

  /// The name of the folder, jar file, and version json in the version folder.
  /// MCLC will look in the `versions` folder for this name
  /// for example, '1.16.4-fabric'
  String? custom;

  dynamic downloads;
  dynamic assetIndex;

  String? assets;

  MinecraftVersion(this.version, this.type, this.custom);

  factory MinecraftVersion.fromJson(Map<String, dynamic> json) {
    final mv = MinecraftVersion(json['id'], json['type'], json['custom']);
    mv.downloads = json['downloads'];
    mv.assetIndex = json['assetIndex'];
    mv.assets = json['assets'];
    return mv;
  }
}

class MinecraftServer {
  String host;
  int? port;

  MinecraftServer(this.host, this.port);
}

class Proxy {
  String host;
  int? port;
  String? username;
  String? password;

  Proxy(this.host, this.port, this.username, this.password);
}

class Overrides {
  int? minArgs;
  String? minecraftJar;
  String? versionJson;
  String? gameDirectory;
  String? directory;
  String? natives;
  String? assetRoot;
  String? assetIndex;
  String? libraryRoot;
  String? cwd;
  bool? detached;
  List<String>? classes;
  int? maxSockets;
  Url? url;
  Fw? fw;
}

class Url {
  String? meta;
  String? resource;
  String? mavenForge;
  String? defaultRepoForge;
  String? fallbackMaven;
}

class Fw {
  String? baseUrl;
  String? version;
  String? sh1;
  int? size;
}

enum AuthType { mojang, microsoft }

class User {
  // access_token: string;
  //   client_token: string;
  //   uuid: string;
  //   name: string;
  //   user_properties: Partial<any>;
  //   meta?: {
  //     type: "mojang" | "msa",
  //     demo?: boolean
  //   };

  String? accessToken;
  String? clientToken;
  String uuid;
  String name;
  dynamic userProperties;
  AuthType? metaType;
  bool? demo;

  User(
      {required this.uuid,
      required this.name,
      this.accessToken,
      this.clientToken,
      this.userProperties,
      this.metaType,
      this.demo});
}

class Options {
  /// Path or URL to the client package zip file.
  String? clientPackage;

  /// if true MCLC will remove the client package zip file after its finished extracting.
  bool? removePackage;

  /// Path to installer being executed.
  String? installer;

  /// Path where you want the launcher to work in.
  /// This will usually be your .minecraft folder
  String root;

  /// OS override for minecraft natives.
  OS? os;

  /// Array of custom Minecraft arguments.
  List<String>? customLaunchArgs;

  /// Array of custom JVM arguments.
  List<String>? customArgs;

  /// Array of game argument feature flags.
  List<String>? features;

  /// minecraft version info
  MinecraftVersion version;

  /// Min and max memory allocation for the JVM, in MB.
  (int, int)? memory;

  /// Path to Forge Jar.
  /// Versions below 1.13 should be the "universal" jar while versions above 1.13+ should be the "installer" jar
  String? forge;

  /// Path to the JRE executable file, will default to java if not entered.
  String? javaPath;

  /// Server to join on launch automatically.
  MinecraftServer? server;

  /// Proxy to use for (no idea what this is for)
  Proxy? proxy;

  /// Timeout on download requests.
  int? timeout;

  /// Resolution of the game window.
  (int, int)? resolution;

  /// If true, the game will be launched in fullscreen mode.
  bool? fullscreen;

  Overrides? overrides;
  Future<User> authorization;

  /// Path of json cache.
  String? cache;

  String? directory;

  Options(
      {this.clientPackage,
      this.removePackage,
      this.installer,
      required this.root,
      this.os,
      this.customLaunchArgs,
      this.customArgs,
      this.features,
      required this.version,
      this.memory,
      this.forge,
      this.javaPath,
      this.server,
      this.proxy,
      this.timeout,
      this.resolution,
      this.fullscreen,
      this.overrides,
      required this.authorization,
      this.cache});
}
