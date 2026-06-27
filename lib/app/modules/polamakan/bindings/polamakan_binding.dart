import 'package:get/get.dart';

import '../controllers/polamakan_controller.dart';

class PolamakanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PolamakanController>(
      () => PolamakanController(),
    );
  }
}
