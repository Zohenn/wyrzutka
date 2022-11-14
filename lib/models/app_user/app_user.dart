import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/identifiable.dart';
import 'package:inzynierka/models/util.dart';
import 'package:inzynierka/theme/colors.dart';

part 'app_user.freezed.dart';

part 'app_user.g.dart';

enum Role {
  user,
  mod,
  admin;

  String get desc {
    switch (this) {
      case Role.user:
        return 'Zwykły użytkownik';
      case Role.mod:
        return 'Moderator';
      case Role.admin:
        return 'Administrator';
    }
  }

  Color get descColor {
    switch (this) {
      case Role.user:
        return Colors.black54;
      case Role.mod:
        return AppColors.primaryDarker;
      case Role.admin:
        return Colors.redAccent;
    }
  }
}

@freezed
class AppUser with _$AppUser, Identifiable {
  const AppUser._();

  const factory AppUser({
    @JsonKey(toJson: toJsonNull, includeIfNull: false) required String id,
    required String email,
    required String name,
    required String surname,
    required Role role,
    @JsonKey(fromJson: FirestoreDateTime.fromFirestore, toJson: FirestoreDateTime.toFirestore)
        required FirestoreDateTime signUpDate,
    @Default([]) List<String> savedProducts,
    @Default([]) List<String> verifiedSortProposals,
    @JsonKey(fromJson: snapshotFromJson, toJson: toJsonNull, includeIfNull: false)
        DocumentSnapshot<Map<String, dynamic>>? snapshot,
  }) = _AppUser;

  factory AppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return AppUser.fromJson({
      'id': snapshot.id,
      'snapshot': snapshot,
      ...data,
    });
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  String get displayName => '$name $surname';

  static Map<String, Object?> toFirestore(AppUser user, SetOptions? options) {
    return {
      ...user.toJson(),
      'searchNameSurname': '${user.name} ${user.surname} ${user.name}'.toLowerCase(),
    };
  }
}
