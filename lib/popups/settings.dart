import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:ntlauncher/ui/settings_pages.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionText extends StatelessWidget {
  const VersionText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
              "Version ${snapshot.data!.version}, build ${snapshot.data!.buildNumber}");
        } else {
          return Text("Version ...");
        }
      },
    );
  }
}

class GeneralSettingsDialog extends StatelessWidget {
  const GeneralSettingsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsPagesDialog(pages: [
      SettingsPage(
        title: 'General',
        icon: FeatherIcons.settings,
        page: SettingsPageSection(title: "General settings", children: [
          SettingsPageControl(
            id: "general.autoupdate",
            title: "Automatically update modpacks on launch",
            defaultValue: true,
          ),
        ]),
      ),
      SettingsPage(
        title: 'Java',
        icon: FeatherIcons.coffee,
        page: SettingsPageSection(title: "Java settings", children: []),
      ),
      SettingsPage(
        title: 'Debug',
        icon: FeatherIcons.terminal,
        page: SettingsPageSection(title: "Debug settings", children: [
          SettingsPageControl(
            id: "debug.show_debug_logs",
            title: "Show debug logs",
            defaultValue: true,
          ),
        ]),
      ),
      SettingsPage(
        title: 'About',
        icon: FeatherIcons.info,
        page: SettingsPageSection(title: "About NeTask Launcher", children: [
          SettingsPageControl(
              id: "",
              defaultValue: Column(
                children: [
                  Image.asset("assets/images/ntlauncher256.png",
                      width: 256, height: 256),
                  const Text(
                    "NeTask Launcher",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const VersionText(),
                ],
              )),
        ]),
      ),
    ]);
  }
}
