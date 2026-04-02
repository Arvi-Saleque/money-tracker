import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/category_model.dart';

class CategoryService {
  CategoryService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('categories');
  }

  Stream<List<CategoryModel>> watchCategories(String uid, {String? type}) {
    return _categoriesRef(uid).snapshots().map((snapshot) {
      final categories = snapshot.docs.map(CategoryModel.fromDocument).toList()
        ..sort((left, right) {
          final createdAtCompare = left.createdAt.compareTo(right.createdAt);
          if (createdAtCompare != 0) {
            return createdAtCompare;
          }
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
        });

      if (type == null) {
        return categories;
      }

      return categories.where((category) => category.type == type).toList();
    });
  }

  Future<void> addCategory(String uid, CategoryModel category) async {
    await _categoriesRef(uid).doc(category.id).set(category.toMap());
  }

  Future<void> updateCategory(String uid, CategoryModel category) async {
    await _categoriesRef(uid).doc(category.id).set(category.toMap());
  }

  Future<void> deleteCategory(String uid, String categoryId) async {
    await _categoriesRef(uid).doc(categoryId).delete();
  }
}
