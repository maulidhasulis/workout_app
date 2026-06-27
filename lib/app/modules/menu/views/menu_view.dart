import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workout_app/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  String userName = "User";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "User";
    });
  }

  // 🔥 GREETING
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Pagi! Siap mulai workout?";
    } else if (hour < 18) {
      return "Siang! Jangan lupa gerak hari ini";
    } else {
      return "Malam! Masih sempat latihan ringan 💪";
    }
  }

  // 🔥 QUOTES
  String getQuote() {
    final quotes = [
      "Konsisten sedikit tiap hari lebih baik daripada berhenti total.",
      "Progress kecil tetap progress.",
      "Latihan hari ini, hasil besok.",
      "Jangan nunggu semangat, mulai dulu aja.",
    ];

    return quotes[DateTime.now().second % quotes.length];
  }

  // 🔥 WIDGET MENU ITEM (FIXED OVERFLOW & RESPONSIVE GRID)
  Widget menuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(
          12,
        ), // Dioptimalkan dari 14 agar lebih aman di HP kecil
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Mengatur jarak atas & bawah secara fleksibel tanpa Spacer
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blueAccent,
                    size: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ), // Menggantikan Spacer() yang memicu overflow
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryCard() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.PROGRESS);
      },
      child: Container(
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
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Progress Hari Ini",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      const Text(
                        "0 ",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Kalori",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Terbakar",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Lihat detail progres ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 90,
                child: CustomPaint(painter: CurvePainter()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFEBF5FF,
      ), // Soft Blue Background sesuai gambar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // 🔥 HEADER PROFILE (Menggunakan CircleAvatar Default Tanpa Foto Url)
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.PROFILE);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFF1E293B),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, $userName 👋",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          getGreeting(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 🔥 QUOTES
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.format_quote,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        getQuote(),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              summaryCard(),

              const SizedBox(height: 10),

              // 🔥 GRID VIEW MENU UTAMA (2 Kolom Aman Bebas Overflow)
              Expanded(
                child: GridView.builder(
                  itemCount: 4,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    // Menyesuaikan rasio grid secara dinamis berdasarkan tinggi layar HP
                    childAspectRatio: MediaQuery.of(context).size.height > 700
                        ? 1.15
                        : 1.0,
                  ),
                  itemBuilder: (context, index) {
                    List<Widget> items = [
                      menuItem(
                        icon: Icons.fitness_center,
                        iconColor: Colors.blueAccent,
                        iconBgColor: const Color(0xFFE8F2FF),
                        title: "Workout",
                        subtitle: "Mulai latihan & hitung repetisi",
                        onTap: () => Get.toNamed(Routes.WORKOUT),
                      ),
                      menuItem(
                        icon: Icons.access_time_filled,
                        iconColor: Colors.purple,
                        iconBgColor: const Color(0xFFF3E8FF),
                        title: "Intermittent Fasting",
                        subtitle: "Atur jadwal puasa",
                        onTap: () => Get.toNamed(Routes.FASTING),
                      ),
                      menuItem(
                        icon: Icons.restaurant,
                        iconColor: Colors.green,
                        iconBgColor: const Color(0xFFE8F5E9),
                        title: "Pola Makan",
                        subtitle: "Atur kalori & makanan",
                        onTap: () => Get.toNamed(Routes.POLAMAKAN),
                      ),
                      menuItem(
                        icon: Icons.monitor_weight,
                        iconColor: Colors.orange,
                        iconBgColor: const Color(0xFFFFF3E0),
                        title: "BMI",
                        subtitle: "Cek kondisi tubuh kamu",
                        onTap: () => Get.toNamed(Routes.BMI),
                      ),
                    ];
                    return items[index];
                  },
                ),
              ),

              // 🔥 LOGOUT BUTTON (Merah Solid Premium)
              GestureDetector(
                onTap: () async {
                  // 1. Tampilkan loading dialog instan agar user tidak klik berkali-kali
                  Get.dialog(
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    barrierDismissible: false,
                  );

                  try {
                    // 2. Bersihkan SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();

                    // 3. Sign out dari Firebase Auth
                    await FirebaseAuth.instance.signOut();

                    // 4. Sign out dari Google Sign In (jika sebelumnya login pakai Google)
                    final GoogleSignIn googleSignIn = GoogleSignIn();
                    if (await googleSignIn.isSignedIn()) {
                      await googleSignIn.signOut();
                      await googleSignIn
                          .disconnect(); // Memaksa putus sesi agar bisa ganti akun nanti
                    }

                    // 5. Tutup loading dialog, lalu tendang ke halaman LOGIN dan hapus semua history page sebelumnya
                    Get.back();
                    Get.offAllNamed(Routes.LOGIN);
                  } catch (e) {
                    Get.back(); // Tutup loading jika gagal
                    Get.snackbar(
                      "Gagal Logout",
                      "Terjadi kesalahan saat keluar: $e",
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  margin: const EdgeInsets.only(bottom: 15, top: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF15A5A),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF15A5A).withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      // Pastikan const di sini tidak bentrok dengan widget dinamis jika ada
                      Icon(Icons.logout, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    var path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.1,
      size.width,
      size.height * 0.2,
    );

    canvas.drawPath(path, paint);

    var dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width, size.height * 0.2), 4, dotPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
