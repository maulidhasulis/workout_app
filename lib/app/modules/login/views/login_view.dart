import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:workout_app/app/modules/menu/views/menu_view.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Get.snackbar(
        "Berhasil",
        "Login Google berhasil",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => const MenuView());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Gagal",
        "Email dan Password wajib diisi",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user!.reload();
      User? user = FirebaseAuth.instance.currentUser;

      if (!user!.emailVerified) {
        Get.snackbar(
          "Email Belum Diverifikasi",
          "Silakan cek inbox email terlebih dahulu",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final response = await http.post(
        Uri.parse("http://10.11.107.226:5000/api/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLogin", true);
        await prefs.setString("email", emailController.text);
        await prefs.setInt("user_id", data["user"]["id"]);
        await prefs.setString("name", data["user"]["name"]);
        await prefs.setString("goal", data["user"]["goal"]);
        
        // 🔥 SIMPAN HEALTH CONDITION KE SHAREDPREFERENCES DI SINI
        // default nilainya string kosong jika datanya null/tidak ada dari backend
        await prefs.setString("health_condition", data["user"]["health_condition"] ?? "");

        Get.offAll(() => const MenuView());
      } else {
        Get.snackbar("Gagal", data["message"]);
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Login Gagal",
        e.message ?? "",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 櫨 CUSTOM INPUT FIELD BERGAYA CLEAN WHITE (TEXT GELAP & SEGAR)
  Widget buildInputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(icon, color: Colors.blueAccent.withOpacity(0.7)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.03)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 64,
                    color: Colors.blueAccent,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Masuk untuk lanjut workout 💪",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 35),

                buildInputField(
                  hint: "Email",
                  icon: Icons.email_rounded,
                  controller: emailController,
                ),

                buildInputField(
                  hint: "Password",
                  icon: Icons.lock_rounded,
                  controller: passwordController,
                  obscureText: true,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      if (emailController.text.isEmpty) {
                        Get.snackbar(
                          "Email Kosong",
                          "Masukkan email terlebih dahulu",
                        );
                        return;
                      }

                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: emailController.text.trim(),
                        );

                        Get.snackbar(
                          "Berhasil",
                          "Link reset password sudah dikirim ke email",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        Get.snackbar("Error", e.toString());
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: handleLogin,
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
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: signInWithGoogle,
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_Logo.svg/24px-Google_\"G\"_Logo.svg.png',
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata_rounded, color: Colors.blueAccent, size: 28);
                      },
                    ),
                    label: const Text(
                      "Login dengan Google",
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
                  ),
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Text(
                    "Kembali",
                    style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}