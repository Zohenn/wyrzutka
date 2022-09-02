import 'package:flutter/widgets.dart';

@immutable
class Product {
  const Product({
    required this.name,
    required this.photo,
    required this.symbols,
    required this.containers,
  });

  final String name;
  final String photo;
  final List<String> symbols;
  final List<String> containers;
}
