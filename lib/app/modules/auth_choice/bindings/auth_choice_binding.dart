import 'package:get/get.dart';

import '../controllers/auth_choice_controller.dart';

class AuthChoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthChoiceController>(
      () => AuthChoiceController(),
    );
  }
}
