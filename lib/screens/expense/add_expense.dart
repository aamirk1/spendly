import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:spendly/controllers/categoryController.dart';
import 'package:spendly/controllers/expenseController.dart';
import 'package:spendly/models/category.dart';
import 'package:spendly/screens/expense/category_creation.dart';
import 'package:uuid/uuid.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final CreateExpenseController createExpenseController =
      Get.put(CreateExpenseController());
  final CategoryController categoryController = Get.put(CategoryController());

  TextEditingController expenseController = TextEditingController();
  TextEditingController categoryTextController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    createExpenseController.expense.expenseId = const Uuid().v1();
    categoryController.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        body: categoryController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Add Expenses",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: expenseController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(FontAwesomeIcons.dollarSign,
                            size: 16, color: Colors.grey),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: categoryTextController,
                      readOnly: true,
                      onTap: () {},
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: createExpenseController.expense.category ==
                                Category.empty
                            ? Colors.white
                            : Color(
                                createExpenseController.expense.category.color),
                        prefixIcon: createExpenseController.expense.category ==
                                Category.empty
                            ? const Icon(FontAwesomeIcons.list,
                                size: 16, color: Colors.grey)
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                    'assets/icons/${createExpenseController.expense.category.icon}.png',
                                    scale: 10),
                              ),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            var newCategory =
                                await getCategoryCreation(context);
                            if (newCategory != null) {
                              categoryController.categories
                                  .insert(0, newCategory);
                            }
                          },
                          icon: const Icon(FontAwesomeIcons.plus, size: 16),
                        ),
                        hintText: 'Category',
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(12))),
                      child: ListView.builder(
                        itemCount: categoryController.categories.length,
                        itemBuilder: (context, i) {
                          final category = categoryController.categories[i];
                          return Card(
                            child: ListTile(
                              onTap: () {
                                createExpenseController
                                    .updateCategory(category);
                                categoryTextController.text = category.name;
                              },
                              leading: Image.asset(
                                  'assets/icons/${category.icon}.png',
                                  scale: 2),
                              title: Text(category.name),
                              tileColor: Color(category.color),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: createExpenseController.expense.date,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (newDate != null) {
                          dateController.text =
                              DateFormat('dd/MM/yyyy').format(newDate);
                          createExpenseController.updateDate(newDate);
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(FontAwesomeIcons.clock,
                            size: 16, color: Colors.grey),
                        hintText: 'Date',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: kToolbarHeight,
                      child: createExpenseController.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : TextButton(
                              onPressed: () {
                                createExpenseController.createExpense(
                                    int.parse(expenseController.text));
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: const Text('Save',
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.white)),
                            ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}
