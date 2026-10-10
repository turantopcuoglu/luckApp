import 'package:flutter_test/flutter_test.dart';
import 'package:kader/features/feedback/feedback_config.dart';
import 'package:kader/features/feedback/notification_service.dart';
import 'package:kader/l10n/app_localizations.dart';
import 'package:kader/l10n/app_localizations_en.dart';

import '../test_ortami.dart';

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
    final AppLocalizations en = AppLocalizationsEn();

    test('en az 10 varyasyon tanımlı', () {
      expect(
        NotificationService.sabahVaryasyonlari(trMetinler).length,
        greaterThanOrEqualTo(10),
      );
    });

    test('deterministik: aynı gün aynı metin', () {
      final DateTime gun = DateTime(2026, 7, 6);
      expect(
        NotificationService.sabahMetni(gun, trMetinler),
        NotificationService.sabahMetni(gun, trMetinler),
      );
    });

    test('seçim her zaman varyasyon listesinden gelir', () {
      for (int i = 0; i < 30; i++) {
        final String metin = NotificationService.sabahMetni(
          DateTime(2026, 7, 1 + i),
          trMetinler,
        );
        expect(
          NotificationService.sabahVaryasyonlari(trMetinler),
          contains(metin),
        );
      }
    });

    test('30 günde birden fazla farklı varyasyon kullanılır', () {
      final Set<String> metinler = <String>{
        for (int i = 0; i < 30; i++)
          NotificationService.sabahMetni(DateTime(2026, 7, 1 + i), trMetinler),
      };
      expect(metinler.length, greaterThan(3));
    });

    test('Türkçe sıra ARB taşımasından önceki listeyle aynı (E5)', () {
      final List<String> tr = NotificationService.sabahVaryasyonlari(
        trMetinler,
      );
      expect(tr.length, 12);
      expect(tr.first, 'Bugünün kaderi hazır ✨');
      expect(tr[7], 'Skorun hazır. Cesaret edebilecek misin? 😏');
      expect(tr.last, 'Şans perileri mesaini tamamladı, rapor hazır 🧚');
    });

    test('iki dilde aynı gün aynı varyasyon indeksi seçilir', () {
      final List<String> tr = NotificationService.sabahVaryasyonlari(
        trMetinler,
      );
      final List<String> ing = NotificationService.sabahVaryasyonlari(en);
      expect(ing.length, tr.length);
      for (int i = 0; i < 30; i++) {
        final DateTime gun = DateTime(2026, 7, 1 + i);
        expect(
          ing.indexOf(NotificationService.sabahMetni(gun, en)),
          tr.indexOf(NotificationService.sabahMetni(gun, trMetinler)),
          reason: '$gun',
        );
      }
    });
  });
}
