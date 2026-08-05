import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/studio_rules.dart';

part 'studio_rules_service.g.dart';

/// Mock servis — F2'de gerçek `gyms/{gymId}.rulesText` alanına bağlanacak.
class StudioRulesService {
  const StudioRulesService();

  StudioRules loadRules() {
    return const StudioRules(
      lastUpdatedLabel: '14 Temmuz 2026',
      text: '⏰ Seansına 10 dakikadan fazla gecikirsen ders kısaltılır, hakkın yanmaz.\n\n'
          'Dersini en az 2 saat önce iptal et; daha sonrası kalan dersinden düşer. Telafi seansların paket bitiminden sonra 30 gün geçerlidir.\n\n'
          '👟 Stüdyoya temiz spor ayakkabı ile gir, ayakkabıları girişteki dolaba bırak. Kendi suyunu getir; ekipmanı kullandıktan sonra dezenfektanla sil.\n\n'
          'Grup derslerinde telefon sessize alınır, ders başladıktan 5 dakika sonra kapı kapanır.\n\n'
          'Her şey için teşekkürler — iyi çalışmalar 💪',
    );
  }
}

@riverpod
StudioRulesService studioRulesService(StudioRulesServiceRef ref) => const StudioRulesService();
