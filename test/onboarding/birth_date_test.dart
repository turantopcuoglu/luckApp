import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_repository.dart';
import 'package:kader/features/onboarding/profile_form_state.dart';

void main() {
  test('v2 doğum tarihi round-trip kimliği ve seed değerini korur', () {
    const UserProfile original = UserProfile(
      isim: 'Ada',
      seedSurumu: 2,
      rituelKimligi: 'fixed-id',
    );
    final UserProfile edited = original.copyWith(
      dogumTarihi: DateTime(1998, 5, 14),
    );
    final UserProfile restored = UserProfile.fromMap(edited.toMap());
    expect(restored.dogumTarihi, DateTime(1998, 5, 14));
    expect(restored.rituelKimligi, original.rituelKimligi);
    expect(restored.seed.isimHash, original.seed.isimHash);
    expect(restored.seed.dogumTarihi, original.seed.dogumTarihi);
    final UserProfile legacy = UserProfile(
      isim: 'Ada',
      dogumTarihi: DateTime(1990, 1, 1),
    );
    expect(
      () => legacy.copyWith(dogumTarihi: DateTime(1991, 1, 1)),
      throwsArgumentError,
    );
  });
  test('yeni form tarih seçilmeden veya gelecek tarih ile yazmaz', () async {
    final _Repo repo = _Repo();
    final ProviderContainer scope = ProviderContainer(
      overrides: <Override>[
        userRepositoryProvider.overrideWithValue(repo),
        birthDateTodayProvider.overrideWithValue(DateTime(2026, 9, 8)),
      ],
    );
    addTearDown(scope.dispose);
    final ProfileFormController form = scope.read(profileFormProvider.notifier);
    form.changeName('Ada');
    expect(await form.save(), isFalse);
    expect(scope.read(profileFormProvider).invalidBirthDate, isTrue);
    form.changeBirthDate(DateTime(2026, 9, 9));
    expect(await form.save(), isFalse);
    form.changeBirthDate(DateTime(1899));
    expect(await form.save(), isFalse);
    expect(repo.writes, 0);
    form.changeBirthDate(DateTime(1998, 5, 14, 12));
    form.changeName('Ada Yeni');
    expect(scope.read(profileFormProvider).birthDate, DateTime(1998, 5, 14));
    expect(await form.save(), isTrue);
    expect(repo.profile!.dogumTarihi, DateTime(1998, 5, 14));
    expect(repo.profile!.seedSurumu, 2);
  });
}

class _Repo extends UserRepository {
  _Repo() : super(_Box());
  UserProfile? profile;
  int writes = 0;
  @override
  UserProfile? profil() => profile;
  @override
  Future<void> kaydet(UserProfile value) async {
    profile = value;
    writes++;
  }
}

class _Box implements Box<Map<dynamic, dynamic>> {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
