import 'dart:async';
import 'dart:io';

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
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    signUpRequired.value = true;

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          )
          .timeout(const Duration(seconds: 10));

      User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(code: "user-creation-failed");
      }

      MyUser myUser = MyUser.empty.copyWith(
        userId: user.uid,
        phoneNumber: phoneNumberController.text.trim(),
        email: emailController.text.trim(),
        name: nameController.text.trim(),
      );

      await setUserData(myUser);
      await addDefaultCategories(user.uid); // ✅ Add default categories

      signUpRequired.value = false;
      Get.snackbar('Success', 'Account created successfully',
          snackPosition: SnackPosition.BOTTOM);
      Get.offAllNamed(RoutesName.homeView, arguments: myUser);
    } on FirebaseAuthException catch (e) {
      signUpRequired.value = false;
      Get.snackbar('Error', _getFirebaseAuthError(e.code),
          snackPosition: SnackPosition.BOTTOM);
    } on FirebaseException catch (e) {
      signUpRequired.value = false;
      Get.snackbar('Error', 'Firestore error: ${e.message}',
          snackPosition: SnackPosition.BOTTOM);
    } on SocketException {
      signUpRequired.value = false;
      Get.snackbar(
          'Network Error', 'No internet connection. Please check your network.',
          snackPosition: SnackPosition.BOTTOM);
    } on TimeoutException {
      signUpRequired.value = false;
      Get.snackbar('Timeout', 'Network timeout. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      signUpRequired.value = false;
      Get.snackbar('Error', 'Unexpected Error: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> setUserData(MyUser myUser) async {
    try {
      await _firestore.collection('users').doc(myUser.userId).set({
        'userId': myUser.userId,
        'name': myUser.name,
        'email': myUser.email,
        'phoneNumber': myUser.phoneNumber,
      }).timeout(const Duration(seconds: 10));
    } on FirebaseException catch (e) {
      Get.snackbar('Error', 'Failed to save user data: ${e.message}',
          snackPosition: SnackPosition.BOTTOM);
    } on SocketException {
      Get.snackbar(
          'Network Error', 'No internet connection. Please check your network.',
          snackPosition: SnackPosition.BOTTOM);
    } on TimeoutException {
      Get.snackbar('Timeout', 'Database request timed out. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error while saving user data: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addDefaultCategories(String userId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final List<Map<String, dynamic>> defaultCategories = [
      {'name': 'Food', 'icon': 'assets/emojis/food.png', 'color': '#FFA500'},
      {
        'name': 'Transport',
        'icon': 'assets/emojis/transport.png',
        'color': '#0000FF'
      },
      {
        'name': 'Entertainment',
        'icon': 'assets/emojis/entertainment.png',
        'color': '#800080'
      },
      {
        'name': 'Shopping',
        'icon': 'assets/emojis/shopping.png',
        'color': '#008000'
      },
      {
        'name': 'Health',
        'icon': 'assets/emojis/health.png',
        'color': '#FF0000'
      },
      {
        'name': 'Education',
        'icon': 'assets/emojis/education.png',
        'color': '#008080'
      },
      {'name': 'Bills', 'icon': 'assets/emojis/bills.png', 'color': '#4B0082'},
      {'name': 'Other', 'icon': 'assets/emojis/other.png', 'color': '#808080'},
    ];

    for (var category in defaultCategories) {
      await _firestore.collection('categories').add({
        'userId': userId,
        'name': category['name'],
        'icon': category['icon'],
        'color': category['color'],
      });
    }
  }

  /// **🔥 FIXED: Added missing _getFirebaseAuthError method**
  String _getFirebaseAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password is too weak. Use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'operation-not-allowed':
        return 'Sign-up is currently disabled. Contact support.';
      case 'user-creation-failed':
        return 'Failed to create user. Please try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Sign-up failed. Please try again.';
    }
  }
}
