import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/studio_packages_controller.dart';
import '../../domain/studio_package.dart';

/// Admin 9 · Paket Ekle / Düzenle — ders tipi ve seans sayısı seçilebilir.
class EditStudioPackagePanel extends BasePanel {
  const EditStudioPackagePanel({this.existing, super.key});

  final StudioPackage? existing;

  bool get isNew => existing == null;

  @override
  ConsumerState<EditStudioPackagePanel> createState() =>
      _EditStudioPackagePanelState();
}

class _EditStudioPackagePanelState
    extends BasePanelState<EditStudioPackagePanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _sessionCountController;
  late final TextEditingController _validityController;
  late final TextEditingController _priceController;
  late PackageSessionType _sessionType;
  late bool _activeForSale;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _nameError;
  String? _sessionCountError;
  String? _validityError;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    // Önceden yeni paket eklerken bu iki alan sabit 12/90 dolu geliyordu —
    // admin fark etmeden gerçek olmayan değerleri kaydedebiliyordu. Yeni
    // pakette boş başlar, sadece düzenlerken gerçek değer dolu gelir.
    _sessionCountController = TextEditingController(
      text: existing == null ? '' : '${existing.sessionCount}',
    );
    _validityController = TextEditingController(
      text: existing == null ? '' : '${existing.validityDays}',
    );
    _priceController = TextEditingController(text: '${existing?.priceTl ?? 0}');
    _sessionType = existing?.sessionType ?? PackageSessionType.solo;
    _activeForSale = existing?.activeForSale ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final controller = ref.read(studioPackagesControllerProvider.notifier);
    final sessionCount = int.tryParse(_sessionCountController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;
    final perSession = sessionCount == 0 ? 0 : (price / sessionCount).round();

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref.watch(
                      rcTextProvider(
                        widget.isNew
                            ? RemoteConfigKeys.packagesAddTitle
                            : RemoteConfigKeys.packagesEditTitle,
                      ),
                    ),
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
                    child: Text(
                      ref.watch(rcTextProvider(RemoteConfigKeys.commonVazgec)),
                      style: typography.bodyLarge.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.packagesEditNameFieldLabel,
                            ),
                          ),
                          controller: _nameController,
                          hint: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.packagesNameFieldHint,
                            ),
                          ),
                          errorText: _nameError,
                          onChanged: (_) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .packagesEditSessionTypeFieldLabel,
                            ),
                          ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            for (final type in PackageSessionType.values)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                        type == PackageSessionType.values.last
                                        ? 0
                                        : AppSpacing.sm,
                                  ),
                                  child: _TypeChip(
                                    label: ref.watch(
                                      rcTextProvider(
                                        type == PackageSessionType.solo
                                            ? RemoteConfigKeys
                                                  .trainersReportOneOnOneToggle
                                            : RemoteConfigKeys
                                                  .trainersReportGroupToggle,
                                      ),
                                    ),
                                    selected: _sessionType == type,
                                    onTap: () =>
                                        setState(() => _sessionType = type),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.commonSeansSayisiLabel,
                                  ),
                                ),
                                hint: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .packagesSessionCountFieldHint,
                                  ),
                                ),
                                controller: _sessionCountController,
                                keyboardType: TextInputType.number,
                                errorText: _sessionCountError,
                                onChanged: (_) =>
                                    setState(() => _sessionCountError = null),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppTextField(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .packagesEditValidityDaysFieldLabel,
                                  ),
                                ),
                                hint: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.packagesValidityFieldHint,
                                  ),
                                ),
                                controller: _validityController,
                                keyboardType: TextInputType.number,
                                errorText: _validityError,
                                onChanged: (_) =>
                                    setState(() => _validityError = null),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.packagesEditPriceFieldLabel,
                            ),
                          ),
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ref
                              .watch(
                                rcTextProvider(
                                  RemoteConfigKeys
                                      .packagesPerSessionPriceCaption,
                                ),
                              )
                              .replaceAll('{price}', '$perSession'),
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 60),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: colors.outline),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .packagesEditOnSaleToggleLabel,
                                        ),
                                      ),
                                      style: typography.bodyLarge.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .packagesEditOnSaleToggleDescription,
                                        ),
                                      ),
                                      style: typography.caption.copyWith(
                                        color: colors.onSurfaceMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _activeForSale = !_activeForSale,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 52,
                                  height: 32,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: _activeForSale
                                        ? colors.primary
                                        : colors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill,
                                    ),
                                  ),
                                  alignment: _activeForSale
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: colors.onSurface,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!widget.isNew)
                          InkWell(
                            onTap: _isDeleting
                                ? null
                                : () async {
                                    setState(() {
                                      _isDeleting = true;
                                      _errorMessage = null;
                                    });
                                    try {
                                      await controller.deletePackage(
                                        widget.existing!.id,
                                      );
                                      if (mounted) {
                                        ref
                                            .read(
                                              panelStackControllerProvider
                                                  .notifier,
                                            )
                                            .pop();
                                      }
                                    } catch (_) {
                                      if (mounted) {
                                        setState(() {
                                          _isDeleting = false;
                                          _errorMessage = ref.read(
                                            rcTextProvider(
                                              RemoteConfigKeys
                                                  .packagesDeleteFailedError,
                                            ),
                                          );
                                        });
                                      }
                                    }
                                  },
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 60),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isDeleting
                                        ? ref.watch(
                                            rcTextProvider(
                                              RemoteConfigKeys
                                                  .authDeleteAccountInProgressButton,
                                            ),
                                          )
                                        : ref.watch(
                                            rcTextProvider(
                                              RemoteConfigKeys
                                                  .packagesDeletePackageButton,
                                            ),
                                          ),
                                    style: typography.bodyLarge.copyWith(
                                      color: colors.error,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: colors.onSurfaceMuted,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: _isSaving
                        ? ref.watch(
                            rcTextProvider(RemoteConfigKeys.membersSavingLabel),
                          )
                        : ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonKaydet),
                          ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            final name = _nameController.text.trim();
                            final sessionCount = int.tryParse(
                              _sessionCountController.text.trim(),
                            );
                            final validityDays = int.tryParse(
                              _validityController.text.trim(),
                            );
                            final nameError = name.isEmpty
                                ? ref.read(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .packagesNameRequiredError,
                                    ),
                                  )
                                : null;
                            final sessionCountError =
                                sessionCount == null || sessionCount <= 0
                                ? ref.read(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .packagesSessionCountInvalidError,
                                    ),
                                  )
                                : null;
                            final validityError =
                                validityDays == null || validityDays <= 0
                                ? ref.read(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .packagesValidityInvalidError,
                                    ),
                                  )
                                : null;
                            if (nameError != null ||
                                sessionCountError != null ||
                                validityError != null) {
                              setState(() {
                                _nameError = nameError;
                                _sessionCountError = sessionCountError;
                                _validityError = validityError;
                              });
                              return;
                            }
                            if (widget.existing == null &&
                                !await ensureSubscriptionAllowsWrite(
                                  context,
                                  ref,
                                )) {
                              return;
                            }
                            setState(() {
                              _isSaving = true;
                              _errorMessage = null;
                            });
                            try {
                              await controller.addOrUpdate(
                                StudioPackage(
                                  id:
                                      widget.existing?.id ??
                                      name.toLowerCase().replaceAll(' ', '-'),
                                  name: name,
                                  sessionType: _sessionType,
                                  sessionCount: sessionCount!,
                                  validityDays: validityDays!,
                                  priceTl:
                                      int.tryParse(_priceController.text) ?? 0,
                                  activeForSale: _activeForSale,
                                ),
                              );
                              if (mounted) {
                                ref
                                    .read(panelStackControllerProvider.notifier)
                                    .pop();
                              }
                            } catch (_) {
                              if (mounted) {
                                setState(() {
                                  _isSaving = false;
                                  _errorMessage = ref.read(
                                    rcTextProvider(
                                      RemoteConfigKeys.packagesSaveFailedError,
                                    ),
                                  );
                                });
                              }
                            }
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sessionCountController.dispose();
    _validityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
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
      color: selected ? colors.primary : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 15,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
