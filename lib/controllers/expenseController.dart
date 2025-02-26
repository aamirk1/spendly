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
      'color': Colors.orangeAccent
    },
    {
      'name': 'Transport',
      'icon': CupertinoIcons.car_detailed,
      'color': Colors.blueAccent
    },
    {
      'name': 'Entertainment',
      'icon': CupertinoIcons.tv_fill,
      'color': Colors.purpleAccent
    },
    {
      'name': 'Shopping',
      'icon': CupertinoIcons.bag_fill,
      'color': Colors.greenAccent
    },
    {
      'name': 'Health',
      'icon': CupertinoIcons.heart_fill,
      'color': Colors.redAccent
    },
    {
      'name': 'Education',
      'icon': CupertinoIcons.book_fill,
      'color': Colors.tealAccent
    },
    {
      'name': 'Bills',
      'icon': CupertinoIcons.doc_text_fill,
      'color': Colors.indigoAccent
    },
    {
      'name': 'Other',
      'icon': CupertinoIcons.question_circle_fill,
      'color': Colors.grey
    },
  ].obs;

  var errorMsg = Rx<String?>(null);
  var isLoading = false.obs;

  var categoryTotals = <String, double>{}.obs;
  var expensesList = <Map<String, dynamic>>[].obs;

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
      List<Map<String, dynamic>> tempExpenses = [];

      for (var doc in snapshot.docs) {
        String id = doc.id;
        Map<String, dynamic> data = doc.data();

        String category = data['category'] ?? "Unknown";
        String description = data['description'] ?? "";
        double amount = (data['amount'] as num).toDouble();
        DateTime date = (data['date'] as Timestamp).toDate();

        tempTotals[category] = (tempTotals[category] ?? 0) + amount;

        tempExpenses.add({
          'id': id,
          'description': description,
          'category': category,
          'amount': amount,
          'date': date,
        });
      }

      categoryTotals.value = tempTotals;
      expensesList.value = tempExpenses;
    });
  }

  Future<void> addExpense() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in.');
      return;
    }

    isLoading.value = true;

    try {
      DocumentReference expenseRef =
          await _firestore.collection('expenses').add({
        'userId': userId,
        'amount': double.parse(amountController.text.trim()),
        'description': descriptionController.text.trim(),
        'category': selectedCategory.value,
        'date': Timestamp.now(),
      });

      await expenseRef.update({'id': expenseRef.id});

      Get.snackbar('Success', 'Expense added successfully!');

      amountController.clear();
      descriptionController.clear();
      selectedCategory.value = '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to add expense: $e');
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
