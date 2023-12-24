import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ntlauncher/launch/launch.dart';
import 'package:ntlauncher/logger.dart';
import 'package:ntlauncher/modpacks/manager.dart';
import 'package:ntlauncher/modpacks/modpack.dart';
import 'package:ntlauncher/popups/account.dart';
import 'package:ntlauncher/providers/auth.dart';
import 'package:ntlauncher/providers/settings.dart';
import 'package:ntlauncher/tabs/log.dart';
import 'package:ntlauncher/tabs/modpacks.dart';
import 'package:ntlauncher/ui/accent_button.dart';
import 'package:ntlauncher/ui/auth_display.dart';
import 'package:ntlauncher/ui/panel.dart';
import 'package:ntlauncher/ui/tabs.dart';
import 'package:ntlauncher/popups/settings.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  await Settings.loadSettings();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    // backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden,
    minimumSize: Size(600, 500),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  Log.info.log("Initialized window manager.");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ModpackManager()),
        ChangeNotifierProvider(create: (ctx) => LogProvider()),
        ChangeNotifierProvider(create: (ctx) => SettingsManager()),
        ChangeNotifierProvider(create: (ctx) => AuthManager()),
      ],
      child: MaterialApp(
        title: 'NeTask Launcher',
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(),
          fontFamily: 'Inter',
          useMaterial3: true,
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color.fromRGBO(255, 255, 255, 0.5),
            selectionColor: Color.fromRGBO(255, 255, 255, 0.3),
            selectionHandleColor: Color.fromRGBO(255, 255, 255, 0.5),
          ),
        ),
        home: const MyHomePage(title: 'NeTask Launcher'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final List<String> tabs = ["modpacks", "logs"];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/reborn.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            NtPanel(
              height: 50,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: NtTabs(
                  names: tabs,
                  displayNames: const ["Modpacks", "Logs"],
                  controller: _tabController,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: tabs.map((tab) {
                  final String label = tab.toLowerCase();
                  return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: NtPanel(
                        radius: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: switch (label) {
                            "modpacks" => const ModpacksTab(),
                            //"vanilla" => const Text("Vanilla"),
                            "logs" => const LogTab(),
                            _ => const Text("Unknown"),
                          },
                        ),
                      ));
                }).toList(),
              ),
            ),
            //   child:
            const BottomBar(),
          ],
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Log.subscribe((s, level) {
      if (level != "ERROR") return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $s",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red.shade700.withOpacity(0.7),
          showCloseIcon: true,
          closeIconColor: Colors.white,
          duration: const Duration(seconds: 10),
        ),
      );
    });

    return Consumer<AuthManager>(builder: (context, auth, child) {
      Widget authPanel = const Text("Not logged in");
      if (auth.isLoggedIn) {
        authPanel = AuthDisplay(auth: auth);
      }

      return NtPanel(
        height: 90,
        width: double.infinity,
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                AccentButton(
                  width: 180,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: authPanel,
                  ),
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => const AccountDialog(),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(child: LaunchButton()),
                const SizedBox(width: 10),
                AccentButton(
                  width: 70,
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) =>
                        const GeneralSettingsDialog(),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                    child: Icon(
                      FeatherIcons.settings,
                      size: 22,
                      semanticLabel: "Settings",
                    ),
                  ),
                ),
              ],
            )),
      );
    });
  }
}

class LaunchButton extends StatefulWidget {
  const LaunchButton({
    super.key,
  });

  @override
  State<LaunchButton> createState() {
    return _LaunchButtonState();
  }
}

class _LaunchButtonState extends State<LaunchButton> {
  bool running = false;

  @override
  void initState() {
    super.initState();
    Launch.addListener(_handleLaunchStateChange);
  }

  @override
  void dispose() {
    Launch.removeListener(_handleLaunchStateChange);
    super.dispose();
  }

  void _handleLaunchStateChange(bool running) {
    setState(() {
      this.running = running;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModpackManager>(builder: (context, value, child) {
      bool actionable = false;
      String text = "Launch";
      if (running) {
        actionable = true;
        text = "Kill game";
      } else {
        if (value.selectedModpack?.status == ModpackInstallStatus.installed) {
          actionable = true;
        } else if (value.selectedModpack?.status ==
            ModpackInstallStatus.updateAvailable) {
          actionable = true;
          text = "Update";
        } else if (value.selectedModpack?.status ==
            ModpackInstallStatus.onlyLocal) {
          actionable = true;
        }
      }

      return AccentButton(
        color: actionable
            ? (running
                ? Color.fromARGB(255, 255, 86, 199)
                : const Color.fromRGBO(123, 27, 138, 1))
            : const Color.fromRGBO(54, 54, 54, 1),
        onPressed: actionable
            ? () {
                if (!running) {
                  Launch.launch(value.selectedModpack!);
                } else {
                  Launch.stop();
                }
              }
            : null,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }
}
