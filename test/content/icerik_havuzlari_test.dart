import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/burc_metinleri.dart';
import 'package:kader/core/content/category_pools.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/dongu_metinleri.dart';
import 'package:kader/core/content/fortune_pools.dart';
import 'package:kader/core/content/kisisel_havuzlar.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/content/sayi_metinleri.dart';
import 'package:kader/core/content/slot_doldurucu.dart';
import 'package:kader/core/content/uyum_metinleri.dart';
import 'package:kader/core/content/yorum_yonu.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

import 'fortune_pools_test.dart' show havuzuDogrula;

/// Numerolojide geçerli tüm yaşam yolu sayıları.
const List<int> _tumSayilar = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33];

/// Kullanıcıya gösterilen tüm metinler (yasaklı ifade ve slot taraması).
List<String> _tumMetinler() {
  final List<String> m = <String>[];
  void ekle(Iterable<String> x) => m.addAll(x);

  for (final SayiKarakteri k in SayiMetinleri.yasamYolu.values) {
    ekle(<String>[
      k.oz,
      k.gucluYanlar,
      k.golgeYan,
      k.askta,
      k.isteVeParada,
      k.yasamDersi,
      k.iliskide,
    ]);
  }
  ekle(SayiMetinleri.ruhSayisi.values);
  ekle(SayiMetinleri.isimSayisi.values);
  ekle(SayiMetinleri.kisilikSayisi.values);
  DonguMetinleri.gunBasliklari.values.forEach(ekle);
  for (final KisiselYilMetni y in DonguMetinleri.kisiselYil.values) {
    ekle(<String>[y.uzun, ...y.gunluk]);
  }
  DonguMetinleri.ayEvresi.values.forEach(ekle);
  ekle(BurcMetinleri.oz.values);
  ekle(<String>[BurcMetinleri.sinirNotu]);
  KisiselHavuzlar.eylemCumleleri.values.forEach(ekle);
  ekle(KisiselHavuzlar.golgesizGun);
  KisiselHavuzlar.enerjiTavsiyeleri.values.forEach(ekle);
  ekle(KisiselHavuzlar.profilIliskiEki.values);
  ekle(KisiselHavuzlar.profilUgrasEki.values);
  UyumMetinleri.yasamYolu.values.forEach(ekle);
  ekle(UyumMetinleri.element.values);
  ekle(UyumMetinleri.ruh.values);
  UyumMetinleri.tavsiye.values.forEach(ekle);
  // v3 yorum yönü.
  for (final GunTemasi t in YorumYonu.gunTemalari.values) {
    t.durum.values.forEach(ekle);
  }
  YorumYonu.bulusmaCumleleri.values.forEach(ekle);
  for (final Map<String, List<String>> s in YorumYonu.gunSahneleri.values) {
    s.values.forEach(ekle);
  }
  for (final KarakterYonu k in YorumYonu.karakterler.values) {
    ekle(k.gucTavsiyeleri);
    ekle(k.golgeTavsiyeleri);
    ekle(k.dengeTavsiyeleri);
    k.kategoriTarzi.values.forEach(ekle);
  }
  for (final Map<String, Map<KategoriTonu, List<String>>> d
      in YorumYonu.kategoriDurumlari.values) {
    for (final Map<KategoriTonu, List<String>> tonlar in d.values) {
      tonlar.values.forEach(ekle);
    }
  }
  for (final Map<LuckCategory, String> t in YorumYonu.temaKategori.values) {
    ekle(t.values);
  }
  YorumYonu.donemCumleleri.values.forEach(ekle);
  YorumYonu.ayCumleleri.values.forEach(ekle);
  // Kullanılmaya devam eden v1 havuzları.
  ekle(FortunePools.gununTavsiyeleri);
  CategoryPools.kategoriTavsiyeleri.values.forEach(ekle);
  return m;
}

int _kelimeSayisi(String metin) =>
    metin.split(RegExp(r'\s+')).where((String k) => k.isNotEmpty).length;

