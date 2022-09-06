import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:inzynierka/models/sort.dart';

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    this.keywords = const [],
    this.photo,
    required this.symbols,
    this.sort,
    this.verifiedBy,
    required this.sortProposals,
    this.containers,
    this.containersCount,
    required this.variants,
    required this.user,
    required this.addedDate,
  });

  final String id;
  final String name;
  final List<String> keywords;
  final String? photo;
  final List<String> symbols;
  final Sort? sort;
  final String? verifiedBy;
  final List<Sort> sortProposals;
  final List<String>? containers;
  final int? containersCount;
  final List<String> variants;
  final String user;
  final DateTime addedDate;

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Product(
      id: snapshot.id,
      name: data['name'],
      keywords: data['keywords'],
      photo: data['photo'],
      symbols: data['symbols'],
      sort: data['sort'] != null ? Sort.fromFirestore(data['sort']) : null,
      verifiedBy: data['verifiedBy'],
      sortProposals: (data['sortProposals'] as List).cast<Map<String, dynamic>>().map((e) => Sort.fromFirestore(e)).toList(),
      containers: data['containers'],
      containersCount: data['containersCount'],
      variants: data['variants'],
      user: data['user'],
      addedDate: (data['addedDate'] as Timestamp).toDate(),
    );
  }

  static Map<String, Object?> toFirestore(Product product, SetOptions? options) {
    return {
      'name': product.name,
      'keywords': product.keywords,
      'photo': product.photo,
      'symbols': product.symbols,
      'sort': product.sort != null ? Sort.toFirestore(product.sort!) : null,
      'verifiedBy': product.verifiedBy,
      'sortProposals': product.sortProposals.map((e) => Sort.toFirestore(e)),
      'containers': product.containers,
      'containersCount': product.containersCount,
      'variants': product.variants,
      'user': product.user,
      'addedDate': product.addedDate,
    };
  }
}
