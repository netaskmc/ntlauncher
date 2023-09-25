import 'package:flutter/material.dart';

class NtTab extends StatefulWidget {
  NtTab({
    super.key,
    required this.name,
  });
  String name;

  @override
  State<NtTab> createState() => _NtTabState();
}

class _NtTabState extends State<NtTab> {
  bool _isHovered = false;
  bool isSelected = true;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHovered = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: Tab(
        // padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          widget.name.toUpperCase(),
          style: TextStyle(
            letterSpacing: 2,
            // color: Color.fromRGBO(255, 44, 192, 1),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class NtTabs extends StatelessWidget {
  NtTabs({
    super.key,
    required this.names,
    this.controller,
    this.displayNames,
  });

  List<String> names;
  List<String>? displayNames;
  TabController? controller;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      // direction: Axis.horizontal,
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      controller: controller,
      indicatorColor: const Color.fromRGBO(255, 44, 192, 1),
      labelColor: const Color.fromRGBO(255, 44, 192, 1),
      unselectedLabelColor: const Color.fromRGBO(255, 255, 255, 0.5),
      splashFactory: NoSplash.splashFactory,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),

      isScrollable: true,
      tabAlignment: TabAlignment.start,

      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: const Color.fromRGBO(255, 44, 192, 1),
        ),
        borderRadius: BorderRadius.circular(10),
      ),

      indicatorPadding: EdgeInsets.fromLTRB(0, 0, 0, 7.5),

      tabs: [
        for (var name in displayNames ?? names)
          NtTab(
            name: name,
          ),
      ],
    );
  }
}
