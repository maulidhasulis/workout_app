import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PolamakanView extends StatefulWidget {
  const PolamakanView({super.key});

  @override
  State<PolamakanView> createState() => _PolamakanViewState();
}

class _PolamakanViewState extends State<PolamakanView> {

  final TextEditingController beratController = TextEditingController();
  final TextEditingController tinggiController = TextEditingController();
  final TextEditingController umurController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String selectedGoal = "Defisit Kalori";
  String searchQuery = "";

  double kaloriHarian = 0;
  double targetKalori = 0;
  int kaloriMakan = 0;

  List<Map<String, dynamic>> makananDipilih = [];

  List<Map<String, dynamic>> makanan = [
    // PROTEIN
    {"nama": "Dada Ayam", "kalori": 165},
    {"nama": "Telur", "kalori": 78},
    {"nama": "Ikan Salmon", "kalori": 208},
    {"nama": "Daging Sapi Lean", "kalori": 250},
    {"nama": "Tahu", "kalori": 80},
    {"nama": "Tempe", "kalori": 192},
    {"nama": "Greek Yogurt", "kalori": 100},
    {"nama": "Susu Protein", "kalori": 120},
    // KARBO
    {"nama": "Nasi Putih", "kalori": 175},
    {"nama": "Oatmeal", "kalori": 150},
    {"nama": "Kentang Rebus", "kalori": 110},
    {"nama": "Ubi", "kalori": 120},
    {"nama": "Roti Gandum", "kalori": 90},
    // BUAH
    {"nama": "Pisang", "kalori": 90},
    {"nama": "Alpukat", "kalori": 160},
    {"nama": "Apel", "kalori": 95},
    // SAYUR
    {"nama": "Brokoli", "kalori": 55},
    {"nama": "Bayam", "kalori": 23},
    {"nama": "Wortel", "kalori": 41},
    {"nama": "Timun", "kalori": 16},
  ];

