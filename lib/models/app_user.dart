import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

@immutable
class AppUser {
  const AppUser({
    required this.email,
    required this.name,
    required this.surname,
  });

  final String email;
  final String name;
  final String surname;

  static AppUser fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return AppUser(
      email: data['email'],
      name: data['name'],
      surname: data['surname'],
    );
  }

  static Map<String, Object?> toFirestore(AppUser user, SetOptions? options) {
    return {
      'email': user.email,
      'name': user.name,
      'surname': user.surname,
    };
  }
}
