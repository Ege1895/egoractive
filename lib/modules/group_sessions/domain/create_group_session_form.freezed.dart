// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_group_session_form.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CreateGroupSessionForm {
  String get title => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  DateTime? get selectedDate => throw _privateConstructorUsedError;

  /// "Tekrarla" ile seçilen EK tarihler — [selectedDate] hariç, her biri
  /// için ayrı bir `groupSessions` dokümanı oluşturulur. Seanslardan
  /// farklı olarak burada bir üst sınır yok (bkz.
  /// `create_group_session_controller.dart`).
  List<DateTime> get repeatDates => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  int get capacityMax => throw _privateConstructorUsedError;
  bool get onlineBookingEnabled => throw _privateConstructorUsedError;
  String get studioName => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// RC'den (`groupSessionDescriptionMaxChars`, varsayılan 500) okunur —
  /// [description] bunu aşınca sayaç kırmızıya döner, "Grup dersi
  /// oluştur" butonu devre dışı kalır.
  int get descriptionMaxChars => throw _privateConstructorUsedError;

  /// Atanan antrenör(ler) — opsiyonel, boş bırakılabilir. Çoklu seçime
  /// izin verir (bkz. `create_group_session_panel.dart`'taki antrenör
  /// seçim sheet'i).
  List<String> get trainerIds => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get titleError => throw _privateConstructorUsedError;
  String? get dateError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Admin'in düzenleme ekranından (bkz. `create_group_session_panel.dart`)
  /// var olan bir dersi açtığını gösterir — dolu ise `submit()` "Tekrarla"
  /// olmadan TEK dokümanı günceller, boşsa (yeni oluşturma) mevcut
  /// davranış (ana tarih + tekrar tarihleri için ayrı ayrı oluşturma)
  /// aynen çalışır.
  String? get editingId => throw _privateConstructorUsedError;
  bool get isLoadingForEdit => throw _privateConstructorUsedError;
  bool get isCancelling => throw _privateConstructorUsedError;

  /// Create a copy of CreateGroupSessionForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateGroupSessionFormCopyWith<CreateGroupSessionForm> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateGroupSessionFormCopyWith<$Res> {
  factory $CreateGroupSessionFormCopyWith(
    CreateGroupSessionForm value,
    $Res Function(CreateGroupSessionForm) then,
  ) = _$CreateGroupSessionFormCopyWithImpl<$Res, CreateGroupSessionForm>;
  @useResult
  $Res call({
    String title,
    String startTime,
    int durationMinutes,
    DateTime? selectedDate,
    List<DateTime> repeatDates,
    int capacity,
    int capacityMax,
    bool onlineBookingEnabled,
    String studioName,
    String description,
    int descriptionMaxChars,
    List<String> trainerIds,
    bool isSubmitting,
    String? titleError,
    String? dateError,
    String? errorMessage,
    String? editingId,
    bool isLoadingForEdit,
    bool isCancelling,
  });
}

/// @nodoc
class _$CreateGroupSessionFormCopyWithImpl<
  $Res,
  $Val extends CreateGroupSessionForm
