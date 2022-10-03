// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_symbol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ProductSymbol _$$_ProductSymbolFromJson(Map<String, dynamic> json) =>
    _$_ProductSymbol(
      id: json['id'] as String,
      name: json['name'] as String,
      photo: json['photo'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$_ProductSymbolToJson(_$_ProductSymbol instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', toJsonNull(instance.id));
  val['name'] = instance.name;
  val['photo'] = instance.photo;
  val['description'] = instance.description;
  return val;
}
