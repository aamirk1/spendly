import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spendly/res/routes/routes_name.dart';

class SplashController extends GetxController {
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate splash delay

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      bool hasSeenOnboarding = box.read('hasSeenOnboarding') ?? false;
      bool isSetupComplete = box.read('isSetupComplete') ?? false;

      if (!hasSeenOnboarding) {
        Get.offAllNamed(RoutesName.onboardingView);
      } else if (isSetupComplete) {
        Get.offAllNamed(RoutesName.homeView);
      } else {
        Get.offAllNamed(RoutesName.welcomeView);
      }
    } else {
      Get.offAllNamed(RoutesName.welcomeView);
    }
  }
}
