import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_symbol.freezed.dart';
part 'product_symbol.g.dart';

toJsonNull(_) => null;

// Symbol already exists within Dart.
@freezed
class ProductSymbol with _$ProductSymbol {
  const factory ProductSymbol({
    @JsonKey(toJson: toJsonNull, includeIfNull: false) required String id,
    required String name,
    required String photo,
    String? description,
  }) = _ProductSymbol;

  factory ProductSymbol.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return ProductSymbol.fromJson({
      'id': snapshot.id,
      ...data,
    });
  }

  factory ProductSymbol.fromJson(Map<String, dynamic> json) => _$ProductSymbolFromJson(json);

  static Map<String, Object?> toFirestore(ProductSymbol product, SetOptions? options) {
    return product.toJson();
  }
}
