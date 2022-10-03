// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  @JsonKey(toJson: toJsonNull, includeIfNull: false)
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get keywords => throw _privateConstructorUsedError;
  String? get photo => throw _privateConstructorUsedError;
  String? get photoSmall => throw _privateConstructorUsedError;
  List<String> get symbols => throw _privateConstructorUsedError;
  Sort? get sort => throw _privateConstructorUsedError;
  String? get verifiedBy => throw _privateConstructorUsedError;
  Map<String, Sort> get sortProposals => throw _privateConstructorUsedError;
  List<String> get variants => throw _privateConstructorUsedError;
  String get user => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromJson)
  DateTime get addedDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: snapshotFromJson, toJson: toJsonNull, includeIfNull: false)
  DocumentSnapshot<Map<String, dynamic>>? get snapshot =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res>;
  $Res call(
      {@JsonKey(toJson: toJsonNull, includeIfNull: false)
          String id,
      String name,
      List<String> keywords,
      String? photo,
      String? photoSmall,
      List<String> symbols,
      Sort? sort,
      String? verifiedBy,
      Map<String, Sort> sortProposals,
      List<String> variants,
      String user,
      @JsonKey(fromJson: dateTimeFromJson)
          DateTime addedDate,
      @JsonKey(fromJson: snapshotFromJson, toJson: toJsonNull, includeIfNull: false)
          DocumentSnapshot<Map<String, dynamic>>? snapshot});

  $SortCopyWith<$Res>? get sort;
}

/// @nodoc
class _$ProductCopyWithImpl<$Res> implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  final Product _value;
  // ignore: unused_field
  final $Res Function(Product) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? keywords = freezed,
    Object? photo = freezed,
    Object? photoSmall = freezed,
    Object? symbols = freezed,
    Object? sort = freezed,
    Object? verifiedBy = freezed,
    Object? sortProposals = freezed,
    Object? variants = freezed,
    Object? user = freezed,
    Object? addedDate = freezed,
    Object? snapshot = freezed,
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
      keywords: keywords == freezed
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      photo: photo == freezed
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String?,
      photoSmall: photoSmall == freezed
          ? _value.photoSmall
          : photoSmall // ignore: cast_nullable_to_non_nullable
              as String?,
      symbols: symbols == freezed
          ? _value.symbols
          : symbols // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sort: sort == freezed
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as Sort?,
      verifiedBy: verifiedBy == freezed
          ? _value.verifiedBy
          : verifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      sortProposals: sortProposals == freezed
          ? _value.sortProposals
          : sortProposals // ignore: cast_nullable_to_non_nullable
              as Map<String, Sort>,
      variants: variants == freezed
          ? _value.variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      user: user == freezed
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      addedDate: addedDate == freezed
          ? _value.addedDate
          : addedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      snapshot: snapshot == freezed
          ? _value.snapshot
          : snapshot // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot<Map<String, dynamic>>?,
    ));
  }

  @override
  $SortCopyWith<$Res>? get sort {
    if (_value.sort == null) {
      return null;
    }

    return $SortCopyWith<$Res>(_value.sort!, (value) {
      return _then(_value.copyWith(sort: value));
    });
  }
}

/// @nodoc
abstract class _$$_ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$_ProductCopyWith(
          _$_Product value, $Res Function(_$_Product) then) =
      __$$_ProductCopyWithImpl<$Res>;
  @override
  $Res call(
      {@JsonKey(toJson: toJsonNull, includeIfNull: false)
          String id,
      String name,
      List<String> keywords,
      String? photo,
      String? photoSmall,
      List<String> symbols,
      Sort? sort,
      String? verifiedBy,
      Map<String, Sort> sortProposals,
      List<String> variants,
      String user,
      @JsonKey(fromJson: dateTimeFromJson)
          DateTime addedDate,
      @JsonKey(fromJson: snapshotFromJson, toJson: toJsonNull, includeIfNull: false)
          DocumentSnapshot<Map<String, dynamic>>? snapshot});

  @override
  $SortCopyWith<$Res>? get sort;
}

