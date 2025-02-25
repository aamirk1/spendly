import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class IncomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  var selectedCategory = ''.obs;
  final formKey = GlobalKey<FormState>();
  final List<String> categories = [
    'Salary',
    'Business',
    'Gift',
    'Loan',
    'Sales',
    'Other'
  ];

  var errorMsg = Rx<String?>(null);
  var isLoading = false.obs; // 🔹 Added isLoading
  Future<void> addIncome() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in.');
      return;
    }

    isLoading.value = true;

    try {
      // Create a separate "incomes" collection
      await _firestore.collection('incomes').add({
        'userId': userId, // To identify which user this income belongs to
        'amount': double.parse(amountController.text.trim()),
        'description': descriptionController.text.trim(),
        'category': selectedCategory.value,
        'date': Timestamp.now(),
      });

      Get.snackbar('Success', 'Income added successfully!');

      // Clear all fields after successful submission
      amountController.clear();
      descriptionController.clear();
      selectedCategory.value = '';
      errorMsg.value = null;
    } catch (e) {
      errorMsg.value = 'Failed to add income: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
