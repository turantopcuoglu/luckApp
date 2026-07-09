import 'package:flutter_test/flutter_test.dart';
import 'package:kader/features/daily_luck/tr_strings.dart';
import 'package:kader/features/feedback/feedback_config.dart';
import 'package:kader/features/feedback/notification_service.dart';

void main() {
  group('sonrakiZaman', () {
    test('saat henüz geçmediyse bugünü seçer', () {
      final DateTime sonraki = NotificationService.sonrakiZaman(
        DateTime(2026, 7, 6, 7, 0),
        saat: FeedbackConfig.sabahSaat,
        dakika: FeedbackConfig.sabahDakika,
      );
      expect(sonraki, DateTime(2026, 7, 6, 8, 30));
    });

    test('saat geçtiyse yarını seçer', () {
      final DateTime sonraki = NotificationService.sonrakiZaman(
        DateTime(2026, 7, 6, 21, 30),
        saat: FeedbackConfig.aksamSaat,
        dakika: FeedbackConfig.aksamDakika,
      );
      expect(sonraki, DateTime(2026, 7, 7, 21, 0));
    });

    test('tam o an ise yarını seçer (geçmişe kurulmaz)', () {
      final DateTime sonraki = NotificationService.sonrakiZaman(
        DateTime(2026, 7, 6, 8, 30),
        saat: FeedbackConfig.sabahSaat,
        dakika: FeedbackConfig.sabahDakika,
      );
      expect(sonraki, DateTime(2026, 7, 7, 8, 30));
    });
  });

  group('saatDakikaAyir (Phase 1)', () {
    test('akşam varsayılanı 1260 → (21, 0)', () {
      expect(NotificationService.saatDakikaAyir(1260), (21, 0));
    });

    test('sabah varsayılanı 510 → (8, 30)', () {
      expect(NotificationService.saatDakikaAyir(510), (8, 30));
    });

    test('gece yarısı 0 → (0, 0)', () {
      expect(NotificationService.saatDakikaAyir(0), (0, 0));
    });

    test('günün son dakikası 1439 → (23, 59)', () {
      expect(NotificationService.saatDakikaAyir(1439), (23, 59));
    });

    test('dakikayaCevir saatDakikaAyir\'ın tersidir', () {
      expect(NotificationService.dakikayaCevir(21, 0), 1260);
      expect(NotificationService.dakikayaCevir(8, 30), 510);
      expect(NotificationService.dakikayaCevir(0, 0), 0);
      // Round-trip: her gün-içi dakika kendine döner.
      for (final int dk in <int>[0, 510, 1260, 1439]) {
        final (int s, int d) = NotificationService.saatDakikaAyir(dk);
        expect(NotificationService.dakikayaCevir(s, d), dk);
      }
    });
  });

  group('bugunSansliSaatAni (Phase 3)', () {
    test('saat henüz gelmediyse bugün o saat:00 döner', () {
      final DateTime? ani = NotificationService.bugunSansliSaatAni(
        DateTime(2026, 7, 6, 9, 30),
        14,
      );
      expect(ani, DateTime(2026, 7, 6, 14));
    });

    test('saat geçtiyse null döner (yarına kaydırmaz)', () {
      final DateTime? ani = NotificationService.bugunSansliSaatAni(
        DateTime(2026, 7, 6, 15, 0),
        14,
      );
      expect(ani, isNull);
    });

    test('aynı saat ama dakika geçmişse null döner', () {
      // 14:30'dayız, şanslı saat 14:00 → başlangıç geçti.
      final DateTime? ani = NotificationService.bugunSansliSaatAni(
        DateTime(2026, 7, 6, 14, 30),
        14,
      );
      expect(ani, isNull);
    });
  });

  group('sansliSaatMetni (Phase 3)', () {
    test('deterministik: aynı gün aynı metin', () {
      final DateTime gun = DateTime(2026, 7, 6);
      expect(
        NotificationService.sansliSaatMetni(gun),
        NotificationService.sansliSaatMetni(gun),
      );
    });

    test('seçim her zaman varyasyon listesinden gelir', () {
      for (int i = 0; i < 30; i++) {
        final String metin =
            NotificationService.sansliSaatMetni(DateTime(2026, 7, 1 + i));
        expect(TrStrings.sansliSaatBildirimVaryasyonlari, contains(metin));
      }
    });
  });

  group('sabahMetni (plan madde 3)', () {
    test('en az 10 varyasyon tanımlı', () {
      expect(
        TrStrings.sabahBildirimVaryasyonlari.length,
        greaterThanOrEqualTo(10),
      );
    });

    test('deterministik: aynı gün aynı metin', () {
      final DateTime gun = DateTime(2026, 7, 6);
      expect(
        NotificationService.sabahMetni(gun),
        NotificationService.sabahMetni(gun),
      );
    });

    test('seçim her zaman varyasyon listesinden gelir', () {
      for (int i = 0; i < 30; i++) {
        final String metin =
            NotificationService.sabahMetni(DateTime(2026, 7, 1 + i));
        expect(TrStrings.sabahBildirimVaryasyonlari, contains(metin));
      }
    });

    test('30 günde birden fazla farklı varyasyon kullanılır', () {
      final Set<String> metinler = <String>{
        for (int i = 0; i < 30; i++)
          NotificationService.sabahMetni(DateTime(2026, 7, 1 + i)),
      };
      expect(metinler.length, greaterThan(3));
    });
  });
}
