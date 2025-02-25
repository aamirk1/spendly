import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  var selectedCategory = ''.obs;
  final formKey = GlobalKey<FormState>();

  final categories = ['Food', 'Transport', 'Entertainment', 'Other'];
  var errorMsg = Rx<String?>(null);
  var isLoading = false.obs; // 🔹 Add this line

  Future<void> addExpense() async {
    if (!formKey.currentState!.validate()) return;

    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      errorMsg.value = 'User not logged in.';
      return;
    }

    isLoading.value = true; // 🔹 Start loading

    try {
      // Create a separate "incomes" collection
      await _firestore.collection('expenses').add({
        'userId': userId, // To identify which user this income belongs to
        'amount': double.parse(amountController.text.trim()),
        'description': descriptionController.text.trim(),
        'category': selectedCategory.value,
        'date': Timestamp.now(),
      });

      Get.snackbar('Success', 'Expense added successfully!');

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
