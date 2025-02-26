import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  var selectedCategory = ''.obs;
  final formKey = GlobalKey<FormState>();

  final RxList<Map<String, dynamic>> incomeCategories = <Map<String, dynamic>>[
    {
      'name': 'Salary',
      'icon': CupertinoIcons.money_dollar_circle_fill,
      'color': Colors.greenAccent,
    },
    {
      'name': 'Business',
      'icon': CupertinoIcons.briefcase_fill,
      'color': Colors.blueAccent,
    },
    {
      'name': 'Gift',
      'icon': CupertinoIcons.gift_fill,
      'color': Colors.purpleAccent,
    },
    {
      'name': 'Loan',
      'icon': CupertinoIcons.creditcard_fill,
      'color': Colors.orangeAccent,
    },
    {
      'name': 'Sales',
      'icon': CupertinoIcons.cart_fill,
      'color': Colors.tealAccent,
    },
    {
      'name': 'Other',
      'icon': CupertinoIcons.question_circle_fill,
      'color': Colors.grey,
    },
  ].obs;

  var errorMsg = Rx<String?>(null);
  var isLoading = false.obs;

  var categoryTotals = <String, double>{}.obs;
  var incomeList = <Map<String, dynamic>>[].obs; // ✅ Income list for UI

  @override
  void onInit() {
    super.onInit();
    fetchIncomeTotals();
  }

  void fetchIncomeTotals() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('incomes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      Map<String, double> tempTotals = {};
      List<Map<String, dynamic>> tempIncomes = [];

      for (var doc in snapshot.docs) {
        String category = doc['category'];
        String description = doc['description'];
        double amount = (doc['amount'] as num).toDouble();
        DateTime date = (doc['date'] as Timestamp).toDate();

        tempTotals[category] = (tempTotals[category] ?? 0) + amount;

        tempIncomes.add({
          'description': description,
          'category': category,
          'amount': amount,
          'date': date,
        });
      }

      categoryTotals.value = tempTotals;
      incomeList.value = tempIncomes;
    });
  }

  Future<void> addIncome() async {
    if (!formKey.currentState!.validate()) return;

    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      errorMsg.value = 'User not logged in.';
      return;
    }

    isLoading.value = true;

    try {
      await _firestore.collection('incomes').add({
        'userId': userId,
        'amount': double.parse(amountController.text.trim()),
        'description': descriptionController.text.trim(),
        'category': selectedCategory.value,
        'date': Timestamp.now(),
      });

      Get.snackbar('Success', 'Income added successfully!');

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

  void updateIncome(String docId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('incomes').doc(docId).update(updatedData);
      Get.snackbar('Success', 'Income updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update income: $e');
    }
  }

  void deleteIncome(String docId) async {
    try {
      await _firestore.collection('incomes').doc(docId).delete();
      Get.snackbar('Deleted', 'Income removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete income: $e');
    }
  }
}
