// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_member_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdminMemberSummary {
  String get id => throw _privateConstructorUsedError;
  String get initials => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get trainerName => throw _privateConstructorUsedError;
  int get remainingSessions => throw _privateConstructorUsedError;

  /// Henüz takvime hiç girilmemiş, gerçekten yeni bir seans için
  /// kullanılabilir hak — `remainingSessions` (planlanmış + planlanmamış
  /// toplamı, "Üyeler" listesinde gösterilen) ile KARIŞTIRILMAMALI. Seans
  /// oluşturma ekranı (`create_session_sheet.dart`) bu alanı kullanır;
  /// aksi halde zaten tamamı takvime girilmiş bir üyeye "hakkı var" diye
  /// yeni seans atanmaya çalışılıp `InsufficientSessionsException` alınır.
  int get unplannedSessions => throw _privateConstructorUsedError;
  String get packageEndDate => throw _privateConstructorUsedError;
  MemberPackageStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of AdminMemberSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminMemberSummaryCopyWith<AdminMemberSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminMemberSummaryCopyWith<$Res> {
  factory $AdminMemberSummaryCopyWith(
    AdminMemberSummary value,
    $Res Function(AdminMemberSummary) then,
  ) = _$AdminMemberSummaryCopyWithImpl<$Res, AdminMemberSummary>;
  @useResult
  $Res call({
    String id,
    String initials,
    String name,
    String phone,
    String trainerName,
    int remainingSessions,
    int unplannedSessions,
    String packageEndDate,
    MemberPackageStatus status,
  });
}

/// @nodoc
class _$AdminMemberSummaryCopyWithImpl<$Res, $Val extends AdminMemberSummary>
    implements $AdminMemberSummaryCopyWith<$Res> {
  _$AdminMemberSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminMemberSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? name = null,
    Object? phone = null,
    Object? trainerName = null,
    Object? remainingSessions = null,
    Object? unplannedSessions = null,
    Object? packageEndDate = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            initials: null == initials
                ? _value.initials
                : initials // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            trainerName: null == trainerName
                ? _value.trainerName
                : trainerName // ignore: cast_nullable_to_non_nullable
                      as String,
            remainingSessions: null == remainingSessions
                ? _value.remainingSessions
                : remainingSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            unplannedSessions: null == unplannedSessions
                ? _value.unplannedSessions
                : unplannedSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            packageEndDate: null == packageEndDate
                ? _value.packageEndDate
                : packageEndDate // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MemberPackageStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminMemberSummaryImplCopyWith<$Res>
    implements $AdminMemberSummaryCopyWith<$Res> {
  factory _$$AdminMemberSummaryImplCopyWith(
    _$AdminMemberSummaryImpl value,
    $Res Function(_$AdminMemberSummaryImpl) then,
  ) = __$$AdminMemberSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String initials,
    String name,
    String phone,
    String trainerName,
    int remainingSessions,
    int unplannedSessions,
    String packageEndDate,
    MemberPackageStatus status,
  });
}

/// @nodoc
class __$$AdminMemberSummaryImplCopyWithImpl<$Res>
    extends _$AdminMemberSummaryCopyWithImpl<$Res, _$AdminMemberSummaryImpl>
    implements _$$AdminMemberSummaryImplCopyWith<$Res> {
  __$$AdminMemberSummaryImplCopyWithImpl(
    _$AdminMemberSummaryImpl _value,
    $Res Function(_$AdminMemberSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminMemberSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? name = null,
    Object? phone = null,
    Object? trainerName = null,
    Object? remainingSessions = null,
    Object? unplannedSessions = null,
    Object? packageEndDate = null,
    Object? status = null,
  }) {
    return _then(
      _$AdminMemberSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        initials: null == initials
            ? _value.initials
            : initials // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        trainerName: null == trainerName
            ? _value.trainerName
            : trainerName // ignore: cast_nullable_to_non_nullable
                  as String,
        remainingSessions: null == remainingSessions
            ? _value.remainingSessions
            : remainingSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        unplannedSessions: null == unplannedSessions
            ? _value.unplannedSessions
            : unplannedSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        packageEndDate: null == packageEndDate
            ? _value.packageEndDate
            : packageEndDate // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MemberPackageStatus,
      ),
    );
  }
}

