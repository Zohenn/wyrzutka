import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

// todo: migrate to freezed
@immutable
class ProductSymbol {
  const ProductSymbol({
    required this.id,
    required this.name,
    required this.photo,
    this.description,
  });

  final String id;
  final String name;
  final String photo;
  final String? description;

  factory ProductSymbol.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return ProductSymbol(
      id: snapshot.id,
      name: data['name'],
      photo: data['photo'],
      description: data['description'],
    );
  }

  static Map<String, Object?> toFirestore(ProductSymbol product, SetOptions? options) {
    return {
      'name': product.name,
      'photo': product.photo,
      'description': product.description,
    };
  }
}
