// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Sort _$$_SortFromJson(Map<String, dynamic> json) => _$_Sort(
      id: json['id'] as String,
      user: json['user'] as String,
      elements: (json['elements'] as List<dynamic>)
          .map((e) => SortElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      voteBalance: json['voteBalance'] as int,
      votes: (json['votes'] as List<dynamic>)
          .map((e) => Vote.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_SortToJson(_$_Sort instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'elements': instance.elements,
      'voteBalance': instance.voteBalance,
      'votes': instance.votes,
    };
