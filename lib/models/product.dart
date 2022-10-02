import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inzynierka/models/sort.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const Product._();

  const factory Product({
    required String id,
    required String name,
    @Default([]) List<String> keywords,
    String? photo,
    String? photoSmall,
    @Default([]) List<String> symbols,
    Sort? sort,
    String? verifiedBy,
    required Map<String, Sort> sortProposals,
    required List<String> variants,
    required String user,
    required DateTime addedDate,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
  }) = _Product;

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
      sortProposals: (data['sortProposals'] as Map)
          .cast<String, Map<String, dynamic>>()
          .map((key, value) => MapEntry(key, Sort.fromFirestore(value))),
      variants: (data['variants'] as List).cast<String>(),
      user: data['user'],
      addedDate: (data['addedDate'] as Timestamp).toDate(),
      snapshot: snapshot,
    );
  }

  List<String>? get containers {
    if (sort == null) {
      return null;
    }

    return Set<String>.from(sort!.elements.map((e) => e.container.name)).toList();
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
      'sortProposals': product.sortProposals.map((key, value) => MapEntry(key, Sort.toFirestore(value))),
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
