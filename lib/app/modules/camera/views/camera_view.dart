import 'dart:io';
import 'dart:math';
import 'pose_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:http/http.dart' as http;

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  Future<void> speak(String text) async {
    await tts.setLanguage("id-ID");
    await tts.setSpeechRate(0.5);
    await tts.speak(text);
  }

  Future<void> saveWorkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt("user_id") ?? 0;

      final response = await http.post(
        Uri.parse("http://10.11.107.226:5000/api/save-workout"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "exercise_name": exercise,
          "repetitions": currentRep,
          "calories": calories,
          "duration": target,
        }),
      );
      print(response.body);
    } catch (e) {
      print(e);
    }
  }

  CameraController? controller;
  List<CameraDescription> cameras = [];
  int cameraIndex = 0;
  String exercise = "";
  int target = 15;
  String coachText = "";
  // String detectedExercise = "-";
  // double confidence = 0;
  int currentRep = 0;
  double calories = 0;
  final FlutterTts tts = FlutterTts();

  final PoseDetector poseDetector = PoseDetector(
    options: PoseDetectorOptions(model: PoseDetectionModel.base),
  );

  bool isProcessing = false;
  bool isOpen = false;
  Pose? currentPose;
  bool repState = false;
  int frameCount = 0;
  // bool isPredicting = false;
  int holdSeconds = 0;
  bool workoutSaved = false;
  DateTime? holdStart;

  Size? imageSize;
  InputImageRotation? imageRotation;

  @override
  void initState() {
    super.initState();
    exercise = Get.arguments ?? "";
    initCamera();
  }

  void addRep() {
    setState(() {
      currentRep++;
      calories += getCalories();
    });

    if (currentRep >= target && !workoutSaved) {
      workoutSaved = true;
      saveWorkout();
    }
  }

  double getCalories() {
    switch (exercise) {
      case "Jumping Jack":
        return 0.6;
      case "High Knee":
        return 0.7;
      case "Squat Jump":
        return 0.8;
      case "Fast Squat":
        return 0.7;
      case "Push Up":
        return 0.45;
      case "Squat":
        return 0.5;
      case "Sit Up":
        return 0.35;
      case "Lunges":
        return 0.45;
      case "Plank":
        return 0.25;
      case "Standing Stretch":
        return 0.15;
      case "Arm Stretch":
        return 0.15;
      case "Side Stretch":
        return 0.15;
      default:
        return 0.3;
    }
  }

  double calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    double radians = atan2(c.y - b.y, c.x - b.x) - atan2(a.y - b.y, a.x - b.x);
    double angle = radians * 180 / pi;
    if (angle < 0) {
      angle += 360;
    }
    if (angle > 180) {
      angle = 360 - angle;
    }
    return angle;
  }

  void countJumpingJack(Pose pose) {
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (leftWrist == null || rightWrist == null || leftAnkle == null || rightAnkle == null) {
      return;
    }

    final leftShoulder =
    pose.landmarks[PoseLandmarkType.leftShoulder];

    final rightShoulder =
    pose.landmarks[PoseLandmarkType.rightShoulder];

    if(leftShoulder==null||rightShoulder==null){
    return;
    }

    bool handUp =
    leftWrist.y < leftShoulder.y &&
    rightWrist.y < rightShoulder.y;
    final hipWidth =
    (pose.landmarks[PoseLandmarkType.rightHip]!.x-
    pose.landmarks[PoseLandmarkType.leftHip]!.x).abs();

    bool legOpen =
    (rightAnkle.x-leftAnkle.x).abs() >
    hipWidth*1.6;
    if (handUp && legOpen) {
      repState = true;
    }

    bool handDown =
    leftWrist.y > leftShoulder.y &&
    rightWrist.y > rightShoulder.y;    
    bool legClose =
    (rightAnkle.x-leftAnkle.x).abs() <
    hipWidth*1.2;
    
    if (handDown && legClose && repState) {
      repState = false;
      addRep();
    }
  }

  void countSquat(Pose pose) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (hip == null || knee == null || ankle == null) {
      return;
    }

    double angle = calculateAngle(hip, knee, ankle);

    if (angle < 95) {
      repState = true;
    }

    if (angle > 160 && repState) {
      repState = false;
      addRep();
    }
  }

  void countHighKnee(Pose pose) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];

    if (hip == null || knee == null) {
      return;
    }

    if (knee.y < hip.y) {
      if (!repState) {
        repState = true;
        addRep();
      }
    } else {
      repState = false;
    }
  }

  void countPushUp(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];

    if (shoulder == null || elbow == null || wrist == null) {
      return;
    }

    double angle = calculateAngle(shoulder, elbow, wrist);

    if (angle < 90) {
      repState = true;
    }

    if (angle > 160 && repState) {
      repState = false;
      addRep();
    }
  }

  void countSitUp(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];

    if (shoulder == null || hip == null || knee == null) {
      return;
    }

    double angle = calculateAngle(shoulder, hip, knee);

    if (angle < 95) {
      repState = true;
    }

    if (angle > 145 && repState) {
      repState = false;
      addRep();
    }
  }

  void countLunges(Pose pose) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (hip == null || knee == null || ankle == null) {
      return;
    }

    double angle = calculateAngle(hip, knee, ankle);

    if (angle < 100) {
      repState = true;
    }

    if (angle > 160 && repState) {
      repState = false;
      addRep();
    }
  }

  void countPlank(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (shoulder == null || hip == null || ankle == null) {
      return;
    }

    double angle = calculateAngle(shoulder, hip, ankle);

    if (angle > 160) {
      if (holdStart == null) {
        holdStart = DateTime.now();
      }

      int sec = DateTime.now().difference(holdStart!).inSeconds;
      coachText = "Tahan $sec detik";

      if (sec >= 30) {
        addRep();
        holdStart = null;
      }
    } else {
      holdStart = null;
    }
  }

  void checkStandingStretch(Pose pose) {
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftWrist == null || rightWrist == null) {
      return;
    }

    if (leftWrist.y < 180 && rightWrist.y < 180) {
      if (holdStart == null) {
        holdStart = DateTime.now();
      }

      int sec = DateTime.now().difference(holdStart!).inSeconds;
      coachText = "Tahan $sec detik";

      if (sec >= 15) {
        addRep();
        holdStart = null;
      }
    } else {
      holdStart = null;
    }
  }

  void checkArmStretch(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftShoulder == null || rightWrist == null) {
      return;
    }

    if ((rightWrist.x - leftShoulder.x).abs() < 40) {
      if (holdStart == null) {
        holdStart = DateTime.now();
      }

      int sec = DateTime.now().difference(holdStart!).inSeconds;
      coachText = "Tahan $sec detik";

      if (sec >= 15) {
        addRep();
        holdStart = null;
      }
    } else {
      holdStart = null;
    }
  }

  void checkSideStretch(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];

    if (shoulder == null || hip == null) {
      return;
    }

    if ((shoulder.x - hip.x).abs() > 40) {
      if (holdStart == null) {
        holdStart = DateTime.now();
      }

      int sec = DateTime.now().difference(holdStart!).inSeconds;
      coachText = "Tahan $sec detik";

      if (sec >= 15) {
        addRep();
        holdStart = null;
      }
    } else {
      holdStart = null;
    }
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    
    if (controller == null) {
      int frontIndex = cameras.indexWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );
      if (frontIndex != -1) {
        cameraIndex = frontIndex;
      }
    }

    controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Format NV21 untuk Android
    );
    await controller!.initialize();
    await controller!.startImageStream(processCameraImage);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) return;

    cameraIndex = cameraIndex == 0 ? 1 : 0;

    if (controller != null) {
      await controller!.stopImageStream();
      await controller!.dispose();
    }

    await initCamera();
  }

  List<double> convertToMoveNetFormat(Pose pose) {
    List<PoseLandmarkType> moveNetOrder = [
      PoseLandmarkType.nose,
      PoseLandmarkType.leftEye,
      PoseLandmarkType.rightEye,
      PoseLandmarkType.leftEar,
      PoseLandmarkType.rightEar,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ];

    List<double> resultPoints = [];
    for (var type in moveNetOrder) {
      final landmark = pose.landmarks[type];
      if (landmark != null) {
        resultPoints.add(landmark.x);
        resultPoints.add(landmark.y);
        resultPoints.add(landmark.likelihood);
      } else {
        resultPoints.add(0.0);
        resultPoints.add(0.0);
        resultPoints.add(0.0);
      }
    }
    return resultPoints;
  }

  void processCameraImage(CameraImage image) async {
    if (isProcessing) return;
    isProcessing = true;

    try {
      final camera = cameras[cameraIndex];
      final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
      
      // Mengabaikan pembacaan format raw dari OS Oppo/Realme, paksa menggunakan NV21 standar ML Kit
      final format = InputImageFormat.nv21;

      // PERBAIKAN FINAL: Menggabungkan seluruh data bytes dari semua bidang plane (Y + UV) 
      // Menggunakan alokasi WriteBuffer untuk mencegah lemparan IllegalArgumentException
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final poses = await poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        if (mounted) {
          setState(() {
            currentPose = poses.first;
            imageSize = Size(image.width.toDouble(), image.height.toDouble());
            imageRotation = rotation;
          });
        }

        runLocalCounter(poses.first);

      } else {
        if (mounted) {
          setState(() {
            currentPose = null;
          });
        }
      }
    } catch (e) {
      print("Gagal mendeteksi gambar: $e");
    } finally {
      isProcessing = false;
    }
  }

  void runLocalCounter(Pose pose) {
    switch (exercise) {
      case "Jumping Jack":
        countJumpingJack(pose);
        break;
      case "High Knee":
        countHighKnee(pose);
        break;
      case "Squat Jump":
      case "Fast Squat":
      case "Squat":
        countSquat(pose);
        break;
      case "Push Up":
        countPushUp(pose);
        break;
      case "Sit Up":
        countSitUp(pose);
        break;
      case "Lunges":
        countLunges(pose);
        break;
      case "Plank":
        countPlank(pose);
        break;
      case "Standing Stretch":
        checkStandingStretch(pose);
        break;
      case "Arm Stretch":
        checkArmStretch(pose);
        break;
      case "Side Stretch":
        checkSideStretch(pose);
        break;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    poseDetector.close();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise),        
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await saveWorkout();
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: switchCamera,
          )
        ],
      ),
      body: controller == null || !controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text("Repetisi", style: TextStyle(color: Colors.black54)),
                              Text(
                                "$currentRep / $target",
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text("Kalori (kcal)", style: TextStyle(color: Colors.black54)),
                              Text(
                                calories.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        coachText.isEmpty ? "Posisikan tubuh Anda di depan kamera" : coachText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CameraPreview(controller!),
                          ),
                          if (currentPose != null && imageSize != null && imageRotation != null)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: PosePainter(
                                  currentPose!,
                                  imageSize!,
                                  imageRotation!,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}