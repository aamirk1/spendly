import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendly/app.dart';
import 'package:spendly/controllers/expenseController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(ExpenseController());
  runApp(MyApp());
}
