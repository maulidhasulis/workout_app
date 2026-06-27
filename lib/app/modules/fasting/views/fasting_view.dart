import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FastingView extends StatefulWidget {
  const FastingView({super.key});

  @override
  State<FastingView> createState() => _FastingViewState();
}

class _FastingViewState extends State<FastingView> {

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }
  final FlutterTts flutterTts = FlutterTts();

  Future<void> requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String selectedFasting = "16:8";

  bool isFasting = false;
  bool isEating = false;

  int fastingHours = 16;
  int eatingHours = 8;

  Duration remaining = Duration.zero;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    // 🔥 REQUEST IZIN NOTIF
    requestNotificationPermission();

    const AndroidInitializationSettings
        initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings
        initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> showNotification(
    String title,
    String body,
  ) async {
    const AndroidNotificationDetails
        androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'fasting_channel',
      'Fasting Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails
        platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails:
          platformChannelSpecifics,
    );
  }

  void selectFasting(String value) {
    // 🔥 TIDAK BISA GANTI SAAT TIMER JALAN
    if (isFasting || isEating) return;

    setState(() {
      selectedFasting = value;

      if (value == "16:8") {
        fastingHours = 16;
        eatingHours = 8;
      }

      if (value == "14:10") {
        fastingHours = 14;
        eatingHours = 10;
      }

      if (value == "12:12") {
        fastingHours = 12;
        eatingHours = 12;
      }
    });
  }

  void startFasting() {
    setState(() {
      isFasting = true;
      isEating = false;

      remaining = Duration(
        hours: fastingHours,
      );
    });

    startTimer();

    Get.snackbar(
      "Puasa Dimulai 🔥",
      "Waktunya mulai intermittent fasting",
      backgroundColor: const Color(0xFFF15A5A),
      colorText: Colors.white,
    );

    showNotification(
      "Puasa Dimulai 🔥",
      "Waktunya mulai intermittent fasting",
    );
    
    speak("Puasa Dimulai. Waktunya mulai intermittent fasting");
  }

  void startEating() {
    setState(() {
      isEating = true;
      isFasting = false;

      remaining = Duration(
        hours: eatingHours,
      );
    });

    startTimer();

    Get.snackbar(
      "Waktunya Makan 🍽️",
      "Jangan lupa makan sehat ya",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    showNotification(
      "Waktunya Makan 🍽️",
      "Jangan lupa makan sehat ya",
    );

    speak("Waktunya Makan. Jangan lupa makan sehat ya");
  }

  // 🔥 STOP FASTING
  void stopFasting() {
    timer?.cancel();

    setState(() {
      isFasting = false;
      isEating = false;
      remaining = Duration.zero;
    });

    Get.snackbar(
      "Puasa Dihentikan",
      "Intermittent fasting berhasil dihentikan",
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
    );

    showNotification(
      "Puasa Dibatalkan ❌",
      "Intermittent fasting telah dihentikan",
    );

    speak("Puasa Dibatalkan. Intermittent fasting telah dihentikan");
  }

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remaining.inSeconds > 0) {
          setState(() {
            remaining =
                remaining - const Duration(seconds: 1);
          });
        } else {
          timer.cancel();

          if (isFasting) {
            Get.snackbar(
              "Puasa Selesai 🎉",
              "Sekarang waktunya makan",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );

            showNotification(
              "Puasa Selesai 🎉",
              "Sekarang waktunya makan",
            );

            speak("Puasa Selesai. Sekarang waktunya makan");

          } else if (isEating) {
            Get.snackbar(
              "Waktu Puasa 🔥",
              "Yuk lanjut puasa lagi",
              backgroundColor: const Color(0xFFF15A5A),
              colorText: Colors.white,
            );

            showNotification(
              "Waktu Puasa 🔥",
              "Yuk lanjut puasa lagi",
            );

            speak("Waktu Puasa. Yuk lanjut puasa lagi");
          }
        }
      },
    );
  }

  String formatDuration(Duration d) {
    String hours =
        d.inHours.toString().padLeft(2, '0');

    String minutes =
        (d.inMinutes % 60)
            .toString()
            .padLeft(2, '0');

    String seconds =
        (d.inSeconds % 60)
            .toString()
            .padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }

  Widget fastingButton(String value) {
    bool selected = selectedFasting == value;
    bool locked = isFasting || isEating;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          selectFasting(value);
        },
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 250,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: locked && selected
                ? Border.all(
                    color: Colors.blueAccent.shade700,
                    width: 2,
                  )
                : Border.all(
                    color: Colors.black.withOpacity(0.05),
                  ),
            boxShadow: [
              BoxShadow(
                color: selected 
                    ? Colors.blueAccent.withOpacity(0.2) 
                    : Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (locked && selected)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    "Dipilih",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget actionButton(
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FF), // Soft Blue Background sesuai MenuView
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 🔥 CUSTOM APP BAR (BACK BUTTON & TITLE)
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
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
                    "Intermittent Fasting",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 🔥 BIG CENTRAL TIMER VISUAL
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFasting
                          ? const Color(0xFFFFEAEA)
                          : isEating
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFEAF2FF),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: isFasting
                          ? const Color(0xFFF15A5A)
                          : isEating
                              ? Colors.green
                              : Colors.blueAccent,
                      size: 64,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 🔥 SECTION METODE TITLE
              const Text(
                "Pilih Metode IF",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Tentukan durasi puasa yang sesuai kemampuanmu",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              // 🔥 ROW PILIHAN BUTTONS
              Row(
                children: [
                  fastingButton("16:8"),
                  const SizedBox(width: 12),
                  fastingButton("14:10"),
                  const SizedBox(width: 12),
                  fastingButton("12:12"),
                ],
              ),

              const SizedBox(height: 25),

              // 🔥 CARD UTAMA MONITOR TIMER
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
                    Text(
                      isFasting
                          ? "SEDANG PUASA 🔥"
                          : isEating
                              ? "WAKTU MAKAN 🍽️"
                              : "BELUM DIMULAI",
                      style: TextStyle(
                        color: isFasting
                            ? const Color(0xFFF15A5A)
                            : isEating
                                ? Colors.green
                                : const Color(0xFF64748B),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formatDuration(remaining),
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Target Rencana: $selectedFasting",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 🔥 DYNAMIC CONTROLS (ACTIONS)
              if (!isFasting && !isEating)
                actionButton(
                  "Mulai Puasa Hari Ini",
                  const Color(0xFFF15A5A),
                  startFasting,
                ),

              if (isFasting && remaining.inSeconds == 0)
                actionButton(
                  "Buka Puasa (Waktunya Makan)",
                  Colors.green,
                  startEating,
                ),

              if (isEating && remaining.inSeconds == 0)
                actionButton(
                  "Mulai Puasa Lagi",
                  const Color(0xFFF15A5A),
                  startFasting,
                ),

              if (isFasting || isEating)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: actionButton(
                    "Batalkan Sesi",
                    const Color(0xFF64748B),
                    stopFasting,
                  ),
                ),

              const SizedBox(height: 25),

              // 🔥 PERSISTENT FOOTER CARD INFO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blueAccent.withOpacity(0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.blueAccent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tetap Konsisten 💪",
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Intermittent fasting mengoptimalkan pembakaran lemak tubuh.",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}