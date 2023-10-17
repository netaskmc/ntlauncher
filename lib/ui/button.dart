import 'package:flutter/material.dart';

class NtButtonColor {
  final Color color;
  final double colorBorderOpacity;
  final double colorBgOpacity;
  final double contentOpacity;
  final Color hoverColor;
  final double hoverBorderOpacity;
  final double hoverBgOpacity;
  final double contentHoverOpacity;

  const NtButtonColor({
    this.color = const Color.fromARGB(255, 255, 255, 255),
    this.colorBorderOpacity = 0.05,
    this.colorBgOpacity = 0,
    this.contentOpacity = 0.7,
    this.hoverColor = const Color.fromARGB(255, 255, 255, 255),
    this.hoverBorderOpacity = 0.20,
    this.hoverBgOpacity = 0.10,
    this.contentHoverOpacity = 1,
  });

  Color getColor(bool hovered) {
    return hovered ? hoverColor : color;
  }

  Color getBorderColor(bool hovered) {
    return getColor(hovered).withOpacity(
      hovered ? hoverBorderOpacity : colorBorderOpacity,
    );
  }

  Color getBackgroundColor(bool hovered) {
    return getColor(hovered).withOpacity(
      hovered ? hoverBgOpacity : colorBgOpacity,
    );
  }

  double getContentOpacity(bool hovered) {
    return hovered ? contentHoverOpacity : contentOpacity;
  }
}

class NtButton extends StatefulWidget {
  // final Widget? child;
  final String? text;
  final IconData? icon;

  final double? width;
  final Function? onPressed;
  final NtButtonColor color;

  const NtButton({
    Key? key,
    // this.child,
    this.text,
    this.icon,
    this.width,
    this.onPressed,
    this.color = const NtButtonColor(),
  }) : super(
          key: key,
        );

  @override
  State<NtButton> createState() => _NtButtonState();
}

class _NtButtonState extends State<NtButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (PointerEvent details) => setState(() {
          _hovered = true;
        }),
        onExit: (PointerEvent details) => setState(() {
          _hovered = false;
        }),
        child: GestureDetector(
          onTap: () {
            if (widget.onPressed != null) {
              widget.onPressed!();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            width: widget.width,
            height: 40,
            decoration: BoxDecoration(
              color: widget.color.getBackgroundColor(_hovered),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.color.getBorderColor(_hovered),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: widget.color.getContentOpacity(_hovered),
                child: Row(
                    // child: widget.child,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.icon != null)
                        Icon(
                          widget.icon!,
                          color: widget.color.getColor(_hovered),
                          size: 18,
                        ),
                      if (widget.icon != null && widget.text != null)
                        const SizedBox(width: 5),
                      Text(
                        widget.text ?? "",
                        style: TextStyle(
                          color: widget.color.getColor(_hovered),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NtButtonDanger extends NtButton {
  const NtButtonDanger({
    super.key,
    // super.child,
    super.text,
    super.icon,
    super.width,
    super.onPressed,
  }) : super(
          color: const NtButtonColor(
            color: Color.fromARGB(255, 252, 165, 165),
            colorBorderOpacity: 0.10,
            colorBgOpacity: 0.05,
            contentOpacity: 0.7,
            hoverColor: Color.fromARGB(255, 248, 113, 113),
            hoverBorderOpacity: 0.30,
            hoverBgOpacity: 0.10,
            contentHoverOpacity: 1,
          ),
        );
}

class NtButtonSuccess extends NtButton {
  const NtButtonSuccess({
    super.key,
    // super.child,
    super.text,
    super.icon,
    super.width,
    super.onPressed,
  }) : super(
          color: const NtButtonColor(
            color: Color.fromARGB(255, 134, 239, 172),
            colorBorderOpacity: 0.10,
            colorBgOpacity: 0,
            contentOpacity: 0.7,
            hoverColor: Color.fromARGB(255, 74, 222, 128),
            hoverBorderOpacity: 0.30,
            hoverBgOpacity: 0.10,
            contentHoverOpacity: 1,
          ),
        );
}

class NtButtonAccent extends NtButton {
  const NtButtonAccent({
    super.key,
    // super.child,
    super.text,
    super.icon,
    super.width,
    super.onPressed,
  }) : super(
          color: const NtButtonColor(
            color: Color.fromARGB(255, 205, 62, 255),
            colorBorderOpacity: 0.20,
            colorBgOpacity: 0.10,
            contentOpacity: 0.8,
            hoverColor: Color.fromARGB(255, 255, 88, 208),
            // hoverColor: Color.fromARGB(255, 88, 255, 124),
            hoverBorderOpacity: 0.40,
            hoverBgOpacity: 0.20,
            contentHoverOpacity: 1,
          ),
        );
}
