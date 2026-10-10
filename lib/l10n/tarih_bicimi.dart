import 'package:intl/intl.dart';

import 'app_localizations.dart';

/// [gun] için arayüz dilinde tam tarih metni üretir.
///
/// Türkçe: "6 Temmuz 2026, Pazartesi"; İngilizce: "Monday, July 6, 2026".
/// Desen ARB'deki `tarihDeseni`dir. Ay ve gün adları `intl` tarih
/// verisinden gelir; bu veri `GlobalMaterialLocalizations` yüklenince
/// hazırdır (widget dışı testlerde `initializeDateFormatting` gerekir).
String tarihMetni(AppLocalizations metinler, DateTime gun) =>
    DateFormat(metinler.tarihDeseni, metinler.localeName).format(gun);

/// [gun] için haftanın günü olmadan kısa tarih metni üretir.
///
/// Türkçe: "6 Temmuz 2026"; İngilizce: "July 6, 2026" (desen
/// `kisaTarihDeseni`).
String kisaTarihMetni(AppLocalizations metinler, DateTime gun) =>
    DateFormat(metinler.kisaTarihDeseni, metinler.localeName).format(gun);