>
    implements $CreateGroupSessionFormCopyWith<$Res> {
  _$CreateGroupSessionFormCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateGroupSessionForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? startTime = null,
    Object? durationMinutes = null,
    Object? selectedDate = freezed,
    Object? repeatDates = null,
    Object? capacity = null,
    Object? capacityMax = null,
    Object? onlineBookingEnabled = null,
    Object? studioName = null,
    Object? description = null,
    Object? descriptionMaxChars = null,
    Object? trainerIds = null,
    Object? isSubmitting = null,
    Object? titleError = freezed,
    Object? dateError = freezed,
    Object? errorMessage = freezed,
    Object? editingId = freezed,
    Object? isLoadingForEdit = null,
    Object? isCancelling = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            selectedDate: freezed == selectedDate
                ? _value.selectedDate
                : selectedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            repeatDates: null == repeatDates
                ? _value.repeatDates
                : repeatDates // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>,
            capacity: null == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int,
            capacityMax: null == capacityMax
                ? _value.capacityMax
                : capacityMax // ignore: cast_nullable_to_non_nullable
                      as int,
            onlineBookingEnabled: null == onlineBookingEnabled
                ? _value.onlineBookingEnabled
                : onlineBookingEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            studioName: null == studioName
                ? _value.studioName
                : studioName // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            descriptionMaxChars: null == descriptionMaxChars
                ? _value.descriptionMaxChars
                : descriptionMaxChars // ignore: cast_nullable_to_non_nullable
                      as int,
            trainerIds: null == trainerIds
                ? _value.trainerIds
                : trainerIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            titleError: freezed == titleError
                ? _value.titleError
                : titleError // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateError: freezed == dateError
                ? _value.dateError
                : dateError // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            editingId: freezed == editingId
                ? _value.editingId
                : editingId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isLoadingForEdit: null == isLoadingForEdit
                ? _value.isLoadingForEdit
                : isLoadingForEdit // ignore: cast_nullable_to_non_nullable
                      as bool,
            isCancelling: null == isCancelling
                ? _value.isCancelling
                : isCancelling // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateGroupSessionFormImplCopyWith<$Res>
    implements $CreateGroupSessionFormCopyWith<$Res> {
  factory _$$CreateGroupSessionFormImplCopyWith(
    _$CreateGroupSessionFormImpl value,
    $Res Function(_$CreateGroupSessionFormImpl) then,
  ) = __$$CreateGroupSessionFormImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String startTime,
    int durationMinutes,
    DateTime? selectedDate,
    List<DateTime> repeatDates,
    int capacity,
    int capacityMax,
    bool onlineBookingEnabled,
    String studioName,
    String description,
    int descriptionMaxChars,
    List<String> trainerIds,
    bool isSubmitting,
    String? titleError,
    String? dateError,
    String? errorMessage,
    String? editingId,
    bool isLoadingForEdit,
    bool isCancelling,
  });
}

