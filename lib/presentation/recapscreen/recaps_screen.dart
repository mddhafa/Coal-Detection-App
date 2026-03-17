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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },

        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            RecapMenuCard(
              title: "Daily Recap",
              subtitle: "Ringkasan data harian",
              icon: Icons.calendar_today,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyRecapScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            RecapMenuCard(
              title: "Weekly Recap",
              subtitle: "Ringkasan data mingguan",
              icon: Icons.date_range,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeeklyRecapScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            RecapMenuCard(
              title: "Monthly Recap",
              subtitle: "Ringkasan data bulanan",
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MonthlyRecapScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RecapMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const RecapMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// ICON
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28),
            ),

            const SizedBox(width: 16),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),

            /// ARROW
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
