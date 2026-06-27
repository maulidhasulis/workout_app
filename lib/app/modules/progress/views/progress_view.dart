import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  String selected = "Harian";
  List history = [];
  double totalCalories = 0;
  int totalRepetitions = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt("user_id") ?? 0;

    try {
      final response = await http.get(
        Uri.parse("http://192.168.48.21:5000/api/get-progress/$userId"),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          totalCalories = data["total_calories"].toDouble();
          totalRepetitions = data["total_repetitions"];
          history = data["history"];
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🔥 PILIHAN BUTTON FILTER PREMIUM (WHITE BG & BLUE TEXT AKTIF)
  Widget filterButton(String title) {
    bool isActive = selected == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selected = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.black.withOpacity(0.05),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // 🔥 GRAFIK LINE CHART DIKEMAS PREMIUM (MENGGUNAKAN WARNA BLUE ACCENT CURVE)
  Widget buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.black.withOpacity(0.04),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: [
              FlSpot(0, totalCalories == 0 ? 0 : totalCalories * 0.2),
              FlSpot(1, totalCalories == 0 ? 0 : totalCalories * 0.4),
              FlSpot(2, totalCalories == 0 ? 0 : totalCalories * 0.6),
              FlSpot(3, totalCalories == 0 ? 0 : totalCalories * 0.8),
              FlSpot(4, totalCalories),
            ],
            dotData: const FlDotData(show: false),
            color: Colors.blueAccent,
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blueAccent.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 RE-DESIGN INFO CARD PUTIH BERSIH DENGAN TEKS GELAP
  Widget infoCard(String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FF), // Soft Blue Background matching total
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // 🔥 CUSTOM APP BAR
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFF1E293B),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          "Progress Latihan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // 🔥 FILTER SELECTION ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        filterButton("Harian"),
                        filterButton("Bulanan"),
                        filterButton("Tahunan"),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 🔥 GRAFIK CONTAINER CARD PUTIH PREMIUM
                    Container(
                      width: double.infinity,
                      height: 220,
                      padding: const EdgeInsets.only(top: 24, right: 16, left: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: buildChart(),
                    ),

                    const SizedBox(height: 25),

                    // 🔥 STATS INDIKATOR INFO CARDS ROW
                    Row(
                      children: [
                        Expanded(
                          child: infoCard(
                            "Kalori",
                            "${totalCalories.toStringAsFixed(1)} kcal",
                            Icons.local_fire_department_rounded,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: infoCard(
                            "Repetisi", 
                            "$totalRepetitions",
                            Icons.fitness_center_rounded,
                            Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: infoCard(
                            "Target", 
                            selected,
                            Icons.flag_rounded,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // 🔥 HEADER RIWAYAT WORKOUT
                    const Text(
                      "Riwayat Workout",
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🔥 LIST VIEW RIWAYAT WORKOUT PREMIUM PUTIH
                    Expanded(
                      child: ListView.builder(
                        itemCount: history.length,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: (context, index) {
                          final item = history[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.fitness_center_rounded,
                                  color: Colors.blueAccent,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                item["exercise_name"],
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "${item["repetitions"]} repetisi  •  ${item["calories"]} kcal",
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}