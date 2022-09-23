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
    this.photoSmall,
    required this.symbols,
    this.sort,
    this.verifiedBy,
    required this.sortProposals,
    required this.variants,
    required this.user,
    required this.addedDate,
    this.snapshot,
  });

  final String id;
  final String name;
  final List<String> keywords;
  final String? photo;
  final String? photoSmall;
  final List<String> symbols;
  final Sort? sort;
  final String? verifiedBy;
  final List<Sort> sortProposals;
  final List<String> variants;
  final String user;
  final DateTime addedDate;
  final DocumentSnapshot<Map<String, dynamic>>? snapshot;

  List<String>? get containers {
    if(sort == null){
      return null;
    }

    return Set<String>.from(sort!.elements.map((e) => e.container.name)).toList();
  }

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Product(
      id: snapshot.id,
      name: data['name'],
      keywords: (data['keywords'] as List).cast<String>(),
      photo: data['photo'],
      photoSmall: data['photoSmall'],
      symbols: (data['symbols'] as List).cast<String>(),
      sort: data['sort'] != null ? Sort.fromFirestore(data['sort']) : null,
      verifiedBy: data['verifiedBy'],
      sortProposals: (data['sortProposals'] as List).cast<Map<String, dynamic>>().map((e) => Sort.fromFirestore(e)).toList(),
      variants: (data['variants'] as List).cast<String>(),
      user: data['user'],
      addedDate: (data['addedDate'] as Timestamp).toDate(),
      snapshot: snapshot,
    );
  }

  static Map<String, Object?> toFirestore(Product product, SetOptions? options) {
    return {
      'name': product.name,
      'keywords': product.keywords,
      'photo': product.photo,
      'photoSmall': product.photoSmall,
      'symbols': product.symbols,
      'sort': product.sort != null ? Sort.toFirestore(product.sort!) : null,
      'verifiedBy': product.verifiedBy,
      'sortProposals': product.sortProposals.map((e) => Sort.toFirestore(e)).toList(),
      // containers and containerCount is needed for queries
      'containers': product.containers,
      'containerCount': product.containers?.length ?? 0,
      'variants': product.variants,
      'user': product.user,
      'addedDate': product.addedDate,
      'searchName': product.name.toLowerCase(),
    };
  }
}
