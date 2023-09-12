import 'dart:ui';

import 'package:flutter/material.dart';

class NtPanel extends StatelessWidget {
  final Widget? child;
  final Color color;
  final double? width;
  final double? height;
  const NtPanel(
      {this.child,
      this.color = const Color.fromRGBO(0, 0, 0, 0.5),
      Key? key,
      this.width,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: ClipRect(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                  decoration: BoxDecoration(color: color),
                  width: double.infinity,
                  height: double.infinity,
                  child: child)),
        ));
  }
}
