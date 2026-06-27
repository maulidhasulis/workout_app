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
        Uri.parse("http://192.168.43.235:5000/api/save-workout"),

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

  String detectedExercise = "-";

  double confidence = 0;

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

  bool isPredicting = false;

  int holdSeconds = 0;

  bool workoutSaved = false;

  DateTime? holdStart;

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

    if (leftWrist == null ||
        rightWrist == null ||
        leftAnkle == null ||
        rightAnkle == null) {
      return;
    }

    bool handUp = leftWrist.y < 180 && rightWrist.y < 180;

    bool legOpen = (rightAnkle.x - leftAnkle.x).abs() > 180;

    if (handUp && legOpen) {
      repState = true;
    }

    bool handDown = leftWrist.y > 260 && rightWrist.y > 260;

    bool legClose = (rightAnkle.x - leftAnkle.x).abs() < 80;

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

    print("Squat Angle : $angle");

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

    print("Push Up Angle : $angle");

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

    print("Sit Up Angle : $angle");

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

    print("Lunges Angle : $angle");

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

    controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.low,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await controller!.initialize();

    await controller!.startImageStream(processCameraImage);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> predictWorkout(List<double> keypoints) async {
    if (isPredicting) return;

    isPredicting = true;

    try {
      final response = await http.post(
        Uri.parse("http://192.168.43.235:5000/api/predict"),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({"keypoints": keypoints}),
      );

      final data = jsonDecode(response.body);

      if (data["success"]) {
        setState(() {
          detectedExercise = data["exercise"];

          confidence = (data["confidence"] ?? 0).toDouble();
        });
      }
    } catch (e) {
      print(e);
    }

    isPredicting = false;
  }

  void countWorkout(Pose pose) {
    if (confidence < 0.70 ||
        detectedExercise.replaceAll("_", " ").toLowerCase() !=
            exercise.toLowerCase()) {
      coachText = "Gerakan tidak sesuai";
      return;
    }

    coachText = "Gerakan Benar";

    switch (exercise) {
      case "Jumping Jack":
        countJumpingJack(pose);
        break;

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

      case "High Knee":
        countHighKnee(pose);
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

  Future<void> processCameraImage(CameraImage image) async {
    print("Format = ${image.format.group}");
    print("Planes = ${image.planes.length}");

    if (isProcessing) return;

    isProcessing = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();

      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      final bytes = allBytes.done().buffer.asUint8List();

      print("bytesPerRow = ${image.planes.first.bytesPerRow}");

      print("width = ${image.width}");

      print("height = ${image.height}");

      print("sensor = ${cameras[cameraIndex].sensorOrientation}");

      final rotation =
          InputImageRotationValue.fromRawValue(
            cameras[cameraIndex].sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final poses = await poseDetector.processImage(inputImage);

      print("Jumlah Pose = ${poses.length}");

      if (poses.isNotEmpty) {
        currentPose = poses.first;

        setState(() {});

        print("POSE DETECTED");
      }

      if (poses.isNotEmpty) {
        Pose pose = poses.first;

        List<double> keypoints = [];

        int count = 0;

        pose.landmarks.forEach((type, landmark) {
          if (count < 17) {
            keypoints.add(landmark.x);

            keypoints.add(landmark.y);

            keypoints.add(landmark.z);

            count++;
          }
        });

        print("Jumlah Keypoints = ${keypoints.length}");

        frameCount++;

        if (frameCount >= 5) {
          frameCount = 0;

          await predictWorkout(keypoints);
        }
        countWorkout(pose);
      }
    } catch (e) {
      print(e);
    }

    isProcessing = false;
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) return;

    cameraIndex = cameraIndex == 0 ? 1 : 0;

    await controller?.dispose();

    controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.low,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await controller!.initialize();

    await controller!.startImageStream(processCameraImage);

    setState(() {});
  }

  @override
  void dispose() {
    poseDetector.close();

    controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise),
        actions: [
          IconButton(
            onPressed: switchCamera,
            icon: const Icon(Icons.flip_camera_android),
          ),
        ],
      ),
      body: controller == null || !controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  color: Colors.grey.shade200,
                  child: Column(
                    children: [
                      const Text(
                        "Target Hari Ini",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "$currentRep / $target",
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      LinearProgressIndicator(value: currentRep / target),

                      const SizedBox(height: 15),

                      Text(
                        "Kalori Terbakar : ${calories.toStringAsFixed(1)} kcal",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 15),

                      Text(coachText, textAlign: TextAlign.center),
                      const SizedBox(height: 10),

                      Text(
                        "Terdeteksi : $detectedExercise",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        "Confidence : ${(confidence * 100).toStringAsFixed(0)} %",
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: CameraPreview(controller!)),

                      if (currentPose != null)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: PosePainter(currentPose!),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
