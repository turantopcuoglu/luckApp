// Şehir verisi hazırlama betiği (K8-3). Uygulamaya girmez.
//
// Kullanım:
//   dart run tool/sehir_verisi.dart <cities15000.txt> <admin1CodesASCII.txt> \
//     assets/veri/sehirler.tsv
//
// Girdi: GeoNames `cities15000.zip` içindeki metin ve `admin1CodesASCII.txt`
// (https://download.geonames.org/export/dump/, CC BY 4.0).
// Çıktı: `DunyaSehirleri.kompaktYaz` biçimi. Kırpma: ad, ASCII ad, ülke,
// enlem, boylam, saat dilimi, büyük şehirlerin diğer adları ve aynı adlı
// şehirlerin bölge adı kalır; Türkiye satırları atılır (Türkiye'de 81 il
// listesi kullanılır); satırlar nüfusa göre sıralanır.
import 'dart:io';

import 'package:kader/core/luck_engine/dunya_sehirleri.dart';

void main(List<String> argumanlar) {
  if (argumanlar.length != 3) {
    stderr.writeln(
      'kullanım: dart run tool/sehir_verisi.dart <şehirler> <bölgeler> <çıktı>',
    );
    exitCode = 64;
    return;
  }
  final List<String> satirlar = File(argumanlar[0]).readAsLinesSync();
  final Map<String, String> bolgeler = DunyaSehri.bolgeTablosu(
    File(argumanlar[1]).readAsStringSync(),
  );
  final List<DunyaSehri> sehirler =
      satirlar
          .map(
            (String s) => DunyaSehri.geoNamesSatirindan(s, bolgeler: bolgeler),
          )
          .nonNulls
          .toList()
        // Kalabalık önce; eşitlikte ad (çıktı her çalıştırmada aynı).
        ..sort((DunyaSehri a, DunyaSehri b) {
          final int n = b.nufus.compareTo(a.nufus);
          return n != 0 ? n : a.ad.compareTo(b.ad);
        });
  final String metin = DunyaSehirleri.kompaktYaz(
    sehirler,
    aciklama: <String>[
      'Şehir verisi: GeoNames (https://www.geonames.org), CC BY 4.0.',
      'Kaynak dosyalar: cities15000 (${satirlar.length} satır),',
      'admin1CodesASCII (${bolgeler.length} bölge). Değiştirildi: Türkiye',
      'satırları atıldı; ad, ASCII ad, ülke, enlem, boylam, saat dilimi,',
      '100 bin üstü şehirlerin Latin diğer adları ve aynı adlı şehirlerin',
      'bölge adı bırakıldı; koordinat yuvarlandı; nüfusa göre sıralandı.',
    ],
  );
  File(argumanlar[2]).writeAsStringSync(metin);
  stdout.writeln(
    '${sehirler.length} şehir, '
    '${sehirler.map((DunyaSehri s) => s.ulkeKodu).toSet().length} ülke, '
    '${(metin.length / 1024).round()} KB (karakter)',
  );
}
