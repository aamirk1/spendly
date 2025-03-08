import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendly/controllers/categoryController.dart';

class ManageCategoriesScreen extends StatelessWidget {
  final CategoryController controller = Get.put(CategoryController());

   ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Categories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.nameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.iconController,
              decoration: InputDecoration(labelText: 'Icon Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.colorController,
              decoration: InputDecoration(labelText: 'Color (Hex Code)'),
            ),
          ),
          ElevatedButton(
            onPressed: controller.addCategory,
            child: Text('Add Category'),
          ),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return ListTile(
                    leading: Icon(Icons.circle, color: Color(int.parse(category['color'].replaceAll("#", "0xff")))),
                    title: Text(category['name']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.deleteCategory(category['id']),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
