// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SortElement _$$_SortElementFromJson(Map<String, dynamic> json) =>
    _$_SortElement(
      container: $enumDecode(_$ElementContainerEnumMap, json['container']),
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$_SortElementToJson(_$_SortElement instance) =>
    <String, dynamic>{
      'container': _$ElementContainerEnumMap[instance.container]!,
      'name': instance.name,
      'description': instance.description,
    };

const _$ElementContainerEnumMap = {
  ElementContainer.plastic: 'plastic',
  ElementContainer.paper: 'paper',
  ElementContainer.bio: 'bio',
  ElementContainer.mixed: 'mixed',
  ElementContainer.glass: 'glass',
  ElementContainer.empty: 'empty',
};
