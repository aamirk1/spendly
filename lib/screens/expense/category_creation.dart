import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:spendly/models/category.dart';
import 'package:spendly/models/myuser.dart';
import 'package:uuid/uuid.dart';

Future<Category?> getCategoryCreation(BuildContext context) {
  MyUser myUser = Get.find<MyUser>();
  List<String> myCategoriesIcons = [
    'car',
    'dinner',
    'games',
    'gift',
    'first-aid-kit',
    'tools',
    'travel-and-tourism'
  ];

  final TextEditingController categoryNameController = TextEditingController();
  final RxString iconSelected = ''.obs;
  final Rx<Color> categoryColor = Colors.white.obs;
  final RxBool isExpanded = false.obs;
  final RxBool isLoading = false.obs;

  return showDialog<Category>(
    context: context,
    builder: (ctx) {
      return Obx(() {
        return AlertDialog(
          title: const Text('Create a Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: categoryNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  onTap: () => isExpanded.toggle(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Icon',
                    suffixIcon:
                        const Icon(CupertinoIcons.chevron_down, size: 12),
                    border: OutlineInputBorder(
                      borderRadius: isExpanded.value
                          ? const BorderRadius.vertical(
                              top: Radius.circular(12))
                          : BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (isExpanded.value)
                  SizedBox(
                    height: 200,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5),
                      itemCount: myCategoriesIcons.length,
                      itemBuilder: (context, i) {
                        final icon = myCategoriesIcons[i];
                        return GestureDetector(
                          onTap: () => iconSelected.value = icon,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 3,
                                  color: iconSelected.value == icon
                                      ? Colors.green
                                      : Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                  image: AssetImage('assets/icons/$icon.png')),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx2) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ColorPicker(
                              pickerColor: categoryColor.value,
                              onColorChanged: (value) =>
                                  categoryColor.value = value,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () => Navigator.pop(ctx2),
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: const Text('Save Color',
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: categoryColor.value,
                    hintText: 'Color',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: kToolbarHeight,
                  child: isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : TextButton(
                          onPressed: () {
                            final newCategory = Category(
                              categoryId: const Uuid().v1(),
                              name: categoryNameController.text,
                              icon: iconSelected.value,
                              color: categoryColor.value.value,
                              userId: myUser,
                              totalExpenses: 0,
                            );
                            Navigator.pop(ctx, newCategory);
                          },
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('Save',
                              style:
                                  TextStyle(fontSize: 22, color: Colors.white)),
                        ),
                )
              ],
            ),
          ),
        );
      });
    },
  );
}
