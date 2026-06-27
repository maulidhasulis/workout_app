import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BmiView extends StatefulWidget {
  const BmiView({super.key});

  @override
  State<BmiView> createState() => _BmiViewState();
}

class _BmiViewState extends State<BmiView> {

  final tinggiController = TextEditingController();
  final beratController = TextEditingController();

  double bmi = 0;
  String kategori = "";
  bool isMale = true;

  void hitungBMI() {
    double tinggi = double.parse(tinggiController.text) / 100;
    double berat = double.parse(beratController.text);

    // 🔥 HITUNG BMI
    double hasil = berat / (tinggi * tinggi);

    // 🔥 BULATKAN
    hasil = double.parse(hasil.toStringAsFixed(1));

    setState(() {
      bmi = hasil;

      // 🔥 LAKI-LAKI
      if (isMale) {
        if (hasil < 18.5) {
          kategori = "Berat Rendah";
        } else if (hasil < 23) {
          kategori = "Normal";
        } else if (hasil < 25) {
          kategori = "Berat Berlebih";
        } else {
          kategori = "Obesitas";
        }
      }
      // 🔥 PEREMPUAN
      else {
        if (hasil < 18) {
          kategori = "Berat Rendah";
        } else if (hasil < 22) {
          kategori = "Normal";
        } else if (hasil < 25) {
          kategori = "Berat Berlebih";
        } else {
          kategori = "Obesitas";
        }
      }
    });
  }

  // 🔥 CUSTOM INPUT FIELD BERGAYA PREMIUM (TEXT GELAP & BG PUTIH BERSIH)
  Widget inputField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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

  // 🔥 GENDER BUTTON MODERN DENGAN ANIMATED CONTAINER & SHADOW HALUS
  Widget genderButton(String title, bool value) {
    bool selected = isMale == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isMale = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? Colors.transparent : Colors.black.withOpacity(0.05),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.25),
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
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Color kategoriColor() {
    if (kategori == "Normal") {
      return Colors.green;
    } else if (kategori == "Berat Rendah") {
      return Colors.orange;
    } else {
      return const Color(0xFFF15A5A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FF), // Soft Blue Background matching total
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
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
                    "BMI Checker",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🔥 SECTION KATEGORI GENDER
              Row(
                children: [
                  genderButton("Laki-laki", true),
                  const SizedBox(width: 15),
                  genderButton("Perempuan", false),
                ],
              ),

              const SizedBox(height: 25),

              // 🔥 FORM INPUT TEXTFIELDS
              inputField("Tinggi Badan (cm)", tinggiController),
              inputField("Berat Badan (kg)", beratController),

              const SizedBox(height: 8),

              // 🔥 BUTTON HITUNG BMI PREMIUM BLUE
              GestureDetector(
                onTap: hitungBMI,
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
                    "Hitung BMI",
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

              // 🔥 RESULT DISPLAY CARD (JIKA BMI > 0)
              if (bmi > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                    ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isMale ? Icons.man_rounded : Icons.woman_rounded,
                          size: 54,
                          color: Colors.blueAccent,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "BMI untuk ${isMale ? "Laki-laki" : "Perempuan"}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        kategori,
                        style: TextStyle(
                          color: kategoriColor(),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ROW STATS INDIKATOR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                "Tinggi",
                                style: TextStyle(color: Colors.black45, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${tinggiController.text} cm",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 30, color: Colors.black12),
                          Column(
                            children: [
                              const Text(
                                "Berat",
                                style: TextStyle(color: Colors.black45, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${beratController.text} kg",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // 🔥 BMI SLIDER BAR
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(height: 12, color: Colors.green),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(height: 12, color: Colors.amber),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF15A5A),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            left: (bmi * 6).clamp(0.0, MediaQuery.of(context).size.width - 120),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                bmi.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Text(
                        kategori == "Normal"
                            ? "Pertahankan pola hidup sehat kamu 💪"
                            : "Utamakan hidup sehat dan perhatikan konsumsi harian",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),
                      
                      const Divider(color: Colors.black12, height: 1),
                      
                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              bmi = 0;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              "Cek Ulang",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}