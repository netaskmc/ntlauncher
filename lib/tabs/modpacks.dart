import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:ntlauncher/modpacks/manager.dart';
import 'package:ntlauncher/modpacks/modpack.dart';
import 'package:ntlauncher/popups/modpacksettings.dart';
import 'package:ntlauncher/ui/button.dart';
import 'package:provider/provider.dart';

class ModpackCtl extends StatelessWidget {
  final bool show;
  final bool installed;
  final bool updateAvailable;
  final bool installing;
  final String modpackId;

  const ModpackCtl({
    super.key,
    required this.show,
    required this.installed,
    required this.updateAvailable,
    required this.installing,
    required this.modpackId,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      opacity: show ? 1 : 0,
      child: IgnorePointer(
        ignoring: !show,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NtButton(
              icon: installed ? FeatherIcons.trash2 : FeatherIcons.download,
              onPressed: () {
                if (installed) {
                  context.read<ModpackManager>().uninstall(modpackId);
                } else {
                  context.read<ModpackManager>().install(modpackId);
                }
              },
            ),
            // NtButton(
            //   icon: FeatherIcons.star,
            //   onPressed: () {},
            // ),
            NtButton(
              icon: FeatherIcons.settings,
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => ModpackSettingsDialog(
                  modpackId: modpackId,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModpackTab extends StatefulWidget {
  final Modpack modpack;
  final bool selected;
  final Function onClick;

  const ModpackTab({
    super.key,
    required this.modpack,
    required this.selected,
    required this.onClick,
  });

  @override
  State<ModpackTab> createState() => _ModpackTabState();
}

class _ModpackTabState extends State<ModpackTab> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    Color installationColor = const Color.fromARGB(255, 128, 128, 128);
    String installationText = "Checking...";
    IconData installationIcon = FeatherIcons.clock;
    if (widget.modpack.status == ModpackInstallStatus.installed) {
      installationColor = const Color.fromARGB(255, 101, 255, 101);
      installationText = "Installed";
      installationIcon = FeatherIcons.check;
    } else if (widget.modpack.status == ModpackInstallStatus.notInstalled) {
      installationColor = const Color.fromARGB(255, 255, 84, 84);
      installationText = "Not installed";
      installationIcon = FeatherIcons.x;
    } else if (widget.modpack.status == ModpackInstallStatus.onlyLocal) {
      installationColor = const Color.fromARGB(255, 255, 166, 0);
      installationText = "Only local";
      installationIcon = FeatherIcons.cloudOff;
    } else if (widget.modpack.status == ModpackInstallStatus.updateAvailable) {
      installationColor = const Color.fromARGB(255, 96, 183, 255);
      installationText = "Update available";
      installationIcon = FeatherIcons.download;
    } else if (widget.modpack.status == ModpackInstallStatus.updating) {
      installationColor = const Color.fromARGB(255, 255, 106, 255);
      installationText = "Updating...";
      installationIcon = FeatherIcons.downloadCloud;
    }

    return GestureDetector(
      onTap: () => widget.onClick(),
      child: MouseRegion(
        cursor: widget.selected
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() {
          _hovered = true;
        }),
        onExit: (_) => setState(() {
          _hovered = false;
        }),
        child: Stack(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              color: widget.selected
                  ? const Color.fromRGBO(128, 128, 128, 0.2)
                  : (_hovered
                      ? const Color.fromRGBO(128, 128, 128, 0.1)
                      : Colors.transparent),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 128,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        "$remoteRoot${widget.modpack.meta.icon}",
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
                            widget.modpack.meta.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "by ${widget.modpack.meta.author}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              "Minecraft ${widget.modpack.meta.mcVersion}, ${widget.modpack.meta.modCount} mods",
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
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            bottom: 8,
            child: ModpackCtl(
              show: _hovered && widget.selected,
              installed:
                  widget.modpack.status == ModpackInstallStatus.installed,
              updateAvailable:
                  widget.modpack.status == ModpackInstallStatus.updateAvailable,
              installing:
                  widget.modpack.status == ModpackInstallStatus.updating,
              modpackId: widget.modpack.id,
            ),
          ),
        ]),
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
            return ModpackTab(
              modpack: e,
              selected: value.isSelected(e),
              onClick: () => value.selectModpack(e.id),
            );
          }).toList(),
        );
      },
    );
  }
}
