// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gym_theme.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GymTheme {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Color get primary => throw _privateConstructorUsedError;
  Color get soft => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;

  /// Create a copy of GymTheme
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymThemeCopyWith<GymTheme> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymThemeCopyWith<$Res> {
  factory $GymThemeCopyWith(GymTheme value, $Res Function(GymTheme) then) =
      _$GymThemeCopyWithImpl<$Res, GymTheme>;
  @useResult
  $Res call({String id, String name, Color primary, Color soft, String note});
}

/// @nodoc
class _$GymThemeCopyWithImpl<$Res, $Val extends GymTheme>
    implements $GymThemeCopyWith<$Res> {
  _$GymThemeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymTheme
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? primary = null,
    Object? soft = null,
    Object? note = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            primary: null == primary
                ? _value.primary
                : primary // ignore: cast_nullable_to_non_nullable
                      as Color,
            soft: null == soft
                ? _value.soft
                : soft // ignore: cast_nullable_to_non_nullable
                      as Color,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GymThemeImplCopyWith<$Res>
    implements $GymThemeCopyWith<$Res> {
  factory _$$GymThemeImplCopyWith(
    _$GymThemeImpl value,
    $Res Function(_$GymThemeImpl) then,
  ) = __$$GymThemeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, Color primary, Color soft, String note});
}

/// @nodoc
class __$$GymThemeImplCopyWithImpl<$Res>
    extends _$GymThemeCopyWithImpl<$Res, _$GymThemeImpl>
    implements _$$GymThemeImplCopyWith<$Res> {
  __$$GymThemeImplCopyWithImpl(
    _$GymThemeImpl _value,
    $Res Function(_$GymThemeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GymTheme
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? primary = null,
    Object? soft = null,
    Object? note = null,
  }) {
    return _then(
      _$GymThemeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        primary: null == primary
            ? _value.primary
            : primary // ignore: cast_nullable_to_non_nullable
                  as Color,
        soft: null == soft
            ? _value.soft
            : soft // ignore: cast_nullable_to_non_nullable
                  as Color,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GymThemeImpl implements _GymTheme {
  const _$GymThemeImpl({
    required this.id,
    required this.name,
    required this.primary,
    required this.soft,
    required this.note,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final Color primary;
  @override
  final Color soft;
  @override
  final String note;

  @override
  String toString() {
    return 'GymTheme(id: $id, name: $name, primary: $primary, soft: $soft, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymThemeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.primary, primary) || other.primary == primary) &&
            (identical(other.soft, soft) || other.soft == soft) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, primary, soft, note);

  /// Create a copy of GymTheme
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymThemeImplCopyWith<_$GymThemeImpl> get copyWith =>
      __$$GymThemeImplCopyWithImpl<_$GymThemeImpl>(this, _$identity);
}

abstract class _GymTheme implements GymTheme {
  const factory _GymTheme({
    required final String id,
    required final String name,
    required final Color primary,
    required final Color soft,
    required final String note,
  }) = _$GymThemeImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  Color get primary;
  @override
  Color get soft;
  @override
  String get note;

  /// Create a copy of GymTheme
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymThemeImplCopyWith<_$GymThemeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GymThemeState {
  List<GymTheme> get themes => throw _privateConstructorUsedError;
  String get activeThemeId => throw _privateConstructorUsedError;
  bool get watermarkEnabled => throw _privateConstructorUsedError;

  /// Create a copy of GymThemeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymThemeStateCopyWith<GymThemeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymThemeStateCopyWith<$Res> {
  factory $GymThemeStateCopyWith(
    GymThemeState value,
    $Res Function(GymThemeState) then,
  ) = _$GymThemeStateCopyWithImpl<$Res, GymThemeState>;
  @useResult
  $Res call({
    List<GymTheme> themes,
    String activeThemeId,
    bool watermarkEnabled,
  });
}

/// @nodoc
class _$GymThemeStateCopyWithImpl<$Res, $Val extends GymThemeState>
    implements $GymThemeStateCopyWith<$Res> {
  _$GymThemeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymThemeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themes = null,
    Object? activeThemeId = null,
    Object? watermarkEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            themes: null == themes
                ? _value.themes
                : themes // ignore: cast_nullable_to_non_nullable
                      as List<GymTheme>,
            activeThemeId: null == activeThemeId
                ? _value.activeThemeId
                : activeThemeId // ignore: cast_nullable_to_non_nullable
                      as String,
            watermarkEnabled: null == watermarkEnabled
                ? _value.watermarkEnabled
                : watermarkEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GymThemeStateImplCopyWith<$Res>
    implements $GymThemeStateCopyWith<$Res> {
  factory _$$GymThemeStateImplCopyWith(
    _$GymThemeStateImpl value,
    $Res Function(_$GymThemeStateImpl) then,
  ) = __$$GymThemeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<GymTheme> themes,
    String activeThemeId,
    bool watermarkEnabled,
  });
}

/// @nodoc
class __$$GymThemeStateImplCopyWithImpl<$Res>
    extends _$GymThemeStateCopyWithImpl<$Res, _$GymThemeStateImpl>
    implements _$$GymThemeStateImplCopyWith<$Res> {
  __$$GymThemeStateImplCopyWithImpl(
    _$GymThemeStateImpl _value,
    $Res Function(_$GymThemeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GymThemeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themes = null,
    Object? activeThemeId = null,
    Object? watermarkEnabled = null,
  }) {
    return _then(
      _$GymThemeStateImpl(
        themes: null == themes
            ? _value._themes
            : themes // ignore: cast_nullable_to_non_nullable
                  as List<GymTheme>,
        activeThemeId: null == activeThemeId
            ? _value.activeThemeId
            : activeThemeId // ignore: cast_nullable_to_non_nullable
                  as String,
        watermarkEnabled: null == watermarkEnabled
            ? _value.watermarkEnabled
            : watermarkEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$GymThemeStateImpl implements _GymThemeState {
  const _$GymThemeStateImpl({
    required final List<GymTheme> themes,
    required this.activeThemeId,
    this.watermarkEnabled = true,
  }) : _themes = themes;

  final List<GymTheme> _themes;
  @override
  List<GymTheme> get themes {
    if (_themes is EqualUnmodifiableListView) return _themes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_themes);
  }

  @override
  final String activeThemeId;
  @override
  @JsonKey()
  final bool watermarkEnabled;

  @override
  String toString() {
    return 'GymThemeState(themes: $themes, activeThemeId: $activeThemeId, watermarkEnabled: $watermarkEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymThemeStateImpl &&
            const DeepCollectionEquality().equals(other._themes, _themes) &&
            (identical(other.activeThemeId, activeThemeId) ||
                other.activeThemeId == activeThemeId) &&
            (identical(other.watermarkEnabled, watermarkEnabled) ||
                other.watermarkEnabled == watermarkEnabled));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_themes),
    activeThemeId,
    watermarkEnabled,
  );

  /// Create a copy of GymThemeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymThemeStateImplCopyWith<_$GymThemeStateImpl> get copyWith =>
      __$$GymThemeStateImplCopyWithImpl<_$GymThemeStateImpl>(this, _$identity);
}

abstract class _GymThemeState implements GymThemeState {
  const factory _GymThemeState({
    required final List<GymTheme> themes,
    required final String activeThemeId,
    final bool watermarkEnabled,
  }) = _$GymThemeStateImpl;

  @override
  List<GymTheme> get themes;
  @override
  String get activeThemeId;
  @override
  bool get watermarkEnabled;

  /// Create a copy of GymThemeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymThemeStateImplCopyWith<_$GymThemeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
