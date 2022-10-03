// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'sort.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Sort _$SortFromJson(Map<String, dynamic> json) {
  return _Sort.fromJson(json);
}

/// @nodoc
mixin _$Sort {
  String get id => throw _privateConstructorUsedError;
  String get user => throw _privateConstructorUsedError;
  List<SortElement> get elements => throw _privateConstructorUsedError;
  int get voteBalance => throw _privateConstructorUsedError;
  List<Vote> get votes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SortCopyWith<Sort> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SortCopyWith<$Res> {
  factory $SortCopyWith(Sort value, $Res Function(Sort) then) =
      _$SortCopyWithImpl<$Res>;
  $Res call(
      {String id,
      String user,
      List<SortElement> elements,
      int voteBalance,
      List<Vote> votes});
}

/// @nodoc
class _$SortCopyWithImpl<$Res> implements $SortCopyWith<$Res> {
  _$SortCopyWithImpl(this._value, this._then);

  final Sort _value;
  // ignore: unused_field
  final $Res Function(Sort) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? user = freezed,
    Object? elements = freezed,
    Object? voteBalance = freezed,
    Object? votes = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: user == freezed
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      elements: elements == freezed
          ? _value.elements
          : elements // ignore: cast_nullable_to_non_nullable
              as List<SortElement>,
      voteBalance: voteBalance == freezed
          ? _value.voteBalance
          : voteBalance // ignore: cast_nullable_to_non_nullable
              as int,
      votes: votes == freezed
          ? _value.votes
          : votes // ignore: cast_nullable_to_non_nullable
              as List<Vote>,
    ));
  }
}

/// @nodoc
abstract class _$$_SortCopyWith<$Res> implements $SortCopyWith<$Res> {
  factory _$$_SortCopyWith(_$_Sort value, $Res Function(_$_Sort) then) =
      __$$_SortCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      String user,
      List<SortElement> elements,
      int voteBalance,
      List<Vote> votes});
}

/// @nodoc
class __$$_SortCopyWithImpl<$Res> extends _$SortCopyWithImpl<$Res>
    implements _$$_SortCopyWith<$Res> {
  __$$_SortCopyWithImpl(_$_Sort _value, $Res Function(_$_Sort) _then)
      : super(_value, (v) => _then(v as _$_Sort));

  @override
  _$_Sort get _value => super._value as _$_Sort;

  @override
  $Res call({
    Object? id = freezed,
    Object? user = freezed,
    Object? elements = freezed,
    Object? voteBalance = freezed,
    Object? votes = freezed,
  }) {
    return _then(_$_Sort(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: user == freezed
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      elements: elements == freezed
          ? _value._elements
          : elements // ignore: cast_nullable_to_non_nullable
              as List<SortElement>,
      voteBalance: voteBalance == freezed
          ? _value.voteBalance
          : voteBalance // ignore: cast_nullable_to_non_nullable
              as int,
      votes: votes == freezed
          ? _value._votes
          : votes // ignore: cast_nullable_to_non_nullable
              as List<Vote>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Sort implements _Sort {
  const _$_Sort(
      {required this.id,
      required this.user,
      required final List<SortElement> elements,
      required this.voteBalance,
      required final List<Vote> votes})
      : _elements = elements,
        _votes = votes;

  factory _$_Sort.fromJson(Map<String, dynamic> json) => _$$_SortFromJson(json);

  @override
  final String id;
  @override
  final String user;
  final List<SortElement> _elements;
  @override
  List<SortElement> get elements {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_elements);
  }

  @override
  final int voteBalance;
  final List<Vote> _votes;
  @override
  List<Vote> get votes {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_votes);
  }

  @override
  String toString() {
    return 'Sort(id: $id, user: $user, elements: $elements, voteBalance: $voteBalance, votes: $votes)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Sort &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.user, user) &&
            const DeepCollectionEquality().equals(other._elements, _elements) &&
            const DeepCollectionEquality()
                .equals(other.voteBalance, voteBalance) &&
            const DeepCollectionEquality().equals(other._votes, _votes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(user),
      const DeepCollectionEquality().hash(_elements),
      const DeepCollectionEquality().hash(voteBalance),
      const DeepCollectionEquality().hash(_votes));

  @JsonKey(ignore: true)
  @override
  _$$_SortCopyWith<_$_Sort> get copyWith =>
      __$$_SortCopyWithImpl<_$_Sort>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SortToJson(
      this,
    );
  }
}

abstract class _Sort implements Sort {
  const factory _Sort(
      {required final String id,
      required final String user,
      required final List<SortElement> elements,
      required final int voteBalance,
      required final List<Vote> votes}) = _$_Sort;

  factory _Sort.fromJson(Map<String, dynamic> json) = _$_Sort.fromJson;

  @override
  String get id;
  @override
  String get user;
  @override
  List<SortElement> get elements;
  @override
  int get voteBalance;
  @override
  List<Vote> get votes;
  @override
  @JsonKey(ignore: true)
  _$$_SortCopyWith<_$_Sort> get copyWith => throw _privateConstructorUsedError;
}
