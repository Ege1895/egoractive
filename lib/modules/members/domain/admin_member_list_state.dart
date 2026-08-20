import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_member_summary.dart';

part 'admin_member_list_state.freezed.dart';

/// F7-2 — F2-2 üye listesi ekranının sayfalı state'i. `items` sayfa sayfa
/// yüklenir (`AdminMemberListController.loadMore()`); `searchResults` dolu
/// olduğunda ekran arama sonuçlarını gösterir (`items`'ı değil).
@freezed
class AdminMemberListState with _$AdminMemberListState {
  const factory AdminMemberListState({
    @Default([]) List<AdminMemberSummary> items,
    @Default(true) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    @Default(false) bool isSearching,
    List<AdminMemberSummary>? searchResults,
    String? errorMessage,
  }) = _AdminMemberListState;
}
