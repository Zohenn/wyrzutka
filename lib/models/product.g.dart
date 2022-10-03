// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Product _$$_ProductFromJson(Map<String, dynamic> json) => _$_Product(
      id: json['id'] as String,
      name: json['name'] as String,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      photo: json['photo'] as String?,
      photoSmall: json['photoSmall'] as String?,
      symbols: (json['symbols'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sort: json['sort'] == null
          ? null
          : Sort.fromJson(json['sort'] as Map<String, dynamic>),
      verifiedBy: json['verifiedBy'] as String?,
      sortProposals: (json['sortProposals'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Sort.fromJson(e as Map<String, dynamic>)),
      ),
      variants:
          (json['variants'] as List<dynamic>).map((e) => e as String).toList(),
      user: json['user'] as String,
      addedDate: dateTimeFromJson(json['addedDate'] as Timestamp?),
      snapshot: snapshotFromJson(json['snapshot']),
    );

Map<String, dynamic> _$$_ProductToJson(_$_Product instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', toJsonNull(instance.id));
  val['name'] = instance.name;
  val['keywords'] = instance.keywords;
  val['photo'] = instance.photo;
  val['photoSmall'] = instance.photoSmall;
  val['symbols'] = instance.symbols;
  val['sort'] = instance.sort;
  val['verifiedBy'] = instance.verifiedBy;
  val['sortProposals'] = instance.sortProposals;
  val['variants'] = instance.variants;
  val['user'] = instance.user;
  val['addedDate'] = instance.addedDate.toIso8601String();
  writeNotNull('snapshot', toJsonNull(instance.snapshot));
  return val;
}
