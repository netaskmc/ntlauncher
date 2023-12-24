import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:ntlauncher/providers/auth.dart';
import 'package:ntlauncher/ui/auth_display.dart';
import 'package:ntlauncher/ui/button.dart';
import 'package:ntlauncher/ui/dialog.dart';
import 'package:ntlauncher/ui/text_field.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SessionStatus extends StatelessWidget {
  final AuthValidState state;
  const SessionStatus({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    Color color = switch (state) {
      AuthValidState.checking => const Color.fromRGBO(55, 55, 55, 1),
      AuthValidState.invalid => const Color.fromRGBO(255, 144, 144, 1),
      AuthValidState.valid => Colors.white,
      AuthValidState.unknown => Colors.white,
    };
    String message = switch (state) {
      AuthValidState.checking => "Checking session",
      AuthValidState.invalid => "Session has expired",
      AuthValidState.valid => "Session valid",
      AuthValidState.unknown => "Unknown session status",
    };
    IconData icon = switch (state) {
      AuthValidState.checking => FeatherIcons.clock,
      AuthValidState.invalid => FeatherIcons.xCircle,
      AuthValidState.valid => FeatherIcons.checkCircle,
      AuthValidState.unknown => FeatherIcons.helpCircle,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          message,
          style: TextStyle(color: color),
        )
      ],
    );
  }
}

class OfflineNicknameFrag extends StatefulWidget {
  final Function(String) onConfirm;
  const OfflineNicknameFrag({
    super.key,
    required this.onConfirm,
  });

  @override
  State<OfflineNicknameFrag> createState() => _OfflineNicknameFragState();
}

class _OfflineNicknameFragState extends State<OfflineNicknameFrag> {
  String nickname = "";

  bool get isValidNickname => nickname.length >= 3 && nickname.length <= 16;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NtTextField(
          labelText: "Nickname",
          onChanged: (value) => setState(() {
            nickname = value;
          }),
        ),
        const SizedBox(height: 6),
        NtButton(
          text: "Set nickname",
          width: double.infinity,
          onPressed: () {
            if (!isValidNickname) return;
            widget.onConfirm(nickname);
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

class AccountDialog extends StatelessWidget {
  const AccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return NtDialog(
      content: Consumer<AuthManager>(builder: (context, auth, child) {
        if (!auth.isLoggedIn) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(
                    FeatherIcons.user,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Log in",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "NeTask ID",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              NtButtonAccent(
                text: "Log in with NeTask ID",
                width: double.infinity,
                onPressed: () {
                  auth.doNeTaskLogin((error) {});
                },
              ),
              const SizedBox(height: 6),
              const Text(
                "Offline",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              OfflineNicknameFrag(onConfirm: (nickname) {
                auth.doOfflineLogin(nickname);
              }),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(
                  FeatherIcons.user,
                  size: 24,
                ),
                SizedBox(width: 10),
                Text(
                  "Account",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(25, 25, 25, 1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AuthDisplay(auth: auth),
              ),
            ),
            const SizedBox(height: 10),
            SessionStatus(state: auth.auth!.validState),
            const SizedBox(height: 10),
            if (auth.auth!.type == AuthType.netask) ...[
              NtButtonAccent(
                text: "NeTask ID",
                onPressed: () => launchUrlString("${authBaseURL}id"),
                width: double.infinity,
              ),
              const SizedBox(height: 10),
            ],
            NtButtonDanger(
              text: "Log out",
              width: double.infinity,
              onPressed: () {
                auth.logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }),
    );
  }
}
