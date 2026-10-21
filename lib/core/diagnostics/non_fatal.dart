import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Kullanıcıya yansımayan ama teşhis için görmemiz gereken hataları hem
/// loga yazar hem Crashlytics'e "non-fatal" olarak gönderir. Bu hatalar
/// önceden sessizce yutuluyordu; örneğin AdMob rıza mesajı eksikken
/// reklamların hiç gösterilmemesi ancak cihaz logu okunarak bulunabildi.
///
/// Crashlytics başlatılmamışsa (test ortamı) yalnızca loga yazar.
void reportNonFatal(String tag, Object error, [StackTrace? stack]) {
  debugPrint('[$tag] $error');
  try {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: tag,
      fatal: false,
    );
  } catch (_) {
    // Crashlytics yoksa yalnızca log yeterli.
  }
}
