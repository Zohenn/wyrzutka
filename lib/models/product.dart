import 'package:flutter/widgets.dart';
import 'package:inzynierka/models/sort.dart';

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    // this.keywords,
    this.photo,
    required this.symbols,
    this.sort,
    this.verifiedBy,
    required this.sortProposals,
    this.containers,
    // this.containersCount,
    required this.variants,
    this.user,
    // this.addedDate,
  });

  final int id;
  final String name;
  //final List<String>? keywords;
  final String? photo;
  final List<String> symbols;
  final Sort? sort;
  final String? verifiedBy;
  final List<Sort> sortProposals;
  final List<String>? containers;
  // final int? containersCount;
  final List<String> variants;
  final String? user;
  // final DateTime? addedDate;
}
