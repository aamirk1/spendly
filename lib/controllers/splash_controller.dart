import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/res/routes/routes.dart';
import 'package:spendly/res/routes/routes_name.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3)); // Simulate animation delay

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.offAllNamed(RoutesName.welcomeView);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isSetupComplete = prefs.getBool('isSetupComplete') ?? false;

      if (isSetupComplete) {
        Get.offAllNamed(RoutesName.homeView);
      } else {
        Get.offAllNamed(RoutesName.setupView);
      }
    }
  }
}
