import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  PosePainter(this.pose, this.absoluteImageSize, this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 6;

    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4;

    final double scaleX = size.width / absoluteImageSize.height;
    final double scaleY = size.height / absoluteImageSize.width;

    Map<PoseLandmarkType, Offset> points = {};

    pose.landmarks.forEach((type, landmark) {
      double x = landmark.x * scaleX;
      double y = landmark.y * scaleY;

      x = size.width - x;

      final offset = Offset(x, y);
      points[type] = offset;

      canvas.drawCircle(
        offset,
        5,
        pointPaint,
      );
    });

    void draw(PoseLandmarkType a, PoseLandmarkType b) {
      if (points[a] != null && points[b] != null) {
        canvas.drawLine(
          points[a]!,
          points[b]!,
          linePaint,
        );
      }
    }

    draw(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    draw(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    draw(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);

    draw(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    draw(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    draw(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    draw(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    draw(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    draw(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    draw(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);

    draw(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    draw(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose;
  }
}