import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/admin_member_list_state.dart';
import '../service/admin_member_list_page_service.dart';

part 'admin_member_list_controller.g.dart';

/// F7-2 — F2-2 üye listesi ekranının sayfalı kontrolcüsü. `AdminMembersController`
/// (tüm üyeleri canlı dinleyen eski kontrolcü) büyük salonlarda ilk render'ı
/// yavaşlattığı için sadece bu liste ekranı buna geçti — üye detayı/seans
/// oluşturma/bildirim gönderme gibi "tüm üyeler üzerinde ara/seç" ihtiyacı
/// olan ekranlar hâlâ `AdminMembersController`'ı kullanıyor.
@riverpod
class AdminMemberListController extends _$AdminMemberListController {
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  String? _gymId;

  @override
  AdminMemberListState build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    _gymId = gymId;
    if (gymId == null) return const AdminMemberListState(isLoading: false);

    _loadFirstPage(gymId);
    return const AdminMemberListState();
  }

  Future<void> loadMore() async {
    final gymId = _gymId;
    if (gymId == null ||
        !state.hasMore ||
        state.isLoadingMore ||
        state.searchResults != null)
      return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    try {
      final page = await ref
          .read(adminMemberListPageServiceProvider)
          .loadPage(gymId, startAfter: _lastDocument);
      _lastDocument = page.lastDocument;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        hasMore: page.hasMore,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Daha fazla üye yüklenemedi, tekrar dene.',
      );
    }
  }

  Future<void> search(String query) async {
    final gymId = _gymId;
    final trimmed = query.trim();
    if (gymId == null) return;
    if (trimmed.isEmpty) {
      state = state.copyWith(searchResults: null, errorMessage: null);
      return;
    }

    state = state.copyWith(isSearching: true, errorMessage: null);
    try {
      final results = await ref
          .read(adminMemberListPageServiceProvider)
          .searchByNamePrefix(gymId, trimmed);
      state = state.copyWith(searchResults: results, isSearching: false);
    } catch (_) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: 'Arama yapılamadı, tekrar dene.',
      );
    }
  }

  /// Başka bir ekrandan yeni üye eklendiğinde (bkz. `MemberInfoPanel`) canlı
  /// güncelleme olmadığı için listeye geri dönüldüğünde manuel çağrılır.
  Future<void> refresh() async {
    final gymId = _gymId;
    if (gymId == null) return;
    _lastDocument = null;
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _loadFirstPage(gymId);
  }

  Future<void> _loadFirstPage(String gymId) async {
    try {
      final page = await ref
          .read(adminMemberListPageServiceProvider)
          .loadPage(gymId);
      _lastDocument = page.lastDocument;
      state = state.copyWith(
        items: page.items,
        isLoading: false,
        hasMore: page.hasMore,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Üye listesi yüklenemedi, tekrar dene.',
      );
    }
  }
}