/// @nodoc

class _$AdminMemberSummaryImpl implements _AdminMemberSummary {
  const _$AdminMemberSummaryImpl({
    required this.id,
    required this.initials,
    required this.name,
    required this.phone,
    required this.trainerName,
    required this.remainingSessions,
    required this.unplannedSessions,
    required this.packageEndDate,
    required this.status,
  });

  @override
  final String id;
  @override
  final String initials;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String trainerName;
  @override
  final int remainingSessions;

  /// Henüz takvime hiç girilmemiş, gerçekten yeni bir seans için
  /// kullanılabilir hak — `remainingSessions` (planlanmış + planlanmamış
  /// toplamı, "Üyeler" listesinde gösterilen) ile KARIŞTIRILMAMALI. Seans
  /// oluşturma ekranı (`create_session_sheet.dart`) bu alanı kullanır;
  /// aksi halde zaten tamamı takvime girilmiş bir üyeye "hakkı var" diye
  /// yeni seans atanmaya çalışılıp `InsufficientSessionsException` alınır.
  @override
  final int unplannedSessions;
  @override
  final String packageEndDate;
  @override
  final MemberPackageStatus status;

  @override
  String toString() {
    return 'AdminMemberSummary(id: $id, initials: $initials, name: $name, phone: $phone, trainerName: $trainerName, remainingSessions: $remainingSessions, unplannedSessions: $unplannedSessions, packageEndDate: $packageEndDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminMemberSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.initials, initials) ||
                other.initials == initials) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.trainerName, trainerName) ||
                other.trainerName == trainerName) &&
            (identical(other.remainingSessions, remainingSessions) ||
                other.remainingSessions == remainingSessions) &&
            (identical(other.unplannedSessions, unplannedSessions) ||
                other.unplannedSessions == unplannedSessions) &&
            (identical(other.packageEndDate, packageEndDate) ||
                other.packageEndDate == packageEndDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    initials,
    name,
    phone,
    trainerName,
    remainingSessions,
    unplannedSessions,
    packageEndDate,
    status,
  );

  /// Create a copy of AdminMemberSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminMemberSummaryImplCopyWith<_$AdminMemberSummaryImpl> get copyWith =>
      __$$AdminMemberSummaryImplCopyWithImpl<_$AdminMemberSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminMemberSummary implements AdminMemberSummary {
  const factory _AdminMemberSummary({
    required final String id,
    required final String initials,
    required final String name,
    required final String phone,
    required final String trainerName,
    required final int remainingSessions,
    required final int unplannedSessions,
    required final String packageEndDate,
    required final MemberPackageStatus status,
  }) = _$AdminMemberSummaryImpl;

  @override
  String get id;
  @override
  String get initials;
  @override
  String get name;
  @override
  String get phone;
  @override
  String get trainerName;
  @override
  int get remainingSessions;

  /// Henüz takvime hiç girilmemiş, gerçekten yeni bir seans için
  /// kullanılabilir hak — `remainingSessions` (planlanmış + planlanmamış
  /// toplamı, "Üyeler" listesinde gösterilen) ile KARIŞTIRILMAMALI. Seans
  /// oluşturma ekranı (`create_session_sheet.dart`) bu alanı kullanır;
  /// aksi halde zaten tamamı takvime girilmiş bir üyeye "hakkı var" diye
  /// yeni seans atanmaya çalışılıp `InsufficientSessionsException` alınır.
  @override
  int get unplannedSessions;
  @override
  String get packageEndDate;
  @override
  MemberPackageStatus get status;

  /// Create a copy of AdminMemberSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminMemberSummaryImplCopyWith<_$AdminMemberSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
