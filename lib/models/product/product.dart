import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inzynierka/models/product/sort.dart';

part 'product.freezed.dart';
part 'product.g.dart';

snapshotFromJson(_) => _;
dateTimeFromJson(Timestamp? timestamp) => timestamp?.toDate();
toJsonNull(_) => null;

@freezed
class Product with _$Product {
  const Product._();

  const factory Product({
    @JsonKey(toJson: toJsonNull, includeIfNull: false) required String id,
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
    @JsonKey(fromJson: dateTimeFromJson) required DateTime addedDate,
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
    return product.toJson();
  }
}