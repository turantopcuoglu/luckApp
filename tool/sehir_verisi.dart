// Şehir verisi hazırlama betiği (K8-3). Uygulamaya girmez.
//
// Kullanım:
//   dart run tool/sehir_verisi.dart <cities15000.txt> assets/veri/sehirler.tsv
//
// Girdi: GeoNames `cities15000.zip` içindeki metin
// (https://download.geonames.org/export/dump/cities15000.zip, CC BY 4.0).
// Çıktı: `DunyaSehirleri.kompaktYaz` biçimi. Kırpma: yalnız ad, ASCII ad,
// ülke, enlem, boylam ve saat dilimi kalır; Türkiye satırları atılır
// (Türkiye'de 81 il listesi kullanılır); satırlar nüfusa göre sıralanır.
import 'dart:io';

import 'package:kader/core/luck_engine/dunya_sehirleri.dart';

void main(List<String> argumanlar) {
  if (argumanlar.length != 2) {
    stderr.writeln('kullanım: dart run tool/sehir_verisi.dart <girdi> <çıktı>');
    exitCode = 64;
    return;
  }
  final List<String> satirlar = File(argumanlar[0]).readAsLinesSync();
  final List<DunyaSehri> sehirler =
      satirlar.map(DunyaSehri.geoNamesSatirindan).nonNulls.toList()
        // Kalabalık önce; eşitlikte ad (çıktı her çalıştırmada aynı).
        ..sort((DunyaSehri a, DunyaSehri b) {
          final int n = b.nufus.compareTo(a.nufus);
          return n != 0 ? n : a.ad.compareTo(b.ad);
        });
  final String metin = DunyaSehirleri.kompaktYaz(
    sehirler,
    aciklama: <String>[
      'Şehir verisi: GeoNames (https://www.geonames.org), CC BY 4.0.',
      'Kaynak dosya: cities15000 (${satirlar.length} satır). Değiştirildi:',
      'Türkiye satırları atıldı; yalnız ad, ASCII ad, ülke, enlem, boylam',
      've saat dilimi bırakıldı; koordinat yuvarlandı; nüfusa göre sıralandı.',
    ],
  );
  File(argumanlar[1]).writeAsStringSync(metin);
  stdout.writeln(
    '${sehirler.length} şehir, '
    '${sehirler.map((DunyaSehri s) => s.ulkeKodu).toSet().length} ülke, '
    '${(metin.length / 1024).round()} KB (karakter)',
  );
}
