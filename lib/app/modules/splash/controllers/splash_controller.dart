import 'package:get/get.dart';
import 'package:workout_app/app/routes/app_pages.dart';

class SplashController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(Duration(seconds: 2), () {
      Get.offNamed(Routes.WELCOME); 
    });
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++; 
}