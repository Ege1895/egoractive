import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_category.freezed.dart';

/// F5-3 — Remote Config'ten (`cfg_expense_categories`) okunan, cihaz diline
/// göre çözümlenmiş gider kategorisi. `id` Firestore'a yazılır (dilden
/// bağımsız); `label` sadece ekranda gösterilir.
@freezed
class ExpenseCategoryOption with _$ExpenseCategoryOption {
  const factory ExpenseCategoryOption({
    required String id,
    required String label,
  }) = _ExpenseCategoryOption;
}
