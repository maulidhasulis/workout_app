import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/app/routes/app_pages.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  String goal = "Umum";
  String healthCondition = ""; // Tambahan variabel untuk menampung riwayat penyakit
  List<String> workouts = [];

  @override
  void initState() {
    super.initState();
    loadWorkout();
  }

  Future<void> loadWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    goal = prefs.getString("goal") ?? "Umum";
    // Ambil data kondisi kesehatan dari lokal storage, default-nya kosong (sehat)
    healthCondition = (prefs.getString("health_condition") ?? "").toLowerCase();

    // 1. SET DAFTAR GERAKAN AWAL SESUAI GOAL
    if (goal == "Pembentukan Otot") {
      workouts = ["Push Up", "Squat", "Sit Up", "Lunges", "Plank"];
    } else if (goal == "Penurunan Berat Badan") {
      workouts = ["Jumping Jack", "High Knee", "Squat Jump", "Fast Squat", "Sit Up"];
    } else {
      workouts = ["Standing Stretch", "Arm Stretch", "Side Stretch", "High Knee", "Jumping Jack", "Sit Up"];
    }

    // 2. LOGIKA ASSESSMENT (FILTERING PENYAKIT/KELUHAN)
    // Jika pengguna memiliki keluhan di lutut atau kaki bawah
    if (healthCondition.contains("lutut") || 
        healthCondition.contains("kaki") || 
        healthCondition.contains("sendi bawah")) {
      // Hapus gerakan yang terlalu membebani lutut secara ekstrem
      workouts.remove("Squat Jump");
      workouts.remove("Squat");
      workouts.remove("Lunges");
      workouts.remove("High Knee");
    }

    // Jika pengguna memiliki gangguan pernapasan, asma, atau jantung (butuh olahraga intensitas rendah)
    if (healthCondition.contains("asma") || 
        healthCondition.contains("napas") || 
        healthCondition.contains("jantung") ||
        healthCondition.contains("paru")) {
      // Hapus gerakan kardio berintensitas tinggi/loncat yang memicu sesak
      workouts.remove("Jumping Jack");
      workouts.remove("Squat Jump");
      workouts.remove("High Knee");
    }

    // Jika pengguna memiliki keluhan di bahu, tangan, atau vertigo (tidak bisa menunduk lama)
    if (healthCondition.contains("bahu") || 
        healthCondition.contains("tangan") || 
        healthCondition.contains("vertigo")) {
      workouts.remove("Push Up");
      workouts.remove("Plank");
    }

    // 3. JIKA SEMUA GERAKAN TERHAPUS KARENA KONDISI KESEHATAN, BERIKAN ALTERNATIF GERAKAN YANG SUPER RINGAN
    if (workouts.isEmpty) {
      workouts = ["Standing Stretch", "Arm Stretch", "Side Stretch"];
    }

    setState(() {});
  }

  // 💎 WIDGET UNTUK SUMMARY CARD GOAL
  Widget goalSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF95D6FF), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Target Latihan Kamu",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            goal,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          // Tambahan informasi kecil di kartu jika pengguna terdeteksi memiliki keluhan kesehatan
          if (healthCondition.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "⚠️ Penyesuaian medis: Gerakan disesuaikan dengan kondisi tubuh Anda.",
              style: TextStyle(
                color: Colors.red[900],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${workouts.length} Gerakan Siap Dimulai",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FF), // Match dengan MenuView background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // 💎 CUSTOM APP BAR (BACK BUTTON & TITLE)
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
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
                    "Workout Hari Ini",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 💎 TAMPILKAN SUMMARY CARD GOAL
              goalSummaryCard(),
              
              const SizedBox(height: 20),
              
              const Text(
                "Daftar Gerakan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // 💎 LIST VIEW GERAKAN WORKOUT
              Expanded(
                child: ListView.builder(
                  itemCount: workouts.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          workouts[index],
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: const Text(
                          "Ketuk untuk mulai deteksi AI",
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                        ),
                        onTap: () {
                          Get.toNamed(
                            Routes.CAMERA,
                            arguments: workouts[index],
                          );
                        },
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