import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inzynierka/models/identifiable.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/models/util.dart';

part 'sort_element_template.freezed.dart';

part 'sort_element_template.g.dart';

@freezed
class SortElementTemplate with _$SortElementTemplate, Identifiable {
  const factory SortElementTemplate({
    @JsonKey(toJson: toJsonNull, includeIfNull: false) required String id,
    required ElementContainer container,
    required String name,
    String? description,
    @JsonKey(fromJson: snapshotFromJson, toJson: toJsonNull, includeIfNull: false)
        DocumentSnapshot<Map<String, dynamic>>? snapshot,
  }) = _SortElementTemplate;

  factory SortElementTemplate.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return SortElementTemplate.fromJson({
      'id': snapshot.id,
      'snapshot': snapshot,
      ...data,
    });
  }

  factory SortElementTemplate.fromJson(Map<String, dynamic> json) => _$SortElementTemplateFromJson(json);

  static Map<String, Object?> toFirestore(SortElementTemplate template, SetOptions? options) {
    return template.toJson();
  }
}
