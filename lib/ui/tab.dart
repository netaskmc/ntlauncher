import 'package:flutter/material.dart';

class NtTab extends StatelessWidget {
  NtTab({
    super.key,
    required this.name,
  });
  String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name.toUpperCase(),
          style: TextStyle(
            letterSpacing: 2,
          ),
        )
      ],
    );
  }
}
