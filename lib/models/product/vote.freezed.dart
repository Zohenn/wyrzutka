// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'vote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Vote _$VoteFromJson(Map<String, dynamic> json) {
  return _Vote.fromJson(json);
}

/// @nodoc
mixin _$Vote {
  String get user => throw _privateConstructorUsedError;
  bool get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VoteCopyWith<Vote> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoteCopyWith<$Res> {
  factory $VoteCopyWith(Vote value, $Res Function(Vote) then) =
      _$VoteCopyWithImpl<$Res>;
  $Res call({String user, bool value});
}

/// @nodoc
class _$VoteCopyWithImpl<$Res> implements $VoteCopyWith<$Res> {
  _$VoteCopyWithImpl(this._value, this._then);

  final Vote _value;
  // ignore: unused_field
  final $Res Function(Vote) _then;

  @override
  $Res call({
    Object? user = freezed,
    Object? value = freezed,
  }) {
    return _then(_value.copyWith(
      user: user == freezed
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      value: value == freezed
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$$_VoteCopyWith<$Res> implements $VoteCopyWith<$Res> {
  factory _$$_VoteCopyWith(_$_Vote value, $Res Function(_$_Vote) then) =
      __$$_VoteCopyWithImpl<$Res>;
  @override
  $Res call({String user, bool value});
}

/// @nodoc
class __$$_VoteCopyWithImpl<$Res> extends _$VoteCopyWithImpl<$Res>
    implements _$$_VoteCopyWith<$Res> {
  __$$_VoteCopyWithImpl(_$_Vote _value, $Res Function(_$_Vote) _then)
      : super(_value, (v) => _then(v as _$_Vote));

  @override
  _$_Vote get _value => super._value as _$_Vote;

  @override
  $Res call({
    Object? user = freezed,
    Object? value = freezed,
  }) {
    return _then(_$_Vote(
      user: user == freezed
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      value: value == freezed
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Vote implements _Vote {
  const _$_Vote({required this.user, required this.value});

  factory _$_Vote.fromJson(Map<String, dynamic> json) => _$$_VoteFromJson(json);

  @override
  final String user;
  @override
  final bool value;

  @override
  String toString() {
    return 'Vote(user: $user, value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Vote &&
            const DeepCollectionEquality().equals(other.user, user) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(user),
      const DeepCollectionEquality().hash(value));

  @JsonKey(ignore: true)
  @override
  _$$_VoteCopyWith<_$_Vote> get copyWith =>
      __$$_VoteCopyWithImpl<_$_Vote>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_VoteToJson(
      this,
    );
  }
}

abstract class _Vote implements Vote {
  const factory _Vote({required final String user, required final bool value}) =
      _$_Vote;

  factory _Vote.fromJson(Map<String, dynamic> json) = _$_Vote.fromJson;

  @override
  String get user;
  @override
  bool get value;
  @override
  @JsonKey(ignore: true)
  _$$_VoteCopyWith<_$_Vote> get copyWith => throw _privateConstructorUsedError;
}
