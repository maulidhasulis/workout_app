import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key}); // Menambahkan constructor super key yang direkomendasikan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEBF5FF), // Soft Blue utama
              Color(0xFFD0E8FF), // Sedikit gradasi biru lebih dalam di bawah
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 ICON GYM DENGAN EFEK EMBEDDED CONTAINER PUTIH PREMIUM
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 72,
                  color: Colors.blueAccent,
                ),
              ),

              const SizedBox(height: 30),

              // 🔥 TITLE DENGAN WARNA DARK BLUE TEXT
              const Text(
                "WORKOUT PRO",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 8),

              // 🔥 SUBTITLE YANG BERSIH
              const Text(
                "Latihan Keras • Tetap Kuat",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 40),

              // 🔥 LOADING INDICATOR YANG SERASI (BLUE ACCENT)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}