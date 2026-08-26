// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_member_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminMemberListControllerHash() =>
    r'90cb462061372284ca876a7d003cd473ed8b7b4f';

/// F7-2 — F2-2 üye listesi ekranının sayfalı kontrolcüsü. `AdminMembersController`
/// (tüm üyeleri canlı dinleyen eski kontrolcü) büyük salonlarda ilk render'ı
/// yavaşlattığı için sadece bu liste ekranı buna geçti — üye detayı/seans
/// oluşturma/bildirim gönderme gibi "tüm üyeler üzerinde ara/seç" ihtiyacı
/// olan ekranlar hâlâ `AdminMembersController`'ı kullanıyor.
///
/// Copied from [AdminMemberListController].
@ProviderFor(AdminMemberListController)
final adminMemberListControllerProvider =
    AutoDisposeNotifierProvider<
      AdminMemberListController,
      AdminMemberListState
    >.internal(
      AdminMemberListController.new,
      name: r'adminMemberListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminMemberListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminMemberListController = AutoDisposeNotifier<AdminMemberListState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
