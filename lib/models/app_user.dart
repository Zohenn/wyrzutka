import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
  });

  final String id;
  final String email;
  final String name;
  final String surname;

  String get displayName => '$name $surname';

  static AppUser fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return AppUser(
      id: snapshot.id,
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

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? surname,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
    );
  }
}
