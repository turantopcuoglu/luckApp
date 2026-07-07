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
