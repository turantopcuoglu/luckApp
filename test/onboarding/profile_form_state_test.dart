import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_profile_factory.dart';
import 'package:kader/core/storage/user_repository.dart';
import 'package:kader/features/onboarding/profile_form_state.dart';

void main() {
  late _Repository repo;
  late ProviderContainer container;
  late ProfileFormController form;
  late int identities;
  setUp(() {
    identities = 0;
    repo = _Repository();
    container = ProviderContainer(
      overrides: <Override>[
        userRepositoryProvider.overrideWithValue(repo),
        userProfileFactoryProvider.overrideWithValue(
          UserProfileFactory(kimlikUret: () => 'identity-${++identities}'),
        ),
      ],
    );
    form = container.read(profileFormProvider.notifier);
  });
  tearDown(() => container.dispose());
  test(
    'boş ad yazılmaz; yeni profil v2, doğum tarihi kayıtlı ve bildirimler kapalı',
    () async {
      form.changeName('  ');
      form.changeBirthDate(DateTime(1998, 5, 14));
      expect(await form.save(), isFalse);
      expect(container.read(profileFormProvider).invalidName, isTrue);
      expect(repo.calls, 0);
      form.changeName('  Ada  ');
      form.changeBirthDate(DateTime(1998, 5, 14));
      expect(await form.save(), isTrue);
      expect(repo.profile!.isim, 'Ada');
      expect(repo.profile!.seedSurumu, 2);
      expect(repo.profile!.dogumTarihi, DateTime(1998, 5, 14));
      expect(repo.profile!.bildirimlerAcik, isFalse);
      expect(repo.profile!.onboardingTamam, isFalse);
      expect(identities, 1);
    },
  );
  test(
    'disk yazması beklenir; çift gönderim tek kimlik/tek kayıt üretir',
    () async {
      repo.pending = Completer<void>();
      form.changeName('Ada');
      form.changeBirthDate(DateTime(1998, 5, 14));
      final Future<bool> saved = form.save();
      expect(container.read(profileFormProvider).saving, isTrue);
      expect(await form.save(), isFalse);
      form.changeName('İkinci');
      form.changeBirthDate(DateTime(1998, 5, 14));
      expect(container.read(profileFormProvider).name, 'Ada');
      expect(repo.calls, 1);
      repo.pending!.complete();
      expect(await saved, isTrue);
      expect(identities, 1);
    },
  );
  test('disk hatası tekrarında taslak ve ilk kimlik korunur', () async {
    repo.pending = Completer<void>();
    form.changeName('Ada');
    form.changeBirthDate(DateTime(1998, 5, 14));
    final Future<bool> saved = form.save();
    repo.pending!.completeError(StateError('disk'));
    expect(await saved, isFalse);
    expect(container.read(profileFormProvider).failed, isTrue);
    expect(container.read(profileFormProvider).name, 'Ada');
    repo.pending = null;
    expect(await form.save(), isTrue);
    expect(identities, 1);
    expect(repo.profile!.rituelKimligi, 'identity-1');
  });
  test(
    'kapanış sonrası tamamlanan yazım dispose edilmiş state kullanmaz',
    () async {
      repo.pending = Completer<void>();
      form.changeName('Ada');
      form.changeBirthDate(DateTime(1998, 5, 14));
      final Future<bool> saved = form.save();
      container.dispose();
      repo.pending!.complete();
      expect(await saved, isFalse);
      container = ProviderContainer();
    },
  );
  test('yarım kalan v2 profilde rumuz değişse de kimlik korunur', () async {
    repo.profile = const UserProfile(
      isim: 'Ada',
      rituelKimligi: 'saved-id',
      seedSurumu: 2,
      bildirimlerAcik: false,
    );
    container.invalidate(profileFormProvider);
    form = container.read(profileFormProvider.notifier);
    expect(container.read(profileFormProvider).name, 'Ada');
    form.changeName('Rumuz');
    form.changeBirthDate(DateTime(1998, 5, 14));
    expect(await form.save(), isTrue);
    expect(repo.profile!.isim, 'Rumuz');
    expect(repo.profile!.rituelKimligi, 'saved-id');
    expect(identities, 0);
  });
  test(
    'yarım kalan legacy profil yeniden tohumlanmaz veya adlandırılmaz',
    () async {
      final UserProfile legacy = UserProfile(
        isim: 'Turan',
        dogumTarihi: DateTime(1990, 5, 15),
      );
      repo.profile = legacy;
      container.invalidate(profileFormProvider);
      form = container.read(profileFormProvider.notifier);
      form.changeName('Değişiklik');
      form.changeBirthDate(DateTime(1998, 5, 14));
      expect(await form.save(), isTrue);
      expect(repo.profile!.toMap(), legacy.toMap());
      expect(identities, 0);
    },
  );
}

class _Repository extends UserRepository {
  _Repository() : super(_UnusedBox());
  UserProfile? profile;
  Completer<void>? pending;
  int calls = 0;
  @override
  UserProfile? profil() => profile;
  @override
  Future<void> kaydet(UserProfile value) async {
    calls++;
    if (pending != null) await pending!.future;
    profile = value;
  }
}

class _UnusedBox implements Box<Map<dynamic, dynamic>> {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
