import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.currency,
    required this.language,
    required this.theme,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String avatarUrl;
  final String currency;
  final String language;
  final String theme;
  final DateTime createdAt;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];

    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      currency: map['currency'] as String? ?? AppConstants.defaultCurrency,
      language: map['language'] as String? ?? AppConstants.defaultLanguageCode,
      theme: map['theme'] as String? ?? AppConstants.sapphireDarkTheme,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.tryParse(createdAtValue?.toString() ?? '') ??
                DateTime.now(),
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserModel.fromMap(<String, dynamic>{
      ...data,
      'uid': data['uid'] ?? doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'currency': currency,
      'language': language,
      'theme': theme,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? avatarUrl,
    String? currency,
    String? language,
    String? theme,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
