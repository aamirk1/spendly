import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:spendly/models/myuser.dart';
import 'package:spendly/res/routes/routes_name.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();

  var obscurePassword = true.obs;
  var signUpRequired = false.obs;

  var containsUpperCase = false.obs;
  var containsLowerCase = false.obs;
  var containsNumber = false.obs;
  var containsSpecialChar = false.obs;
  var contains8Length = false.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void checkPasswordStrength(String val) {
    containsUpperCase.value = val.contains(RegExp(r'[A-Z]'));
    containsLowerCase.value = val.contains(RegExp(r'[a-z]'));
    containsNumber.value = val.contains(RegExp(r'[0-9]'));
    containsSpecialChar.value =
        val.contains(RegExp(r'[!@#\$&*~`()%\-_+=;:,.<>?/"\[\]{}|^]'));
    contains8Length.value = val.length >= 8;
  }

  Future<void> signUp() async {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      signUpRequired.value = true;

      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            )
            .timeout(const Duration(seconds: 10));
        print('data $userCredential');
        MyUser myUser = MyUser.empty.copyWith(
          userId: userCredential.user!.uid,
          phoneNumber: phoneNumberController.text,
          email: emailController.text,
          name: nameController.text,
        );

        await setUserData(myUser);

        signUpRequired.value = false;
        Get.snackbar('Success', 'Account created successfully');
        Get.toNamed(RoutesName.homeView, arguments: myUser);
      } on TimeoutException {
        signUpRequired.value = false;
        Get.snackbar('Error', 'Network timeout. Please try again.');
      } on FirebaseAuthException catch (e) {
        signUpRequired.value = false;
        Get.snackbar('Error', 'Firebase Error: ${e.message}');
      } catch (e) {
        signUpRequired.value = false;
        Get.snackbar('Error', 'Unexpected Error: $e');
      }
    } else {
      Get.snackbar('Error', 'Please fill all fields');
    }
  }

  Future<void> setUserData(MyUser myUser) async {
    try {
      await _firestore.collection('users').doc(myUser.userId).set({
        'userId': myUser.userId,
        'name': myUser.name,
        'email': myUser.email,
        'phoneNumber': myUser.phoneNumber,
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to set user data: ${e.toString()}');
    }
  }
}
