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
}
