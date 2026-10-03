import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  const LuckEngine motor = LuckEngine();
  const int kartSayisi = 24;
  final UserSeed turan = UserSeed.fromIsim(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
  );
  final UserSeed ayse = UserSeed.fromIsim(
    isim: 'Ayşe',
    dogumTarihi: DateTime(1994, 3, 14),
  );

  /// [gun]den başlayan [n] günlük çekilişler.
  List<KartCekilisi> cekilisler(UserSeed k, DateTime gun, int n) =>
      <KartCekilisi>[
        for (int i = 0; i < n; i++)
          motor.gununKarti(
            kullanici: k,
            gun: DateTime(gun.year, gun.month, gun.day + i),
            kartSayisi: kartSayisi,
          ),
      ];

  test('deterministik: aynı (kullanıcı, gün) aynı çekilişi verir', () {
    final DateTime gun = DateTime(2026, 7, 6);
    expect(
      motor.gununKarti(kullanici: turan, gun: gun, kartSayisi: kartSayisi),
      motor.gununKarti(kullanici: turan, gun: gun, kartSayisi: kartSayisi),
    );
  });

  test('günün saati çekilişi değiştirmez', () {
    expect(
      motor.gununKarti(
        kullanici: turan,
        gun: DateTime(2026, 7, 6, 7, 5),
        kartSayisi: kartSayisi,
      ),
      motor.gununKarti(
        kullanici: turan,
        gun: DateTime(2026, 7, 6, 23, 59),
        kartSayisi: kartSayisi,
      ),
    );
  });

  test('indeks her zaman katalog aralığında', () {
    for (final KartCekilisi c in cekilisler(turan, DateTime(2026), 400)) {
      expect(c.indeks, inInclusiveRange(0, kartSayisi - 1));
    }
  });

  test('bir döngüde (24 gün) her kart tam bir kez gelir', () {
    // Döngü sınırına hizalı ilk günü bul: gün numarası 24'ün katı.
    DateTime bas = DateTime(2026, 7, 1);
    while (LuckEngine.gunNumarasi(bas) % kartSayisi != 0) {
      bas = DateTime(bas.year, bas.month, bas.day + 1);
    }
    final Set<int> indeksler = <int>{
      for (final KartCekilisi c in cekilisler(turan, bas, kartSayisi))
        c.indeks,
    };
    expect(indeksler, hasLength(kartSayisi));
  });

  test('nadir çekiliş yaklaşık her 8 günde bir gelir', () {
    final List<KartCekilisi> yil = cekilisler(turan, DateTime(2026), 800);
    final double oran =
        yil.where((KartCekilisi c) => c.nadir).length / yil.length;
    expect(oran, inInclusiveRange(0.08, 0.18));
  });

  test('farklı kullanıcıların kart sırası farklıdır', () {
    final DateTime gun = DateTime(2026, 7, 6);
    expect(
      cekilisler(turan, gun, 10).map((KartCekilisi c) => c.indeks),
      isNot(orderedEquals(
        cekilisler(ayse, gun, 10).map((KartCekilisi c) => c.indeks),
      )),
    );
  });

  test('çekiliş günün skorunu değiştirmez (bağımsız tohum)', () {
    final DateTime gun = DateTime(2026, 7, 6);
    final LuckResult once = motor.hesapla(kullanici: turan, gun: gun);
    motor.gununKarti(kullanici: turan, gun: gun, kartSayisi: kartSayisi);
    final LuckResult sonra = motor.hesapla(kullanici: turan, gun: gun);
    expect(sonra.genelSkor, once.genelSkor);
    expect(sonra.kategoriSkorlari, once.kategoriSkorlari);
  });
}
