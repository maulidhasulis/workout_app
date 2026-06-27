import 'package:get/get.dart';

import '../modules/auth_choice/bindings/auth_choice_binding.dart';
import '../modules/auth_choice/views/auth_choice_view.dart';
import '../modules/bmi/bindings/bmi_binding.dart';
import '../modules/bmi/views/bmi_view.dart';
import '../modules/camera/bindings/camera_binding.dart';
import '../modules/camera/views/camera_view.dart';
import '../modules/fasting/bindings/fasting_binding.dart';
import '../modules/fasting/views/fasting_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/polamakan/bindings/polamakan_binding.dart';
import '../modules/polamakan/views/polamakan_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/progress/bindings/progress_binding.dart';
import '../modules/progress/views/progress_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';
import '../modules/workout/bindings/workout_binding.dart';
import '../modules/workout/views/workout_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME,
      page: () => WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_CHOICE,
      page: () => AuthChoiceView(),
      binding: AuthChoiceBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.MENU,
      page: () => MenuView(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: _Paths.PROGRESS,
      page: () => ProgressView(),
      binding: ProgressBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.BMI,
      page: () => BmiView(),
      binding: BmiBinding(),
    ),
    GetPage(
      name: _Paths.FASTING,
      page: () => FastingView(),
      binding: FastingBinding(),
    ),
    GetPage(
      name: _Paths.POLAMAKAN,
      page: () => PolamakanView(),
      binding: PolamakanBinding(),
    ),
    GetPage(
      name: _Paths.WORKOUT,
      page: () => const WorkoutView(),
      binding: WorkoutBinding(),
    ),
    GetPage(
      name: _Paths.CAMERA,
      page: () => const CameraView(),
      binding: CameraBinding(),
    ),
  ];
}
