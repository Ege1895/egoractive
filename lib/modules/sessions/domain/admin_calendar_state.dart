import 'package:freezed_annotation/freezed_annotation.dart';

import '../../expenses/domain/expense_state.dart';

part 'admin_calendar_state.freezed.dart';

enum AdminSessionState { planned, current, completed, absent, cancelled }

@freezed
class AdminSessionSlot with _$AdminSessionSlot {
  const factory AdminSessionSlot({
    required String id,
    required String time,
    required String title,
    required String meta,
    required AdminSessionState state,
    @Default('') String memberId,
    // F7-x — düet dersler her üye için ayrı bir `sessions` dokümanı
    // olduğundan (aynı `duetGroupId`'yi paylaşırlar), takvimde tek satır
    // olarak gösterilebilmesi için birden fazla doküman id'si taşıyabilir.
    // `sessionType == 'individual'` olan slotlarda tek elemanlı, `id` ile
    // aynıdır.
    @Default('individual') String sessionType,
    @Default(<String>[]) List<String> duetMemberNames,
    @Default(<String>[]) List<String> sessionIds,
  }) = _AdminSessionSlot;

  const AdminSessionSlot._();

  bool get isDuet => sessionType == 'duet';
}

@freezed
class AdminCalendarState with _$AdminCalendarState {
  const factory AdminCalendarState({
    required DateTime selectedDate,
    required Map<int, List<AdminSessionSlot>> slotsByDayOfMonth,

    /// Gün numarası → o gün eklenmiş gider kayıtları. Takvimde bildirim
    /// rozeti sayısı için `.length`, seçili gün panelinde liste için
    /// doğrudan kullanılır.
    @Default(<int, List<ExpenseEntry>>{})
    Map<int, List<ExpenseEntry>> expensesByDayOfMonth,
  }) = _AdminCalendarState;
}
