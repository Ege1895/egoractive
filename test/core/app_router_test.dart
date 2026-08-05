import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/panels/shell/admin_shell_panel.dart';
import 'package:egoractive/core/panels/shell/member_shell_panel.dart';
import 'package:egoractive/core/panels/shell/trainer_shell_panel.dart';
import 'package:egoractive/core/router/app_router.dart';

void main() {
  group('roleFromClaims', () {
    test('maps known role strings to AppRole', () {
      expect(roleFromClaims({'role': 'admin'}), AppRole.admin);
      expect(roleFromClaims({'role': 'trainer'}), AppRole.trainer);
      expect(roleFromClaims({'role': 'member'}), AppRole.member);
    });

    test('returns null for missing, unknown, or malformed claims', () {
      expect(roleFromClaims(null), isNull);
      expect(roleFromClaims({}), isNull);
      expect(roleFromClaims({'role': 'superadmin'}), isNull);
      expect(roleFromClaims({'role': 123}), isNull);
    });
  });

  group('shellForRole', () {
    test('maps each role to its shell panel', () {
      expect(shellForRole(AppRole.admin), isA<AdminShellPanel>());
      expect(shellForRole(AppRole.trainer), isA<TrainerShellPanel>());
      expect(shellForRole(AppRole.member), isA<MemberShellPanel>());
    });
  });
}
