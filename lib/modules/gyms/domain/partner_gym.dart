import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_gym.freezed.dart';

/// Girişten önceki "Anlaşmalı Salonlar" listesinde gösterilen, tüm
/// kullanıcılara açık salon alt kümesi — bkz.
/// `functions/src/callable/list-partner-gyms.ts`.
@freezed
class PartnerGym with _$PartnerGym {
  const factory PartnerGym({
    required String id,
    required String name,
    required String phone,
    required String city,
    required String address,
    @Default('') String logoUrl,
  }) = _PartnerGym;
}
