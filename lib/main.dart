import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spendly/app.dart';
import 'package:spendly/controllers/expenseController.dart';
import 'package:spendly/controllers/incomeController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Get.put(ExpenseController());
  Get.put(IncomeController());

  await GetStorage.init(); // ✅ Initialize GetStorage
  runApp(MyApp());
}
