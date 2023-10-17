import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class NtSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;
  final bool showIcon;

  const NtSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      hoverColor: Colors.transparent,
      splashRadius: 0,
      activeColor: Color.fromRGBO(74, 222, 128, 1),
      activeTrackColor: Color.fromRGBO(74, 222, 128, 0.3),
      inactiveThumbColor: Color.fromRGBO(252, 165, 165, 1),
      inactiveTrackColor: Color.fromRGBO(252, 165, 165, 0.3),
      trackOutlineColor: MaterialStateColor.resolveWith(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return Color.fromRGBO(74, 222, 128, 0.5);
          }
          return Color.fromRGBO(252, 165, 165, 0.5);
        },
      ),
      trackOutlineWidth: MaterialStateProperty.resolveWith(
        (states) => 1,
      ),
      thumbIcon: showIcon
          ? MaterialStateProperty.resolveWith<Icon?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return const Icon(FeatherIcons.check);
                }
                return const Icon(FeatherIcons.x);
              },
            )
          : null,
    );
  }
}
