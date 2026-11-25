import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/fortune_pools.dart';
import 'package:kader/core/content/sans_rengi.dart';

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
  group('FortunePools bütünlük', () {
    test('tavsiye havuzu minimum boyutta ve temiz', () {
      expect(
        FortunePools.gununTavsiyeleri.length,
        greaterThanOrEqualTo(ContentConfig.enAzTavsiye),
      );
      havuzuDogrula('tavsiye', FortunePools.gununTavsiyeleri);
    });

    test('renkler: minimum sayı, benzersiz ad, tam opak ARGB', () {
      expect(
        FortunePools.sansRenkleri.length,
        greaterThanOrEqualTo(ContentConfig.enAzRenk),
      );
      final Set<String> adlar = <String>{};
      for (final SansRengi renk in FortunePools.sansRenkleri) {
        expect(renk.ad.trim(), isNotEmpty);
        expect(adlar.add(renk.ad), isTrue,
            reason: 'Tekrarlı renk adı: ${renk.ad}');
        // Alpha kanalı 0xFF olmalı: kart üzerinde soluk renk istenmez.
        expect(renk.hexArgb >> 24 & 0xFF, 0xFF,
            reason: '${renk.ad} tam opak değil');
      }
    });
  });

  group('SkorBandi / KategoriTonu eşikleri', () {
    test('bandiBul sınır değerleri doğru banda düşer', () {
      expect(SkorBandi.bandiBul(0), SkorBandi.cokDusuk);
      expect(SkorBandi.bandiBul(ContentConfig.cokDusukEsik - 1),
          SkorBandi.cokDusuk);
      expect(SkorBandi.bandiBul(ContentConfig.cokDusukEsik), SkorBandi.dusuk);
      expect(
          SkorBandi.bandiBul(ContentConfig.dusukEsik - 1), SkorBandi.dusuk);
      expect(SkorBandi.bandiBul(ContentConfig.dusukEsik), SkorBandi.orta);
      expect(SkorBandi.bandiBul(ContentConfig.ortaEsik - 1), SkorBandi.orta);
      expect(SkorBandi.bandiBul(ContentConfig.ortaEsik), SkorBandi.yuksek);
      expect(
          SkorBandi.bandiBul(ContentConfig.yuksekEsik), SkorBandi.yuksek);
      expect(SkorBandi.bandiBul(ContentConfig.yuksekEsik + 1),
          SkorBandi.cokYuksek);
      expect(SkorBandi.bandiBul(100), SkorBandi.cokYuksek);
    });

    test('tonuBul sınır değerleri doğru tona düşer', () {
      expect(KategoriTonu.tonuBul(0), KategoriTonu.dusuk);
      expect(KategoriTonu.tonuBul(ContentConfig.kategoriDusukEsik - 1),
          KategoriTonu.dusuk);
      expect(KategoriTonu.tonuBul(ContentConfig.kategoriDusukEsik),
          KategoriTonu.orta);
      expect(KategoriTonu.tonuBul(ContentConfig.kategoriYuksekEsik),
          KategoriTonu.orta);
      expect(KategoriTonu.tonuBul(ContentConfig.kategoriYuksekEsik + 1),
          KategoriTonu.yuksek);
      expect(KategoriTonu.tonuBul(100), KategoriTonu.yuksek);
    });
  });
}
