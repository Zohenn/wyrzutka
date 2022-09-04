import 'package:flutter/widgets.dart';

@immutable
class Symbol {
  const Symbol({
    required this.id,
    required this.name,
    required this.photo,
    this.description,
  });

  final String id;
  final String name;
  final String photo;
  final String? description;
}
