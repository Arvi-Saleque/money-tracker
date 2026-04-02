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
    Query<Map<String, dynamic>> query = _categoriesRef(uid);
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    return query
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(CategoryModel.fromDocument).toList(),
        );
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
