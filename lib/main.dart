import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ntlauncher/auth/descriptor.dart';
import 'package:ntlauncher/ui/accent_button.dart';
import 'package:ntlauncher/ui/panel.dart';
import 'package:ntlauncher/ui/tabs.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      // backgroundColor: Colors.transparent,
      skipTaskbar: false,
      // titleBarStyle: TitleBarStyle.hidden,
      minimumSize: Size(400, 500));
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeTask Launcher',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NeTask Launcher'),
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
  List<String> tabs = ["modpacks", "vanilla", "news"];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                  displayNames: ["Modpacks", "Vanilla", "News"],
                  controller: _tabController,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: tabs.map((tab) {
                  final String label = tab.toLowerCase();
                  return Container(
                    child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: NtPanel(
                          radius: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: switch (label) {
                              "modpacks" => const Text("Modpacks"),
                              "vanilla" => const Text("Vanilla"),
                              "news" => const Text("News"),
                              _ => const Text("Unknown"),
                            },
                          ),
                        )),
                  );
                }).toList(),
              ),
            ),
            //   child:
            BottomBar(auth: EXAMPLE_AUTH_DISPLAY),
          ],
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.auth,
  });

  final AuthDisplay auth;

  @override
  Widget build(BuildContext context) {
    Widget authPanel = const Text("Not logged in");
    if (auth.isLoggedIn()) {
      authPanel = Row(
          // alignment: WrapAlignment.center,
          // runAlignment: WrapAlignment.center,
          children: [
            Image.network(
              "https://daddy.su/vania.jpg",
              filterQuality: FilterQuality.none,
              width: 46,
              height: 46,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Wrap(
                direction: Axis.vertical,
                spacing: 2,
                children: [
                  Text(
                    auth.descriptor!.type == AuthType.netask
                        ? "NeTask ID"
                        : "Offline",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(155, 155, 155, 1),
                      // fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 105,
                    child: Text(
                      auth.descriptor!.nickname,
                      softWrap: false,
                      style: const TextStyle(
                        overflow: TextOverflow.fade,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]);
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
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: AccentButton(
                color: const Color.fromRGBO(123, 27, 138, 1),
                child: Text(
                  "Launch",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // onPressed: _incrementCounter,
              )),
              const SizedBox(width: 10),
              const AccentButton(
                width: 70,
                child: Padding(
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
  }
}
