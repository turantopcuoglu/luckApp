import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_profile_factory.dart';
import 'package:kader/core/storage/user_repository.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/history/history_providers.dart';
import 'package:kader/features/onboarding/profile_form_state.dart';

import '../fixtures/legacy_storage_fixtures.dart';

void main() {
  late Directory directory;
  late Box<Map<dynamic, dynamic>> profiles;
  late Box<Map<dynamic, dynamic>> records;
  late UserRepository users;
  late LuckHistoryRepository history;
  final DateTime day = DateTime(2026, 7, 6);
  final DateTime openedAt = DateTime.utc(2026, 7, 6, 9);
  const LuckEngine engine = LuckEngine();

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('kader_schema_v2_');
    Hive.init(directory.path);
    profiles = await Hive.openBox<Map<dynamic, dynamic>>('profiles');
    records = await Hive.openBox<Map<dynamic, dynamic>>('records');
    users = UserRepository(profiles);
    history = LuckHistoryRepository(records);
  });

  tearDown(() async {
    await profiles.deleteFromDisk();
    await records.deleteFromDisk();
    await directory.delete(recursive: true);
  });

  Future<void> legacyRecord() => records.put(
    gunAnahtari(day),
    Map<dynamic, dynamic>.from(legacyDailyRecordFixture),
  );

  test(
    'onboarding formu gerçek Hive yazımından sonra yeniden açılınca aynı tohumu kullanır',
    () async {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          userRepositoryProvider.overrideWithValue(users),
          userProfileFactoryProvider.overrideWithValue(
            UserProfileFactory(kimlikUret: () => 'onboarding-stable-id'),
          ),
        ],
      );
      final ProfileFormController controller = container.read(
        profileFormProvider.notifier,
      );
      controller.changeName('Ada');
      controller.changeBirthDate(DateTime(1998, 5, 14));
      expect(await controller.save(), isTrue);
      final UserProfile saved = users.profil()!;
      final LuckResult before = engine.hesapla(kullanici: saved.seed, gun: day);
      await users.onboardingTamamla();
      container.dispose();
      await profiles.close();
      profiles = await Hive.openBox<Map<dynamic, dynamic>>('profiles');
      users = UserRepository(profiles);
      final UserProfile reopened = users.profil()!;
      expect(reopened.rituelKimligi, saved.rituelKimligi);
      expect(reopened.onboardingTamam, isTrue);
      expect(reopened.bildirimlerAcik, isFalse);
      expect(reopened.dogumTarihi, DateTime(1998, 5, 14));
      expect(
        engine.hesapla(kullanici: reopened.seed, gun: day).genelSkor,
        before.genelSkor,
      );
      expect(
        engine.hesapla(kullanici: reopened.seed, gun: day).kategoriSkorlari,
        before.kategoriSkorlari,
      );
    },
  );

  test(
    'üretim factorysi 256 bit anonim kimlik üretir ve bildirimleri kapalı başlatır',
    () {
      final UserProfile p = const UserProfileFactory().olustur(isim: 'Ada');
      expect(p.rituelKimligi, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(p.dogumTarihi, isNull);
      expect(p.seedSurumu, 2);
      expect(p.bildirimlerAcik, isFalse);
      expect(p.onboardingTamam, isFalse);
      expect(p.seed.isimHash, p.seed.isimHash);
      expect(UserProfile.fromMap(p.toMap()).rituelKimligi, p.rituelKimligi);
    },
  );

  test('geçersiz factory çıktısı kalıcı profil oluşturmaz', () async {
    await expectLater(
      users.profilOlustur(
        isim: 'Ada',
        factory: UserProfileFactory(kimlikUret: () => ' '),
      ),
      throwsFormatException,
    );
    expect(profiles.isEmpty, isTrue);
  });

  test(
    'bozuk alan türleri anlaşılır migration hatası verir; ham veri korunur',
    () async {
      for (final Map<String, dynamic> extra in <Map<String, dynamic>>[
        <String, dynamic>{'seedSurumu': null},
        <String, dynamic>{'seedSurumu': 1.0},
        <String, dynamic>{'dogumTarihi': 'bozuk'},
        <String, dynamic>{'isim': 42},
      ]) {
        final Map<String, dynamic> bad = <String, dynamic>{
          ...legacyUserProfileFixture,
          ...extra,
        };
        await profiles.put(StorageKeys.profilKaydi, bad);
        expect(users.profil, throwsFormatException);
        await expectLater(
          users.profilOlustur(isim: 'Ada', factory: const UserProfileFactory()),
          throwsFormatException,
        );
        expect(profiles.get(StorageKeys.profilKaydi), bad);
      }
      for (final Map<String, dynamic> extra in <Map<String, dynamic>>[
        <String, dynamic>{'revealedAt': 'bozuk'},
        <String, dynamic>{
          'feedbackTags': <dynamic>[42],
        },
        <String, dynamic>{'sonuc': 'bozuk'},
        <String, dynamic>{'feedbackPozitif': 'true'},
      ]) {
        final Map<String, dynamic> bad = <String, dynamic>{
          ...legacyDailyRecordFixture,
          ...extra,
        };
        await records.put(gunAnahtari(day), bad);
        expect(() => history.getir(day), throwsFormatException);
        expect(records.get(gunAnahtari(day)), bad);
      }
    },
  );

  test(
    'eski profil okunurken yeniden yazılmaz ve motor golden korunur',
    () async {
      await profiles.put(StorageKeys.profilKaydi, legacyUserProfileFixture);
      final UserProfile profile = users.profil()!;
      expect(profile.seedSurumu, 1);
      expect(profile.rituelKimligi, isNull);
      final LuckResult result = engine.hesapla(
        kullanici: profile.seed,
        gun: day,
      );
      expect(result.genelSkor, 62);
      expect(
        result.kategoriSkorlari,
        DailyRecord.fromMap(legacyDailyRecordFixture).sonuc.kategoriSkorlari,
      );
      expect(profiles.get(StorageKeys.profilKaydi), legacyUserProfileFixture);
    },
  );

  test(
    'doğum tarihsiz kimlik yalnız bir kez üretilir ve yeniden açmada korunur',
    () async {
      int calls = 0;
      final UserProfileFactory factory = UserProfileFactory(
        kimlikUret: () => 'identity-${++calls}',
      );
      final List<UserProfile> created = await Future.wait(<Future<UserProfile>>[
        users.profilOlustur(isim: 'Ada', factory: factory),
        users.profilOlustur(isim: 'Ada', factory: factory),
      ]);
      expect(calls, 1);
      expect(created.map((UserProfile p) => p.rituelKimligi).toSet(), <String>{
        'identity-1',
      });
      await profiles.close();
      profiles = await Hive.openBox<Map<dynamic, dynamic>>('profiles');
      users = UserRepository(profiles);
      final UserProfile loaded = users.profil()!;
      expect(loaded.seedSurumu, 2);
      expect(loaded.dogumTarihi, isNull);
      expect(loaded.rituelKimligi, 'identity-1');
      await users.profilOlustur(isim: 'Başka', factory: factory);
      expect(calls, 1);
    },
  );

  test('eski profil oluşturma çağrısında sürüm 2ye taşınmaz', () async {
    await profiles.put(StorageKeys.profilKaydi, legacyUserProfileFixture);
    final UserProfile p = await users.profilOlustur(
      isim: 'Yeni',
      factory: UserProfileFactory(
        kimlikUret: () => throw StateError('çağrılmamalı'),
      ),
    );
    expect(p.seedSurumu, 1);
    expect(profiles.get(StorageKeys.profilKaydi), legacyUserProfileFixture);
  });

  test(
    'görünen ad v2 tohumunu; tercihler hiçbir sürümün tohumunu değiştirmez',
    () {
      final UserProfile modern = UserProfileFactory(
        kimlikUret: () => 'stable-id',
      ).olustur(isim: 'Ada');
      for (final UserProfile p in <UserProfile>[
        modern,
        UserProfile.fromMap(legacyUserProfileFixture),
      ]) {
        final UserProfile changed = p.copyWith(
          isim: p.seedSurumu == 2 ? 'Ege' : p.isim,
          dil: AppDil.en,
          bildirimlerAcik: false,
          aksamBildirimDakika: 600,
          sabahBildirimDakika: 400,
        );
        expect(changed.seed.isimHash, p.seed.isimHash);
        expect(changed.seed.dogumTarihi, p.seed.dogumTarihi);
        expect(
          engine.hesapla(kullanici: changed.seed, gun: day).kategoriSkorlari,
          engine.hesapla(kullanici: p.seed, gun: day).kategoriSkorlari,
        );
      }
    },
  );

  test(
    'nullable profil tercihleri açık null ile temizlenir, kimlik korunur',
    () {
      final UserProfile p = UserProfileFactory(kimlikUret: () => 'stable-id')
          .olustur(isim: 'Ada')
          .copyWith(
            dil: AppDil.en,
            aksamBildirimDakika: 600,
            sabahBildirimDakika: 400,
          );
      expect(p.copyWith().toMap(), p.toMap());
      final UserProfile cleared = p.copyWith(
        dil: null,
        aksamBildirimDakika: null,
        sabahBildirimDakika: null,
      );
      expect(cleared.dil, isNull);
      expect(cleared.aksamBildirimDakika, isNull);
      expect(cleared.sabahBildirimDakika, isNull);
      expect(cleared.rituelKimligi, p.rituelKimligi);
    },
  );

  test(
    'legacy günlük okuma yazmaz; eşzamanlı reveal ilk zamanı korur',
    () async {
      await legacyRecord();
      expect(history.getir(day)!.revealedAt, isNull);
      expect(records.get(gunAnahtari(day)), legacyDailyRecordFixture);
      await Future.wait(<Future<void>>[
        history.revealKaydet(day, revealedAt: openedAt),
        history.revealKaydet(
          day,
          revealedAt: openedAt.add(const Duration(minutes: 1)),
        ),
        history.feedbackDurumuKaydet(
          day,
          mood: FeedbackMood.neutral,
          tags: <String>['akis'],
        ),
      ]);
      await records.close();
      records = await Hive.openBox<Map<dynamic, dynamic>>('records');
      history = LuckHistoryRepository(records);
      expect(history.getir(day)!.revealedAt, openedAt);
      expect(history.getir(day)!.feedbackMood, FeedbackMood.neutral);
      expect(
        records.get(gunAnahtari(day))!['sonuc'],
        legacyDailyRecordFixture['sonuc'],
      );
    },
  );

  for (final FeedbackMood mood in FeedbackMood.values) {
    test('${mood.name} feedback aynı kayda yazılır ve sonucu korur', () async {
      await legacyRecord();
      await history.revealKaydet(day, revealedAt: openedAt);
      await history.feedbackDurumuKaydet(
        day,
        mood: mood,
        tags: <String>['bag', 'denge'],
      );
      final DailyRecord loaded = history.getir(day)!;
      expect(loaded.feedbackMood, mood);
      expect(loaded.feedbackTags, <String>['bag', 'denge']);
      expect(loaded.revealedAt, openedAt);
      expect(records.length, 1);
      expect(
        records.get(gunAnahtari(day))!['sonuc'],
        legacyDailyRecordFixture['sonuc'],
      );
    });
  }

  test(
    'eski bool feedback doğru çevrilir; yeni alanın null değeri önceliklidir',
    () {
      for (final bool? value in <bool?>[true, false, null]) {
        final DailyRecord r = DailyRecord.fromMap(<String, dynamic>{
          ...legacyDailyRecordFixture,
          'feedbackPozitif': value,
        });
        expect(
          r.feedbackMood,
          value == null
              ? null
              : value
              ? FeedbackMood.positive
              : FeedbackMood.difficult,
        );
        expect(r.feedbackPozitif, value);
      }
      expect(
        DailyRecord.fromMap(<String, dynamic>{
          ...legacyDailyRecordFixture,
          'feedbackPozitif': true,
          'feedbackMood': null,
        }).feedbackMood,
        isNull,
      );
    },
  );

  test('daily copyWith null temizler; etiket listesi dışarıdan değişmez', () {
    final List<String> tags = <String>['akis'];
    final DailyRecord r = DailyRecord.fromMap(legacyDailyRecordFixture)
        .copyWith(
          revealedAt: openedAt,
          feedbackMood: FeedbackMood.positive,
          feedbackEmoji: '🍀',
          feedbackTags: tags,
        );
    tags.add('bag');
    expect(r.feedbackTags, <String>['akis']);
    expect(() => r.feedbackTags.add('denge'), throwsUnsupportedError);
    expect(r.copyWith().toMap(), r.toMap());
    final DailyRecord cleared = r.copyWith(
      revealedAt: null,
      feedbackMood: null,
      feedbackEmoji: null,
      feedbackTags: <String>[],
    );
    expect(cleared.revealedAt, isNull);
    expect(cleared.feedbackMood, isNull);
    expect(cleared.feedbackPozitif, isNull);
    expect(cleared.feedbackEmoji, isNull);
    expect(cleared.feedbackTags, isEmpty);
    expect(r.copyWith(feedbackPozitif: null).feedbackMood, isNull);
  });

  test(
    'feedback güncellemesi diğer güne dokunmaz ve eski emojiyi temizler',
    () async {
      await legacyRecord();
      await history.feedbackKaydet(day, pozitif: true, emoji: '🍀');
      final DateTime other = DateTime(2026, 7, 7);
      await history.getirVeyaUret(
        motor: engine,
        kullanici: UserProfile.fromMap(legacyUserProfileFixture).seed,
        gun: other,
      );
      await history.feedbackDurumuKaydet(day, mood: FeedbackMood.neutral);
      expect(history.getir(day)!.feedbackEmoji, isNull);
      expect(history.getir(day)!.feedbackPozitif, isNull);
      expect(history.getir(other)!.feedbackMood, isNull);
      expect(records.length, 2);
    },
  );

  test('olmayan güne reveal veya yeni feedback kaydı oluşturulmaz', () {
    expect(
      () => history.revealKaydet(day, revealedAt: openedAt),
      throwsStateError,
    );
    expect(
      () => history.feedbackDurumuKaydet(day, mood: FeedbackMood.neutral),
      throwsStateError,
    );
    expect(records.isEmpty, isTrue);
  });

  test(
    'bozuk migration hatası kaydı silmez veya yeni kimlik üretmez',
    () async {
      for (final Map<String, dynamic> bad in <Map<String, dynamic>>[
        <String, dynamic>{...legacyUserProfileFixture, 'seedSurumu': 99},
        <String, dynamic>{...legacyUserProfileFixture, 'dogumTarihi': null},
        <String, dynamic>{
          ...legacyUserProfileFixture,
          'seedSurumu': 2,
          'rituelKimligi': '',
        },
      ]) {
        await profiles.put(StorageKeys.profilKaydi, bad);
        expect(users.profil, throwsFormatException);
        expect(profiles.get(StorageKeys.profilKaydi), bad);
      }
      final Map<String, dynamic> bad = <String, dynamic>{
        ...legacyDailyRecordFixture,
        'feedbackMood': 'unknown',
      };
      await records.put(gunAnahtari(day), bad);
      expect(() => history.getir(day), throwsFormatException);
      expect(
        () => history.revealKaydet(day, revealedAt: openedAt),
        throwsFormatException,
      );
      expect(records.get(gunAnahtari(day)), bad);
    },
  );

  test(
    'providerlar açık ekranları profil, reveal ve feedback yazımında yeniler',
    () async {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          userProfileBoxProvider.overrideWithValue(profiles),
          dailyRecordsBoxProvider.overrideWithValue(records),
          userProfileFactoryProvider.overrideWithValue(
            UserProfileFactory(kimlikUret: () => 'provider-id'),
          ),
          bugunProvider.overrideWithValue(day),
        ],
      );
      addTearDown(container.dispose);
      container.listen(aktifProfilProvider, (_, _) {});
      container.listen(tumKayitlarProvider, (_, _) {});
      container.listen(gunlukKayitProvider(day), (_, _) {});
      await container.pump();
      final UserRepository repository = container.read(userRepositoryProvider);
      await repository.profilOlustur(
        isim: 'Ada',
        factory: container.read(userProfileFactoryProvider),
      );
      await container.pump();
      expect(container.read(aktifProfilProvider).rituelKimligi, 'provider-id');
      await legacyRecord();
      await container.pump();
      expect(container.read(tumKayitlarProvider), hasLength(1));
      await history.revealKaydet(day, revealedAt: openedAt);
      await container.pump();
      expect(container.read(gunlukKayitProvider(day))!.revealedAt, openedAt);
      await history.feedbackDurumuKaydet(day, mood: FeedbackMood.neutral);
      await container.pump();
      expect(
        container.read(tumKayitlarProvider).single.feedbackMood,
        FeedbackMood.neutral,
      );
      await repository.kaydet(repository.profil()!.copyWith(dil: AppDil.en));
      await container.pump();
      expect(container.read(dilProvider), AppDil.en);
    },
  );
}
