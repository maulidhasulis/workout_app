import 'package:get/get.dart';

import '../controllers/fasting_controller.dart';

class FastingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FastingController>(
      () => FastingController(),
    );
  }
}
