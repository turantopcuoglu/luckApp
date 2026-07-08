import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_repository.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> kutu;
  late UserRepository repo;

  setUp(() async {
    // Gerçek Hive, geçici dizinde: mock'a gerek kalmadan tam davranış.
    geciciDizin = await Directory.systemTemp.createTemp('user_repo_test');
    Hive.init(geciciDizin.path);
    kutu = await Hive.openBox<Map<dynamic, dynamic>>(
      StorageKeys.userProfileBox,
    );
    repo = UserRepository(kutu);
  });

  tearDown(() async {
    await kutu.deleteFromDisk();
    await geciciDizin.delete(recursive: true);
  });

  final UserProfile turan = UserProfile(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
  );

  test('boş kutuda profil null ve onboarding tamamlanmamış', () {
    expect(repo.profil(), isNull);
    expect(repo.onboardingTamamlandiMi, isFalse);
  });

  test('kaydedilen profil aynı alanlarla geri okunur', () async {
    await repo.kaydet(turan);

    final UserProfile? okunan = repo.profil();
    expect(okunan, isNotNull);
    expect(okunan!.isim, 'Turan');
    expect(okunan.dogumTarihi, DateTime(1990, 5, 15));
    expect(okunan.onboardingTamam, isFalse);
  });

  test('onboardingTamamla profili işaretler', () async {
    await repo.kaydet(turan);
    await repo.onboardingTamamla();

    expect(repo.onboardingTamamlandiMi, isTrue);
    // Diğer alanlar korunur.
    expect(repo.profil()!.isim, 'Turan');
  });

  test('profil yokken onboardingTamamla StateError fırlatır', () {
    expect(repo.onboardingTamamla, throwsStateError);
  });

  test('profil seed üretebilir ve isim normalizasyonu uygulanır', () async {
    await repo.kaydet(turan);
    final UserProfile okunan = repo.profil()!;
    // "Turan" ile " turan " aynı deterministik kullanıcıdır.
    final UserProfile bosluklu = UserProfile(
      isim: ' turan ',
      dogumTarihi: DateTime(1990, 5, 15),
    );
    expect(okunan.seed.isimHash, bosluklu.seed.isimHash);
  });

  group('bildirim tercihleri (Phase 1)', () {
    test('yeni profil varsayılan olarak bildirimleri açık tutar', () {
      expect(turan.bildirimlerAcik, isTrue);
      expect(turan.aksamBildirimDakika, isNull);
      expect(turan.sabahBildirimDakika, isNull);
    });

    test('eski map (bildirim anahtarsız) geriye uyumlu okunur', () {
      // Yeni alanlar eklenmeden önce yazılmış bir kaydı taklit eder.
      final Map<String, dynamic> eskiMap = <String, dynamic>{
        'isim': 'Turan',
        'dogumTarihi': DateTime(1990, 5, 15).toIso8601String(),
        'onboardingTamam': true,
      };

      final UserProfile okunan = UserProfile.fromMap(eskiMap);
      expect(okunan.bildirimlerAcik, isTrue);
      expect(okunan.aksamBildirimDakika, isNull);
      expect(okunan.sabahBildirimDakika, isNull);
    });

    test('toMap→fromMap round-trip bildirim alanlarını korur', () {
      final UserProfile kapali = turan.copyWith(
        bildirimlerAcik: false,
        aksamBildirimDakika: 1290,
        sabahBildirimDakika: 480,
      );

      final UserProfile okunan = UserProfile.fromMap(kapali.toMap());
      expect(okunan.bildirimlerAcik, isFalse);
      expect(okunan.aksamBildirimDakika, 1290);
      expect(okunan.sabahBildirimDakika, 480);
    });

    test('copyWith(isim:) diğer alanlara dokunmaz', () {
      final UserProfile once = turan.copyWith(
        bildirimlerAcik: false,
        aksamBildirimDakika: 1200,
      );
      final UserProfile sonra = once.copyWith(isim: 'Elif');

      expect(sonra.isim, 'Elif');
      expect(sonra.dogumTarihi, once.dogumTarihi);
      expect(sonra.bildirimlerAcik, isFalse);
      expect(sonra.aksamBildirimDakika, 1200);
    });

    test('bildirim alanları seed\'i DEĞİŞTİRMEZ (determinizm koruması)', () {
      final UserProfile degisik = turan.copyWith(
        bildirimlerAcik: false,
        aksamBildirimDakika: 60,
        sabahBildirimDakika: 900,
      );

      // Kural 8: aynı (isim, doğum tarihi) → aynı tohum.
      expect(degisik.seed.isimHash, turan.seed.isimHash);
      expect(degisik.seed.dogumTarihi, turan.seed.dogumTarihi);
    });
  });
}