void main() {
  group('Sayı metinleri', () {
    test('tüm sayılar için tüm alanlar dolu ve yeterince uzun', () {
      for (final int sayi in _tumSayilar) {
        final SayiKarakteri? k = SayiMetinleri.yasamYolu[sayi];
        expect(k, isNotNull, reason: 'yaşam yolu $sayi eksik');
        expect(k!.anahtarlar.length, 3);
        for (final String metin in <String>[
          k.oz,
          k.gucluYanlar,
          k.golgeYan,
          k.askta,
          k.isteVeParada,
          k.yasamDersi,
        ]) {
          expect(
            _kelimeSayisi(metin),
            greaterThanOrEqualTo(ContentConfig.profilEnAzKelime),
            reason: 'yaşam yolu $sayi metni kısa: "$metin"',
          );
        }
        expect(SayiMetinleri.ruhSayisi[sayi], contains('$sayi'));
        expect(SayiMetinleri.isimSayisi[sayi], contains('$sayi'));
        expect(SayiMetinleri.kisilikSayisi[sayi], contains('$sayi'));
      }
    });
  });

  group('Yorum yönü (v3)', () {
    test('her kişisel gün için istek ve her tonda en az iki durum', () {
      for (int k = 1; k <= 9; k++) {
        final GunTemasi? t = YorumYonu.gunTemalari[k];
        expect(t, isNotNull, reason: 'tema $k');
        expect(t!.istek.trim(), isNotEmpty);
        expect(t.istek.endsWith('.'), isFalse, reason: 'istek mastar öbeği');
        for (final GunTonu ton in GunTonu.values) {
          expect(
            t.durum[ton]!.length,
            greaterThanOrEqualTo(ContentConfig.enAzDurumVaryanti),
          );
          havuzuDogrula('durum[$k][$ton]', t.durum[ton]!);
        }
        expect(DonguMetinleri.gunBasliklari[k], isNotEmpty);
      }
    });

    test('karakterler: 12 sayı, günler uyumlu/zorlayıcı/dengeli olarak '
        'ayrışır ve kendi sayısı her zaman uyumludur', () {
      for (final int sayi in _tumSayilar) {
        final KarakterYonu? k = YorumYonu.karakterler[sayi];
        expect(k, isNotNull, reason: 'karakter $sayi');
        expect(k!.uyumluGunler.intersection(k.zorlayiciGunler), isEmpty);
        expect(k.uyumluGunler.length, 3, reason: '$sayi uyumlu');
        expect(k.zorlayiciGunler.length, 3, reason: '$sayi zorlayıcı');
        for (final int g in <int>{...k.uyumluGunler, ...k.zorlayiciGunler}) {
          expect(g, inInclusiveRange(1, 9));
        }
        expect(
          k.bulusma(Numeroloji.tabanSayi(sayi)),
          BulusmaTuru.uyumlu,
          reason: '$sayi kendi gününde uyumlu olmalı',
        );
        expect(k.doga.endsWith('.'), isFalse);
        for (final BulusmaTuru tur in BulusmaTuru.values) {
          final List<String> oneriler = k.tavsiyeler(tur);
          expect(
            oneriler.length,
            greaterThanOrEqualTo(ContentConfig.enAzOneriVaryanti),
            reason: '$sayi $tur',
          );
          havuzuDogrula('öneri[$sayi][$tur]', oneriler);
        }
        for (final LuckCategory kat in LuckCategory.values) {
          final List<String>? tarz = k.kategoriTarzi[kat];
          expect(tarz, isNotNull, reason: '$sayi $kat');
          expect(
            tarz!.length,
            greaterThanOrEqualTo(ContentConfig.enAzTarzVaryanti),
            reason: '$sayi $kat',
          );
          havuzuDogrula('tarz[$sayi][$kat]', tarz);
        }
      }
    });

    test('okumanın ortasındaki cümleler "Bugün" ile başlamaz; tarz '
        'cümleleri günden bağımsızdır', () {
      // Yalnızca açılış (gün teması durumu) günü anar; ortadaki cümleler
      // de "Bugün" ile başlarsa okuma tek kalıptan çıkmış gibi okunur.
      final List<String> ortaCumleler = <String>[
        ...YorumYonu.bulusmaCumleleri.values.expand((List<String> l) => l),
        for (final Map<String, List<String>> s in YorumYonu.gunSahneleri.values)
          ...s.values.expand((List<String> l) => l),
        for (final KarakterYonu k in YorumYonu.karakterler.values) ...<String>[
          ...k.gucTavsiyeleri,
          ...k.golgeTavsiyeleri,
          ...k.dengeTavsiyeleri,
        ],
        for (final Map<String, Map<KategoriTonu, List<String>>> d
            in YorumYonu.kategoriDurumlari.values)
          for (final Map<KategoriTonu, List<String>> tonlar in d.values)
            ...tonlar.values.expand((List<String> l) => l),
        for (final Map<LuckCategory, String> t in YorumYonu.temaKategori.values)
          ...t.values,
        ...KisiselHavuzlar.golgesizGun,
        ...YorumYonu.donemCumleleri.values.expand((List<String> l) => l),
        ...YorumYonu.ayCumleleri.values.expand((List<String> l) => l),
      ];
      for (final String c in ortaCumleler) {
        expect(c.startsWith('Bugün'), isFalse, reason: c);
      }
      for (final KarakterYonu k in YorumYonu.karakterler.values) {
        for (final String c in k.kategoriTarzi.values.expand(
          (List<String> l) => l,
        )) {
          expect(c.toLowerCase().contains('bugün'), isFalse, reason: c);
        }
      }
    });

    test('buluşma cümleleri her türde yeterli varyantta', () {
      for (final BulusmaTuru tur in BulusmaTuru.values) {
        final List<String> havuz = YorumYonu.bulusmaCumleleri[tur]!;
        expect(
          havuz.length,
          greaterThanOrEqualTo(ContentConfig.enAzBulusmaVaryanti),
        );
        havuzuDogrula('buluşma[$tur]', havuz);
      }
    });

    test('her tema × uğraş sahnesi mevcut (genel dahil) ve varyantlı', () {
      for (int k = 1; k <= 9; k++) {
        final Map<String, List<String>> s = YorumYonu.gunSahneleri[k]!;
        expect(s.containsKey(YorumYonu.genelAnahtar), isTrue);
        for (final String anahtar in <String>[
          YorumYonu.genelAnahtar,
          for (final Ugras u in Ugras.values) u.name,
        ]) {
          final List<String>? havuz = s[anahtar];
          expect(havuz, isNotNull, reason: 'sahne $k $anahtar');
          expect(
            havuz!.length,
            greaterThanOrEqualTo(ContentConfig.enAzSahneVaryanti),
          );
          havuzuDogrula('sahne[$k][$anahtar]', havuz);
        }
      }
    });

    test('her kategori için durum anahtarları ve üç ton mevcut', () {
      for (final LuckCategory kat in LuckCategory.values) {
        final Map<String, Map<KategoriTonu, List<String>>> d =
            YorumYonu.kategoriDurumlari[kat]!;
        expect(d.containsKey(YorumYonu.genelAnahtar), isTrue, reason: '$kat');
        for (final MapEntry<String, Map<KategoriTonu, List<String>>> e
            in d.entries) {
          for (final KategoriTonu ton in KategoriTonu.values) {
            final List<String> havuz = e.value[ton]!;
            expect(
              havuz.length,
              greaterThanOrEqualTo(ContentConfig.enAzKategoriDurumVaryanti),
            );
            havuzuDogrula('durum[$kat][${e.key}][$ton]', havuz);
          }
        }
        for (int k = 1; k <= 9; k++) {
          expect(YorumYonu.temaKategori[k]![kat], isNotNull);
        }
      }
    });

    test('durum anahtarı kişinin durumuna göre değişir', () {
      const OkuyucuTercihleri t = OkuyucuTercihleri(
        iliski: IliskiDurumu.evli,
        ugras: Ugras.ogrenci,
        karar: KararTarzi.akil,
        enerji: EnerjiTarzi.disaDonuk,
      );
      expect(YorumYonu.durumAnahtari(LuckCategory.ask, t), 'partnerli');
      expect(YorumYonu.durumAnahtari(LuckCategory.para, t), 'ogrenci');
      expect(YorumYonu.durumAnahtari(LuckCategory.risk, t), 'akil');
      expect(YorumYonu.durumAnahtari(LuckCategory.sosyal, t), 'disaDonuk');
      expect(YorumYonu.durumAnahtari(LuckCategory.saglik, t), 'genel');
      expect(
        YorumYonu.durumAnahtari(LuckCategory.ask, const OkuyucuTercihleri()),
        'genel',
      );
    });

    test('dönem ve ay cümleleri 1-9, eylem cümleleri şanslı saati taşır', () {
      for (int k = 1; k <= 9; k++) {
        expect(
          YorumYonu.donemCumleleri[k]!.length,
          greaterThanOrEqualTo(ContentConfig.enAzDonemVaryanti),
        );
        expect(
          YorumYonu.ayCumleleri[k]!.length,
          greaterThanOrEqualTo(ContentConfig.enAzDonemVaryanti),
        );
        havuzuDogrula('dönem[$k]', YorumYonu.donemCumleleri[k]!);
        havuzuDogrula('ay[$k]', YorumYonu.ayCumleleri[k]!);
        // Kapanış havuzunda dönem ve ay cümleleri birbirini tekrar etmez.
        havuzuDogrula('kapanış[$k]', YorumYonu.kapanisHavuzu(k, k));
      }
      for (final List<String> eylemler
          in KisiselHavuzlar.eylemCumleleri.values) {
        expect(
          eylemler.length,
          greaterThanOrEqualTo(ContentConfig.enAzEylemDikkat),
        );
        havuzuDogrula('eylem', eylemler);
        for (final String c in eylemler) {
          expect(slotlariBul(c), contains(SlotAnahtarlari.saat), reason: c);
        }
      }
    });
  });

  group('Tüm metinler: güvenlik ve biçim', () {
    final List<String> metinler = _tumMetinler();

    test('yasaklı ifade içermez (kesinlik, teşhis, yatırım, korku)', () {
      for (final String metin in metinler) {
        final String kucuk = metin.toLowerCase();
        for (final String yasak in ContentConfig.yasakliIfadeler) {
          // Kelime başı eşleşmesi: öncesinde harf olmamalı ("bölüm" serbest).
          final RegExp desen = RegExp(
            '(^|[^a-zçğıöşüâîû])${RegExp.escape(yasak)}',
          );
          expect(
            desen.hasMatch(kucuk),
            isFalse,
            reason: '"$yasak" yasaklı: "$metin"',
          );
        }
      }
    });

    test('ana yorum metinleri numeroloji jargonu içermez', () {
      // Kişisel gün, yaşam yolu ve ay evresi terimleri yalnızca "Neden
      // bugün?" açıklamalarında geçer; günlük okuma günlük dille yazılır.
      final List<String> gunlukMetinler = <String>[
        for (final GunTemasi t in YorumYonu.gunTemalari.values)
          ...t.durum.values.expand((List<String> l) => l),
        ...YorumYonu.bulusmaCumleleri.values.expand((List<String> l) => l),
        for (final Map<String, List<String>> s in YorumYonu.gunSahneleri.values)
          ...s.values.expand((List<String> l) => l),
        ...YorumYonu.donemCumleleri.values.expand((List<String> l) => l),
        ...YorumYonu.ayCumleleri.values.expand((List<String> l) => l),
        for (final KarakterYonu k in YorumYonu.karakterler.values) ...<String>[
          ...k.gucTavsiyeleri,
          ...k.golgeTavsiyeleri,
          ...k.dengeTavsiyeleri,
          ...k.kategoriTarzi.values.expand((List<String> l) => l),
        ],
      ];
      for (final String metin in gunlukMetinler) {
        final String kucuk = metin.toLowerCase();
        for (final String terim in <String>[
          'kişisel gün',
          'yaşam yolu',
          'yıldız',
          'evren',
          'sayın',
        ]) {
          // Kelime başı eşleşmesi ("çevren" içindeki "evren" serbest).
          final RegExp desen = RegExp(
            '(^|[^a-zçğıöşüâîû])${RegExp.escape(terim)}',
          );
          expect(desen.hasMatch(kucuk), isFalse, reason: '"$terim": $metin');
        }
      }
    });

    test('yalnızca tanımlı yer tutucular kullanılır', () {
      for (final String metin in metinler) {
        for (final String slot in slotlariBul(metin)) {
          expect(
            SlotAnahtarlari.hepsi,
            contains(slot),
            reason: 'Tanımsız yer tutucu {$slot}: "$metin"',
          );
        }
      }
    });

    test('çift boşluk ya da boş metin yok', () {
      for (final String metin in metinler) {
        expect(metin.trim(), isNotEmpty);
        expect(metin.contains('  '), isFalse, reason: 'Çift boşluk: "$metin"');
      }
    });
  });
}
