import 'package:coalmobile_app/core/appbarcustom.dart';
import 'package:coalmobile_app/presentation/recaps/bloc/recaps_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/service_pdf.dart';

class WeeklyRecapScreen extends StatefulWidget {
  const WeeklyRecapScreen({super.key});

  @override
  State<WeeklyRecapScreen> createState() => _WeeklyRecapScreenState();
}

class _WeeklyRecapScreenState extends State<WeeklyRecapScreen> {
  @override
  void initState() {
    super.initState();

    /// load data saat screen dibuka
    context.read<RecapsBloc>().add(GetWeeklyRecap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Weekly Recap"),

      // appBar: AppBar(title: const Text("Weekly Recap"), centerTitle: true),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3A3A3A),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context.read<RecapsBloc>().add(GenerateWeeklyRecap());
              },
              child: const Text("Generate Weekly Recap"),
            ),
          ),

          Expanded(
            child: BlocBuilder<RecapsBloc, RecapsState>(
              builder: (context, state) {
                if (state is RecapsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RecapsFailure) {
                  return Center(child: Text(state.error));
                }

                if (state is RecapsLoaded) {
                  final recaps = state.data;

                  if (recaps.isEmpty) {
                    return const Center(child: Text("No recap data available"));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<RecapsBloc>().add(GetWeeklyRecap());
                    },

                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: recaps.length,

                      itemBuilder: (context, index) {
                        final recap = recaps[index];

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),

                          margin: const EdgeInsets.only(bottom: 12),

                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),

                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Week ${recap.week} selected"),
                                ),
                              );
                            },

                            child: Padding(
                              padding: const EdgeInsets.all(16),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_month,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 10),

                                          Text(
                                            "Week ${recap.week} - ${recap.year}",
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      IconButton(
                                        icon: const Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          PdfService.generateRecapPdf([recap]);
                                        },
                                      ),
                                    ],
                                  ),

                                  const Divider(height: 20),

                                  /// DATA ROW
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _statItem(
                                        "Coal",
                                        recap.total_coal.toString(),
                                        Icons.local_fire_department,
                                        Colors.orange,
                                      ),

                                      _statItem(
                                        "Gangue",
                                        recap.total_gangue.toString(),
                                        Icons.category,
                                        Colors.blue,
                                      ),

                                      _statItem(
                                        "Objects",
                                        recap.total_objects.toString(),
                                        Icons.analytics,
                                        Colors.green,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(title),
      ],
    );
  }
}