/// @nodoc
class __$$CreateGroupSessionFormImplCopyWithImpl<$Res>
    extends
        _$CreateGroupSessionFormCopyWithImpl<$Res, _$CreateGroupSessionFormImpl>
    implements _$$CreateGroupSessionFormImplCopyWith<$Res> {
  __$$CreateGroupSessionFormImplCopyWithImpl(
    _$CreateGroupSessionFormImpl _value,
    $Res Function(_$CreateGroupSessionFormImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateGroupSessionForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? startTime = null,
    Object? durationMinutes = null,
    Object? selectedDate = freezed,
    Object? repeatDates = null,
    Object? capacity = null,
    Object? capacityMax = null,
    Object? onlineBookingEnabled = null,
    Object? studioName = null,
    Object? description = null,
    Object? descriptionMaxChars = null,
    Object? trainerIds = null,
    Object? isSubmitting = null,
    Object? titleError = freezed,
    Object? dateError = freezed,
    Object? errorMessage = freezed,
    Object? editingId = freezed,
    Object? isLoadingForEdit = null,
    Object? isCancelling = null,
  }) {
    return _then(
      _$CreateGroupSessionFormImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        selectedDate: freezed == selectedDate
            ? _value.selectedDate
            : selectedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        repeatDates: null == repeatDates
            ? _value._repeatDates
            : repeatDates // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>,
        capacity: null == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int,
        capacityMax: null == capacityMax
            ? _value.capacityMax
            : capacityMax // ignore: cast_nullable_to_non_nullable
                  as int,
        onlineBookingEnabled: null == onlineBookingEnabled
            ? _value.onlineBookingEnabled
            : onlineBookingEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        studioName: null == studioName
            ? _value.studioName
            : studioName // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        descriptionMaxChars: null == descriptionMaxChars
            ? _value.descriptionMaxChars
            : descriptionMaxChars // ignore: cast_nullable_to_non_nullable
                  as int,
        trainerIds: null == trainerIds
            ? _value._trainerIds
            : trainerIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        titleError: freezed == titleError
            ? _value.titleError
            : titleError // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateError: freezed == dateError
            ? _value.dateError
            : dateError // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        editingId: freezed == editingId
            ? _value.editingId
            : editingId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isLoadingForEdit: null == isLoadingForEdit
            ? _value.isLoadingForEdit
            : isLoadingForEdit // ignore: cast_nullable_to_non_nullable
                  as bool,
        isCancelling: null == isCancelling
            ? _value.isCancelling
            : isCancelling // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CreateGroupSessionFormImpl implements _CreateGroupSessionForm {
  const _$CreateGroupSessionFormImpl({
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    this.selectedDate,
    final List<DateTime> repeatDates = const <DateTime>[],
    required this.capacity,
    required this.capacityMax,
    required this.onlineBookingEnabled,
    required this.studioName,
    this.description = '',
    this.descriptionMaxChars = 500,
    final List<String> trainerIds = const <String>[],
    this.isSubmitting = false,
    this.titleError,
    this.dateError,
    this.errorMessage,
    this.editingId,
    this.isLoadingForEdit = false,
    this.isCancelling = false,
  }) : _repeatDates = repeatDates,
       _trainerIds = trainerIds;

  @override
  final String title;
  @override
  final String startTime;
  @override
  final int durationMinutes;
  @override
  final DateTime? selectedDate;

  /// "Tekrarla" ile seçilen EK tarihler — [selectedDate] hariç, her biri
  /// için ayrı bir `groupSessions` dokümanı oluşturulur. Seanslardan
  /// farklı olarak burada bir üst sınır yok (bkz.
  /// `create_group_session_controller.dart`).
  final List<DateTime> _repeatDates;

  /// "Tekrarla" ile seçilen EK tarihler — [selectedDate] hariç, her biri
  /// için ayrı bir `groupSessions` dokümanı oluşturulur. Seanslardan
  /// farklı olarak burada bir üst sınır yok (bkz.
  /// `create_group_session_controller.dart`).
  @override
  @JsonKey()
  List<DateTime> get repeatDates {
    if (_repeatDates is EqualUnmodifiableListView) return _repeatDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_repeatDates);
  }

  @override
  final int capacity;
  @override
  final int capacityMax;
  @override
  final bool onlineBookingEnabled;
  @override
  final String studioName;
  @override
  @JsonKey()
  final String description;

  /// RC'den (`groupSessionDescriptionMaxChars`, varsayılan 500) okunur —
  /// [description] bunu aşınca sayaç kırmızıya döner, "Grup dersi
  /// oluştur" butonu devre dışı kalır.
  @override
  @JsonKey()
  final int descriptionMaxChars;

  /// Atanan antrenör(ler) — opsiyonel, boş bırakılabilir. Çoklu seçime
  /// izin verir (bkz. `create_group_session_panel.dart`'taki antrenör
  /// seçim sheet'i).
  final List<String> _trainerIds;

  /// Atanan antrenör(ler) — opsiyonel, boş bırakılabilir. Çoklu seçime
  /// izin verir (bkz. `create_group_session_panel.dart`'taki antrenör
  /// seçim sheet'i).
  @override
  @JsonKey()
  List<String> get trainerIds {
    if (_trainerIds is EqualUnmodifiableListView) return _trainerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trainerIds);
  }

  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? titleError;
  @override
  final String? dateError;
  @override
  final String? errorMessage;

  /// Admin'in düzenleme ekranından (bkz. `create_group_session_panel.dart`)
  /// var olan bir dersi açtığını gösterir — dolu ise `submit()` "Tekrarla"
  /// olmadan TEK dokümanı günceller, boşsa (yeni oluşturma) mevcut
  /// davranış (ana tarih + tekrar tarihleri için ayrı ayrı oluşturma)
  /// aynen çalışır.
  @override
  final String? editingId;
  @override
  @JsonKey()
  final bool isLoadingForEdit;
  @override
  @JsonKey()
  final bool isCancelling;

  @override
  String toString() {
    return 'CreateGroupSessionForm(title: $title, startTime: $startTime, durationMinutes: $durationMinutes, selectedDate: $selectedDate, repeatDates: $repeatDates, capacity: $capacity, capacityMax: $capacityMax, onlineBookingEnabled: $onlineBookingEnabled, studioName: $studioName, description: $description, descriptionMaxChars: $descriptionMaxChars, trainerIds: $trainerIds, isSubmitting: $isSubmitting, titleError: $titleError, dateError: $dateError, errorMessage: $errorMessage, editingId: $editingId, isLoadingForEdit: $isLoadingForEdit, isCancelling: $isCancelling)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateGroupSessionFormImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            const DeepCollectionEquality().equals(
              other._repeatDates,
              _repeatDates,
            ) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.capacityMax, capacityMax) ||
                other.capacityMax == capacityMax) &&
            (identical(other.onlineBookingEnabled, onlineBookingEnabled) ||
                other.onlineBookingEnabled == onlineBookingEnabled) &&
            (identical(other.studioName, studioName) ||
                other.studioName == studioName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.descriptionMaxChars, descriptionMaxChars) ||
                other.descriptionMaxChars == descriptionMaxChars) &&
            const DeepCollectionEquality().equals(
              other._trainerIds,
              _trainerIds,
            ) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.titleError, titleError) ||
                other.titleError == titleError) &&
            (identical(other.dateError, dateError) ||
                other.dateError == dateError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.editingId, editingId) ||
                other.editingId == editingId) &&
            (identical(other.isLoadingForEdit, isLoadingForEdit) ||
                other.isLoadingForEdit == isLoadingForEdit) &&
            (identical(other.isCancelling, isCancelling) ||
                other.isCancelling == isCancelling));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    title,
    startTime,
    durationMinutes,
    selectedDate,
    const DeepCollectionEquality().hash(_repeatDates),
    capacity,
    capacityMax,
    onlineBookingEnabled,
    studioName,
    description,
    descriptionMaxChars,
    const DeepCollectionEquality().hash(_trainerIds),
    isSubmitting,
    titleError,
    dateError,
    errorMessage,
    editingId,
    isLoadingForEdit,
    isCancelling,
  ]);

  /// Create a copy of CreateGroupSessionForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateGroupSessionFormImplCopyWith<_$CreateGroupSessionFormImpl>
  get copyWith =>
      __$$CreateGroupSessionFormImplCopyWithImpl<_$CreateGroupSessionFormImpl>(
        this,
        _$identity,
      );
}

