import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/kayitli_kisi.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_repository.dart';
import 'package:kader/core/storage/uygulama_durumu.dart';

void main() {
  late Directory dizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;
  late Box<Map<dynamic, dynamic>> durumKutusu;
  late Box<Map<dynamic, dynamic>> kisiKutusu;

  setUp(() async {
    dizin = await Directory.systemTemp.createTemp('storage_v2_test');
    Hive.init(dizin.path);
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>('p');
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>('k');
    durumKutusu = await Hive.openBox<Map<dynamic, dynamic>>('d');
    kisiKutusu = await Hive.openBox<Map<dynamic, dynamic>>('s');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dizin.delete(recursive: true);
  });

  group('UserProfile v2', () {
    test('eski kayıt (yalnız isim+tarih) varsayılanlarla okunur', () {
      final UserProfile p = UserProfile.fromMap(<String, dynamic>{
        'isim': 'Turan',
        'dogumTarihi': DateTime(1990, 5, 15).toIso8601String(),
        'onboardingTamam': true,
      });
      expect(p.tamAd, isNull);
      expect(p.dogumSaatiDakika, isNull);
      expect(p.dogumIliPlaka, isNull);
      expect(p.uyariKabulSurumu, isNull);
      expect(p.onboardingTamam, isTrue);
    });

    test('tüm yeni alanlar gidip gelir', () async {
      final UserRepository repo = UserRepository(profilKutusu);
      await repo.kaydet(
        UserProfile(
          isim: 'Ayşe',
          dogumTarihi: DateTime(1994, 3, 14),
          tamAd: 'Ayşe Yılmaz',
          uyariKabulSurumu: 1,
          dogumSaatiDakika: 14 * Duration.minutesPerHour + 30,
          dogumIliPlaka: 35,
        ),
      );
      final UserProfile okunan = repo.profil()!;
      expect(okunan.tamAd, 'Ayşe Yılmaz');
      expect(okunan.uyariKabulSurumu, 1);
      expect(okunan.dogumSaatiDakika, 14 * Duration.minutesPerHour + 30);
      expect(okunan.dogumIliPlaka, 35);
    });

    test('eski kayıttaki tercih cevapları yok sayılır: okuma yalnızca doğum '
        'verisine dayanır', () {
      final UserProfile p = UserProfile.fromMap(<String, dynamic>{
        'isim': 'Ayşe',
        'dogumTarihi': DateTime(1994, 3, 14).toIso8601String(),
        'onboardingTamam': true,
        // Eski sürümün sakladığı tanışma cevapları.
        'enerji': 'iceDonuk',
        'karar': 'kalp',
        'iliski': 'evli',
        'ugras': 'girisimci',
      });
      // Portre yalnız burç elementinden gelir (Balık: su → içe dönük,
      // kalp); kayıttaki cevaplar okunmaz.
      expect(
        p.okuyucu.portre,
        const Portre(enerji: EnerjiTarzi.iceDonuk, karar: KararTarzi.kalp),
      );
      expect(p.toMap().keys, isNot(contains('ugras')));
    });

    test('eski tanışma cevapları kayıttan bir kez silinir, diğer alanlar '
        'kalır', () async {
      final UserRepository repo = UserRepository(profilKutusu);
      await profilKutusu.put(StorageKeys.profilKaydi, <String, dynamic>{
        'isim': 'Ayşe',
        'dogumTarihi': DateTime(1994, 3, 14).toIso8601String(),
        'onboardingTamam': true,
        'tamAd': 'Ayşe Yılmaz',
        'enerji': 'iceDonuk',
        'karar': 'kalp',
        'iliski': 'evli',
        'ugras': 'girisimci',
      });
      expect(await repo.eskiTanismaCevaplariniSil(), isTrue);
      final Map<dynamic, dynamic> kayit = profilKutusu.get(
        StorageKeys.profilKaydi,
      )!;
      for (final String a in StorageKeys.eskiTanismaCevaplari) {
        expect(kayit.containsKey(a), isFalse, reason: a);
      }
      expect(kayit['tamAd'], 'Ayşe Yılmaz');
      expect(repo.profil()!.onboardingTamam, isTrue);
      // İkinci çağrı yazma yapmaz.
      expect(await repo.eskiTanismaCevaplariniSil(), isFalse);
    });

    test('profil yoksa ya da eski cevap yoksa silme yazmaz', () async {
      final UserRepository repo = UserRepository(profilKutusu);
      expect(await repo.eskiTanismaCevaplariniSil(), isFalse);
      expect(profilKutusu.isEmpty, isTrue);
      await repo.kaydet(
        UserProfile(isim: 'Ayşe', dogumTarihi: DateTime(1994, 3, 14)),
      );
      expect(await repo.eskiTanismaCevaplariniSil(), isFalse);
    });

    test('okuyucu profili tam adla hesaplar; seed isimden değişmez', () {
      final UserProfile p = UserProfile(
        isim: 'Ayşe',
        dogumTarihi: DateTime(1994, 3, 14),
        tamAd: 'Ayşe',
      );
      expect(p.okuyucu.profil.isimSayisi!.deger, 5);
      expect(
        p.copyWith(tamAd: 'Başka Ad').seed.isimHash,
        p.seed.isimHash,
      );
      expect(p.copyWith(tamAdiTemizle: true).tamAd, isNull);
    });

    test('uyariKabulEt profile sürümü işler, profil yoksa hata', () async {
      final UserRepository repo = UserRepository(profilKutusu);
      expect(() => repo.uyariKabulEt(1), throwsStateError);
      await repo.kaydet(
        UserProfile(isim: 'A', dogumTarihi: DateTime(2000)),
      );
      await repo.uyariKabulEt(2);
      expect(repo.profil()!.uyariKabulSurumu, 2);
    });
  });

  group('LuckHistoryRepository v2', () {
    const LuckEngine motor = LuckEngine();
    final UserSeed seed =
        UserSeed.fromIsim(isim: 'Ayşe', dogumTarihi: DateTime(1994, 3, 14));

    Future<LuckHistoryRepository> hazirla(List<DateTime> gunler) async {
      final LuckHistoryRepository repo = LuckHistoryRepository(kayitKutusu);
      for (final DateTime g in gunler) {
        await repo.getirVeyaUret(motor: motor, kullanici: seed, gun: g);
      }
      return repo;
    }

    test('eski kayıt yeni alanlar olmadan okunur', () async {
      final LuckHistoryRepository repo =
          await hazirla(<DateTime>[DateTime(2026, 9, 1)]);
      final Map<dynamic, dynamic> ham =
          Map<dynamic, dynamic>.of(kayitKutusu.values.first)
            ..remove('bolumGeriBildirimleri')
            ..remove('reklamKilitleri');
      final DailyRecord kayit = DailyRecord.fromMap(ham);
      expect(kayit.bolumGeriBildirimleri, isEmpty);
      expect(kayit.reklamKilitleri, isEmpty);
      expect(repo.kayitliGunSayisi, 1);
    });

    test('bölüm geri bildirimi yazılır; en son cevap geçerlidir', () async {
      final DateTime g1 = DateTime(2026, 9, 1);
      final DateTime g2 = DateTime(2026, 9, 2);
      final DateTime g3 = DateTime(2026, 9, 3);
      final LuckHistoryRepository repo = await hazirla(<DateTime>[g1, g2, g3]);

      await repo.bolumGeriBildirimiKaydet(g1, bolumKimligi: 'enerji:a', anlatti: false);
      await repo.bolumGeriBildirimiKaydet(g1, bolumKimligi: 'dikkat:b', anlatti: false);
      await repo.bolumGeriBildirimiKaydet(g2, bolumKimligi: 'dikkat:b', anlatti: true);
      await repo.bolumGeriBildirimiKaydet(g3, bolumKimligi: 'parlayan:c', anlatti: false);

      // g3 için yalnızca önceki günler sayılır; b sonradan "anlattı" oldu.
      expect(repo.begenilmeyenKimlikler(once: g3), <String>{'enerji:a'});
      // g2 için b hâlâ beğenilmemiş (g2'nin kendi cevabı dahil değil).
      expect(
        repo.begenilmeyenKimlikler(once: g2),
        <String>{'enerji:a', 'dikkat:b'},
      );
      expect(repo.begenilmeyenKimlikler(once: g1), isEmpty);
    });

    test('kayıt yokken bölüm geri bildirimi ve kilit hata verir', () {
      final LuckHistoryRepository repo = LuckHistoryRepository(kayitKutusu);
      expect(
        () => repo.bolumGeriBildirimiKaydet(
          DateTime(2026),
          bolumKimligi: 'x',
          anlatti: true,
        ),
        throwsStateError,
      );
      expect(() => repo.reklamKilidiAc(DateTime(2026), 'x'), throwsStateError);
    });

    test('reklam kilidi yalnızca o gün için açıktır', () async {
      final DateTime g1 = DateTime(2026, 9, 1);
      final DateTime g2 = DateTime(2026, 9, 2);
      final LuckHistoryRepository repo = await hazirla(<DateTime>[g1, g2]);
      await repo.reklamKilidiAc(g1, 'kategori:ask');
      expect(repo.reklamKilidiAcikMi(g1, 'kategori:ask'), isTrue);
      expect(repo.reklamKilidiAcikMi(g2, 'kategori:ask'), isFalse);
      expect(repo.reklamKilidiAcikMi(g1, 'kategori:para'), isFalse);
      // Sonuç ve akşam geri bildirimi korunur.
      await repo.feedbackKaydet(g1, pozitif: true);
      expect(repo.getir(g1)!.reklamKilitleri, contains('kategori:ask'));
    });
  });

  group('UygulamaDurumuRepository', () {
    test('varsayılan durum, ilk açılış bir kez yazılır', () async {
      final UygulamaDurumuRepository repo = UygulamaDurumuRepository(durumKutusu);
      expect(repo.durum.premiumAktif, isFalse);
      await repo.ilkAcilisiIsaretle(DateTime(2026, 9, 1));
      await repo.ilkAcilisiIsaretle(DateTime(2026, 9, 5));
      expect(repo.durum.ilkAcilis, DateTime(2026, 9, 1));
    });

    test('premium önbelleği; aktif değilken ürün temizlenir', () async {
      final UygulamaDurumuRepository repo = UygulamaDurumuRepository(durumKutusu);
      await repo.premiumuKaydet(
        aktif: true,
        dogrulama: DateTime(2026, 9, 1),
        urunId: 'kader_premium_yillik',
      );
      expect(repo.durum.premiumUrunId, 'kader_premium_yillik');
      await repo.gecisReklamiGosterildi(DateTime(2026, 9, 2));
      await repo.premiumuKaydet(aktif: false, dogrulama: DateTime(2026, 9, 3));
      expect(repo.durum.premiumAktif, isFalse);
      expect(repo.durum.premiumUrunId, isNull);
      expect(repo.durum.sonGecisReklami, DateTime(2026, 9, 2));
    });
  });

  group('KisiRepository', () {
    test('ekle, sırala, sil', () async {
      final KisiRepository repo = KisiRepository(kisiKutusu);
      final KayitliKisi mert = KayitliKisi(
        id: KisiRepository.yeniKimlik(DateTime(2026, 9, 1)),
        ad: 'Mert Kaya',
        dogumTarihi: DateTime(1991, 7, 30),
        rol: KisiRolu.partner,
      );
      final KayitliKisi zeynep = KayitliKisi(
        id: KisiRepository.yeniKimlik(DateTime(2026, 9, 2)),
        ad: 'Zeynep',
        dogumTarihi: DateTime(1995, 1, 2),
        rol: KisiRolu.arkadas,
      );
      await repo.kaydet(zeynep);
      await repo.kaydet(mert);
      expect(repo.tumu().map((KayitliKisi k) => k.kisaAd), <String>['Mert', 'Zeynep']);
      expect(repo.tumu().first.profil.burc, Burc.aslan);
      await repo.sil(mert.id);
      expect(repo.sayi, 1);
    });
  });
}
