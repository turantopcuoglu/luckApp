import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  const LuckEngine motor = LuckEngine();
  final UserSeed turan = UserSeed.fromIsim(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
  );
  final DateTime gun = DateTime(2026, 7, 6);

  group('secimIndeksi', () {
    test('deterministik: aynı (kullanıcı, gün, amaç, boyut) aynı indeks', () {
      final int a = motor.secimIndeksi(
        kullanici: turan,
        gun: gun,
        amac: 'acilis',
        havuzBoyutu: 30,
      );
      final int b = motor.secimIndeksi(
        kullanici: turan,
        gun: gun,
        amac: 'acilis',
        havuzBoyutu: 30,
      );
      expect(a, b);
    });

    test('günün saati sonucu değiştirmez', () {
      final int sabah = motor.secimIndeksi(
        kullanici: turan,
        gun: DateTime(2026, 7, 6, 8, 15),
        amac: 'tavsiye',
        havuzBoyutu: 24,
      );
      final int gece = motor.secimIndeksi(
        kullanici: turan,
        gun: DateTime(2026, 7, 6, 23, 59),
        amac: 'tavsiye',
        havuzBoyutu: 24,
      );
      expect(sabah, gece);
    });

    test('365 gün boyunca indeks her zaman havuz sınırları içinde', () {
      const List<String> amaclar = <String>['acilis', 'orta', 'kapanis'];
      const List<int> boyutlar = <int>[1, 7, 12, 99];
      for (int i = 0; i < 365; i++) {
        for (final String amac in amaclar) {
          for (final int boyut in boyutlar) {
            final int indeks = motor.secimIndeksi(
              kullanici: turan,
              gun: gun.add(Duration(days: i)),
              amac: amac,
              havuzBoyutu: boyut,
            );
            expect(indeks, inInclusiveRange(0, boyut - 1));
          }
        }
      }
    });

    test('tek elemanlı havuz her zaman 0 döner', () {
      final int indeks = motor.secimIndeksi(
        kullanici: turan,
        gun: gun,
        amac: 'renk',
        havuzBoyutu: 1,
      );
      expect(indeks, 0);
    });

    test('boş havuz (boyut < 1) ArgumentError fırlatır', () {
      expect(
        () => motor.secimIndeksi(
          kullanici: turan,
          gun: gun,
          amac: 'acilis',
          havuzBoyutu: 0,
        ),
        throwsArgumentError,
      );
    });

    test('günler arası ıraksama: 30 günde tek düze değil', () {
      final Set<int> indeksler = <int>{
        for (int i = 0; i < 30; i++)
          motor.secimIndeksi(
            kullanici: turan,
            gun: gun.add(Duration(days: i)),
            amac: 'acilis',
            havuzBoyutu: 30,
          ),
      };
      expect(indeksler.length, greaterThan(1));
    });

    test('amaçlar arası ayrışma: 30 günde en az bir gün farklı seçim', () {
      bool ayristi = false;
      for (int i = 0; i < 30 && !ayristi; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final int a = motor.secimIndeksi(
          kullanici: turan,
          gun: g,
          amac: 'acilis',
          havuzBoyutu: 30,
        );
        final int b = motor.secimIndeksi(
          kullanici: turan,
          gun: g,
          amac: 'kapanis',
          havuzBoyutu: 30,
        );
        ayristi = a != b;
      }
      expect(ayristi, isTrue);
    });

    test('kullanıcılar arası ayrışma: 30 günde en az bir gün farklı', () {
      final UserSeed ayse = UserSeed.fromIsim(
        isim: 'Ayşe',
        dogumTarihi: DateTime(1995, 3, 20),
      );
      bool ayristi = false;
      for (int i = 0; i < 30 && !ayristi; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final int a = motor.secimIndeksi(
          kullanici: turan,
          gun: g,
          amac: 'orta',
          havuzBoyutu: 30,
        );
        final int b = motor.secimIndeksi(
          kullanici: ayse,
          gun: g,
          amac: 'orta',
          havuzBoyutu: 30,
        );
        ayristi = a != b;
      }
      expect(ayristi, isTrue);
    });

    test('secimIndeksi skor tohumundan bağımsızdır (skoru değiştirmez)', () {
      final LuckResult once = motor.hesapla(kullanici: turan, gun: gun);
      motor.secimIndeksi(
        kullanici: turan,
        gun: gun,
        amac: 'acilis',
        havuzBoyutu: 30,
      );
      final LuckResult sonra = motor.hesapla(kullanici: turan, gun: gun);
      expect(once.kategoriSkorlari, sonra.kategoriSkorlari);
      expect(once.genelSkor, sonra.genelSkor);
    });
  });
}
