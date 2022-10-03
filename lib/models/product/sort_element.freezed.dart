// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'sort_element.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SortElement _$SortElementFromJson(Map<String, dynamic> json) {
  return _SortElement.fromJson(json);
}

/// @nodoc
mixin _$SortElement {
  ElementContainer get container => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SortElementCopyWith<SortElement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SortElementCopyWith<$Res> {
  factory $SortElementCopyWith(
          SortElement value, $Res Function(SortElement) then) =
      _$SortElementCopyWithImpl<$Res>;
  $Res call({ElementContainer container, String name, String? description});
}

/// @nodoc
class _$SortElementCopyWithImpl<$Res> implements $SortElementCopyWith<$Res> {
  _$SortElementCopyWithImpl(this._value, this._then);

  final SortElement _value;
  // ignore: unused_field
  final $Res Function(SortElement) _then;

  @override
  $Res call({
    Object? container = freezed,
    Object? name = freezed,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      container: container == freezed
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as ElementContainer,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_SortElementCopyWith<$Res>
    implements $SortElementCopyWith<$Res> {
  factory _$$_SortElementCopyWith(
          _$_SortElement value, $Res Function(_$_SortElement) then) =
      __$$_SortElementCopyWithImpl<$Res>;
  @override
  $Res call({ElementContainer container, String name, String? description});
}

/// @nodoc
class __$$_SortElementCopyWithImpl<$Res> extends _$SortElementCopyWithImpl<$Res>
    implements _$$_SortElementCopyWith<$Res> {
  __$$_SortElementCopyWithImpl(
      _$_SortElement _value, $Res Function(_$_SortElement) _then)
      : super(_value, (v) => _then(v as _$_SortElement));

  @override
  _$_SortElement get _value => super._value as _$_SortElement;

  @override
  $Res call({
    Object? container = freezed,
    Object? name = freezed,
    Object? description = freezed,
  }) {
    return _then(_$_SortElement(
      container: container == freezed
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as ElementContainer,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
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
class _$_SortElement implements _SortElement {
  const _$_SortElement(
      {required this.container, required this.name, this.description});

  factory _$_SortElement.fromJson(Map<String, dynamic> json) =>
      _$$_SortElementFromJson(json);

  @override
  final ElementContainer container;
  @override
  final String name;
  @override
  final String? description;

  @override
  String toString() {
    return 'SortElement(container: $container, name: $name, description: $description)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SortElement &&
            const DeepCollectionEquality().equals(other.container, container) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality()
                .equals(other.description, description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(container),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(description));

  @JsonKey(ignore: true)
  @override
  _$$_SortElementCopyWith<_$_SortElement> get copyWith =>
      __$$_SortElementCopyWithImpl<_$_SortElement>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SortElementToJson(
      this,
    );
  }
}

abstract class _SortElement implements SortElement {
  const factory _SortElement(
      {required final ElementContainer container,
      required final String name,
      final String? description}) = _$_SortElement;

  factory _SortElement.fromJson(Map<String, dynamic> json) =
      _$_SortElement.fromJson;

  @override
  ElementContainer get container;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$_SortElementCopyWith<_$_SortElement> get copyWith =>
      throw _privateConstructorUsedError;
}
