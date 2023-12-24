import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:ntlauncher/modpacks/manager.dart';
import 'package:ntlauncher/modpacks/modpack.dart';
import 'package:ntlauncher/providers/settings.dart';
import 'package:ntlauncher/ui/dialog.dart';
import 'package:ntlauncher/ui/settings_pages.dart';
import 'package:provider/provider.dart';

class ModpackSettingsDialog extends StatelessWidget {
  final String modpackId;

  const ModpackSettingsDialog({
    super.key,
    required this.modpackId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ModpackManager>(builder: (context, value, child) {
      Modpack? modpack = value.modpackById(modpackId);
      if (modpack == null) {
        return const NtDialog(
          content: Text("Modpack not found."),
        );
      }
      return NtDialog(
        content: Column(
          children: [
            Row(
              children: [
                const Icon(
                  FeatherIcons.settings,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  "${modpack.meta.name} Settings",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(
              width: 400,
              // screen height - 200
              height: MediaQuery.of(context).size.height - 120,
              child: SettingsPageSection(
                title: "Modpack settings",
                showTitle: false,
                children: [
                  SettingsPageControl(
                    id: "modpacks.$modpackId.jvm_ram",
                    title: "RAM allocation limits (MB)",
                    defaultValue: Settings.getSetting(
                        "general.jvm_ram", DoubleNum(2048, 4096)),
                    min: 1024,
                    max: 16384,
                    step: 256,
                  ),
                ],
              ).buildSection(),
            ),
          ],
        ),
      );
    });
  }
}
