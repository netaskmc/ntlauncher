import 'package:flutter/material.dart';

class NtTab extends StatelessWidget {
  const NtTab({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Tab(
      // padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        name.toUpperCase(),
        style: const TextStyle(
          letterSpacing: 2,
          // color: Color.fromRGBO(255, 44, 192, 1),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class NtTabs extends StatelessWidget {
  const NtTabs({
    super.key,
    required this.names,
    this.controller,
    this.displayNames,
  });

  final List<String> names;
  final List<String>? displayNames;
  final TabController? controller;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      // direction: Axis.horizontal,
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      controller: controller,
      indicatorColor: const Color.fromARGB(255, 255, 88, 205),
      labelColor: const Color.fromARGB(255, 255, 88, 205),
      unselectedLabelColor: const Color.fromRGBO(255, 255, 255, 0.5),
      splashFactory: NoSplash.splashFactory,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),

      isScrollable: true,
      tabAlignment: TabAlignment.start,

      indicator: UnderlineTabIndicator(
        borderSide: const BorderSide(
          width: 2,
          color: Color.fromRGBO(255, 44, 192, 1),
        ),
        borderRadius: BorderRadius.circular(10),
      ),

      indicatorPadding: const EdgeInsets.fromLTRB(0, 0, 0, 7.5),

      tabs: [
        for (var name in displayNames ?? names)
          NtTab(
            name: name,
          ),
      ],
    );
  }
}
