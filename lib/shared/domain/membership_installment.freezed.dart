// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_installment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MembershipInstallment {
  int get index => throw _privateConstructorUsedError;
  int get amountTl => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  bool get paid => throw _privateConstructorUsedError;

  /// Create a copy of MembershipInstallment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembershipInstallmentCopyWith<MembershipInstallment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipInstallmentCopyWith<$Res> {
  factory $MembershipInstallmentCopyWith(
    MembershipInstallment value,
    $Res Function(MembershipInstallment) then,
  ) = _$MembershipInstallmentCopyWithImpl<$Res, MembershipInstallment>;
  @useResult
  $Res call({int index, int amountTl, DateTime dueDate, bool paid});
}

/// @nodoc
class _$MembershipInstallmentCopyWithImpl<
  $Res,
  $Val extends MembershipInstallment
>
    implements $MembershipInstallmentCopyWith<$Res> {
  _$MembershipInstallmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembershipInstallment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? amountTl = null,
    Object? dueDate = null,
    Object? paid = null,
  }) {
    return _then(
      _value.copyWith(
            index: null == index
                ? _value.index
                : index // ignore: cast_nullable_to_non_nullable
                      as int,
            amountTl: null == amountTl
                ? _value.amountTl
                : amountTl // ignore: cast_nullable_to_non_nullable
                      as int,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            paid: null == paid
                ? _value.paid
                : paid // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MembershipInstallmentImplCopyWith<$Res>
    implements $MembershipInstallmentCopyWith<$Res> {
  factory _$$MembershipInstallmentImplCopyWith(
    _$MembershipInstallmentImpl value,
    $Res Function(_$MembershipInstallmentImpl) then,
  ) = __$$MembershipInstallmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int index, int amountTl, DateTime dueDate, bool paid});
}

/// @nodoc
class __$$MembershipInstallmentImplCopyWithImpl<$Res>
    extends
        _$MembershipInstallmentCopyWithImpl<$Res, _$MembershipInstallmentImpl>
    implements _$$MembershipInstallmentImplCopyWith<$Res> {
  __$$MembershipInstallmentImplCopyWithImpl(
    _$MembershipInstallmentImpl _value,
    $Res Function(_$MembershipInstallmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MembershipInstallment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? amountTl = null,
    Object? dueDate = null,
    Object? paid = null,
  }) {
    return _then(
      _$MembershipInstallmentImpl(
        index: null == index
            ? _value.index
            : index // ignore: cast_nullable_to_non_nullable
                  as int,
        amountTl: null == amountTl
            ? _value.amountTl
            : amountTl // ignore: cast_nullable_to_non_nullable
                  as int,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        paid: null == paid
            ? _value.paid
            : paid // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$MembershipInstallmentImpl implements _MembershipInstallment {
  const _$MembershipInstallmentImpl({
    required this.index,
    required this.amountTl,
    required this.dueDate,
    required this.paid,
  });

  @override
  final int index;
  @override
  final int amountTl;
  @override
  final DateTime dueDate;
  @override
  final bool paid;

  @override
  String toString() {
    return 'MembershipInstallment(index: $index, amountTl: $amountTl, dueDate: $dueDate, paid: $paid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipInstallmentImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.amountTl, amountTl) ||
                other.amountTl == amountTl) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.paid, paid) || other.paid == paid));
  }

  @override
  int get hashCode => Object.hash(runtimeType, index, amountTl, dueDate, paid);

  /// Create a copy of MembershipInstallment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipInstallmentImplCopyWith<_$MembershipInstallmentImpl>
  get copyWith =>
      __$$MembershipInstallmentImplCopyWithImpl<_$MembershipInstallmentImpl>(
        this,
        _$identity,
      );
}

abstract class _MembershipInstallment implements MembershipInstallment {
  const factory _MembershipInstallment({
    required final int index,
    required final int amountTl,
    required final DateTime dueDate,
    required final bool paid,
  }) = _$MembershipInstallmentImpl;

  @override
  int get index;
  @override
  int get amountTl;
  @override
  DateTime get dueDate;
  @override
  bool get paid;

  /// Create a copy of MembershipInstallment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembershipInstallmentImplCopyWith<_$MembershipInstallmentImpl>
  get copyWith => throw _privateConstructorUsedError;
}
