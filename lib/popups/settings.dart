import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:ntlauncher/ui/button.dart';
import 'package:ntlauncher/ui/dialog.dart';
import 'package:ntlauncher/ui/switch.dart';
import 'package:ntlauncher/ui/text_field.dart';

class SettingsPage {
  String title;
  IconData icon;
  Widget page;
  SettingsPage({required this.title, required this.icon, required this.page});
}

var pages = [
  SettingsPage(
    title: 'General',
    icon: FeatherIcons.settings,
    page: Container(),
  ),
  SettingsPage(
    title: 'Appearance',
    icon: FeatherIcons.eye,
    page: Container(),
  ),
  SettingsPage(
    title: 'About',
    icon: FeatherIcons.info,
    page: Container(),
  ),
];

class GeneralSettingsDialog extends StatelessWidget {
  const GeneralSettingsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NtDialog(
      content: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Row(
          children: [
            NavigationRail(
              // backgroundColor: Colors.transparent,
              extended: true,
              minExtendedWidth: 200,
              useIndicator: false,

              onDestinationSelected: (value) => {},
              destinations: pages
                  .map((e) => NavigationRailDestination(
                        icon: Icon(e.icon),
                        label: Text(e.title),
                      ))
                  .toList(),
              selectedIndex: 0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Container(width: 1, color: Colors.grey[900]),
            ),
          ],
        ),
      ),
    );
  }
}
