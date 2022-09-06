import 'package:flutter/widgets.dart';
import 'package:inzynierka/models/sort_element.dart';

@immutable
class Sort {
  const Sort({
    // required this.user,
    required this.elements,
    // required this.votesBalance,
    // required this.votes,
  });

  // final String user;
  final List<SortElement> elements;
  // final int votesBalance;
  // final List<Vote> votes;

  factory Sort.fromFirestore(Map<String, dynamic> data) {
    return Sort(
      elements: data['elements'],
    );
  }

  static Map<String, Object?> toFirestore(Sort sort) {
    return {
      'user': '',
      'elements': sort.elements.map((e) => SortElement.toFirestore(e)),
      'votesBalance': 0,
      'votes': [],
    };
  }
}
