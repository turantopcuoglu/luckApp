import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/history/aylik_ozet.dart';
import 'package:kader/core/history/history_analiz_config.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';

/// Belirli tarih/skor (+ opsiyonel kategori skorları) ile kayıt üretir.
DailyRecord _kayit(
  DateTime gun,
  int skor, {
  Map<LuckCategory, int>? kategoriler,
}) {
  return DailyRecord(
    sonuc: LuckResult(
      gun: gun,
      genelSkor: skor,
      kategoriSkorlari: kategoriler ?? const <LuckCategory, int>{},
      modifiyerler: const <LuckModifier>[],
    ),
  );
}

void main() {
  group('aylikOzet', () {
    test('boş ay → bosMu, gün 0, null alanlar', () {
      final AylikOzet o = aylikOzet(<DailyRecord>[], yil: 2026, ay: 7);
      expect(o.bosMu, isTrue);
      expect(o.gunSayisi, 0);
      expect(o.ortalamaSkor, 0);
      expect(o.enSansliGun, isNull);
      expect(o.baskinKategori, isNull);
      expect(o.altinGunSayisi, 0);
      expect(o.enUzunSeri, 0);
    });

    test('yalnız istenen ayın kayıtları sayılır', () {
      final AylikOzet o = aylikOzet(
        <DailyRecord>[
          _kayit(DateTime(2026, 7, 3), 50),
          _kayit(DateTime(2026, 7, 20), 70),
          _kayit(DateTime(2026, 6, 30), 90), // önceki ay → hariç
          _kayit(DateTime(2026, 8, 1), 95), // sonraki ay → hariç
          _kayit(DateTime(2025, 7, 15), 80), // önceki yıl → hariç
        ],
        yil: 2026,
        ay: 7,
      );
      expect(o.gunSayisi, 2);
      expect(o.ortalamaSkor, 60); // (50+70)/2
    });

    test('altın gün eşiği: 92 dahil, 91 hariç', () {
      final AylikOzet o = aylikOzet(
        <DailyRecord>[
          _kayit(DateTime(2026, 7, 1), 91),
          _kayit(DateTime(2026, 7, 2), 92),
          _kayit(DateTime(2026, 7, 3), 100),
        ],
        yil: 2026,
        ay: 7,
      );
      expect(HistoryAnalizConfig.altinGunEsigi, 92);
      expect(o.altinGunSayisi, 2);
    });

    test('en şanslı gün eşitlikte en erken günü seçer', () {
      final AylikOzet o = aylikOzet(
        <DailyRecord>[
          _kayit(DateTime(2026, 7, 9), 88),
          _kayit(DateTime(2026, 7, 4), 88),
          _kayit(DateTime(2026, 7, 6), 50),
        ],
        yil: 2026,
        ay: 7,
      );
      expect(o.enSansliSkor, 88);
      expect(o.enSansliGun, DateTime(2026, 7, 4));
    });

    test('baskın kategori ay boyunca toplamdan seçilir', () {
      // Para her gün yüksek toplanır → baskın.
      Map<LuckCategory, int> skorlar(int para) => <LuckCategory, int>{
            LuckCategory.ask: 10,
            LuckCategory.para: para,
            LuckCategory.saglik: 10,
            LuckCategory.risk: 10,
            LuckCategory.sosyal: 10,
          };
      final AylikOzet o = aylikOzet(
        <DailyRecord>[
          _kayit(DateTime(2026, 7, 1), 60, kategoriler: skorlar(80)),
          _kayit(DateTime(2026, 7, 2), 60, kategoriler: skorlar(90)),
        ],
        yil: 2026,
        ay: 7,
      );
      expect(o.baskinKategori, LuckCategory.para);
    });

    test('ay içi en uzun seri (grace tek boş gün tolere)', () {
      // 1,2 ardışık; 4 (fark 2 tolere) → 3'lük seri; 10 kopar.
      final AylikOzet o = aylikOzet(
        <DailyRecord>[
          _kayit(DateTime(2026, 7, 1), 50),
          _kayit(DateTime(2026, 7, 2), 50),
          _kayit(DateTime(2026, 7, 4), 50),
          _kayit(DateTime(2026, 7, 10), 50),
        ],
        yil: 2026,
        ay: 7,
      );
      expect(o.enUzunSeri, 3);
    });

    test('yıl/ay alanları korunur', () {
      final AylikOzet o = aylikOzet(
        <DailyRecord>[_kayit(DateTime(2026, 3, 5), 50)],
        yil: 2026,
        ay: 3,
      );
      expect(o.yil, 2026);
      expect(o.ay, 3);
      expect(o.bosMu, isFalse);
    });
  });
}
