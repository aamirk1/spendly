import 'dart:async';

import 'package:get/get.dart';
import 'package:spendly/controllers/user_preference/user_preference_view_model.dart';
import 'package:spendly/res/routes/routes_name.dart';
import 'package:spendly/models/myuser.dart';

class SplashServices {
  UserPreference userPreference = UserPreference();
  
  void isLogin() {
    userPreference.getUser().then((MyUser? user) {
      if (user == null) {
        Timer(Duration(seconds: 3), () => Get.toNamed(RoutesName.welcomeView));
      } else {
        Timer(Duration(seconds: 3), () => Get.toNamed(RoutesName.homeView, arguments: user));
      }
    });
  }
}
