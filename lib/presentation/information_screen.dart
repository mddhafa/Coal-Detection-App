import 'package:coalmobile_app/core/appbarcustom.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  String appName = "Coal Detection App";
  String version = "0.1";
  String buildNumber = "1";
  String deviceName = "-";
  String osVersion = "-";
  String cctv = "V380 Pro Y06";
  String edge = "Raspberry Pi 4";

  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  Future<void> loadInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    String dName = "-";
    String os = "-";

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      dName = "${android.brand} ${android.model}";
      os = "Android ${android.version.release}";
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      dName = ios.utsname.machine;
      os = "iOS ${ios.systemVersion}";
    }

    setState(() {
      appName = packageInfo.appName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      deviceName = dName;
      osVersion = os;
    });
  }

  Widget buildCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.grey[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: const CustomAppBar(title: "Information"),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Application",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            buildCard("App Name", appName, Icons.apps),
            buildCard("Version", "$version ($buildNumber)", Icons.info),

            const SizedBox(height: 20),

            const Text("Device", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            buildCard("Device Name", deviceName, Icons.phone_android),
            buildCard("OS Version", osVersion, Icons.android),
            buildCard("Edge Computing Model", edge, Icons.computer),
            buildCard("CCTV Model", cctv, Icons.videocam),

            const SizedBox(height: 20),

            const Text(
              "Developer",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            buildCard("Developed By", "Muhammad Dhafa", Icons.person),
          ],
        ),
      ),
    );
  }
}
