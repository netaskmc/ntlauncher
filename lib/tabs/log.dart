import 'package:flutter/material.dart';
import 'package:ntlauncher/default_settings.dart';
import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/providers/settings.dart';
import 'package:provider/provider.dart';

class LogTab extends StatefulWidget {
  const LogTab({super.key});

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LogProvider>(
      builder: (logContext, logValue, logChild) => Consumer<SettingsManager>(
        builder: (settingsContext, settingsValue, settingsChild) => ListView(
          reverse: true,
          children: logValue.logs
              .where((e) => !settingsValue.getSettingQuietly(
                      "debug.show_debug_logs", DefaultSettings.printDebug)
                  ? e.level != "DEBUG"
                  : true)
              .map(
                (e) {
                  var color = Colors.white;
                  if (e.level == "ERROR") {
                    color = const Color.fromARGB(255, 255, 109, 98);
                  } else if (e.level == "WARN") {
                    color = Colors.yellow;
                  } else if (e.level == "DEBUG") {
                    color = const Color.fromARGB(255, 94, 94, 94);
                  }
                  return Text(
                    e.toString(),
                    style: TextStyle(
                      color: color,
                      fontFamily: "JetBrainsMono",
                      fontSize: 12,
                    ),
                  );
                },
              )
              .toList()
              .reversed
              .toList(),
        ),
      ),
    );
  }
}
