import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kader/l10n/app_localizations.dart';
import 'package:kader/l10n/app_localizations_en.dart';
import 'package:kader/l10n/tarih_bicimi.dart';

import '../test_ortami.dart';

/// E5 öncesi `TrStrings.tarihMetni`'nin elle kurduğu biçim (D9: Türkçe
/// çıktı aynı kalmalı).
String _eskiTurkceTarih(DateTime gun) {
  const List<String> gunler = <String>[
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];
  const List<String> aylar = <String>[
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
  return '${gun.day} ${aylar[gun.month - 1]} ${gun.year}, '
      '${gunler[gun.weekday - 1]}';
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr');
    await initializeDateFormatting('en');
  });

  test('Türkçe tarih eski elle kurulan biçimle birebir aynı', () {
    final DateTime baslangic = DateTime(2026);
    for (int i = 0; i < 2 * 366; i++) {
      final DateTime gun = DateTime(
        baslangic.year,
        baslangic.month,
        baslangic.day + i,
      );
      expect(
        tarihMetni(trMetinler, gun),
        _eskiTurkceTarih(gun),
        reason: '$gun',
      );
      // Eski kısa biçim: tam metnin virgülden önceki kısmı.
      expect(
        kisaTarihMetni(trMetinler, gun),
        _eskiTurkceTarih(gun).split(',').first,
        reason: '$gun',
      );
    }
  });

  test('İngilizce tarih "Monday, July 6, 2026" biçiminde', () {
    final AppLocalizations en = AppLocalizationsEn();
    expect(tarihMetni(en, DateTime(2026, 7, 6)), 'Monday, July 6, 2026');
    expect(tarihMetni(en, DateTime(2027, 1, 1)), 'Friday, January 1, 2027');
    expect(kisaTarihMetni(en, DateTime(2026, 7, 6)), 'July 6, 2026');
  });
}
