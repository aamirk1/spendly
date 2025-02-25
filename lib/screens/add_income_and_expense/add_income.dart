import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendly/controllers/incomeController.dart';
import 'package:spendly/controllers/sign_in_controller.dart';
import 'package:spendly/screens/auth/components/my_text_field.dart';

class AddIncome extends StatelessWidget {
  AddIncome({super.key});

  final controller = Get.put(IncomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Amount Field
              Obx(() => MyTextField(
                    controller: controller.amountController,
                    hintText: 'Amount',
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    errorMsg: controller.errorMsg.value,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(val) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  )),

              const SizedBox(height: 10),

              // Description Field
              Obx(() => MyTextField(
                    controller: controller.descriptionController,
                    hintText: 'Write a description',
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    errorMsg: controller.errorMsg.value,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  )),

              const SizedBox(height: 10),

              // Category Dropdown
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedCategory.value.isEmpty
                        ? null
                        : controller.selectedCategory.value,
                    decoration: InputDecoration(
                      hintText: 'Select a category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: controller.categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      controller.selectedCategory.value = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  )),

              const SizedBox(height: 20),

              // Submit Button
              Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextButton(
                        onPressed: () {
                          if (controller.formKey.currentState!.validate()) {
                            controller.addIncome();
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Text(
                            'Add Income',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
