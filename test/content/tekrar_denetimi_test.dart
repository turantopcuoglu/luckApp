import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/gunluk_okuma.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

/// Tekrar denetimi: günlük okumanın bir ay boyunca okura ezber gibi
/// gelmemesi için ölçülebilir sınırlar.
///
/// Referans (v3, bu denetim yazılmadan önce): 30 günde ~340 cümlenin
/// yalnızca %41'i benzersizdi, tek bir cümle 19 kez tekrar ediyordu ve
/// okumaların hemen her cümlesi "Bugün" ile başlıyordu.
void main() {
  const LuckEngine motor = LuckEngine();

  /// Tüm yaşam yolu sayıları (1-9 ve usta sayılar).
  const List<int> yasamYollari = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33];

  /// Doğum haritası durumları: yok; yalnız Ay; Ay ve yükselen (K7'den
  /// beri tanışma cevabı yok).
  const int haritaDurumu = 3;

  /// Ölçüm pencerelerinin başlangıç günleri (farklı ay ve yıllar).
  final List<DateTime> pencereler = <DateTime>[
    DateTime(2026, 10, 1),
    DateTime(2027, 2, 14),
    DateTime(2027, 7, 20),
  ];

  /// [yasamYolu] sayısını veren ilk doğum tarihini bulur.
  DateTime dogumBul(int yasamYolu) {
    DateTime d = DateTime(1970, 1, 1);
    while (Numeroloji.yasamYolu(d).deger != yasamYolu) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  /// Her yaşam yolu için, harita durumları dönüşümlü bir okuyucu.
  final List<Okuyucu> okuyucular = <Okuyucu>[
    for (int i = 0; i < yasamYollari.length; i++)
      () {
        final DateTime d = dogumBul(yasamYollari[i]);
        final String isim = 'Deneme$i';
        return Okuyucu(
          isim: isim,
          seed: UserSeed.fromIsim(isim: isim, dogumTarihi: d),
          profil: KaderProfili.hesapla(dogumTarihi: d, tamAd: '$isim Yılmaz'),
          dogumAyi: i % haritaDurumu >= 1
              ? Burc.values[(i * 5) % Burc.values.length]
              : null,
          yukselen: i % haritaDurumu >= 2
              ? Burc.values[(i * 7 + 3) % Burc.values.length]
              : null,
        );
      }(),
  ];

  /// Metni cümlelere böler.
  List<String> cumleler(String metin) => metin
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((String c) => c.trim())
      .where((String c) => c.isNotEmpty)
      .toList();

  /// [o] için [baslangic]tan itibaren denetim penceresindeki okumalar.
  List<GunlukOkuma> okumalar(Okuyucu o, DateTime baslangic) => <GunlukOkuma>[
    for (int g = 0; g < ContentConfig.denetimGunSayisi; g++)
      gunlukOkuma(
        motor: motor,
        okuyucu: o,
        sonuc: motor.hesapla(
          kullanici: o.seed,
          gun: DateTime(baslangic.year, baslangic.month, baslangic.day + g),
        ),
      ),
  ];

  /// Bilinen aşımlar: "okuyucu, pencere: cümle" → izin verilen en çok
  /// tekrar. Bu kayıt K7'den önce de üretimdeydi; eski test okuyucusu
  /// tanışma cevaplarıyla bu cümleyi gizliyordu. Düzeltmek okumayı
  /// değiştirir ve içerik onayı bekler (reports/k7_kanit/README.md).
  /// Yeni bir aşım buraya eklenmez, düzeltilir.
  const Map<String, int> bilinenAsimlar = <String, int>{
    'yaşam yolu 9, 2026-10-01T00:00:00.000: Oğlak burcu olarak ilk '
            'izlenimde mesafeli görünebilirsin; seni tanıyanlar ise '
            'sıcaklığını bilir.':
        7,
  };

  test('bir ayda aynı cümle sınırlı sayıda tekrar eder ve cümlelerin '
      'çoğu benzersizdir', () {
    final List<String> asimlar = <String>[];
    for (final Okuyucu o in okuyucular) {
      for (final DateTime p in pencereler) {
        final Map<String, int> sayac = <String, int>{};
        int toplam = 0;
        for (final GunlukOkuma okuma in okumalar(o, p)) {
          for (final String c in cumleler(okuma.tamMetin)) {
            sayac[c] = (sayac[c] ?? 0) + 1;
            toplam++;
          }
        }
        final MapEntry<String, int> enSik = sayac.entries.reduce(
          (MapEntry<String, int> a, MapEntry<String, int> b) =>
              b.value > a.value ? b : a,
        );
        final String kim =
            'yaşam yolu ${o.profil.yasamYolu.deger}, ${p.toIso8601String()}';
        final int sinir =
            bilinenAsimlar['$kim: ${enSik.key}'] ??
            ContentConfig.denetimEnFazlaAyniCumle;
        if (enSik.value > sinir) {
          asimlar.add('$kim: ${enSik.value} kez "${enSik.key}"');
        }
        // Tam sayı aritmetiği: benzersiz × 100 ≥ eşik × toplam.
        expect(
          sayac.length * 100,
          greaterThanOrEqualTo(
            ContentConfig.denetimEnAzBenzersizYuzde * toplam,
          ),
          reason: '$kim: ${sayac.length}/$toplam benzersiz',
        );
      }
    }
    expect(asimlar, isEmpty);
  });

  test('yalnızca açılış cümlesi "Bugün" diye başlar ve kalıp ifadeler '
      'sınırlıdır', () {
    for (final Okuyucu o in okuyucular) {
      for (final DateTime p in pencereler) {
        for (final GunlukOkuma okuma in okumalar(o, p)) {
          final List<String> c = cumleler(okuma.tamMetin);
          final int bugunBasi = c
              .where((String s) => s.startsWith('Bugün'))
              .length;
          expect(
            bugunBasi,
            lessThanOrEqualTo(ContentConfig.denetimEnFazlaBugunBasi),
            reason: okuma.kartMetni,
          );
          final String kucuk = okuma.tamMetin.toLowerCase();
          final int kalip = ContentConfig.kalipIfadeler
              .map((String k) => k.allMatches(kucuk).length)
              .fold(0, (int a, int b) => a + b);
          expect(
            kalip,
            lessThanOrEqualTo(ContentConfig.denetimEnFazlaKalip),
            reason: okuma.kartMetni,
          );
        }
      }
    }
  });

  test('ardışık iki günün okuması ortak cümle paylaşmaz (kapanış hariç '
      'çoğunlukla)', () {
    // Döngüsel seçim, döngü sınırında aynı varyantı art arda verebilir;
    // bu yüzden ölçüt "hiç" değil, gün çiftlerinin büyük çoğunluğudur.
    for (final Okuyucu o in okuyucular) {
      final List<GunlukOkuma> liste = okumalar(o, pencereler.first);
      int ortaksizCift = 0;
      for (int i = 1; i < liste.length; i++) {
        final Set<String> dun = cumleler(liste[i - 1].tamMetin).toSet()
          ..remove(liste[i - 1].kapanis);
        final Set<String> bugun = cumleler(liste[i].tamMetin).toSet()
          ..remove(liste[i].kapanis);
        if (dun.intersection(bugun).isEmpty) {
          ortaksizCift++;
        }
      }
      expect(
        ortaksizCift * 100,
        greaterThanOrEqualTo(
          ContentConfig.denetimEnAzArdisikFarkYuzde * (liste.length - 1),
        ),
        reason:
            'yaşam yolu ${o.profil.yasamYolu.deger}: '
            '$ortaksizCift/${liste.length - 1} gün çifti ortaksız',
      );
    }
  });
}
