import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/remote_config/remote_config_service.dart';
import '../../core/theme/app_theme.dart';

/// Platformun kendi native tarih seçicisi: iOS'ta gün/ay/yıl scroll wheel'i
/// (`CupertinoDatePicker`), Android'de kendi Material takvim diyaloğu
/// (`showDatePicker`). Üye kayıt tarihi (`member_info_panel.dart`) ve üyelik
/// başlangıç/bitiş tarihi (`new_membership_package_panel.dart`) arasında
/// paylaşılır.
Future<void> showNativeDatePicker({
  required BuildContext context,
  required DateTime initial,
  required DateTime firstDate,
  required DateTime lastDate,
  required ValueChanged<DateTime> onSelected,
}) async {
  if (Platform.isIOS) {
    final colors = context.appColors;
    var selected = initial;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) {
        return Container(
          height: 320,
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          color: colors.surface,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    child: Text(
                      ProviderScope.containerOf(sheetContext).read(
                        rcTextProvider(RemoteConfigKeys.commonTamamButton),
                      ),
                    ),
                    onPressed: () {
                      onSelected(selected);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    minimumDate: firstDate,
                    maximumDate: lastDate,
                    onDateTimeChanged: (date) => selected = date,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return;
  }
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: firstDate,
    lastDate: lastDate,
  );
  if (picked != null) onSelected(picked);
}
