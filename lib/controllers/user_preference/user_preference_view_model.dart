import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/models/myuser.dart';

class UserPreference extends GetxController {
  Future<bool> saveUser(MyUser user) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('userId', user.userId);
    await sp.setString('name', user.name);
    await sp.setString('email', user.email);
    await sp.setString('phoneNumber', user.phoneNumber);
    await sp.setBool('isLogin', true);
    return true;
  }

  Future<MyUser?> getUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString('userId');
    String? name = sp.getString('name');
    String? email = sp.getString('email');
    String? phoneNumber = sp.getString('phoneNumber');
    bool? isLogin = sp.getBool('isLogin');

    if (userId != null && isLogin == true) {
      return MyUser(
        userId: userId,
        name: name ?? '',
        email: email ?? '',
        phoneNumber: phoneNumber ?? '',
      );
    }
    return null;
  }

  Future<bool> removeUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();
    return true;
  }
}
