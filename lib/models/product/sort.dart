import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/models/util.dart';

part 'sort.freezed.dart';
part 'sort.g.dart';

@freezed
class Sort with _$Sort {
  const factory Sort({
    @JsonKey(toJson: toJsonNull, includeIfNull: false) required String id,
    required String user,
    required List<SortElement> elements,
    @Default(0) int voteBalance,
    @Default({}) Map<String, bool> votes,
  }) = _Sort;

  factory Sort.verified({
    required String user,
    required List<SortElement> elements,
  }) =>
      Sort(
        id: '',
        user: user,
        elements: elements,
        voteBalance: 0,
        votes: {},
      );

  factory Sort.fromJson(Map<String, dynamic> json) => _$SortFromJson(json);
}
