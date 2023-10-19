import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:ntlauncher/modpacks/manager.dart';
import 'package:ntlauncher/modpacks/modpack.dart';
import 'package:ntlauncher/ui/dialog.dart';
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
                Icon(
                  FeatherIcons.settings,
                  size: 24,
                ),
                SizedBox(width: 16),
                Text(
                  "${modpack.meta.name} Settings",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}
