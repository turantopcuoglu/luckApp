import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  const LuckEngine motor = LuckEngine();
  final UserSeed turan = UserSeed.fromIsim(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
  );
  final DateTime gun = DateTime(2026, 7, 6);

  group('sansliSaat', () {
    test('deterministik: aynı (kullanıcı, gün, kategori) aynı aralık', () {
      final SansliSaat a = motor.sansliSaat(
        kullanici: turan,
        gun: gun,
        kategori: LuckCategory.ask,
      );
      final SansliSaat b = motor.sansliSaat(
        kullanici: turan,
        gun: gun,
        kategori: LuckCategory.ask,
      );
      expect(a, b);
    });

    test('günün saati sonucu değiştirmez', () {
      final SansliSaat sabah = motor.sansliSaat(
        kullanici: turan,
        gun: DateTime(2026, 7, 6, 8, 15),
        kategori: LuckCategory.para,
      );
      final SansliSaat gece = motor.sansliSaat(
        kullanici: turan,
        gun: DateTime(2026, 7, 6, 23, 59),
        kategori: LuckCategory.para,
      );
      expect(sabah, gece);
    });

    test('365 günde aralık her zaman sınırlar içinde ve 2 saat', () {
      for (int i = 0; i < 365; i++) {
        for (final LuckCategory kategori in LuckCategory.values) {
          final SansliSaat saat = motor.sansliSaat(
            kullanici: turan,
            gun: gun.add(Duration(days: i)),
            kategori: kategori,
          );
          expect(
            saat.baslangicSaati,
            inInclusiveRange(
              EngineConfig.sansliSaatEnErken,
              EngineConfig.sansliSaatEnGecBaslangic,
            ),
          );
          expect(
            saat.bitisSaati,
            saat.baslangicSaati + EngineConfig.sansliSaatSuresi,
          );
        }
      }
    });

    test('kategoriler arası ayrışma: 30 günde tek düze değil', () {
      // Aynı günde tüm kategoriler aynı saati vermemeli (30 günde en
      // az bir gün ayrışma beklenir; deterministik girdiyle sabittir).
      bool ayristi = false;
      for (int i = 0; i < 30 && !ayristi; i++) {
        final Set<int> baslangiclar = <int>{
          for (final LuckCategory k in LuckCategory.values)
            motor
                .sansliSaat(
                  kullanici: turan,
                  gun: gun.add(Duration(days: i)),
                  kategori: k,
                )
                .baslangicSaati,
        };
        ayristi = baslangiclar.length > 1;
      }
      expect(ayristi, isTrue);
    });

    test('şanslı saat, skor tohumundan bağımsızdır (skoru değiştirmez)', () {
      final LuckResult once = motor.hesapla(kullanici: turan, gun: gun);
      motor.sansliSaat(kullanici: turan, gun: gun, kategori: LuckCategory.risk);
      final LuckResult sonra = motor.hesapla(kullanici: turan, gun: gun);
      expect(once.kategoriSkorlari, sonra.kategoriSkorlari);
    });

    test('etiket biçimi "HH:00 - HH:00"', () {
      const SansliSaat saat = SansliSaat(baslangicSaati: 9, bitisSaati: 11);
      expect(saat.etiket, '09:00 - 11:00');
    });
  });
}
