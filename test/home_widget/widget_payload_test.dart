import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/features/home_widget/widget_payload.dart';
import 'package:kader/features/home_widget/widget_strings.dart';

void main() {
  group('widgetYuku', () {
    test('teaser çok cümleli yorumun ilk cümlesidir', () {
      final WidgetPayload y = widgetYuku(
        skor: 85,
        gun: DateTime(2026, 7, 6),
        yorum: 'Bugün rüzgâr arkanda. İkinci cümle. Üçüncü cümle.',
        dil: AppDil.tr,
      );
      expect(y.teaser, 'Bugün rüzgâr arkanda');
    });

    test('tek cümle + sondaki nokta kırpılır', () {
      final WidgetPayload y = widgetYuku(
        skor: 50,
        gun: DateTime(2026, 7, 6),
        yorum: 'Sakin bir gün seni bekliyor.',
        dil: AppDil.tr,
      );
      expect(y.teaser, 'Sakin bir gün seni bekliyor');
    });

    test('noktasız yorum olduğu gibi kullanılır', () {
      final WidgetPayload y = widgetYuku(
        skor: 50,
        gun: DateTime(2026, 7, 6),
        yorum: 'Noktasız kısa ipucu',
        dil: AppDil.tr,
      );
      expect(y.teaser, 'Noktasız kısa ipucu');
    });

    test('boş yorum yedek teaser verir (TR)', () {
      final WidgetPayload y = widgetYuku(
        skor: 10,
        gun: DateTime(2026, 7, 6),
        yorum: '   ',
        dil: AppDil.tr,
      );
      expect(y.teaser, WidgetStrings.yedekTeaser(AppDil.tr));
    });

    test('İngilizce dil: tarih ay adı ve yedek teaser İngilizce', () {
      final WidgetPayload y = widgetYuku(
        skor: 70,
        gun: DateTime(2026, 7, 6),
        yorum: '   ',
        dil: AppDil.en,
      );
      expect(y.tarih, '6 July');
      expect(y.teaser, WidgetStrings.yedekTeaser(AppDil.en));
    });

    test('tarih "gün Ay" biçiminde (TR)', () {
      final WidgetPayload y = widgetYuku(
        skor: 70,
        gun: DateTime(2026, 7, 6),
        yorum: 'x.',
        dil: AppDil.tr,
      );
      expect(y.tarih, '6 Temmuz');
    });

    test('skor değiştirilmeden taşınır', () {
      final WidgetPayload y = widgetYuku(
        skor: 92,
        gun: DateTime(2026, 12, 31),
        yorum: 'y.',
        dil: AppDil.tr,
      );
      expect(y.skor, 92);
      expect(y.tarih, '31 Aralık');
    });

    test('deterministik: aynı girdi aynı paketi verir', () {
      WidgetPayload uret() => widgetYuku(
        skor: 42,
        gun: DateTime(2026, 3, 15),
        yorum: 'Aynı cümle. Devamı.',
        dil: AppDil.tr,
      );
      expect(uret(), uret());
    });
  });
}
