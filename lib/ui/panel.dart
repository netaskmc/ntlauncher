import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

class NtPanel extends StatelessWidget {
  final Widget? child;
  final Color color;
  final double? width;
  final double? height;
  final double? radius;

  const NtPanel({
    this.child,
    this.color = const Color.fromRGBO(0, 0, 0, 0.5),
    super.key,
    this.width,
    this.height,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
      child: Container(
        decoration: BoxDecoration(color: color),
        width: double.infinity,
        height: double.infinity,
        child: child,
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: radius == null
          ? ClipRect(child: content)
          : SmoothClipRRect(
              borderRadius: BorderRadius.circular(radius!),
              smoothness: 0.7,
              child: content,
            ),
    );
  }
}
