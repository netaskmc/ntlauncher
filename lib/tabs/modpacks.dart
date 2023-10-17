import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:ntlauncher/modpacks/manager.dart';
import 'package:ntlauncher/modpacks/modpack.dart';
import 'package:provider/provider.dart';

class ModpackTab extends StatelessWidget {
  final Modpack modpack;

  const ModpackTab({super.key, required this.modpack});

  @override
  Widget build(BuildContext context) {
    Color installationColor = const Color.fromARGB(255, 128, 128, 128);
    String installationText = "Checking...";
    IconData installationIcon = FeatherIcons.clock;
    if (modpack.status == ModpackInstallStatus.installed) {
      installationColor = Color.fromARGB(255, 101, 255, 101);
      installationText = "Installed";
      installationIcon = FeatherIcons.check;
    } else if (modpack.status == ModpackInstallStatus.notInstalled) {
      installationColor = Color.fromARGB(255, 255, 84, 84);
      installationText = "Not installed";
      installationIcon = FeatherIcons.x;
    } else if (modpack.status == ModpackInstallStatus.onlyLocal) {
      installationColor = Color.fromARGB(255, 255, 166, 0);
      installationText = "Only local";
      installationIcon = FeatherIcons.cloudOff;
    } else if (modpack.status == ModpackInstallStatus.updateAvailable) {
      installationColor = Color.fromARGB(255, 96, 183, 255);
      installationText = "Update available";
      installationIcon = FeatherIcons.download;
    } else if (modpack.status == ModpackInstallStatus.updating) {
      installationColor = Color.fromARGB(255, 255, 106, 255);
      installationText = "Updating...";
      installationIcon = FeatherIcons.downloadCloud;
    }

    return SizedBox(
      height: 128,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "$remoteRoot${modpack.meta.icon}",
              width: 128,
              height: 128,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  modpack.meta.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "by ${modpack.meta.author}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    "Minecraft ${modpack.meta.mcVersion}, ${modpack.meta.modCount} mods",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 141, 141, 141),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      installationIcon,
                      size: 24,
                      color: installationColor,
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        installationText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: installationColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModpacksTab extends StatefulWidget {
  const ModpacksTab({super.key});

  @override
  State<ModpacksTab> createState() => _ModpacksTabState();
}

class _ModpacksTabState extends State<ModpacksTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ModpackManager>(
      builder: (context, value, child) {
        List<Modpack> all = [...value.local, ...value.remote];
        return ListView(
          children: all.map((e) {
            return ModpackTab(modpack: e);
          }).toList(),
        );
      },
    );
  }
}