  List<Map<String, dynamic>> get filteredMakanan {
    return makanan.where((item) {
      return item["nama"]
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }

  // =========================
  // HITUNG KALORI
  // =========================
  void hitungKalori() {
    double berat = double.tryParse(beratController.text) ?? 0;
    double tinggi = double.tryParse(tinggiController.text) ?? 0;
    double umur = double.tryParse(umurController.text) ?? 0;

    // =====================
    // BMR
    // =====================
    double bmr = 10 * berat + 6.25 * tinggi - 5 * umur + 5;

    // =====================
    // TDEE
    // =====================
    double hasilKalori = bmr * 1.3;
    double target = 0;

    // =====================
    // DEFISIT
    // =====================
    if (selectedGoal == "Defisit Kalori") {
      target = hasilKalori - 500;
    }
    // =====================
    // MAINTAIN
    // =====================
    else if (selectedGoal == "Maintain") {
      target = hasilKalori;
    }
    // =====================
    // BULKING
    // =====================
    else if (selectedGoal == "Bulking") {
      target = hasilKalori + 300;
    }

    setState(() {
      kaloriHarian = hasilKalori;
      targetKalori = target;
    });

    Get.snackbar(
      "Berhasil 🔥",
      "$selectedGoal berhasil dihitung",
      backgroundColor: selectedGoal == "Defisit Kalori"
          ? Colors.orange
          : selectedGoal == "Maintain"
              ? Colors.blue
              : Colors.green,
      colorText: Colors.white,
    );
  }

  // =========================
  // TAMBAH MAKANAN
  // =========================
  void tambahKalori(Map<String, dynamic> item) {
    setState(() {
      kaloriMakan += item["kalori"] as int;

      int index = makananDipilih.indexWhere(
        (element) => element["nama"] == item["nama"],
      );

      if (index != -1) {
        makananDipilih[index]["jumlah"] += 1;
      } else {
        makananDipilih.add({
          "nama": item["nama"],
          "kalori": item["kalori"],
          "jumlah": 1,
        });
      }
    });

    Get.snackbar(
      "Ditambahkan 🍽️",
      "${item["nama"]} berhasil ditambahkan",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // =========================
  // HAPUS MAKANAN
  // =========================
  void hapusKalori(int index) {
    setState(() {
      kaloriMakan -= makananDipilih[index]["kalori"] as int;

      if (kaloriMakan < 0) {
        kaloriMakan = 0;
      }

      if (makananDipilih[index]["jumlah"] > 1) {
        makananDipilih[index]["jumlah"] -= 1;
      } else {
        makananDipilih.removeAt(index);
      }
    });
  }

  // =========================
  // RESET
  // =========================
  void resetMakanan() {
    setState(() {
      kaloriMakan = 0;
      makananDipilih.clear();
    });
  }

  // 🔥 CUSTOM INPUT FIELD BERGAYA CLEAN WHITE & TEXT GELAP
  Widget inputField(String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
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

  // 🔥 GOAL BUTTON ADAPTIF PREMIUM
  Widget goalButton(String title) {
    bool selected = selectedGoal == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedGoal = title;
          });

          // AUTO HITUNG ULANG
          if (beratController.text.isNotEmpty &&
              tinggiController.text.isNotEmpty &&
              umurController.text.isNotEmpty) {
            hitungKalori();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? selectedGoal == "Defisit Kalori"
                    ? Colors.orange
                    : selectedGoal == "Maintain"
                        ? Colors.blue
                        : Colors.green
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? Colors.transparent : Colors.black.withOpacity(0.05),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: selectedGoal == "Defisit Kalori"
                          ? Colors.orange.withOpacity(0.3)
                          : selectedGoal == "Maintain"
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.green.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 INFO CARD ELEGAN CERAH DENGAN SAKLAR WARNA ICON NYAMAN DI MATA
  Widget infoCard(String title, String value, IconData icon, Color iconColor) {
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
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sisaKalori = targetKalori - kaloriMakan;

    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FF), // Soft Blue Background matching total
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    "Pola Makan & Gym",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "Hitung Kalori Harian",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Atur pola makan sesuai tujuan tubuh kamu",
                style: TextStyle(color: Colors.black45, fontSize: 14),
              ),

              const SizedBox(height: 25),

              // Form Input Fields
              inputField("Berat Badan (kg)", beratController),
              inputField("Tinggi Badan (cm)", tinggiController),
              inputField("Umur", umurController),

              const SizedBox(height: 5),

              // Row Goal Options
              Row(
                children: [
                  goalButton("Defisit Kalori"),
                  const SizedBox(width: 10),
                  goalButton("Maintain"),
                  const SizedBox(width: 10),
                  goalButton("Bulking"),
                ],
              ),

              const SizedBox(height: 20),

              // Button Hitung
              GestureDetector(
                onTap: hitungKalori,
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
                    "Hitung Kalori",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Monitor Output Cards
              infoCard("Kebutuhan Kalori Harian", "${kaloriHarian.toStringAsFixed(0)} kcal", Icons.local_fire_department, Colors.orange),
              infoCard("Target Kalori", "${targetKalori.toStringAsFixed(0)} kcal", Icons.flag_rounded, Colors.blueAccent),
              infoCard("Kalori Masuk", "$kaloriMakan kcal", Icons.restaurant_rounded, Colors.green),
              infoCard("Sisa Kalori", sisaKalori <= 0 ? "0 kcal" : "${sisaKalori.toStringAsFixed(0)} kcal", Icons.monitor_heart_rounded, Colors.redAccent),

              // Dinamic Insight Description Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 25, top: 8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.12)),
                ),
                child: Text(
                  targetKalori <= 0
                      ? "Hitung kalori harian terlebih dahulu 🔥"
                      : selectedGoal == "Bulking"
                          ? kaloriMakan < targetKalori
                              ? "Kamu masih kurang ${(targetKalori - kaloriMakan).toStringAsFixed(0)} kcal untuk mencapai target bulking hari ini 💪"
                              : "Kalori bulking kamu sudah tercapai 🔥"
                          : selectedGoal == "Maintain"
                              ? kaloriMakan < targetKalori
                                  ? "Kamu masih bisa makan ${(targetKalori - kaloriMakan).toStringAsFixed(0)} kcal lagi agar tetap maintain ⚖️"
                                  : "Kalori maintain sudah tercapai ✅"
                              : kaloriMakan < targetKalori
                                  ? "Kamu masih punya sisa ${(targetKalori - kaloriMakan).toStringAsFixed(0)} kcal untuk tetap defisit 🔥"
                                  : "Kalori sudah melebihi target defisit ⚠️",
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),

              // 🔥 SEKSI LIST MAKANAN DIPILIH (JIKA TIDAK KOSONG)
              if (makananDipilih.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Makanan Dipilih",
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: resetMakanan,
                      style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                      child: const Text("Reset", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  makananDipilih.length,
                  (index) {
                    final item = makananDipilih[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.restaurant_menu, color: Colors.orange, size: 20),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["nama"],
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "${item["kalori"]} kcal / porsi",
                                      style: const TextStyle(color: Colors.black45, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              // Tombol Tambah Porsi (+)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    item["jumlah"]++;
                                    kaloriMakan += item["kalori"] as int;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.add, color: Colors.green, size: 18),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "${item["jumlah"]}",
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Tombol Kurang Porsi (-)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    item["jumlah"]--;
                                    kaloriMakan -= item["kalori"] as int;
                                    if (kaloriMakan < 0) kaloriMakan = 0;
                                    if (item["jumlah"] <= 0) {
                                      makananDipilih.removeAt(index);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.remove, color: Colors.redAccent, size: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Subtotal: ${item["kalori"] * item["jumlah"]} kcal",
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              const Text(
                "Rekomendasi Makanan Gym",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Search Box Makanan
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: "Cari makanan...",
                    hintStyle: const TextStyle(color: Colors.black38),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.black38),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
              ),

              // List Item Rekomendasi Makanan
              ...filteredMakanan.map(
                (item) {
                  return GestureDetector(
                    onTap: () => tambahKalori(item),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black.withOpacity(0.02)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.fastfood_rounded, color: Colors.green, size: 20),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["nama"],
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${item["kalori"]} kcal",
                                  style: const TextStyle(color: Colors.black45, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.add_circle_rounded, color: Colors.green, size: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}