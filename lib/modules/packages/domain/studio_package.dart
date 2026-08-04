import 'package:freezed_annotation/freezed_annotation.dart';

part 'studio_package.freezed.dart';

enum PackageSessionType { solo, group }

extension PackageSessionTypeLabel on PackageSessionType {
  String get label => switch (this) {
        PackageSessionType.solo => 'Birebir',
        PackageSessionType.group => 'Grup',
      };
}

@freezed
class StudioPackage with _$StudioPackage {
  const factory StudioPackage({
    required String id,
    required String name,
    required PackageSessionType sessionType,
    required int sessionCount,
    required int validityDays,
    required int priceTl,
    @Default(true) bool activeForSale,
  }) = _StudioPackage;

  const StudioPackage._();

  int get pricePerSession => sessionCount == 0 ? 0 : (priceTl / sessionCount).round();
}
