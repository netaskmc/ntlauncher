import 'dart:io';

import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:ntlauncher/modpacks/manager.dart';
import 'package:ntlauncher/modpacks/modpack.dart';
import 'package:ntlauncher/popups/modpacksettings.dart';
import 'package:ntlauncher/ui/button.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class ModpackImage extends StatelessWidget {
  final Modpack modpack;
  const ModpackImage({super.key, required this.modpack});

  @override
  Widget build(BuildContext context) {
    if (!modpack.meta.isRemote) {
      return Image.file(
        File(path.join(
          ModpackManager.basePath,
          modpack.meta.icon!,
        )),
        width: 128,
        height: 128,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => const Padding(
          padding: EdgeInsets.all(48),
          child: Icon(
            FeatherIcons.frown,
            size: 32,
          ),
        ),
      );
    }

    return Image.network(
      "$remoteRoot${modpack.meta.icon}",
      width: 128,
      height: 128,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        double? progress;
        if (loadingProgress.expectedTotalBytes != null) {
          progress = loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes!;
        }
        return Padding(
          padding: const EdgeInsets.all(46),
          child: Stack(
            children: [
              CircularProgressIndicator(
                color: Colors.white,
                value: progress,
              ),
              const Padding(
                // padding: EdgeInsets.all(7.5),
                padding: EdgeInsets.fromLTRB(7.5, 6.5, 7.5, 8.5),
                child: Icon(
                  FeatherIcons.image,
                  size: 21,
                ),
              )
            ],
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => const Padding(
        padding: EdgeInsets.all(48),
        child: Icon(
          FeatherIcons.frown,
          size: 32,
        ),
      ),
    );
  }
}

class ModpackCtl extends StatelessWidget {
  final bool show;
  final bool installed;
  final bool updateAvailable;
  final bool installing;
  final bool compatible;
  final String modpackId;

  const ModpackCtl({
    super.key,
    required this.show,
    required this.installed,
    required this.updateAvailable,
    required this.installing,
    required this.modpackId,
    required this.compatible,
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
            if (!installed && compatible)
              NtButton(
                icon: FeatherIcons.download,
                onPressed: () {
                  context.read<ModpackManager>().install(modpackId);
                },
              ),
            if (updateAvailable)
              NtButtonSuccess(
                icon: FeatherIcons.download,
                onPressed: () {
                  context.read<ModpackManager>().update(modpackId);
                },
              ),
            if (installed)
              NtButtonDanger(
                icon: FeatherIcons.trash2,
                onPressed: () {
                  context.read<ModpackManager>().uninstall(modpackId);
                },
              ),
            // NtButton(
            //   icon: FeatherIcons.star,
            //   onPressed: () {},
            // ),
            if (installed)
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
    switch (widget.modpack.status) {
      case ModpackInstallStatus.installed:
        installationColor = const Color.fromARGB(255, 101, 255, 101);
        installationText = "Installed";
        installationIcon = FeatherIcons.check;
        break;
      case ModpackInstallStatus.notInstalled:
        installationColor = const Color.fromARGB(255, 255, 189, 189);
        installationText = "Not installed";
        installationIcon = FeatherIcons.x;
        break;
      case ModpackInstallStatus.onlyLocal:
        installationColor = const Color.fromARGB(255, 255, 166, 0);
        installationText = "Only local";
        installationIcon = FeatherIcons.cloudOff;
        break;
      case ModpackInstallStatus.updateAvailable:
        installationColor = const Color.fromARGB(255, 96, 183, 255);
        installationText = "Update available";
        installationIcon = FeatherIcons.download;
        break;
      case ModpackInstallStatus.updating:
        installationColor = const Color.fromARGB(255, 255, 106, 255);
        installationText = "Updating...";
        installationIcon = FeatherIcons.downloadCloud;
        break;
      case ModpackInstallStatus.unknown:
        // installationColor = const Color.fromARGB(255, 128, 128, 128);
        installationText = "Unknown";
        installationIcon = FeatherIcons.helpCircle;
        break;
      case ModpackInstallStatus.incompatible:
        installationColor = const Color.fromARGB(255, 255, 97, 97);
        installationText = "Incompatible";
        installationIcon = FeatherIcons.slash;
        break;
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
                      child: ModpackImage(modpack: widget.modpack),
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
                          Column(
                            children: [
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
                                      widget.modpack.installation == null
                                          ? installationText
                                          : widget.modpack.installation!
                                              .progressDetails,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: installationColor,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.modpack.installation != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(2, 4, 48, 0),
                                  child: LinearProgressIndicator(
                                    value:
                                        widget.modpack.installation!.progress,
                                    color: Colors.white,
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
              installed: widget.modpack.status ==
                      ModpackInstallStatus.installed ||
                  widget.modpack.status == ModpackInstallStatus.onlyLocal ||
                  widget.modpack.status == ModpackInstallStatus.updating ||
                  widget.modpack.status == ModpackInstallStatus.updateAvailable,
              updateAvailable:
                  widget.modpack.status == ModpackInstallStatus.updateAvailable,
              installing:
                  widget.modpack.status == ModpackInstallStatus.updating,
              compatible:
                  widget.modpack.status != ModpackInstallStatus.incompatible,
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
        return ListView(
          children: value.allPacks.map((e) {
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
