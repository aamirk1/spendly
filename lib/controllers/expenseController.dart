import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  var selectedCategory = ''.obs;
  final formKey = GlobalKey<FormState>();
  final RxList<Map<String, dynamic>> expenseCategories = <Map<String, dynamic>>[
    {
      'name': 'Food',
      'icon': CupertinoIcons.cart_fill,
      'color': Colors.orangeAccent,
    },
    {
      'name': 'Transport',
      'icon': CupertinoIcons.car_detailed,
      'color': Colors.blueAccent,
    },
    {
      'name': 'Entertainment',
      'icon': CupertinoIcons.tv_fill,
      'color': Colors.purpleAccent,
    },
    {
      'name': 'Shopping',
      'icon': CupertinoIcons.bag_fill,
      'color': Colors.greenAccent,
    },
    {
      'name': 'Health',
      'icon': CupertinoIcons.heart_fill,
      'color': Colors.redAccent,
    },
    {
      'name': 'Education',
      'icon': CupertinoIcons.book_fill,
      'color': Colors.tealAccent,
    },
    {
      'name': 'Bills',
      'icon': CupertinoIcons.doc_text_fill,
      'color': Colors.indigoAccent,
    },
    {
      'name': 'Other',
      'icon': CupertinoIcons.question_circle_fill,
      'color': Colors.grey,
    },
  ].obs;

  var errorMsg = Rx<String?>(null);
  var isLoading = false.obs; // 🔹 Add this line

  var categoryTotals =
      <String, double>{}.obs; // Observable map for category totals

  var expensesList =
      <Map<String, dynamic>>[].obs; // List of maps instead of models

  @override
  void onInit() {
    super.onInit();
    fetchExpenseTotals();
  }

  void fetchExpenseTotals() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      Map<String, double> tempTotals = {};
      List<Map<String, dynamic>> tempExpenses = []; // List of maps

      for (var doc in snapshot.docs) {
        String category = doc['category'];
        String description = doc['description'];
        double amount = (doc['amount'] as num).toDouble();
        DateTime date =
            (doc['date'] as Timestamp).toDate(); // Convert timestamp

        // Update category totals
        tempTotals[category] = (tempTotals[category] ?? 0) + amount;

        // Store expense details as a map
        tempExpenses.add({
          'description': description,
          'category': category,
          'amount': amount,
          'date': date,
        });
      }

      categoryTotals.value = tempTotals;
      expensesList.value = tempExpenses; // Update list without using models
    });
  }

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

  void updateExpense(String docId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('expenses').doc(docId).update(updatedData);
      Get.snackbar('Success', 'Expense updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update expense: $e');
    }
  }

  void deleteExpense(String docId) async {
    try {
      await _firestore.collection('expenses').doc(docId).delete();
      Get.snackbar('Deleted', 'Expense removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete expense: $e');
    }
  }
}
