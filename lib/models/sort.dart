import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inzynierka/models/sort_element.dart';
import 'package:inzynierka/models/vote.dart';

part 'sort.freezed.dart';
part 'sort.g.dart';

@freezed
class Sort with _$Sort {
  const factory Sort({
    required String id,
    required String user,
    required List<SortElement> elements,
    required int voteBalance,
    // todo: perhaps this could be changed to Map<String, bool>?
    required List<Vote> votes,
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
        votes: [],
      );

  factory Sort.fromJson(Map<String, dynamic> json) => _$SortFromJson(json);
}
