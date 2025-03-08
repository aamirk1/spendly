import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var categories = <Map<String, dynamic>>[].obs;
  final nameController = TextEditingController();
  final iconController = TextEditingController();
  final colorController = TextEditingController();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      categories.value = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'icon': doc['icon'],
          'color': doc['color'],
        };
      }).toList();
    });
  }

  Future<void> addCategory() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Category name cannot be empty.');
      return;
    }

    isLoading.value = true;

    try {
      await _firestore.collection('categories').add({
        'userId': userId,
        'name': nameController.text.trim(),
        'icon': iconController.text.trim(),
        'color': colorController.text.trim(),
      });

      Get.snackbar('Success', 'Category added successfully!');
      nameController.clear();
      iconController.clear();
      colorController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
      Get.snackbar('Deleted', 'Category removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category: $e');
    }
  }
}
