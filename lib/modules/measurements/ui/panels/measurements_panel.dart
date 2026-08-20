import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/trend_bar_chart.dart';
import '../../controller/measurements_controller.dart';
import '../../domain/measurement_metric.dart';
import '../../domain/measurements_state.dart';
import '../widgets/measurement_avatar.dart';

/// Üye · Ölçümlerim (Ölçümlerim sekmesi kökü, kendi verisi için sekme
/// içine gömülü kullanılır) — avatar / grafik geçişi.
///
/// F4-1 — `memberId`/`memberName` verilirse (admin/antrenörün bir üyenin
/// detayından buraya girmesi) geri butonu gösterilir ve panel açık olduğu
/// sürece `measurementsViewedUidProvider` o üyenin uid'sine ayarlanır —
/// tüm alt widget'lar (avatar, grafik, "Yeni ölçüm ekle") otomatik olarak
/// o üyenin verisini gösterir/düzenler, ekstra bir değişiklik gerekmez.
class MeasurementsPanel extends BasePanel {
  const MeasurementsPanel({this.memberId, this.memberName, super.key});

  final String? memberId;
  final String? memberName;

  @override
  ConsumerState<MeasurementsPanel> createState() => _MeasurementsPanelState();
}

class _MeasurementsPanelState extends BasePanelState<MeasurementsPanel> {
  @override
  void onPanelShow() {
    if (widget.memberId != null) {
      ref.read(measurementsViewedUidProvider.notifier).set(widget.memberId);
    }
  }

  @override
  void onPanelHide() {
    if (widget.memberId != null) {
      ref.read(measurementsViewedUidProvider.notifier).set(null);
      ref.read(measurementsControllerProvider.notifier).selectDate(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(measurementsControllerProvider);
    final controller = ref.read(measurementsControllerProvider.notifier);
    final isAvatar = state.viewMode == MeasurementsViewMode.avatar;
    final title = widget.memberName != null
        ? ref
              .watch(rcTextProvider(RemoteConfigKeys.measurementsMemberTitle))
              .replaceAll('{name}', widget.memberName!)
        : ref.watch(rcTextProvider(RemoteConfigKeys.measurementsTitle));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.lg,
                AppSpacing.screenEdge,
                0,
              ),
              child: Row(
                children: [
                  if (widget.memberId != null) ...[
                    AppBackButton(
                      onTap: () =>
                          ref.read(panelStackControllerProvider.notifier).pop(),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: typography.headingLarge.copyWith(
                            color: colors.onSurface,
                            fontSize: widget.memberId != null ? 20 : null,
                          ),
                        ),
                        Text(
                          isAvatar
                              ? ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.measurementsAvatarHint,
                                  ),
                                )
                              : ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.measurementsChartHint,
                                  ),
                                ),
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ViewToggleChip(
                    label: isAvatar
                        ? ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.measurementsChartToggleLabel,
                            ),
                          )
                        : ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.measurementsAvatarToggleLabel,
                            ),
                          ),
                    onTap: () => controller.setViewMode(
                      isAvatar
                          ? MeasurementsViewMode.chart
                          : MeasurementsViewMode.avatar,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isAvatar ? const _AvatarView() : const _ChartView(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewToggleChip extends StatelessWidget {
  const _ViewToggleChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: colors.outlineStrong),
          ),
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

const _monthNames = {
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

String _formatDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month]} ${date.year}';

