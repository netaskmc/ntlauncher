import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

class AccentButton extends StatefulWidget {
  final Widget? child;
  final Color color;
  final Function? action;
  final double? width;
  final double smoothness;
  final Function? onPressed;
  const AccentButton({
    Key? key,
    this.child,
    this.color = const Color.fromARGB(255, 147, 147, 147),
    this.action,
    this.smoothness = 0.7,
    this.width,
    this.onPressed,
  }) : super(
          key: key,
        );

  @override
  State<AccentButton> createState() => _AccentButtonState();
}

class _AccentButtonState extends State<AccentButton>
    with SingleTickerProviderStateMixin {
  GlobalKey clipKey = GlobalKey();

  bool _hovered = false;

  double dir = 0.0;
  double dist = 0.0;
  double x = 0.0;
  double y = 0.0;

  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _updateLocation(PointerEvent details) {
    setState(() {
      dir = details.position.direction;
      dist = details.position.distance;
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 70.0,
      child: GestureDetector(
        onTap: () {
          if (widget.onPressed != null) widget.onPressed!();
        },
        onTapDown: (details) => _hoverController.forward(),
        // onVerticalDragStart: (details) => _hoverController.forward(),
        // onHorizontalDragStart: (details) => _hoverController.forward(),
        onTapUp: (details) => _hoverController.reverse(),
        onTapCancel: () {
          _hovered = false;
          _hoverController.reverse();
        },
        // onVerticalDragEnd: (details) => _hoverController.reverse(),
        // onHorizontalDragEnd: (details) => _hoverController.reverse(),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (e) => setState(() {
            _hovered = true;
            // _hoverController.forward();
          }),
          onExit: (e) => setState(() {
            _hovered = false;
            _hoverController.reverse();
          }),
          onHover: _updateLocation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.95).animate(
              CurvedAnimation(
                parent: _hoverController,
                curve: Curves.ease,
              ),
            ),
            child: SmoothClipRRect(
              smoothness: widget.smoothness,
              borderRadius: BorderRadius.circular(20),
              key: clipKey,
              // child: BackdropFilter(
              child: Container(
                //   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),,
                child: SmoothClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  smoothness: widget.smoothness,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.5),
                        ),
                        child: AnimatedOpacity(
                          opacity: _hovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: <Color>[
                                  widget.color.withOpacity(0.5),
                                  Colors.white.withOpacity(1),
                                  widget.color.withOpacity(0.5)
                                ],
                                stops: <double>[
                                  0.0,
                                  pow(min(dist / 1000, 0.8), 2).toDouble(),
                                  1.0
                                ],
                                transform: GradientRotation(dir * 4.2),
                              ).createShader(bounds);
                            },
                            child: SmoothContainer(
                              // margin: const EdgeInsets.all(0.5),
                              borderRadius: BorderRadius.circular(20),
                              smoothness: widget.smoothness,
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: double.infinity,
                        child: widget.child,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