abstract class _CreateGroupSessionForm implements CreateGroupSessionForm {
  const factory _CreateGroupSessionForm({
    required final String title,
    required final String startTime,
    required final int durationMinutes,
    final DateTime? selectedDate,
    final List<DateTime> repeatDates,
    required final int capacity,
    required final int capacityMax,
    required final bool onlineBookingEnabled,
    required final String studioName,
    final String description,
    final int descriptionMaxChars,
    final List<String> trainerIds,
    final bool isSubmitting,
    final String? titleError,
    final String? dateError,
    final String? errorMessage,
    final String? editingId,
    final bool isLoadingForEdit,
    final bool isCancelling,
  }) = _$CreateGroupSessionFormImpl;

  @override
  String get title;
  @override
  String get startTime;
  @override
  int get durationMinutes;
  @override
  DateTime? get selectedDate;

  /// "Tekrarla" ile seçilen EK tarihler — [selectedDate] hariç, her biri
  /// için ayrı bir `groupSessions` dokümanı oluşturulur. Seanslardan
  /// farklı olarak burada bir üst sınır yok (bkz.
  /// `create_group_session_controller.dart`).
  @override
  List<DateTime> get repeatDates;
  @override
  int get capacity;
  @override
  int get capacityMax;
  @override
  bool get onlineBookingEnabled;
  @override
  String get studioName;
  @override
  String get description;

  /// RC'den (`groupSessionDescriptionMaxChars`, varsayılan 500) okunur —
  /// [description] bunu aşınca sayaç kırmızıya döner, "Grup dersi
  /// oluştur" butonu devre dışı kalır.
  @override
  int get descriptionMaxChars;

  /// Atanan antrenör(ler) — opsiyonel, boş bırakılabilir. Çoklu seçime
  /// izin verir (bkz. `create_group_session_panel.dart`'taki antrenör
  /// seçim sheet'i).
  @override
  List<String> get trainerIds;
  @override
  bool get isSubmitting;
  @override
  String? get titleError;
  @override
  String? get dateError;
  @override
  String? get errorMessage;

  /// Admin'in düzenleme ekranından (bkz. `create_group_session_panel.dart`)
  /// var olan bir dersi açtığını gösterir — dolu ise `submit()` "Tekrarla"
  /// olmadan TEK dokümanı günceller, boşsa (yeni oluşturma) mevcut
  /// davranış (ana tarih + tekrar tarihleri için ayrı ayrı oluşturma)
  /// aynen çalışır.
  @override
  String? get editingId;
  @override
  bool get isLoadingForEdit;
  @override
  bool get isCancelling;

  /// Create a copy of CreateGroupSessionForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateGroupSessionFormImplCopyWith<_$CreateGroupSessionFormImpl>
  get copyWith => throw _privateConstructorUsedError;
}
