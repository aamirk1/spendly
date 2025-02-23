import 'package:get/get.dart';
import 'package:spendly/models/category.dart';
import 'package:spendly/models/myuser.dart';

class CategoryController extends GetxController {
  MyUser user = MyUser.empty;
  var categories = <Category>[].obs;
  var isLoading = false.obs;

  void fetchCategories() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    categories.value = [
      Category(
          name: 'Food',
          icon: 'dinner',
          color: 0xFFE57373,
          categoryId: '1',
          userId: user,
          totalExpenses: 0),
      Category(
          name: 'Travel',
          icon: 'travel-and-tourism',
          color: 0xFF64B5F6,
          categoryId: '2',
          userId: user,
          totalExpenses: 0),
    ];
    isLoading.value = false;
  }

  void addCategory(Category category) {
    categories.add(category);
    update();
  }
}
