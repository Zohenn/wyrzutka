import 'package:flutter/widgets.dart';
import 'package:inzynierka/models/sort_element.dart';
import 'package:inzynierka/models/vote.dart';

@immutable
class Sort {
  const Sort({
    required this.id,
    required this.user,
    required this.elements,
    required this.voteBalance,
    required this.votes,
  });

  const Sort.verified({
    required this.user,
    required this.elements,
  })  : id = '',
        voteBalance = 0,
        votes = const <Vote>[];

  factory Sort.fromFirestore(Map<String, dynamic> data) {
    return Sort(
      id: data['id'],
      user: data['user'],
      elements:
          (data['elements'] as List).cast<Map<String, dynamic>>().map((e) => SortElement.fromFirestore(e)).toList(),
      voteBalance: data['voteBalance'],
      votes: (data['votes'] as List).cast<Map<String, dynamic>>().map((e) => Vote.fromFirestore(e)).toList(),
    );
  }

  final String id;
  final String user;
  final List<SortElement> elements;
  final int voteBalance;
  // todo: perhaps this could be changed to Map<String, bool>?
  final List<Vote> votes;

  static Map<String, Object?> toFirestore(Sort sort) {
    return {
      'id': sort.id,
      'user': sort.user,
      'elements': sort.elements.map((e) => SortElement.toFirestore(e)).toList(),
      'voteBalance': sort.voteBalance,
      'votes': sort.votes.map((e) => Vote.toFirestore(e)).toList(),
    };
  }
}
