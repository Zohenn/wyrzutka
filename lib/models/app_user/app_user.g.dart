// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_AppUser _$$_AppUserFromJson(Map<String, dynamic> json) => _$_AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
    );

Map<String, dynamic> _$$_AppUserToJson(_$_AppUser instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', toNull(instance.id));
  val['email'] = instance.email;
  val['name'] = instance.name;
  val['surname'] = instance.surname;
  return val;
}
