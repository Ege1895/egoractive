import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/native_date_picker.dart';
import '../../controller/admin_calendar_controller.dart';
import '../../domain/admin_calendar_state.dart';
import '../../service/sessions_write_service.dart';
import '../widgets/create_session_sheet.dart';

const _monthAbbrev = {
  1: 'Ocak',
  2: 'Şubat',
  3: 'Mart',
  4: 'Nisan',
  5: 'Mayıs',
  6: 'Haziran',
  7: 'Temmuz',
  8: 'Ağustos',
  9: 'Eylül',
  10: 'Ekim',
  11: 'Kasım',
  12: 'Aralık',
};
const _weekdayNames = {
  1: 'Pazartesi',
  2: 'Salı',
  3: 'Çarşamba',
  4: 'Perşembe',
  5: 'Cuma',
  6: 'Cumartesi',
  7: 'Pazar',
};

enum _SessionFilter { all, planned, completed, cancelled }

/// Admin 10 · Ders / Seans Yönetimi — filtreler + aksiyon paneli, tarih
/// kısıtı olmadan iptal/erteleme.
class AdminSessionManagementPanel extends BasePanel {
  const AdminSessionManagementPanel({super.key});

  @override
  ConsumerState<AdminSessionManagementPanel> createState() =>
      _AdminSessionManagementPanelState();
}

class _AdminSessionManagementPanelState
    extends BasePanelState<AdminSessionManagementPanel> {
  DateTime _date = DateTime.now();
  _SessionFilter _filter = _SessionFilter.all;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final calendarState = ref.watch(adminCalendarControllerProvider);
    final sessions =
        (calendarState.slotsByDayOfMonth[_date.day] ??
                const <AdminSessionSlot>[])
            .where(_matchesFilter)
            .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppBackButton(
                        onTap: () => ref
                            .read(panelStackControllerProvider.notifier)
                            .pop(),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Seanslar',
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Material(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusInner,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                          onTap: () =>
                              showCreateSessionSheet(context, ref, _date),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            constraints: const BoxConstraints(minHeight: 40),
                            alignment: Alignment.center,
                            child: Text(
                              '+ Seans',
                              style: typography.headingSmall.copyWith(
                                fontSize: 14,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    constraints: const BoxConstraints(minHeight: 44),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => showNativeDatePicker(
                              context: context,
                              initial: _date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              onSelected: (d) => setState(() => _date = d),
                            ),
                            child: Text(
                              '${_date.day} ${_monthAbbrev[_date.month]} ${_weekdayNames[_date.weekday]}',
                              style: typography.bodyMedium.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        _ArrowButton(
                          icon: Icons.chevron_left,
                          onTap: () => setState(
                            () =>
                                _date = _date.subtract(const Duration(days: 1)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _ArrowButton(
                          icon: Icons.chevron_right,
                          onTap: () => setState(
                            () => _date = _date.add(const Duration(days: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(
                          label: 'Tümü',
                          selected: _filter == _SessionFilter.all,
                          onTap: () =>
                              setState(() => _filter = _SessionFilter.all),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'Planlandı',
                          selected: _filter == _SessionFilter.planned,
                          onTap: () =>
                              setState(() => _filter = _SessionFilter.planned),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'Tamamlandı',
                          selected: _filter == _SessionFilter.completed,
                          onTap: () => setState(
                            () => _filter = _SessionFilter.completed,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'İptal',
                          selected: _filter == _SessionFilter.cancelled,
                          onTap: () => setState(
                            () => _filter = _SessionFilter.cancelled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Text(
                        'Bu güne uyan seans yok.',
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenEdge,
                        AppSpacing.md,
                        AppSpacing.screenEdge,
                        AppSpacing.lg,
                      ),
                      children: [
                        for (final session in sessions)
                          _SessionCard(
                            slot: session,
                            onTap: () => _showActionSheet(context, session),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _slotStartTime(AdminSessionSlot slot) {
    final parts = slot.time.split(':');
    return DateTime(
      _date.year,
      _date.month,
      _date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  bool _matchesFilter(AdminSessionSlot slot) {
    return switch (_filter) {
      _SessionFilter.all => true,
      _SessionFilter.planned =>
        slot.state == AdminSessionState.planned ||
            slot.state == AdminSessionState.current,
      _SessionFilter.completed => slot.state == AdminSessionState.completed,
      _SessionFilter.cancelled => slot.state == AdminSessionState.cancelled,
    };
  }

  void _showActionSheet(BuildContext context, AdminSessionSlot slot) {
    final colors = context.appColors;
    final typography = context.appTypography;
    var isCancelling = false;
    String? cancelError;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        // Önceki sürüm sheet'i yazma tamamlanmadan kapatıyordu — iptal gibi
        // geri alınamaz bir aksiyon için false-success riski taşıyordu.
        // StatefulBuilder, yazma bitene kadar sheet'i açık tutup hata
        // olursa göstermeyi sağlıyor.
        return StatefulBuilder(
          builder: (sheetContext, setLocalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.lg,
                AppSpacing.screenEdge,
                AppSpacing.xxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${slot.time} · ${slot.title}',
                    style: typography.headingLarge.copyWith(
                      color: colors.onSurface,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    slot.meta,
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Seansı ertele',
                    variant: AppButtonVariant.secondary,
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await showRescheduleSessionSheet(
                        context,
                        ref,
                        sessionId: slot.id,
                        currentStart: _slotStartTime(slot),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (cancelError != null) ...[
                    Text(
                      cancelError!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Material(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      onTap: isCancelling
                          ? null
                          : () async {
                              setLocalState(() {
                                isCancelling = true;
                                cancelError = null;
                              });
                              try {
                                await ref
                                    .read(sessionsWriteServiceProvider)
                                    .cancelSession(slot.id);
                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                              } catch (_) {
                                setLocalState(() {
                                  isCancelling = false;
                                  cancelError =
                                      'Seans iptal edilemedi, tekrar dene.';
                                });
                              }
                            },
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: AppSpacing.primaryActionHeight,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isCancelling ? 'İptal ediliyor…' : 'Seansı iptal et',
                          style: typography.headingSmall.copyWith(
                            fontSize: 15,
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Yönetici olarak tarih kısıtı olmadan iptal ve erteleme yapabilirsiniz.',
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, color: colors.onSurfaceVariant, size: 16),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          constraints: const BoxConstraints(minHeight: 34),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineStrong,
            ),
          ),
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 14,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.slot, required this.onTap});

  final AdminSessionSlot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final (chipLabel, chipBg, chipFg, border) = switch (slot.state) {
      AdminSessionState.completed => (
        'Tamamlandı',
        colors.successContainer,
        colors.onSuccessContainer,
        colors.outline,
      ),
      AdminSessionState.current => (
        'Şimdi',
        colors.primaryContainer,
        colors.onPrimaryContainer,
        colors.primary.withValues(alpha: 0.4),
      ),
      AdminSessionState.cancelled => (
        'İptal',
        colors.errorContainer,
        colors.onErrorContainer,
        colors.error.withValues(alpha: 0.3),
      ),
      AdminSessionState.planned => (
        'Planlandı',
        colors.surfaceRaised,
        colors.onSurfaceVariant,
        colors.outline,
      ),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              child: Text(
                slot.time,
                style: typography.headingSmall.copyWith(
                  color: colors.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.title,
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    slot.meta,
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                chipLabel,
                style: typography.caption.copyWith(color: chipFg, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
