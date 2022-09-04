import 'package:flutter/widgets.dart';

@immutable
class SortElement {
  const SortElement({
    required this.container,
    required this.name,
    this.description,
  });

  final String container;
  final String name;
  final String? description;
}
