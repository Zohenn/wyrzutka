import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inzynierka/app_icons.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/util.dart';

part 'sort_element.freezed.dart';

part 'sort_element.g.dart';

enum ElementContainer {
  plastic,
  paper,
  bio,
  mixed,
  glass,
  // todo: should this be here?
  empty;

  String get containerName {
    switch (this) {
      case ElementContainer.plastic:
        return 'Metale i tworzywa sztuczne';
      case ElementContainer.paper:
        return 'Papier';
      case ElementContainer.bio:
        return 'Bio';
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
      case ElementContainer.plastic:
        return Colors.black54;
      default:
        return Colors.white;
    }
  }

  IconData get icon {
    switch (this) {
      case ElementContainer.plastic:
        return AppIcons.plastic;
      case ElementContainer.mixed:
        return AppIcons.mixed;
      case ElementContainer.paper:
        return AppIcons.paper;
      case ElementContainer.bio:
        return AppIcons.bio;
      case ElementContainer.glass:
        return AppIcons.glass;
      default:
        return Icons.question_mark;
    }
  }
}

@freezed
class SortElement with _$SortElement {
  const factory SortElement({
    required ElementContainer container,
    required String name,
    String? description,
  }) = _SortElement;

  factory SortElement.fromJson(Map<String, dynamic> json) => _$SortElementFromJson(json);
}
