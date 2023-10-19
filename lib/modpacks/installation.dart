import 'package:ntlauncher/modpacks/manager.dart';
import 'package:ntlauncher/modpacks/modpack.dart';

enum InstallationStage {
  pack,
  modLoader,
  game,
  done,
}

class Installation {
  String id;
  Modpack get modpack => manager.modpackById(id)!;

  ModpackManager manager;

  double packProgress = 0;
  double modLoaderProgress = 0;
  double gameProgress = 0;
  InstallationStage stage = InstallationStage.pack;

  Installation({required this.id, required this.manager}) {
    if (manager.modpackById(id) == null) {
      throw Exception("Modpack not found.");
    }
  }

  double get progress {
    return (packProgress * 0.35 +
        modLoaderProgress * 0.1 +
        gameProgress * 0.55);
  }
}
