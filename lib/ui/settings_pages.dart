import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ntlauncher/providers/settings.dart';
import 'package:ntlauncher/ui/dialog.dart';
import 'package:ntlauncher/ui/switch.dart';
import 'package:ntlauncher/ui/text_field.dart';
import 'package:provider/provider.dart';

class SettingsPage {
  String title;
  IconData icon;
  SettingsPageSection page;
  SettingsPage({required this.title, required this.icon, required this.page});
}

class SettingsPages extends StatelessWidget {
  final List<SettingsPage> pages;

  const SettingsPages({
    super.key,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    bool tooNarrow = MediaQuery.of(context).size.width < 700;
    return DefaultTabController(
      length: pages.length,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RotatedBox(
            quarterTurns: 1,
            child: TabBar(
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              splashFactory: NoSplash.splashFactory,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: const Color.fromRGBO(255, 255, 255, 0.5),
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
              indicator: UnderlineTabIndicator(
                borderSide: const BorderSide(
                  width: 2,
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              tabs: pages
                  .map((e) => Tab(
                        height: tooNarrow ? 50 : 150,
                        child: RotatedBox(
                            quarterTurns: 3,
                            child: Row(
                              children: [
                                const SizedBox(width: 10),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Icon(e.icon),
                                ),
                                SizedBox(width: tooNarrow ? 0 : 10),
                                Text(tooNarrow ? "" : e.title),
                              ],
                            )),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
            child: Container(width: 1, color: Colors.grey[900]),
          ),
          SizedBox(
            width: min(
                MediaQuery.of(context).size.width - (tooNarrow ? 215 : 330),
                600),
            child: TabBarView(
              children: pages.map((e) => e.page.buildSection()).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPagesDialog extends StatelessWidget {
  final List<SettingsPage> pages;
  const SettingsPagesDialog({
    super.key,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return NtDialog(content: SettingsPages(pages: pages));
  }
}

class DoubleNum {
  double first;
  double second;
  DoubleNum(this.first, this.second);

  List<double> serialize() {
    return [first, second];
  }

  static DoubleNum deserialize(List<double> list) {
    if (list.length != 2) {
      throw Exception(
          "DoubleNum.deserialize must be passed a list of length 2");
    }
    return DoubleNum(list[0], list[1]);
  }
}

class SettingsPageControl<T> {
  String id;
  String? title;
  T defaultValue;

  double? min;
  double? max;

  double? step;

  SettingsPageControl({
    required this.id,
    this.title,
    required this.defaultValue,
    this.min,
    this.max,
    this.step,
  });

  Widget getControl(T value, void Function(T) onChange) {
    if (value.runtimeType.toString() == "bool") {
      return NtSwitch(
        value: value as bool,
        onChanged: (bool value) {
          onChange(value as T);
        },
      );
    }
    if (value.runtimeType.toString() == "int" ||
        value.runtimeType.toString() == "double") {
      if (min == null || max == null) {
        throw Exception("min and max must be set for int or double controls");
      }
      return Row(
        children: [
          Slider(
            value: (value as num).toDouble(),
            min: min ?? 0,
            max: max ?? 100,
            divisions: step != null
                ? ((max ?? 100) - (min ?? 0) == 0
                    ? 1
                    : ((max ?? 100) - (min ?? 0)) ~/ step!)
                : null,
            onChanged: (double value) {
              onChange(value as T);
            },
            activeColor: Colors.white,
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }
    if (value.runtimeType.toString().startsWith("DoubleNum")) {
      if (min == null || max == null) {
        throw Exception("min and max must be set for int or double controls");
      }
      return Column(
        children: [
          Row(
            children: [
              Slider(
                value: (value as DoubleNum).first.toDouble(),
                secondaryTrackValue: value.second.toDouble(),
                min: min ?? 0,
                max: max ?? 100,
                divisions: step != null
                    ? ((max ?? 100) - (min ?? 0) == 0
                        ? 1
                        : ((max ?? 100) - (min ?? 0)) ~/ step!)
                    : null,
                onChanged: (double v) {
                  onChange(DoubleNum(v, value.second) as T);
                },
                activeColor: Colors.white,
                secondaryActiveColor: Colors.white.withOpacity(0.5),
                inactiveColor: Colors.white.withOpacity(0.1),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  value.first.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Slider(
                value: value.second.toDouble(),
                min: min ?? 0,
                max: max ?? 100,
                divisions: step != null
                    ? ((max ?? 100) - (min ?? 0) == 0
                        ? 1
                        : ((max ?? 100) - (min ?? 0)) ~/ step!)
                    : null,
                onChanged: (double v) {
                  onChange(DoubleNum(value.first, v) as T);
                },
                activeColor: Colors.white,
                secondaryActiveColor: Colors.white.withOpacity(0.5),
                inactiveColor: Colors.white.withOpacity(0.1),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  value.second.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    if (value.runtimeType.toString() == "String") {
      return SizedBox(
        width: 256,
        child: NtTextField(
          value: value as String,
          onChanged: (String value) {
            onChange(value as T);
          },
        ),
      );
    }
    throw Exception(
        "Unknown type passed to SettingsPageControl ${value.runtimeType.toString()}");
  }

  Widget getControlWithLabel(T value, void Function(T) onChange) {
    return Flex(
      direction: Axis.horizontal,
      // direction: value is! String ? Axis.horizontal : Axis.vertical,
      // mainAxisSize: value is! String ? MainAxisSize.max : MainAxisSize.min,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            title ?? id,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        getControl(value, onChange),
      ],
    );
  }

  Widget buildControl() {
    if (this.defaultValue is Widget) {
      return this.defaultValue as Widget;
    }
    return Consumer<SettingsManager>(
      builder: (context, value, child) {
        return getControlWithLabel(
          value.getSetting(id, defaultValue),
          (T v) {
            value.setSetting(id, v);
          },
        );
      },
    );
  }
}

class SettingsPageSection {
  String title;
  List<SettingsPageControl> children;
  bool showTitle;
  SettingsPageSection({
    required this.title,
    required this.children,
    this.showTitle = true,
  });

  Widget buildSection() {
    return ListView(
      children: [
        if (showTitle) ...[
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
        ],
        ...children.map((e) => e.buildControl()).toList(),
      ],
    );
  }
}
