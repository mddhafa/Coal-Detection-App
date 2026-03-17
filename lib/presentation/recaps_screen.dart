import 'package:coalmobile_app/core/appbarcustom.dart';
import 'package:coalmobile_app/presentation/recapscreen/daily_screen.dart';
import 'package:coalmobile_app/presentation/recapscreen/monthly_screen.dart';
import 'package:coalmobile_app/presentation/recapscreen/weekly_screen.dart';
import 'package:flutter/material.dart';

class RecapsMenuScreen extends StatelessWidget {
  const RecapsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Recaps"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyRecapScreen()),
                );
              },
              child: const Text("Daily Recap"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeeklyRecapScreen()),
                );
              },
              child: const Text("Weekly Recap"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MonthlyRecapScreen()),
                );
              },
              child: const Text("Monthly Recap"),
            ),
          ],
        ),
      ),
    );
  }
}
