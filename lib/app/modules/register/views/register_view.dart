import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final confirmPassword = TextEditingController();
  final nama = TextEditingController();
  final umur = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final tinggi = TextEditingController();
  final berat = TextEditingController();

  String? selectedGoal;
  String? selectedGender;
  String? selectedActivity;

  final List<String> goals = [
    "Postur & Peregangan Tubuh",
    "Penurunan Berat Badan",
    "Pembentukan Otot",
  ];

  final List<String> genders = ["Laki-Laki", "Perempuan"];

  final List<String> activities = [
    "Jarang Bergerak",
    "Aktif Ringan",
    "Aktif Sedang",
    "Aktif Berat",
  ];

  // 🔥 CUSTOM INPUT FIELD BERGAYA CLEAN WHITE & PREMIUM TEXT
  Widget inputField(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.03)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  // 🔥 SECTION TITLE YANG SEGAR DAN TEGAS
  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 14, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // 🔥 KARTU KONTAINER BAGIAN DENGAN SOFT SHADOW ELEGAN
  Widget cardSection(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // 🔥 GOAL DROPDOWN DENGAN MENUTUP LATAR BELAKANG PUTIH BERSIH
  Widget goalDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGoal,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        hintText: "Pilih Tujuan Workout",
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.03)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      items: goals.map((goal) {
        return DropdownMenuItem(value: goal, child: Text(goal));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedGoal = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FF), // Soft Blue Background matching total
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 25),

              // 🔥 LOGO & HEADER PREMIUM
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.fitness_center_rounded, size: 48, color: Colors.blueAccent),
              ),

              const SizedBox(height: 16),

              const Text(
                "Buat Akun Workout",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Lengkapi profil kebugaran untuk memulai",
                style: TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 25),

              // 🔹 PERSONAL INFO
              sectionTitle("INFORMASI PRIBADI"),
              cardSection([
                inputField("Nama Lengkap", nama),
                inputField("Umur", umur, isNumber: true),

                DropdownButtonFormField<String>(
                  value: selectedGender,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Pilih Gender",
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.03)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  items: genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                inputField("Email", email),
                inputField("Password", password, isPassword: true),
                inputField(
                  "Konfirmasi Password",
                  confirmPassword,
                  isPassword: true,
                ),
              ]),

              // 🔹 BODY INFO
              sectionTitle("DATA TUBUH"),
              cardSection([
                inputField("Tinggi Badan (cm)", tinggi, isNumber: true),
                inputField("Berat Badan (kg)", berat, isNumber: true),
              ]),

              // 🔹 ACTIVITY
              sectionTitle("AKTIVITAS HARIAN"),
              cardSection([
                DropdownButtonFormField<String>(
                  value: selectedActivity,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Pilih Aktivitas Harian",
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.03)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  items: activities.map((activity) {
                    return DropdownMenuItem(
                      value: activity,
                      child: Text(activity),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedActivity = value;
                    });
                  },
                ),
              ]),

              // 🔹 GOAL
              sectionTitle("TUJUAN WORKOUT"),
              cardSection([goalDropdown()]),

              const SizedBox(height: 25),

              // 🔥 BUTTON REGISTER UTAMA (BLUE ACCENT PREMIUM)
              GestureDetector(
                onTap: () async {
                  if (nama.text.isEmpty ||
                      umur.text.isEmpty ||
                      email.text.isEmpty ||
                      password.text.isEmpty ||
                      tinggi.text.isEmpty ||
                      berat.text.isEmpty ||
                      selectedGender == null ||
                      selectedActivity == null ||
                      selectedGoal == null) {
                    Get.snackbar(
                      "Data Belum Lengkap",
                      "Mohon isi semua data terlebih dahulu",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );

                    return;
                  }
                  if (!GetUtils.isEmail(email.text.trim())) {
                    Get.snackbar(
                      "Email Tidak Valid",
                      "Masukkan alamat email yang benar",
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );

                    return;
                  }

                  if (password.text.length < 8) {
                    Get.snackbar(
                      "Password Terlalu Pendek",
                      "Password minimal 8 karakter",
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );

                    return;
                  }

                  if (password.text != confirmPassword.text) {
                    Get.snackbar(
                      "Password Tidak Cocok",
                      "Konfirmasi password harus sama",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );

                    return;
                  }
                  if (int.parse(umur.text) < 10) {
                    Get.snackbar(
                      "Umur Tidak Valid",
                      "Umur minimal 10 tahun",
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );

                    return;
                  }
                  if (double.parse(tinggi.text) < 100) {
                    Get.snackbar(
                      "Tinggi Badan Tidak Valid",
                      "Masukkan tinggi badan yang benar",
                    );

                    return;
                  }
                  if (double.parse(berat.text) < 20) {
                    Get.snackbar(
                      "Berat Badan Tidak Valid",
                      "Masukkan berat badan yang benar",
                    );

                    return;
                  }

                  try {
                    UserCredential userCredential = await FirebaseAuth
                        .instance
                        .createUserWithEmailAndPassword(
                          email: email.text.trim(),
                          password: password.text.trim(),
                        );

                    await userCredential.user!.sendEmailVerification();
                  } on FirebaseAuthException catch (e) {
                    Get.snackbar(
                      "Registrasi Gagal",
                      e.message ?? "Terjadi kesalahan",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );

                    return;
                  }

                  final response = await http.post(
                    Uri.parse("http://192.168.48.21:5000/api/register"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "name": nama.text,
                      "email": email.text,
                      "password": password.text,
                      "age": int.parse(umur.text),
                      "gender": selectedGender,
                      "height": double.parse(tinggi.text),
                      "weight": double.parse(berat.text),
                      "activity_level": selectedActivity,
                      "goal": selectedGoal,
                    }),
                  );

                  final data = jsonDecode(response.body);

                  if (data["success"] == true) {
                    Get.defaultDialog(
                      title: "Registrasi Berhasil 🎉",
                      middleText:
                          "Registrasi berhasil. Silakan cek email Anda untuk verifikasi akun sebelum login.",
                      textConfirm: "Login Sekarang",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.offAllNamed('/login');
                      },
                    );

                    Future.delayed(const Duration(seconds: 5), () {
                      if (Get.isDialogOpen ?? false) {
                        Get.back();
                      }

                      Get.offAllNamed('/login');
                    });
                  } else {
                    Get.snackbar("Gagal", data["message"]);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Mulai Perjalanan Fitness 💪",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 🔥 TOMBOL GOOGLE REGISTRATION UTAMA (WHITE BOX OUTLINE)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_Logo.svg/24px-Google_\"G\"_Logo.svg.png',
                    height: 18,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.login_rounded, color: Colors.blueAccent, size: 20);
                    },
                  ),
                  label: const Text(
                    "Daftar Dengan Google",
                    style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black.withOpacity(0.05)),
                    elevation: 0,
                    shadowColor: Colors.black.withOpacity(0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    // 1. Validasi dulu apakah data tubuh & tujuan sudah diisi atau belum
                    if (umur.text.isEmpty ||
                        tinggi.text.isEmpty ||
                        berat.text.isEmpty ||
                        selectedGender == null ||
                        selectedActivity == null ||
                        selectedGoal == null) {
                      Get.snackbar(
                        "Data Belum Lengkap",
                        "Mohon isi data fisik (Umur, Gender, TB, BB, Aktivitas, Tujuan) terlebih dahulu sebelum mendaftar dengan Google.",
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    try {
                      // 2. Proses Google Sign-In
                      final GoogleSignIn googleSignIn = GoogleSignIn();
                      final GoogleSignInAccount? account = await googleSignIn.signIn();

                      if (account == null) {
                        return;
                      }

                      // 3. Hubungkan ke Firebase Auth
                      final GoogleSignInAuthentication googleAuth = await account.authentication;
                      final AuthCredential credential = GoogleAuthProvider.credential(
                        accessToken: googleAuth.accessToken,
                        idToken: googleAuth.idToken,
                      );

                      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
                      User? firebaseUser = userCredential.user;

                      if (firebaseUser != null) {
                        // 4. Kirim gabungan data Google + Data Form Fisik ke Backend Anda
                        final response = await http.post(
                          Uri.parse("http://192.168.48.21:5000/api/register"),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "name": firebaseUser.displayName ?? account.displayName ?? "User Google",
                            "email": firebaseUser.email ?? account.email,
                            "password": "", 
                            "age": int.parse(umur.text),
                            "gender": selectedGender,
                            "height": double.parse(tinggi.text),
                            "weight": double.parse(berat.text),
                            "activity_level": selectedActivity,
                            "goal": selectedGoal,
                          }),
                        );

                        final data = jsonDecode(response.body);

                        // 5. Handle respon dari backend
                        if (data["success"] == true) {
                          Get.defaultDialog(
                            title: "Registrasi Berhasil 🎉",
                            middleText: "Akun Google Anda berhasil terdaftar dengan profil kebugaran Anda.",
                            textConfirm: "Masuk ke Dashboard",
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              Get.offAllNamed('/home'); 
                            },
                          );

                          Future.delayed(const Duration(seconds: 3), () {
                            if (Get.isDialogOpen ?? false) {
                              Get.back();
                            }
                            Get.offAllNamed('/home');
                          });
                        } else {
                          Get.snackbar(
                            "Gagal Sinkronisasi",
                            data["message"] ?? "Gagal menyimpan data ke server.",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      }
                    } catch (error) {
                      Get.snackbar(
                        "Login Gagal",
                        "Terjadi kesalahan saat mendaftar dengan Google: $error",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 25),

              // TOMBOL KEMBALI
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Text(
                  "Kembali",
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}