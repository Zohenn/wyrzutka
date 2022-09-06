import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';

enum ElementContainer {
  plastic,
  paper,
  bio,
  mixed,
  glass,
  empty;

  String get name {
    switch (this) {
      case ElementContainer.plastic:
        return 'Metale i tworzywa sztuczne';
      case ElementContainer.paper:
        return 'Papier';
      case ElementContainer.bio:
        return 'Bytowe';
      case ElementContainer.mixed:
        return 'Zmieszane';
      case ElementContainer.glass:
        return 'Szkło';
      case ElementContainer.empty:
        return 'Brak';
    }
  }

  Color get containerColor {
    switch (this) {
      case ElementContainer.plastic:
        return AppColors.plastic;
      case ElementContainer.paper:
        return AppColors.paper;
      case ElementContainer.glass:
        return AppColors.glass;
      case ElementContainer.mixed:
        return AppColors.mixed;
      case ElementContainer.bio:
        return AppColors.bio;
      case ElementContainer.empty:
        return AppColors.gray;
    }
  }

  Color get iconColor {
    switch (this) {
      case ElementContainer.mixed:
      case ElementContainer.bio:
        return Colors.white;
      default:
        return Colors.black87;
    }
  }
}

@immutable
class SortElement {
  const SortElement({
    required this.container,
    required this.name,
    this.description,
  });

  final ElementContainer container;
  final String name;
  final String? description;

  factory SortElement.fromFirestore(Map<String, dynamic> data) {
    return SortElement(
      container: data['container'],
      name: data['name'],
      description: data['description'],
    );
  }

  static Map<String, Object?> toFirestore(SortElement element) {
    return {
      'container': element.container.index,
      'name': element.name,
      'description': element.description,
    };
  }
}
