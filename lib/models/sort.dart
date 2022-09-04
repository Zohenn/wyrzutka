import 'package:flutter/widgets.dart';
import 'package:inzynierka/models/sortElement.dart';

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
}