/// @nodoc
class __$$_ProductCopyWithImpl<$Res> extends _$ProductCopyWithImpl<$Res>
    implements _$$_ProductCopyWith<$Res> {
  __$$_ProductCopyWithImpl(_$_Product _value, $Res Function(_$_Product) _then)
      : super(_value, (v) => _then(v as _$_Product));

  @override
  _$_Product get _value => super._value as _$_Product;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? keywords = freezed,
    Object? photo = freezed,
    Object? photoSmall = freezed,
    Object? symbols = freezed,
    Object? sort = freezed,
    Object? verifiedBy = freezed,
    Object? sortProposals = freezed,
    Object? variants = freezed,
    Object? user = freezed,
    Object? addedDate = freezed,
    Object? snapshot = freezed,
  }) {
    return _then(_$_Product(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      keywords: keywords == freezed
          ? _value._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      photo: photo == freezed
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String?,
      photoSmall: photoSmall == freezed
          ? _value.photoSmall
          : photoSmall // ignore: cast_nullable_to_non_nullable
              as String?,
      symbols: symbols == freezed
          ? _value._symbols
          : symbols // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sort: sort == freezed
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as Sort?,
      verifiedBy: verifiedBy == freezed
          ? _value.verifiedBy
          : verifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      sortProposals: sortProposals == freezed
          ? _value._sortProposals
          : sortProposals // ignore: cast_nullable_to_non_nullable
              as Map<String, Sort>,
      variants: variants == freezed
          ? _value._variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      user: user == freezed
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      addedDate: addedDate == freezed
          ? _value.addedDate
          : addedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      snapshot: snapshot == freezed
          ? _value.snapshot
          : snapshot // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot<Map<String, dynamic>>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Product extends _Product {
  const _$_Product(
      {@JsonKey(toJson: toJsonNull, includeIfNull: false)
          required this.id,
      required this.name,
      final List<String> keywords = const [],
      this.photo,
      this.photoSmall,
      final List<String> symbols = const [],
      this.sort,
      this.verifiedBy,
      required final Map<String, Sort> sortProposals,
      required final List<String> variants,
      required this.user,
      @JsonKey(fromJson: dateTimeFromJson)
          required this.addedDate,
      @JsonKey(fromJson: snapshotFromJson, toJson: toJsonNull, includeIfNull: false)
          this.snapshot})
      : _keywords = keywords,
        _symbols = symbols,
        _sortProposals = sortProposals,
        _variants = variants,
        super._();

  factory _$_Product.fromJson(Map<String, dynamic> json) =>
      _$$_ProductFromJson(json);

  @override
  @JsonKey(toJson: toJsonNull, includeIfNull: false)
  final String id;
  @override
  final String name;
  final List<String> _keywords;
  @override
  @JsonKey()
  List<String> get keywords {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywords);
  }

  @override
  final String? photo;
  @override
  final String? photoSmall;
  final List<String> _symbols;
  @override
  @JsonKey()
  List<String> get symbols {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_symbols);
  }

  @override
  final Sort? sort;
  @override
  final String? verifiedBy;
  final Map<String, Sort> _sortProposals;
  @override
  Map<String, Sort> get sortProposals {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sortProposals);
  }

  final List<String> _variants;
  @override
  List<String> get variants {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variants);
  }

  @override
  final String user;
  @override
  @JsonKey(fromJson: dateTimeFromJson)
  final DateTime addedDate;
  @override
  @JsonKey(fromJson: snapshotFromJson, toJson: toJsonNull, includeIfNull: false)
  final DocumentSnapshot<Map<String, dynamic>>? snapshot;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, keywords: $keywords, photo: $photo, photoSmall: $photoSmall, symbols: $symbols, sort: $sort, verifiedBy: $verifiedBy, sortProposals: $sortProposals, variants: $variants, user: $user, addedDate: $addedDate, snapshot: $snapshot)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Product &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            const DeepCollectionEquality().equals(other.photo, photo) &&
            const DeepCollectionEquality()
                .equals(other.photoSmall, photoSmall) &&
            const DeepCollectionEquality().equals(other._symbols, _symbols) &&
            const DeepCollectionEquality().equals(other.sort, sort) &&
            const DeepCollectionEquality()
                .equals(other.verifiedBy, verifiedBy) &&
            const DeepCollectionEquality()
                .equals(other._sortProposals, _sortProposals) &&
            const DeepCollectionEquality().equals(other._variants, _variants) &&
            const DeepCollectionEquality().equals(other.user, user) &&
            const DeepCollectionEquality().equals(other.addedDate, addedDate) &&
            const DeepCollectionEquality().equals(other.snapshot, snapshot));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(_keywords),
      const DeepCollectionEquality().hash(photo),
      const DeepCollectionEquality().hash(photoSmall),
      const DeepCollectionEquality().hash(_symbols),
      const DeepCollectionEquality().hash(sort),
      const DeepCollectionEquality().hash(verifiedBy),
      const DeepCollectionEquality().hash(_sortProposals),
      const DeepCollectionEquality().hash(_variants),
      const DeepCollectionEquality().hash(user),
      const DeepCollectionEquality().hash(addedDate),
      const DeepCollectionEquality().hash(snapshot));

  @JsonKey(ignore: true)
  @override
  _$$_ProductCopyWith<_$_Product> get copyWith =>
      __$$_ProductCopyWithImpl<_$_Product>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ProductToJson(
      this,
    );
  }
}

abstract class _Product extends Product {
  const factory _Product(
      {@JsonKey(toJson: toJsonNull, includeIfNull: false)
          required final String id,
      required final String name,
      final List<String> keywords,
      final String? photo,
      final String? photoSmall,
      final List<String> symbols,
      final Sort? sort,
      final String? verifiedBy,
      required final Map<String, Sort> sortProposals,
      required final List<String> variants,
      required final String user,
      @JsonKey(fromJson: dateTimeFromJson)
          required final DateTime addedDate,
      @JsonKey(fromJson: snapshotFromJson, toJson: toJsonNull, includeIfNull: false)
          final DocumentSnapshot<Map<String, dynamic>>? snapshot}) = _$_Product;
  const _Product._() : super._();

  factory _Product.fromJson(Map<String, dynamic> json) = _$_Product.fromJson;

  @override
  @JsonKey(toJson: toJsonNull, includeIfNull: false)
  String get id;
  @override
  String get name;
  @override
  List<String> get keywords;
  @override
  String? get photo;
  @override
  String? get photoSmall;
  @override
  List<String> get symbols;
  @override
  Sort? get sort;
  @override
  String? get verifiedBy;
  @override
  Map<String, Sort> get sortProposals;
  @override
  List<String> get variants;
  @override
  String get user;
  @override
  @JsonKey(fromJson: dateTimeFromJson)
  DateTime get addedDate;
  @override
  @JsonKey(fromJson: snapshotFromJson, toJson: toJsonNull, includeIfNull: false)
  DocumentSnapshot<Map<String, dynamic>>? get snapshot;
  @override
  @JsonKey(ignore: true)
  _$$_ProductCopyWith<_$_Product> get copyWith =>
      throw _privateConstructorUsedError;
}
