// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'product_symbol.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ProductSymbol _$ProductSymbolFromJson(Map<String, dynamic> json) {
  return _ProductSymbol.fromJson(json);
}

/// @nodoc
mixin _$ProductSymbol {
  @JsonKey(toJson: toJsonNull, includeIfNull: false)
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get photo => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductSymbolCopyWith<ProductSymbol> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductSymbolCopyWith<$Res> {
  factory $ProductSymbolCopyWith(
          ProductSymbol value, $Res Function(ProductSymbol) then) =
      _$ProductSymbolCopyWithImpl<$Res>;
  $Res call(
      {@JsonKey(toJson: toJsonNull, includeIfNull: false) String id,
      String name,
      String photo,
      String? description});
}

/// @nodoc
class _$ProductSymbolCopyWithImpl<$Res>
    implements $ProductSymbolCopyWith<$Res> {
  _$ProductSymbolCopyWithImpl(this._value, this._then);

  final ProductSymbol _value;
  // ignore: unused_field
  final $Res Function(ProductSymbol) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? photo = freezed,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      photo: photo == freezed
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_ProductSymbolCopyWith<$Res>
    implements $ProductSymbolCopyWith<$Res> {
  factory _$$_ProductSymbolCopyWith(
          _$_ProductSymbol value, $Res Function(_$_ProductSymbol) then) =
      __$$_ProductSymbolCopyWithImpl<$Res>;
  @override
  $Res call(
      {@JsonKey(toJson: toJsonNull, includeIfNull: false) String id,
      String name,
      String photo,
      String? description});
}

/// @nodoc
class __$$_ProductSymbolCopyWithImpl<$Res>
    extends _$ProductSymbolCopyWithImpl<$Res>
    implements _$$_ProductSymbolCopyWith<$Res> {
  __$$_ProductSymbolCopyWithImpl(
      _$_ProductSymbol _value, $Res Function(_$_ProductSymbol) _then)
      : super(_value, (v) => _then(v as _$_ProductSymbol));

  @override
  _$_ProductSymbol get _value => super._value as _$_ProductSymbol;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? photo = freezed,
    Object? description = freezed,
  }) {
    return _then(_$_ProductSymbol(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      photo: photo == freezed
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ProductSymbol implements _ProductSymbol {
  const _$_ProductSymbol(
      {@JsonKey(toJson: toJsonNull, includeIfNull: false) required this.id,
      required this.name,
      required this.photo,
      this.description});

  factory _$_ProductSymbol.fromJson(Map<String, dynamic> json) =>
      _$$_ProductSymbolFromJson(json);

  @override
  @JsonKey(toJson: toJsonNull, includeIfNull: false)
  final String id;
  @override
  final String name;
  @override
  final String photo;
  @override
  final String? description;

  @override
  String toString() {
    return 'ProductSymbol(id: $id, name: $name, photo: $photo, description: $description)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ProductSymbol &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.photo, photo) &&
            const DeepCollectionEquality()
                .equals(other.description, description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(photo),
      const DeepCollectionEquality().hash(description));

  @JsonKey(ignore: true)
  @override
  _$$_ProductSymbolCopyWith<_$_ProductSymbol> get copyWith =>
      __$$_ProductSymbolCopyWithImpl<_$_ProductSymbol>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ProductSymbolToJson(
      this,
    );
  }
}

abstract class _ProductSymbol implements ProductSymbol {
  const factory _ProductSymbol(
      {@JsonKey(toJson: toJsonNull, includeIfNull: false)
          required final String id,
      required final String name,
      required final String photo,
      final String? description}) = _$_ProductSymbol;

  factory _ProductSymbol.fromJson(Map<String, dynamic> json) =
      _$_ProductSymbol.fromJson;

  @override
  @JsonKey(toJson: toJsonNull, includeIfNull: false)
  String get id;
  @override
  String get name;
  @override
  String get photo;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$_ProductSymbolCopyWith<_$_ProductSymbol> get copyWith =>
      throw _privateConstructorUsedError;
}
