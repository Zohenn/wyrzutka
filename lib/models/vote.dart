import 'package:flutter/widgets.dart';

@immutable
class Vote {
  const Vote({
    required this.user,
    required this.value,
  });

  factory Vote.fromFirestore(Map<String, dynamic> data) {
    return Vote(
      user: data['user'],
      value: data['value'],
    );
  }

  final String user;
  final bool value;

  static toFirestore(Vote vote) {
    return {
      'user': vote.user,
      'value': vote.value,
    };
  }
}
