import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

part 'app_user.g.dart';

toNull(_) => null;

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
}

@freezed
class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    @JsonKey(toJson: toNull, includeIfNull: false) required String id,
    required String email,
    required String name,
    required String surname,
    required Role role,
    @Default([]) List<String> savedProducts,
  }) = _AppUser;

  factory AppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return AppUser.fromJson({
      'id': snapshot.id,
      ...data,
    });
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  String get displayName => '$name $surname';

  static Map<String, Object?> toFirestore(AppUser user, SetOptions? options) {
    return user.toJson();
  }
}
