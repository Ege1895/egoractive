import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/currency_constants.dart';
import '../../core/theme/app_theme.dart';

/// F9-2 — global para birimi desteği. `AppTextField`'ın görsel diliyle
/// (surfaceRaised zemin, radiusInner) uyumlu, dokununca aranabilir bir alt
/// sayfa (bottom sheet) açan para birimi seçici. TRY listenin her zaman en
/// üstünde/ilk sırada gösterilir.
class AppCurrencyField extends StatelessWidget {
  const AppCurrencyField({
    required this.currencyCode,
    required this.locale,
    this.label,
    this.enabled = true,
    this.onChanged,
    super.key,
  });

  final String currencyCode;
  final String locale;
  final String? label;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final radius = BorderRadius.circular(AppSpacing.radiusInner);

    return Material(
      color: colors.surfaceRaised,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: enabled
            ? () => _openPicker(context, currencyCode, locale, onChanged)
            : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (label != null)
                      Text(
                        label!,
                        style: typography.caption.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    Text(
                      '$currencyCode — ${currencyDisplayName(currencyCode, locale)}',
                      style: typography.bodyLarge.copyWith(
                        color: enabled
                            ? colors.onSurface
                            : colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                Icon(Icons.keyboard_arrow_down, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  void _openPicker(
    BuildContext context,
    String selected,
    String locale,
    ValueChanged<String>? onChanged,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _CurrencyPickerSheet(
        selected: selected,
        locale: locale,
        onSelected: (code) {
          onChanged?.call(code);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({
    required this.selected,
    required this.locale,
    required this.onSelected,
  });

  final String selected;
  final String locale;
  final ValueChanged<String> onSelected;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final query = _query.trim().toLowerCase();
    final filtered = supportedCurrencyCodes.where((code) {
      if (query.isEmpty) return true;
      final name = currencyDisplayName(code, widget.locale).toLowerCase();
      return code.toLowerCase().contains(query) || name.contains(query);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.lg,
                AppSpacing.screenEdge,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colors.outlineStrong,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _searchController,
                    autofocus: false,
                    onChanged: (value) => setState(() => _query = value),
                    style: typography.bodyLarge.copyWith(
                      color: colors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.locale == 'tr' ? 'Ara' : 'Search',
                      hintStyle: typography.bodyLarge.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                      filled: true,
                      fillColor: colors.surfaceRaised,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusInner,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenEdge,
                ),
                children: [
                  for (final code in filtered)
                    _CurrencyRow(
                      code: code,
                      name: currencyDisplayName(code, widget.locale),
                      selected: code == widget.selected,
                      onTap: () => widget.onSelected(code),
                    ),
                  const SizedBox(height: AppSpacing.md),
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
    _searchController.dispose();
    super.dispose();
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String name;
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code,
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    name,
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check, color: colors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
