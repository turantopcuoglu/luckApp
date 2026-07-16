import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/category_pools.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/fortune_pools.dart';
import 'package:kader/core/content/sans_rengi.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

/// Bir metin havuzunun bütünlüğünü doğrular: boş/duplicate eleman yok,
/// her cümle noktalama ile bitiyor (kombinasyon kuralı).
void havuzuDogrula(String ad, List<String> havuz) {
  final Set<String> benzersiz = <String>{};
  for (final String cumle in havuz) {
    expect(cumle.trim(), isNotEmpty, reason: '$ad boş cümle içeriyor');
    expect(
      cumle.endsWith('.') ||
          cumle.endsWith('!') ||
          cumle.endsWith('?') ||
          cumle.endsWith('…'),
      isTrue,
      reason: '$ad noktalamasız cümle içeriyor: "$cumle"',
    );
    expect(
      benzersiz.add(cumle),
      isTrue,
      reason: '$ad tekrarlı cümle içeriyor: "$cumle"',
    );
  }
}

void main() {
  // Her havuz bütünlük testi HER İKİ dilde de koşar (TR + EN).
  group('FortunePools bütünlük', () {
    for (final AppDil dil in AppDil.values) {
      test('[$dil] açılış: her bant mevcut ve minimum boyutta', () {
        for (final SkorBandi bant in SkorBandi.values) {
          final List<String>? havuz = FortunePools.acilisCumleleri(dil)[bant];
          expect(havuz, isNotNull, reason: '$bant açılış havuzu eksik');
          expect(
            havuz!.length,
            greaterThanOrEqualTo(ContentConfig.enAzAcilisVaryanti),
          );
          havuzuDogrula('acilis[$bant]', havuz);
        }
      });

      test('[$dil] orta: her (kategori, ton) mevcut ve minimum boyutta', () {
        for (final LuckCategory kategori in LuckCategory.values) {
          final Map<KategoriTonu, List<String>>? tonlar =
              FortunePools.ortaCumleleri(dil)[kategori];
          expect(tonlar, isNotNull, reason: '$kategori orta havuzu eksik');
          for (final KategoriTonu ton in KategoriTonu.values) {
            final List<String>? havuz = tonlar![ton];
            expect(havuz, isNotNull, reason: '($kategori, $ton) eksik');
            expect(
              havuz!.length,
              greaterThanOrEqualTo(ContentConfig.enAzOrtaVaryanti),
            );
            havuzuDogrula('orta[$kategori][$ton]', havuz);
          }
        }
      });

      test('[$dil] kapanış ve tavsiye havuzları minimum boyutta ve temiz', () {
        expect(
          FortunePools.kapanisCumleleri(dil).length,
          greaterThanOrEqualTo(ContentConfig.enAzKapanis),
        );
        havuzuDogrula('kapanis', FortunePools.kapanisCumleleri(dil));

        expect(
          FortunePools.gununTavsiyeleri(dil).length,
          greaterThanOrEqualTo(ContentConfig.enAzTavsiye),
        );
        havuzuDogrula('tavsiye', FortunePools.gununTavsiyeleri(dil));
      });

      test('[$dil] renkler: minimum sayı, benzersiz ad, tam opak ARGB', () {
        expect(
          FortunePools.sansRenkleri.length,
          greaterThanOrEqualTo(ContentConfig.enAzRenk),
        );
        final Set<String> adlar = <String>{};
        for (final SansRengi renk in FortunePools.sansRenkleri) {
          expect(renk.ad(dil).trim(), isNotEmpty);
          expect(
            adlar.add(renk.ad(dil)),
            isTrue,
            reason: 'Tekrarlı renk adı: ${renk.ad(dil)}',
          );
          // Alpha kanalı 0xFF olmalı: kart üzerinde soluk renk istenmez.
          expect(
            renk.hexArgb >> 24 & 0xFF,
            0xFF,
            reason: '${renk.ad(dil)} tam opak değil',
          );
        }
      });
    }
  });

  group('CategoryPools bütünlük', () {
    for (final AppDil dil in AppDil.values) {
      test('[$dil] kategori açılışları: her (kategori, ton) yeterli', () {
        for (final LuckCategory kategori in LuckCategory.values) {
          final Map<KategoriTonu, List<String>>? tonlar =
              CategoryPools.kategoriAcilislari(dil)[kategori];
          expect(tonlar, isNotNull, reason: '$kategori açılışları eksik');
          for (final KategoriTonu ton in KategoriTonu.values) {
            final List<String>? havuz = tonlar![ton];
            expect(havuz, isNotNull, reason: '($kategori, $ton) eksik');
            expect(
              havuz!.length,
              greaterThanOrEqualTo(ContentConfig.enAzKategoriVaryanti),
            );
            havuzuDogrula('kategoriAcilis[$kategori][$ton]', havuz);
          }
        }
      });

      test('[$dil] kategori tavsiyeleri: her kategori yeterli', () {
        for (final LuckCategory kategori in LuckCategory.values) {
          final List<String>? havuz = CategoryPools.kategoriTavsiyeleri(
            dil,
          )[kategori];
          expect(havuz, isNotNull, reason: '$kategori tavsiyeleri eksik');
          expect(
            havuz!.length,
            greaterThanOrEqualTo(ContentConfig.enAzKategoriTavsiye),
          );
          havuzuDogrula('kategoriTavsiye[$kategori]', havuz);
        }
      });
    }
  });

  // Determinizm (kural 8): TR ve EN havuzları BİREBİR aynı uzunlukta
  // olmalı ki seed indeksi her iki dilde de aynı slotu seçsin.
  group('TR/EN parite (aynı uzunluk)', () {
    test('açılış bantları eşit uzunlukta', () {
      for (final SkorBandi bant in SkorBandi.values) {
        expect(
          FortunePools.acilisCumleleri(AppDil.tr)[bant]!.length,
          FortunePools.acilisCumleleri(AppDil.en)[bant]!.length,
          reason: 'acilis[$bant] uzunlukları farklı',
        );
      }
    });

    test('orta ve kategori havuzları eşit uzunlukta', () {
      for (final LuckCategory kategori in LuckCategory.values) {
        for (final KategoriTonu ton in KategoriTonu.values) {
          expect(
            FortunePools.ortaCumleleri(AppDil.tr)[kategori]![ton]!.length,
            FortunePools.ortaCumleleri(AppDil.en)[kategori]![ton]!.length,
            reason: 'orta[$kategori][$ton] uzunlukları farklı',
          );
          expect(
            CategoryPools.kategoriAcilislari(AppDil.tr)[kategori]![ton]!.length,
            CategoryPools.kategoriAcilislari(AppDil.en)[kategori]![ton]!.length,
            reason: 'kategoriAcilis[$kategori][$ton] uzunlukları farklı',
          );
        }
        expect(
          CategoryPools.kategoriTavsiyeleri(AppDil.tr)[kategori]!.length,
          CategoryPools.kategoriTavsiyeleri(AppDil.en)[kategori]!.length,
          reason: 'kategoriTavsiye[$kategori] uzunlukları farklı',
        );
      }
    });

    test('kapanış, tavsiye eşit uzunlukta', () {
      expect(
        FortunePools.kapanisCumleleri(AppDil.tr).length,
        FortunePools.kapanisCumleleri(AppDil.en).length,
      );
      expect(
        FortunePools.gununTavsiyeleri(AppDil.tr).length,
        FortunePools.gununTavsiyeleri(AppDil.en).length,
      );
    });
  });

  group('SkorBandi / KategoriTonu eşikleri', () {
    test('bandiBul sınır değerleri doğru banda düşer', () {
      expect(SkorBandi.bandiBul(0), SkorBandi.cokDusuk);
      expect(
        SkorBandi.bandiBul(ContentConfig.cokDusukEsik - 1),
        SkorBandi.cokDusuk,
      );
      expect(SkorBandi.bandiBul(ContentConfig.cokDusukEsik), SkorBandi.dusuk);
      expect(SkorBandi.bandiBul(ContentConfig.dusukEsik - 1), SkorBandi.dusuk);
      expect(SkorBandi.bandiBul(ContentConfig.dusukEsik), SkorBandi.orta);
      expect(SkorBandi.bandiBul(ContentConfig.ortaEsik - 1), SkorBandi.orta);
      expect(SkorBandi.bandiBul(ContentConfig.ortaEsik), SkorBandi.yuksek);
      expect(SkorBandi.bandiBul(ContentConfig.yuksekEsik), SkorBandi.yuksek);
      expect(
        SkorBandi.bandiBul(ContentConfig.yuksekEsik + 1),
        SkorBandi.cokYuksek,
      );
      expect(SkorBandi.bandiBul(100), SkorBandi.cokYuksek);
    });

    test('tonuBul sınır değerleri doğru tona düşer', () {
      expect(KategoriTonu.tonuBul(0), KategoriTonu.dusuk);
      expect(
        KategoriTonu.tonuBul(ContentConfig.kategoriDusukEsik - 1),
        KategoriTonu.dusuk,
      );
      expect(
        KategoriTonu.tonuBul(ContentConfig.kategoriDusukEsik),
        KategoriTonu.orta,
      );
      expect(
        KategoriTonu.tonuBul(ContentConfig.kategoriYuksekEsik),
        KategoriTonu.orta,
      );
      expect(
        KategoriTonu.tonuBul(ContentConfig.kategoriYuksekEsik + 1),
        KategoriTonu.yuksek,
      );
      expect(KategoriTonu.tonuBul(100), KategoriTonu.yuksek);
    });
  });
}
