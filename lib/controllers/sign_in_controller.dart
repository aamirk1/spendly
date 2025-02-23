import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:spendly/models/myuser.dart';
import 'package:spendly/res/routes/routes_name.dart';

class SignInController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var signInRequired = false.obs;
  var obscurePassword = true.obs;
  var iconPassword = CupertinoIcons.eye_fill.obs;
  var errorMsg = Rx<String?>(null);

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
    iconPassword.value = obscurePassword.value
        ? CupertinoIcons.eye_fill
        : CupertinoIcons.eye_slash_fill;
  }

  Future<void> signIn() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      signInRequired.value = true;
      errorMsg.value = null;

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Fetch user data from Firestore
        User? user = userCredential.user;
        if (user != null) {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(user.uid).get();

          if (userDoc.exists) {
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;

            MyUser myUser = MyUser.empty.copyWith(
              userId: userData['userId'] ?? user.uid,
              name: userData['name'] ?? '',
              email: userData['email'] ?? '',
              phoneNumber: userData['phoneNumber'] ?? '',
            );

            signInRequired.value = false;
            Get.snackbar("Success", "Sign-in successful!",
                snackPosition: SnackPosition.BOTTOM);

            // Pass user data to home screen
            Get.offAllNamed(RoutesName.homeView, arguments: myUser);
          } else {
            signInRequired.value = false;
            Get.snackbar("Error", "User data not found.");
          }
        }
      } catch (e) {
        signInRequired.value = false;
        errorMsg.value = 'Invalid email or password';
        Get.snackbar("Error", e.toString());
      }
    } else {
      Get.snackbar("Error", "Please fill in all fields");
    }
  }
}
