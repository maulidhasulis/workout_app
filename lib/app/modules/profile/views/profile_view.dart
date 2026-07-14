import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart'; // Tambah ini untuk identifikasi gambar

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? imageFile;
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();

  String selectedGoal = "Penurunan Berat Badan";
  final List<String> goals = [
    "Postur & Peregangan Tubuh",
    "Penurunan Berat Badan",
    "Pembentukan Otot",
  ];

  // Silakan sesuaikan baseUrl dengan IP server backend Anda (contoh: localhost / IP lokal laptop)
  final String baseUrl = "http://10.11.107.226:5000/api/profile/update"; 
  final int userId = 1; // Contoh id user log-in saat ini, sesuaikan dari Auth State Anda

  Future<void> pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
      // Opsional: Langsung upload setelah pilih gambar, atau tunggu klik "Simpan Perubahan"
    }
  }

  // 🔥 FUNGSI UNTUK KIRIM DATA KE BACKEND
  Future<void> updateProfileBackend({String? updateGoalOnly}) async {
    final connect = GetConnect();

    // Buat objek FormData untuk menampung teks & file multipart
    final formData = FormData({
      'goal': updateGoalOnly ?? selectedGoal,
      'current_password': currentPassword.text,
      'new_password': newPassword.text,
    });

    // Jika user memilih gambar baru, masukkan ke dalam formData
    if (imageFile != null && updateGoalOnly == null) {
      formData.files.add(MapEntry(
        'image',
        MultipartFile(
          imageFile!,
          filename: imageFile!.path.split('/').last,
          contentType: 'image/jpeg', // Sesuaikan tipe data gambar
        ),
      ));
    }

    // Tampilkan loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await connect.post('$baseUrl/$userId', formData);
      Get.back(); // Tutup loading dialog

      if (response.statusCode == 200) {
        // Kosongkan field password setelah berhasil
        currentPassword.clear();
        newPassword.clear();

        Get.snackbar(
          "Berhasil",
          response.body['message'] ?? "Profile berhasil diperbarui",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Gagal",
          response.body['message'] ?? "Terjadi kesalahan",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Tutup loading jika error
      Get.snackbar(
        "Error",
        "Tidak dapat terhubung ke server",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔥 CUSTOM APP BAR
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
                    "Profile",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // 🔥 FOTO PROFILE DENGAN AKSEN BIRU PREMIUM
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF1E293B),
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : null, // Note: Bagian ini nanti bisa diarahkan ke NetworkImage dari backend jika data sudah tersimpan
                      child: imageFile == null
                          ? const Icon(
                              Icons.person_rounded,
                              size: 65,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                "User",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Workout Enthusiast 💪",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 35),

              // 🔥 INFO PROFILE STATS CARDS
              profileCard(Icons.monitor_weight_rounded, "Berat Badan", "65 Kg"),
              profileCard(Icons.height_rounded, "Tinggi Badan", "170 Cm"),

              // 🔥 TUJUAN WORKOUT CARD DROPDOWN
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Tujuan Workout",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedGoal,
                      dropdownColor: Colors.white,
                      elevation: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.03)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      items: goals.map((goal) {
                        return DropdownMenuItem(
                          value: goal,
                          child: Text(goal),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedGoal = value;
                          });
                          // Panggil fungsi API khusus update goal secara realtime saat diganti
                          updateProfileBackend(updateGoalOnly: value);
                        }
                      },
                    ),
                  ],
                ),
              ),

              profileCard(Icons.local_fire_department_rounded,
                  "Kalori Terbakar", "1200 Kcal"),

              const SizedBox(height: 25),

              // 🔥 UPDATE PASSWORD SECTION LABEL
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Update Password",
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              passwordField("Password Lama", currentPassword),
              passwordField("Password Baru", newPassword),

              const SizedBox(height: 12),

              // 🔥 BUTTON SAVE CHANGES
              GestureDetector(
                onTap: () {
                  // Jalankan fungsi update ke backend jika diklik
                  updateProfileBackend();
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
                    "Simpan Perubahan",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

  // Component Card (Tetap sama, diperbaiki sedikit bug BoxShape logic pada shadow)
  Widget profileCard(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
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

  Widget passwordField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
}