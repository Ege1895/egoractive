// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gym_rules.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GymRules {
  List<dynamic> get delta => throw _privateConstructorUsedError;
  String? get lastUpdatedLabel => throw _privateConstructorUsedError;

  /// Create a copy of GymRules
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymRulesCopyWith<GymRules> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymRulesCopyWith<$Res> {
  factory $GymRulesCopyWith(GymRules value, $Res Function(GymRules) then) =
      _$GymRulesCopyWithImpl<$Res, GymRules>;
  @useResult
  $Res call({List<dynamic> delta, String? lastUpdatedLabel});
}

/// @nodoc
class _$GymRulesCopyWithImpl<$Res, $Val extends GymRules>
    implements $GymRulesCopyWith<$Res> {
  _$GymRulesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymRules
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? delta = null, Object? lastUpdatedLabel = freezed}) {
    return _then(
      _value.copyWith(
            delta: null == delta
                ? _value.delta
                : delta // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            lastUpdatedLabel: freezed == lastUpdatedLabel
                ? _value.lastUpdatedLabel
                : lastUpdatedLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GymRulesImplCopyWith<$Res>
    implements $GymRulesCopyWith<$Res> {
  factory _$$GymRulesImplCopyWith(
    _$GymRulesImpl value,
    $Res Function(_$GymRulesImpl) then,
  ) = __$$GymRulesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<dynamic> delta, String? lastUpdatedLabel});
}

/// @nodoc
class __$$GymRulesImplCopyWithImpl<$Res>
    extends _$GymRulesCopyWithImpl<$Res, _$GymRulesImpl>
    implements _$$GymRulesImplCopyWith<$Res> {
  __$$GymRulesImplCopyWithImpl(
    _$GymRulesImpl _value,
    $Res Function(_$GymRulesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GymRules
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? delta = null, Object? lastUpdatedLabel = freezed}) {
    return _then(
      _$GymRulesImpl(
        delta: null == delta
            ? _value._delta
            : delta // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        lastUpdatedLabel: freezed == lastUpdatedLabel
            ? _value.lastUpdatedLabel
            : lastUpdatedLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$GymRulesImpl implements _GymRules {
  const _$GymRulesImpl({
    required final List<dynamic> delta,
    this.lastUpdatedLabel,
  }) : _delta = delta;

  final List<dynamic> _delta;
  @override
  List<dynamic> get delta {
    if (_delta is EqualUnmodifiableListView) return _delta;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_delta);
  }

  @override
  final String? lastUpdatedLabel;

  @override
  String toString() {
    return 'GymRules(delta: $delta, lastUpdatedLabel: $lastUpdatedLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymRulesImpl &&
            const DeepCollectionEquality().equals(other._delta, _delta) &&
            (identical(other.lastUpdatedLabel, lastUpdatedLabel) ||
                other.lastUpdatedLabel == lastUpdatedLabel));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_delta),
    lastUpdatedLabel,
  );

  /// Create a copy of GymRules
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymRulesImplCopyWith<_$GymRulesImpl> get copyWith =>
      __$$GymRulesImplCopyWithImpl<_$GymRulesImpl>(this, _$identity);
}

abstract class _GymRules implements GymRules {
  const factory _GymRules({
    required final List<dynamic> delta,
    final String? lastUpdatedLabel,
  }) = _$GymRulesImpl;

  @override
  List<dynamic> get delta;
  @override
  String? get lastUpdatedLabel;

  /// Create a copy of GymRules
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymRulesImplCopyWith<_$GymRulesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
