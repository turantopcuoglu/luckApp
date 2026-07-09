import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/history/gecmis_ozeti.dart';
import 'package:kader/core/history/history_analiz_config.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';

/// Belirli skor ve feedback ile minimal bir günlük kayıt üretir.
///
/// Saf analiz yalnız [skor] ve günü okuduğu için kategori/modifiyer
/// alanları boş bırakılır (motor gerekmez).
DailyRecord _kayit(int gunNo, int skor, {bool? feedback}) {
  return DailyRecord(
    sonuc: LuckResult(
      gun: DateTime(2026, 7, gunNo),
      genelSkor: skor,
      kategoriSkorlari: const <LuckCategory, int>{},
      modifiyerler: const <LuckModifier>[],
    ),
    feedbackPozitif: feedback,
  );
}

void main() {
  group('gecmisiOzetle', () {
    test('boş liste GecmisOzeti.bos döndürür', () {
      final GecmisOzeti ozet = gecmisiOzetle(<DailyRecord>[]);
      expect(ozet, same(GecmisOzeti.bos));
      expect(ozet.toplamGun, 0);
      expect(ozet.ortalamaSkor, 0);
      expect(ozet.enSansliGun, isNull);
      expect(ozet.kanitYuzdesi, isNull);
      expect(ozet.kanitYeterli, isFalse);
    });

    test('toplam gün ve ortalama skoru yuvarlar', () {
      final GecmisOzeti ozet = gecmisiOzetle(<DailyRecord>[
        _kayit(1, 40),
        _kayit(2, 41),
        _kayit(3, 42),
      ]);
      expect(ozet.toplamGun, 3);
      // (40+41+42)/3 = 41.
      expect(ozet.ortalamaSkor, 41);
    });

    test('kanıt matematiği: 4 yüksek günün 3\'ü pozitif → %75', () {
      final GecmisOzeti ozet = gecmisiOzetle(<DailyRecord>[
        _kayit(1, 80, feedback: true),
        _kayit(2, 75, feedback: true),
        _kayit(3, 90, feedback: true),
        _kayit(4, 88, feedback: false),
      ]);
      expect(ozet.kanitOrnekSayisi, 4);
      expect(ozet.kanitPozitifSayisi, 3);
      expect(ozet.kanitYuzdesi, 75);
      expect(ozet.kanitYeterli, isTrue);
    });

    test('eşik altı örnek sayısı yüzdeyi gizler ama sayıyı raporlar', () {
      // 2 yüksek+feedbackli gün, varsayılan eşik 3.
      final GecmisOzeti ozet = gecmisiOzetle(<DailyRecord>[
        _kayit(1, 80, feedback: true),
        _kayit(2, 70, feedback: true),
      ]);
      expect(ozet.kanitOrnekSayisi, 2);
      expect(ozet.kanitYuzdesi, isNull);
      expect(ozet.kanitYeterli, isFalse);
    });

    test('enAzKanitGunu override edilince yüzde hesaplanır', () {
      final GecmisOzeti ozet = gecmisiOzetle(
        <DailyRecord>[
          _kayit(1, 80, feedback: true),
          _kayit(2, 70, feedback: false),
        ],
        enAzKanitGunu: 2,
      );
      expect(ozet.kanitOrnekSayisi, 2);
      expect(ozet.kanitYuzdesi, 50);
    });

    test('seçim doğruluğu: feedbacksiz yüksek ve feedbackli düşük dışlanır',
        () {
      final GecmisOzeti ozet = gecmisiOzetle(
        <DailyRecord>[
          _kayit(1, 90), // yüksek ama feedback yok → hariç
          _kayit(2, 30, feedback: true), // düşük → hariç
          _kayit(3, 80, feedback: true), // dahil
          _kayit(4, 85, feedback: false), // dahil
          _kayit(5, 95, feedback: true), // dahil
        ],
        enAzKanitGunu: 2,
      );
      expect(ozet.kanitOrnekSayisi, 3);
      expect(ozet.kanitPozitifSayisi, 2);
    });

    test('bant sınırı: skor 60 dahil, 59 hariç (bandiBul ile aynı kaynak)',
        () {
      final GecmisOzeti ozet = gecmisiOzetle(
        <DailyRecord>[
          _kayit(1, 60, feedback: true), // yuksek bandı → dahil
          _kayit(2, 59, feedback: true), // orta bandı → hariç
        ],
        enAzKanitGunu: 1,
      );
      expect(ozet.kanitOrnekSayisi, 1);
      expect(ozet.kanitYuzdesi, 100);
    });

    test('en şanslı gün eşitlikte en erken günü seçer, sıra bağımsız', () {
      // Aynı en yüksek skor (90) iki günde; en erken (gün 2) kazanmalı.
      final GecmisOzeti ozet = gecmisiOzetle(<DailyRecord>[
        _kayit(5, 90),
        _kayit(9, 70),
        _kayit(2, 90),
      ]);
      expect(ozet.enSansliSkor, 90);
      expect(ozet.enSansliGun, DateTime(2026, 7, 2));
    });

    test('varsayılan eşik HistoryAnalizConfig.enAzKanitGunu ile uyumlu', () {
      // Tam eşik kadar örnek → yüzde görünür.
      final List<DailyRecord> kayitlar = <DailyRecord>[
        for (int i = 1; i <= HistoryAnalizConfig.enAzKanitGunu; i++)
          _kayit(i, 80, feedback: true),
      ];
      final GecmisOzeti ozet = gecmisiOzetle(kayitlar);
      expect(ozet.kanitYeterli, isTrue);
      expect(ozet.kanitYuzdesi, 100);
    });
  });
}
