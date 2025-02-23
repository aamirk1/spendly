import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:spendly/models/category.dart';
import 'package:spendly/models/expense.dart';

class CreateExpenseController extends GetxController {
  var expense = Expense.empty;
  var isLoading = false.obs;

  void updateCategory(Category category) {
    expense.category = category;
    update();
  }

  void updateDate(DateTime date) {
    expense.date = date;
    update();
  }

  void createExpense(int amount) async {
    try {
      isLoading.value = true;

      // Set expense amount
      expense.amount = amount;

      // Get Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Store the expense in Firestore
      await firestore.collection('expenses').add({
        'amount': amount,
        'category': expense.category,
        // 'description': expense.description ?? '',
        'date': Timestamp.now(),
        'userId': expense.userId,
      });

      // Return the expense and close dialog
      Get.back(result: expense);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create expense: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
