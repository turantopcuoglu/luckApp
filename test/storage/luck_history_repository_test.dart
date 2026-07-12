import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/storage_keys.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> kutu;
  late LuckHistoryRepository repo;

  const LuckEngine motor = LuckEngine();
  final UserSeed turan = UserSeed.fromIsim(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
  );
  final DateTime bugun = DateTime(2026, 7, 6);

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('history_repo_test');
    Hive.init(geciciDizin.path);
    kutu = await Hive.openBox<Map<dynamic, dynamic>>(
      StorageKeys.dailyRecordsBox,
    );
    repo = LuckHistoryRepository(kutu);
  });

  tearDown(() async {
    await kutu.deleteFromDisk();
    await geciciDizin.delete(recursive: true);
  });

  group('kayıt/okuma', () {
    test('kayıt yokken kayitVarMi false, getir null döner', () {
      expect(repo.kayitVarMi(bugun), isFalse);
      expect(repo.getir(bugun), isNull);
    });

    test('LuckResult tüm alanlarıyla kayıp yaşamadan gidip gelir', () async {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: bugun);
      await repo.kaydet(DailyRecord(sonuc: sonuc));

      final DailyRecord okunan = repo.getir(bugun)!;
      expect(okunan.sonuc.gun, sonuc.gun);
      expect(okunan.sonuc.genelSkor, sonuc.genelSkor);
      expect(okunan.sonuc.kategoriSkorlari, sonuc.kategoriSkorlari);
      expect(okunan.sonuc.modifiyerler, sonuc.modifiyerler);
      expect(okunan.feedbackPozitif, isNull);
      expect(okunan.feedbackEmoji, isNull);
    });

    test('gün anahtarı saatten bağımsızdır', () async {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: bugun);
      await repo.kaydet(DailyRecord(sonuc: sonuc));
      expect(repo.kayitVarMi(DateTime(2026, 7, 6, 23, 45)), isTrue);
    });
  });

  group('getirVeyaUret (plan madde 3)', () {
    test('ilk çağrı üretir ve kaydeder', () async {
      expect(repo.kayitVarMi(bugun), isFalse);

      final LuckResult sonuc = await repo.getirVeyaUret(
        motor: motor,
        kullanici: turan,
        gun: bugun,
      );

      expect(repo.kayitVarMi(bugun), isTrue);
      expect(repo.getir(bugun)!.sonuc.genelSkor, sonuc.genelSkor);
    });

    test('ikinci açılışta motor çalıştırılmaz, kayıttan okunur', () async {
      // Kutuya motorun üreteceğinden kasıtlı olarak farklı bir kayıt
      // koyuyoruz: getirVeyaUret bunu döndürüyorsa depodan okumuştur.
      final LuckResult gercek = motor.hesapla(kullanici: turan, gun: bugun);
      final LuckResult sahte = LuckResult(
        gun: bugun,
        genelSkor: gercek.genelSkor == 1 ? 2 : 1,
        kategoriSkorlari: gercek.kategoriSkorlari,
        modifiyerler: gercek.modifiyerler,
      );
      await repo.kaydet(DailyRecord(sonuc: sahte));

      final LuckResult okunan = await repo.getirVeyaUret(
        motor: motor,
        kullanici: turan,
        gun: bugun,
      );
      expect(okunan.genelSkor, sahte.genelSkor);
      expect(okunan.genelSkor, isNot(gercek.genelSkor));
    });

    test('düşük geçmişte üretime seri dengesi bias\'ı yansır', () async {
      // Önceki 3 güne düşük skorlu kayıtlar koy (ortalama < 45).
      for (int i = 1; i <= LuckHistoryRepository.biasGunSayisi; i++) {
        final DateTime gun = DateTime(2026, 7, 6 - i);
        final LuckResult temel = motor.hesapla(kullanici: turan, gun: gun);
        await repo.kaydet(
          DailyRecord(
            sonuc: LuckResult(
              gun: gun,
              genelSkor: 30,
              kategoriSkorlari: temel.kategoriSkorlari,
              modifiyerler: temel.modifiyerler,
            ),
          ),
        );
      }

      final LuckResult sonuc = await repo.getirVeyaUret(
        motor: motor,
        kullanici: turan,
        gun: bugun,
      );
      expect(
        sonuc.modifiyerler.any((LuckModifier m) => m.ad == seriDengesiAdi),
        isTrue,
      );
    });
  });

  group('sonUcGunSkorlari (plan madde 4)', () {
    test('kayıt yoksa boş liste döner', () {
      expect(repo.sonUcGunSkorlari(bugun), isEmpty);
    });

    test('yalnızca mevcut günlerin skorlarını toplar', () async {
      // Sadece dün ve 3 gün öncesine kayıt koy; 2 gün öncesi boş.
      for (final int gunFarki in <int>[1, 3]) {
        final DateTime gun = DateTime(2026, 7, 6 - gunFarki);
        final LuckResult temel = motor.hesapla(kullanici: turan, gun: gun);
        await repo.kaydet(
          DailyRecord(
            sonuc: LuckResult(
              gun: gun,
              genelSkor: 50 + gunFarki,
              kategoriSkorlari: temel.kategoriSkorlari,
              modifiyerler: temel.modifiyerler,
            ),
          ),
        );
      }

      expect(repo.sonUcGunSkorlari(bugun), <int>[51, 53]);
    });

    test('bugünün kaydı geçmişe dahil edilmez', () async {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: bugun);
      await repo.kaydet(DailyRecord(sonuc: sonuc));
      expect(repo.sonUcGunSkorlari(bugun), isEmpty);
    });

    test('ay başında önceki aya doğru taşar', () async {
      // 1 Temmuz'dan geriye bakınca 28-30 Haziran taranmalı.
      final DateTime ayBasi = DateTime(2026, 7, 1);
      final DateTime haziranSonu = DateTime(2026, 6, 30);
      final LuckResult temel = motor.hesapla(
        kullanici: turan,
        gun: haziranSonu,
      );
      await repo.kaydet(
        DailyRecord(
          sonuc: LuckResult(
            gun: haziranSonu,
            genelSkor: 42,
            kategoriSkorlari: temel.kategoriSkorlari,
            modifiyerler: temel.modifiyerler,
          ),
        ),
      );

      expect(repo.sonUcGunSkorlari(ayBasi), <int>[42]);
    });
  });

  group('tumKayitlar (Phase 2)', () {
    test('kayıt yoksa boş liste döner', () {
      expect(repo.tumKayitlar(), isEmpty);
    });

    test(
      'kayıtları güne göre artan sırada döndürür (ekleme sırası fark etmez)',
      () async {
        // Kasıtlı sırasız ekle: 6, 3, 8 Temmuz.
        for (final int gunNo in <int>[6, 3, 8]) {
          final DateTime gun = DateTime(2026, 7, gunNo);
          final LuckResult temel = motor.hesapla(kullanici: turan, gun: gun);
          await repo.kaydet(
            DailyRecord(
              sonuc: LuckResult(
                gun: gun,
                genelSkor: gunNo,
                kategoriSkorlari: temel.kategoriSkorlari,
                modifiyerler: temel.modifiyerler,
              ),
            ),
          );
        }

        final List<DailyRecord> hepsi = repo.tumKayitlar();
        expect(hepsi.map((DailyRecord k) => k.gun.day), <int>[3, 6, 8]);
      },
    );

    test('feedback alanları round-trip korunur', () async {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: bugun);
      await repo.kaydet(DailyRecord(sonuc: sonuc));
      await repo.feedbackKaydet(bugun, pozitif: true, emoji: '🍀');

      final DailyRecord tek = repo.tumKayitlar().single;
      expect(tek.feedbackPozitif, isTrue);
      expect(tek.feedbackEmoji, '🍀');
    });
  });

  group('feedbackKaydet', () {
    test('mevcut kayda feedback işler ve sonucu korur', () async {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: bugun);
      await repo.kaydet(DailyRecord(sonuc: sonuc));

      await repo.feedbackKaydet(bugun, pozitif: true, emoji: '🍀');

      final DailyRecord okunan = repo.getir(bugun)!;
      expect(okunan.feedbackPozitif, isTrue);
      expect(okunan.feedbackEmoji, '🍀');
      expect(okunan.sonuc.genelSkor, sonuc.genelSkor);
    });

    test('kayıt yokken StateError fırlatır', () {
      expect(
        () => repo.feedbackKaydet(bugun, pozitif: false),
        throwsStateError,
      );
    });
  });
}
