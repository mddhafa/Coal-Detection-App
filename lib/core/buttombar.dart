import 'package:flutter/material.dart';

class AppBottomBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomBar({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    String route = "/";

    switch (index) {
      case 0:
        route = "/home";
        break;
      case 1:
        route = "/monitoring";
        break;
      case 2:
        route = "/recaps";
        break;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(
          icon: Icon(Icons.videocam),
          label: "Monitoring",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: "Laporan",
        ),
      ],

      onTap: (index) => _navigate(context, index),
    );
  }
}
