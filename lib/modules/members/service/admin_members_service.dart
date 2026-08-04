import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_member_summary.dart';

part 'admin_members_service.g.dart';

/// Mock servis — F2'de gerçek `members` koleksiyonuna bağlanacak.
class AdminMembersService {
  const AdminMembersService();

  List<AdminMemberSummary> loadMembers() {
    return const [
      AdminMemberSummary(
        id: 'ayse-yilmaz',
        initials: 'AY',
        name: 'Ayşe Yılmaz',
        phone: '0532 418 76 05',
        trainerName: 'Berk Aydın',
        remainingSessions: 6,
        packageEndDate: '12 Eyl 2026',
        status: MemberPackageStatus.active,
      ),
      AdminMemberSummary(
        id: 'cem-demir',
        initials: 'CD',
        name: 'Cem Demir',
        phone: '0533 219 84 40',
        trainerName: 'Berk Aydın',
        remainingSessions: 2,
        packageEndDate: '19 Ağu 2026',
        status: MemberPackageStatus.endingSoon,
      ),
      AdminMemberSummary(
        id: 'zeynep-kaya',
        initials: 'ZK',
        name: 'Zeynep Kaya',
        phone: '0505 762 30 18',
        trainerName: 'Berk Aydın',
        remainingSessions: 9,
        packageEndDate: '3 Eki 2026',
        status: MemberPackageStatus.active,
      ),
      AdminMemberSummary(
        id: 'mert-arslan',
        initials: 'MA',
        name: 'Mert Arslan',
        phone: '0542 887 15 62',
        trainerName: 'Berk Aydın',
        remainingSessions: 0,
        packageEndDate: '15 Ağu 2026',
        status: MemberPackageStatus.none,
      ),
      AdminMemberSummary(
        id: 'defne-soylu',
        initials: 'DS',
        name: 'Defne Soylu',
        phone: '0536 220 41 77',
        trainerName: 'Selin Kara',
        remainingSessions: 5,
        packageEndDate: '28 Ağu 2026',
        status: MemberPackageStatus.active,
      ),
      AdminMemberSummary(
        id: 'kaan-yildirim',
        initials: 'KY',
        name: 'Kaan Yıldırım',
        phone: '0538 904 12 63',
        trainerName: 'Ayşe Demir',
        remainingSessions: 1,
        packageEndDate: '9 Ağu 2026',
        status: MemberPackageStatus.endingSoon,
      ),
    ];
  }
}

@riverpod
AdminMembersService adminMembersService(AdminMembersServiceRef ref) => const AdminMembersService();
