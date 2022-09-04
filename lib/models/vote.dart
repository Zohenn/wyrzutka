import 'package:flutter/widgets.dart';

@immutable
class Vote {
  const Vote({
    required this.user,
    required this.value,
  });

  final String user;
  final String value;
}
