import 'package:egoractive/modules/sessions/domain/member_package_alert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveMemberPackageAlert', () {
    test('returns null when the total increases (admin tops up a package)', () {
      expect(
        resolveMemberPackageAlert(
          beforeTotal: 0,
          afterTotal: 12,
          endingSoonThreshold: 3,
        ),
        isNull,
      );
    });

    test('returns null when the total decreases but stays above the threshold', () {
      expect(
        resolveMemberPackageAlert(
          beforeTotal: 9,
          afterTotal: 8,
          endingSoonThreshold: 3,
        ),
        isNull,
      );
    });

    test('returns endingSoon when the total newly crosses the threshold from above', () {
      expect(
        resolveMemberPackageAlert(
          beforeTotal: 4,
          afterTotal: 3,
          endingSoonThreshold: 3,
        ),
        MemberPackageAlert.endingSoon,
      );
    });

    test('does not re-alert on every further decrease while already ending soon (2 -> 1)', () {
      expect(
        resolveMemberPackageAlert(
          beforeTotal: 2,
          afterTotal: 1,
          endingSoonThreshold: 3,
        ),
        isNull,
      );
    });

    test('returns none when the total reaches zero', () {
      expect(
        resolveMemberPackageAlert(
          beforeTotal: 1,
          afterTotal: 0,
          endingSoonThreshold: 3,
        ),
        MemberPackageAlert.none,
      );
    });

    test('returns none directly when a single write drops the total from well above zero straight to zero', () {
      expect(
        resolveMemberPackageAlert(
          beforeTotal: 5,
          afterTotal: 0,
          endingSoonThreshold: 3,
        ),
        MemberPackageAlert.none,
      );
    });

    test('returns null when already at zero and staying at zero', () {
      expect(
        resolveMemberPackageAlert(
          beforeTotal: 0,
          afterTotal: 0,
          endingSoonThreshold: 3,
        ),
        isNull,
      );
    });
  });
}
