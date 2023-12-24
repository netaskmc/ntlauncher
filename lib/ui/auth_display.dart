import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:ntlauncher/providers/auth.dart';

class AuthDisplay extends StatelessWidget {
  final AuthManager auth;
  const AuthDisplay({
    super.key,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        // alignment: WrapAlignment.center,
        // runAlignment: WrapAlignment.center,
        children: [
          Image.network(
            auth.auth!.getDescriptor().headIconUrl,
            filterQuality: FilterQuality.none,
            width: 46,
            height: 46,
            loadingBuilder: (context, child, loadingProgress) =>
                loadingProgress == null
                    ? child
                    : const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: CircularProgressIndicator(),
                      ),
            errorBuilder: (context, error, stackTrace) => const Padding(
              padding: EdgeInsets.all(7.0),
              child: Icon(
                FeatherIcons.helpCircle,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Wrap(
              direction: Axis.vertical,
              spacing: 2,
              children: [
                Text(
                  auth.auth!.getDescriptor().type == AuthType.netask
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
                    auth.auth!.nickname,
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
}
