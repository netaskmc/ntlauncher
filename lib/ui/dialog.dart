import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

class NtDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  const NtDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: actions,
      shape: SmoothRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        smoothness: 0.7,
      ),
      // backgroundColor: const Color.fromRGBO(20, 20, 20, 1),
      surfaceTintColor: Color.fromARGB(255, 0, 0, 0),
    );
  }
}