/// F4-1 — üyenin geçmiş ölçüm kayıtlarından birini seçip avatar ekranında
/// o tarihe ait değerleri görüntülemek için (en son kayıt varsayılan).
void _showDatePicker(
  BuildContext context,
  WidgetRef ref,
  List<DateTime> dates,
  DateTime? selected,
) {
  final colors = context.appColors;
  final typography = context.appTypography;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref.read(
                  rcTextProvider(RemoteConfigKeys.measurementsDatePickerTitle),
                ),
                style: typography.headingMedium.copyWith(
                  color: colors.onSurface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _DateOption(
                label: ref.read(
                  rcTextProvider(
                    RemoteConfigKeys.measurementsLatestRecordOption,
                  ),
                ),
                selected: selected == null,
                onTap: () {
                  ref
                      .read(measurementsControllerProvider.notifier)
                      .selectDate(null);
                  Navigator.of(sheetContext).pop();
                },
              ),
              for (final date in dates)
                _DateOption(
                  label: _formatDate(date),
                  selected:
                      selected != null &&
                      selected.year == date.year &&
                      selected.month == date.month &&
                      selected.day == date.day,
                  onTap: () {
                    ref
                        .read(measurementsControllerProvider.notifier)
                        .selectDate(date);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _DateOption extends StatelessWidget {
  const _DateOption({
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
    final typography = context.appTypography;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: (selected ? typography.headingSmall : typography.bodyLarge)
                  .copyWith(
                    color: selected ? colors.primary : colors.onSurface,
                    fontSize: 15,
                  ),
            ),
            if (selected) Icon(Icons.check, size: 18, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _AvatarView extends ConsumerStatefulWidget {
  const _AvatarView();

  @override
  ConsumerState<_AvatarView> createState() => _AvatarViewState();
}

class _AvatarViewState extends ConsumerState<_AvatarView> {
  final _valueController = TextEditingController();
  final _valueFocusNode = FocusNode();
  MeasurementMetric? _syncedMetric;
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _save(MeasurementMetric metric) async {
    final raw = _valueController.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(raw);
    if (parsed == null) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await ref.read(measurementsControllerProvider.notifier).addMeasurement({
        metric: parsed,
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage = ref.read(
            rcTextProvider(RemoteConfigKeys.measurementsSaveFailedError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(measurementsControllerProvider);
    final controller = ref.read(measurementsControllerProvider.notifier);
    final selectedPoint = state.points[state.selectedMetric];
    final isLatest = state.selectedDate == null;

    // Nokta değiştiğinde (avatar üzerinde başka bir yere dokunulunca)
    // giriş alanı o noktanın güncel değerine (yoksa boşa) senkronlanır —
    // yarım kalmış bir taslak bir sonraki metriğe sızmaz.
    if (_syncedMetric != state.selectedMetric) {
      _syncedMetric = state.selectedMetric;
      _valueController.text = selectedPoint?.value ?? '';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        AppSpacing.lg,
      ),
      children: [
        if (state.recordedDates.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
              onTap: () => _showDatePicker(
                context,
                ref,
                state.recordedDates,
                state.selectedDate,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        isLatest
                            ? ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys
                                      .measurementsShowingLatestLabel,
                                ),
                              )
                            : ref
                                  .watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .measurementsShowingDateLabel,
                                    ),
                                  )
                                  .replaceAll(
                                    '{date}',
                                    _formatDate(state.selectedDate!),
                                  ),
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.measurementsChangeDateLabel,
                        ),
                      ),
                      style: typography.headingSmall.copyWith(
                        color: colors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Center(
          child: MeasurementAvatar(
            points: state.points,
            selected: state.selectedMetric,
            onSelect: controller.selectPoint,
            gender: state.gender,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.measurementsSelectedPointLabel,
                            ),
                          ),
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                        Text(
                          state.selectedMetric.label,
                          style: typography.headingMedium.copyWith(
                            color: colors.onSurface,
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 130,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: colors.onSurfaceMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: TextField(
                            controller: _valueController,
                            focusNode: _valueFocusNode,
                            enabled: !_isSaving,
                            textAlign: TextAlign.right,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,.]'),
                              ),
                            ],
                            style: typography.dataLarge.copyWith(
                              color: colors.onSurface,
                              fontSize: 24,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              isCollapsed: true,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              hintText: ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.measurementsValueFieldHint,
                                ),
                              ),
                              hintStyle: typography.bodyMedium.copyWith(
                                color: colors.onSurfaceMuted,
                                fontSize: 14,
                              ),
                              suffixText:
                                  ' ${ref.watch(rcTextProvider(RemoteConfigKeys.measurementsUnitCm))}',
                              suffixStyle: typography.bodyMedium.copyWith(
                                color: colors.onSurfaceMuted,
                                fontSize: 15,
                              ),
                            ),
                            onSubmitted: (_) => _save(state.selectedMetric),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (selectedPoint != null)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: selectedPoint.isImprovement
                            ? colors.successContainer
                            : colors.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                      ),
                      child: Text(
                        selectedPoint.delta,
                        style: typography.caption.copyWith(
                          color: selectedPoint.isImprovement
                              ? colors.onSuccessContainer
                              : colors.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        selectedPoint.since,
                        style: typography.caption.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  ref.watch(
                    rcTextProvider(RemoteConfigKeys.measurementsEmptyPointHint),
                  ),
                  style: typography.caption.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  style: typography.bodyMedium.copyWith(
                    color: colors.error,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Material(
                color: colors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  onTap: _isSaving ? null : () => _save(state.selectedMetric),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: AppSpacing.primaryActionHeight,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isSaving
                          ? ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.membersSavingLabel,
                              ),
                            )
                          : ref.watch(
                              rcTextProvider(RemoteConfigKeys.commonKaydet),
                            ),
                      style: typography.headingSmall.copyWith(
                        fontSize: 15,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }
}

class _ChartView extends ConsumerWidget {
  const _ChartView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(measurementsControllerProvider);
    final controller = ref.read(measurementsControllerProvider.notifier);
    final series = state.series[state.selectedMetric];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        AppSpacing.lg,
      ),
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final metric in MeasurementMetric.values)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _MetricChip(
                    label: metric.label,
                    selected: metric == state.selectedMetric,
                    onTap: () => controller.selectPoint(metric),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (series == null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: colors.outline),
            ),
            child: Text(
              ref
                  .watch(
                    rcTextProvider(
                      RemoteConfigKeys.measurementsNoDataForMetric,
                    ),
                  )
                  .replaceAll('{metric}', state.selectedMetric.label),
              style: typography.bodyMedium.copyWith(
                color: colors.onSurfaceMuted,
              ),
            ),
          )
        else ...[
          Builder(
            builder: (context) {
              final lastValue = series.values.last;
              final prevValue = series.values.length > 1
                  ? series.values[series.values.length - 2]
                  : lastValue;
              final diff = lastValue - prevValue;
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref
                                  .watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .measurementsMetricLatestLabel,
                                    ),
                                  )
                                  .replaceAll('{metric}', series.metric.label),
                              style: typography.caption.copyWith(
                                color: colors.onSurfaceMuted,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: lastValue
                                    .toStringAsFixed(1)
                                    .replaceAll('.', ','),
                                style: typography.dataLarge.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 40,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        ' ${ref.watch(rcTextProvider(RemoteConfigKeys.measurementsUnitCm))}',
                                    style: typography.bodyMedium.copyWith(
                                      color: colors.onSurfaceMuted,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: diff == 0
                                    ? colors.surfaceRaised
                                    : (diff < 0
                                          ? colors.successContainer
                                          : colors.primaryContainer),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                diff == 0
                                    ? ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .measurementsNoChangeLabel,
                                        ),
                                      )
                                    : '${diff < 0 ? '−' : '+'}${diff.abs().toStringAsFixed(1).replaceAll('.', ',')} ${ref.watch(rcTextProvider(RemoteConfigKeys.measurementsUnitCm))}',
                                style: typography.caption.copyWith(
                                  fontSize: 12,
                                  color: diff == 0
                                      ? colors.onSurfaceMuted
                                      : (diff < 0
                                            ? colors.onSuccessContainer
                                            : colors.onPrimaryContainer),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              ref
                                  .watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .measurementsSixMonthDeltaLabel,
                                    ),
                                  )
                                  .replaceAll(
                                    '{delta}',
                                    series.totalDeltaLabel,
                                  ),
                              style: typography.caption.copyWith(
                                color: colors.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TrendBarChart(
                      values: series.values,
                      labels: series.months,
                      valueFormatter: (value) =>
                          value.toStringAsFixed(1).replaceAll('.', ','),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            ref.watch(
              rcTextProvider(RemoteConfigKeys.measurementsHistorySection),
            ),
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              children: [
                for (
                  var i = series.values.length - 1;
                  i >= 0 && i >= series.values.length - 4;
                  i--
                )
                  _HistoryRow(
                    date: i == series.values.length - 1
                        ? ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .measurementsLatestMeasurementLabel,
                            ),
                          )
                        : series.months[i],
                    value: series.values[i],
                    delta: i == 0
                        ? null
                        : series.values[i] - series.values[i - 1],
                    showDivider: i > 0 && i >= series.values.length - 4,
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Material(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            onTap: () => controller.setViewMode(MeasurementsViewMode.avatar),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: AppSpacing.primaryActionHeight,
              ),
              alignment: Alignment.center,
              child: Text(
                ref.watch(
                  rcTextProvider(
                    RemoteConfigKeys.measurementsSwitchToAvatarCta,
                  ),
                ),
                style: typography.headingSmall.copyWith(
                  fontSize: 15,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
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
          padding: const EdgeInsets.symmetric(horizontal: 13),
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

class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({
    required this.date,
    required this.value,
    required this.delta,
    required this.showDivider,
  });

  final String date;
  final double value;
  final double? delta;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final deltaLabel = delta == null
        ? '—'
        : delta == 0
        ? ref.watch(rcTextProvider(RemoteConfigKeys.measurementsNoChangeLabel))
        : '${delta! < 0 ? '−' : '+'}${delta!.abs().toStringAsFixed(1).replaceAll('.', ',')}';
    final deltaColor = delta == null || delta == 0
        ? colors.onSurfaceMuted
        : (delta! < 0 ? colors.success : colors.onPrimaryContainer);

    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.outline))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: typography.bodyLarge.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 15,
            ),
          ),
          Row(
            children: [
              Text(
                '${value.toStringAsFixed(1).replaceAll('.', ',')} ${ref.watch(rcTextProvider(RemoteConfigKeys.measurementsUnitCm))}',
                style: typography.headingSmall.copyWith(
                  color: colors.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                deltaLabel,
                style: typography.caption.copyWith(
                  color: deltaColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
