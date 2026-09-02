import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Geri alınamaz (yıkıcı) aksiyonlar için ortak onay diyaloğu — antrenör
/// silme, grup dersi iptali, etkinlik iptali aynı davranışı paylaşsın diye
/// tek yerde toplandı.
///
/// Davranış kuralları (üçü de bilinçli):
/// - `barrierDismissible: false` → dışarı dokununca kapanmaz, yanlışlıkla
///   onaylanmasın/kaybolmasın.
/// - Diyalog, [onConfirm] TAMAMLANANA kadar AÇIK kalır (`StatefulBuilder`) —
///   "kapandı, demek ki oldu" yanılgısını önler; hata olursa [errorMessage]
///   diyaloğun içinde gösterilir, kullanıcı tekrar deneyebilir.
/// - İşlem sürerken her iki buton da pasif, onay butonu [busyLabel]'a döner.
///
/// [onConfirm] başarıyla tamamlanırsa `true`, kullanıcı vazgeçerse ya da
/// diyalog hata sonrası kapatılırsa `false` döner.
Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  required String busyLabel,
  required String errorMessage,
  required Future<void> Function() onConfirm,
}) async {
  var isBusy = false;
  String? error;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final colors = dialogContext.appColors;
      final typography = dialogContext.appTypography;

      return StatefulBuilder(
        builder: (dialogContext, setLocalState) {
          return AlertDialog(
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            title: Text(
              title,
              style: typography.headingSmall.copyWith(
                color: colors.onSurface,
                fontSize: 17,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: typography.bodyMedium.copyWith(
                    color: colors.onSurfaceMuted,
                    fontSize: 14,
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    error!,
                    style: typography.bodyMedium.copyWith(
                      color: colors.error,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isBusy
                    ? null
                    : () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  cancelLabel,
                  style: typography.bodyMedium.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ),
              TextButton(
                onPressed: isBusy
                    ? null
                    : () async {
                        setLocalState(() {
                          isBusy = true;
                          error = null;
                        });
                        try {
                          await onConfirm();
                        } catch (_) {
                          setLocalState(() {
                            isBusy = false;
                            error = errorMessage;
                          });
                          return;
                        }
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop(true);
                        }
                      },
                child: Text(
                  isBusy ? busyLabel : confirmLabel,
                  style: typography.bodyMedium.copyWith(color: colors.error),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  return result ?? false;
}
