// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExpenseCategoryOption {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseCategoryOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseCategoryOptionCopyWith<ExpenseCategoryOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseCategoryOptionCopyWith<$Res> {
  factory $ExpenseCategoryOptionCopyWith(
    ExpenseCategoryOption value,
    $Res Function(ExpenseCategoryOption) then,
  ) = _$ExpenseCategoryOptionCopyWithImpl<$Res, ExpenseCategoryOption>;
  @useResult
  $Res call({String id, String label});
}

/// @nodoc
class _$ExpenseCategoryOptionCopyWithImpl<
  $Res,
  $Val extends ExpenseCategoryOption
>
    implements $ExpenseCategoryOptionCopyWith<$Res> {
  _$ExpenseCategoryOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseCategoryOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? label = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpenseCategoryOptionImplCopyWith<$Res>
    implements $ExpenseCategoryOptionCopyWith<$Res> {
  factory _$$ExpenseCategoryOptionImplCopyWith(
    _$ExpenseCategoryOptionImpl value,
    $Res Function(_$ExpenseCategoryOptionImpl) then,
  ) = __$$ExpenseCategoryOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String label});
}

/// @nodoc
class __$$ExpenseCategoryOptionImplCopyWithImpl<$Res>
    extends
        _$ExpenseCategoryOptionCopyWithImpl<$Res, _$ExpenseCategoryOptionImpl>
    implements _$$ExpenseCategoryOptionImplCopyWith<$Res> {
  __$$ExpenseCategoryOptionImplCopyWithImpl(
    _$ExpenseCategoryOptionImpl _value,
    $Res Function(_$ExpenseCategoryOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseCategoryOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? label = null}) {
    return _then(
      _$ExpenseCategoryOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ExpenseCategoryOptionImpl implements _ExpenseCategoryOption {
  const _$ExpenseCategoryOptionImpl({required this.id, required this.label});

  @override
  final String id;
  @override
  final String label;

  @override
  String toString() {
    return 'ExpenseCategoryOption(id: $id, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseCategoryOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, label);

  /// Create a copy of ExpenseCategoryOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseCategoryOptionImplCopyWith<_$ExpenseCategoryOptionImpl>
  get copyWith =>
      __$$ExpenseCategoryOptionImplCopyWithImpl<_$ExpenseCategoryOptionImpl>(
        this,
        _$identity,
      );
}

abstract class _ExpenseCategoryOption implements ExpenseCategoryOption {
  const factory _ExpenseCategoryOption({
    required final String id,
    required final String label,
  }) = _$ExpenseCategoryOptionImpl;

  @override
  String get id;
  @override
  String get label;

  /// Create a copy of ExpenseCategoryOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseCategoryOptionImplCopyWith<_$ExpenseCategoryOptionImpl>
  get copyWith => throw _privateConstructorUsedError;
}
