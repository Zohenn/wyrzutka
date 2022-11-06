import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/identifiable.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/models/util.dart';

part 'product.freezed.dart';

part 'product.g.dart';

Sort? _sortFromJson(Map<String, dynamic>? data) {
  return data != null ? Sort.fromJson({'id': '', ...data}) : null;
}

Map<String, Sort> _sortProposalsFromJson(Map<String, dynamic> data) {
  return data.map((k, e) {
    final sortData = e as Map<String, dynamic>;
    return MapEntry(k, Sort.fromJson({'id': k, ...sortData}));
  });
}

@freezed
class Product with _$Product, Identifiable {
  const Product._();

  const factory Product({
    @JsonKey(toJson: toJsonNull, includeIfNull: false) required String id,
    required String name,
    @Default([]) List<String> keywords,
    String? photo,
    String? photoSmall,
    @Default([]) List<String> symbols,
    @JsonKey(fromJson: _sortFromJson) Sort? sort,
    String? verifiedBy,
    @JsonKey(fromJson: _sortProposalsFromJson) @Default({}) Map<String, Sort> sortProposals,
    @Default([]) List<String> variants,
    required String user,
    @JsonKey(fromJson: FirestoreDateTime.fromFirestore, toJson: FirestoreDateTime.toFirestore)
        required FirestoreDateTime addedDate,
    @JsonKey(fromJson: snapshotFromJson, toJson: toJsonNull, includeIfNull: false)
        DocumentSnapshot<Map<String, dynamic>>? snapshot,
  }) = _Product;

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Product.fromJson({
      'id': snapshot.id,
      'snapshot': snapshot,
      ...data,
    });
  }

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  List<String>? get containers {
    if (sort == null) {
      return null;
    }

    return Set<String>.from(sort!.elements.map((e) => e.container.name)).toList();
  }

  static Map<String, Object?> toFirestore(Product product, SetOptions? options) {
    return {
      ...product.toJson(),
      'containers': product.containers,
      'searchName': product.name.toLowerCase(),
    };
  }
}
