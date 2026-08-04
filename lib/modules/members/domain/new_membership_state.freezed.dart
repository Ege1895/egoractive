// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_membership_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$NewMembershipState {
  StudioPackage? get selectedPackage => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get makeupSessions => throw _privateConstructorUsedError;
  int get paidAmount => throw _privateConstructorUsedError;
  String? get otherAmountDraft => throw _privateConstructorUsedError;

  /// Create a copy of NewMembershipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewMembershipStateCopyWith<NewMembershipState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewMembershipStateCopyWith<$Res> {
  factory $NewMembershipStateCopyWith(
    NewMembershipState value,
    $Res Function(NewMembershipState) then,
  ) = _$NewMembershipStateCopyWithImpl<$Res, NewMembershipState>;
  @useResult
  $Res call({
    StudioPackage? selectedPackage,
    DateTime startDate,
    DateTime endDate,
    int makeupSessions,
    int paidAmount,
    String? otherAmountDraft,
  });

  $StudioPackageCopyWith<$Res>? get selectedPackage;
}

/// @nodoc
class _$NewMembershipStateCopyWithImpl<$Res, $Val extends NewMembershipState>
    implements $NewMembershipStateCopyWith<$Res> {
  _$NewMembershipStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewMembershipState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedPackage = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? makeupSessions = null,
    Object? paidAmount = null,
    Object? otherAmountDraft = freezed,
  }) {
    return _then(
      _value.copyWith(
            selectedPackage: freezed == selectedPackage
                ? _value.selectedPackage
                : selectedPackage // ignore: cast_nullable_to_non_nullable
                      as StudioPackage?,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            makeupSessions: null == makeupSessions
                ? _value.makeupSessions
                : makeupSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            paidAmount: null == paidAmount
                ? _value.paidAmount
                : paidAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            otherAmountDraft: freezed == otherAmountDraft
                ? _value.otherAmountDraft
                : otherAmountDraft // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of NewMembershipState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StudioPackageCopyWith<$Res>? get selectedPackage {
    if (_value.selectedPackage == null) {
      return null;
    }

    return $StudioPackageCopyWith<$Res>(_value.selectedPackage!, (value) {
      return _then(_value.copyWith(selectedPackage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NewMembershipStateImplCopyWith<$Res>
    implements $NewMembershipStateCopyWith<$Res> {
  factory _$$NewMembershipStateImplCopyWith(
    _$NewMembershipStateImpl value,
    $Res Function(_$NewMembershipStateImpl) then,
  ) = __$$NewMembershipStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    StudioPackage? selectedPackage,
    DateTime startDate,
    DateTime endDate,
    int makeupSessions,
    int paidAmount,
    String? otherAmountDraft,
  });

  @override
  $StudioPackageCopyWith<$Res>? get selectedPackage;
}

/// @nodoc
class __$$NewMembershipStateImplCopyWithImpl<$Res>
    extends _$NewMembershipStateCopyWithImpl<$Res, _$NewMembershipStateImpl>
    implements _$$NewMembershipStateImplCopyWith<$Res> {
  __$$NewMembershipStateImplCopyWithImpl(
    _$NewMembershipStateImpl _value,
    $Res Function(_$NewMembershipStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewMembershipState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedPackage = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? makeupSessions = null,
    Object? paidAmount = null,
    Object? otherAmountDraft = freezed,
  }) {
    return _then(
      _$NewMembershipStateImpl(
        selectedPackage: freezed == selectedPackage
            ? _value.selectedPackage
            : selectedPackage // ignore: cast_nullable_to_non_nullable
                  as StudioPackage?,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        makeupSessions: null == makeupSessions
            ? _value.makeupSessions
            : makeupSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        paidAmount: null == paidAmount
            ? _value.paidAmount
            : paidAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        otherAmountDraft: freezed == otherAmountDraft
            ? _value.otherAmountDraft
            : otherAmountDraft // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$NewMembershipStateImpl extends _NewMembershipState {
  const _$NewMembershipStateImpl({
    this.selectedPackage,
    required this.startDate,
    required this.endDate,
    required this.makeupSessions,
    required this.paidAmount,
    this.otherAmountDraft,
  }) : super._();

  @override
  final StudioPackage? selectedPackage;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final int makeupSessions;
  @override
  final int paidAmount;
  @override
  final String? otherAmountDraft;

  @override
  String toString() {
    return 'NewMembershipState(selectedPackage: $selectedPackage, startDate: $startDate, endDate: $endDate, makeupSessions: $makeupSessions, paidAmount: $paidAmount, otherAmountDraft: $otherAmountDraft)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewMembershipStateImpl &&
            (identical(other.selectedPackage, selectedPackage) ||
                other.selectedPackage == selectedPackage) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.makeupSessions, makeupSessions) ||
                other.makeupSessions == makeupSessions) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.otherAmountDraft, otherAmountDraft) ||
                other.otherAmountDraft == otherAmountDraft));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedPackage,
    startDate,
    endDate,
    makeupSessions,
    paidAmount,
    otherAmountDraft,
  );

  /// Create a copy of NewMembershipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewMembershipStateImplCopyWith<_$NewMembershipStateImpl> get copyWith =>
      __$$NewMembershipStateImplCopyWithImpl<_$NewMembershipStateImpl>(
        this,
        _$identity,
      );
}

abstract class _NewMembershipState extends NewMembershipState {
  const factory _NewMembershipState({
    final StudioPackage? selectedPackage,
    required final DateTime startDate,
    required final DateTime endDate,
    required final int makeupSessions,
    required final int paidAmount,
    final String? otherAmountDraft,
  }) = _$NewMembershipStateImpl;
  const _NewMembershipState._() : super._();

  @override
  StudioPackage? get selectedPackage;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get makeupSessions;
  @override
  int get paidAmount;
  @override
  String? get otherAmountDraft;

  /// Create a copy of NewMembershipState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewMembershipStateImplCopyWith<_$NewMembershipStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
