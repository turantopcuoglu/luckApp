import '../daily_luck/tr_strings.dart';
import 'widget_strings.dart';

/// Ana ekran widget'ında gösterilecek veri paketi.
///
/// Saf Dart değer nesnesi (Flutter'sız); native tarafa yazılacak üç
/// alanı taşır. Sayısal skor saklanan sonuçtan gelir; teaser günün
/// yorumundan türetilir (persist edilmez, deterministik).
class WidgetPayload {
  /// Tüm alanlarıyla paket oluşturur.
  const WidgetPayload({
    required this.skor,
    required this.tarih,
    required this.teaser,
  });

  /// Günün genel skoru (0-100).
  final int skor;

  /// Biçimli kısa tarih ("6 Temmuz").
  final String tarih;

  /// Günün yorumundan alınan tek cümlelik kısa ipucu.
  final String teaser;

  @override
  bool operator ==(Object other) =>
      other is WidgetPayload &&
      other.skor == skor &&
      other.tarih == tarih &&
      other.teaser == teaser;

  @override
  int get hashCode => Object.hash(skor, tarih, teaser);
}

/// [skor], [gun] ve günün [yorum]'undan widget veri paketini üretir.
///
/// Teaser = yorumun ilk cümlesi (ilk `.`'e kadar); yorum boşsa
/// [WidgetStrings.yedekTeaser]. Deterministik: `DateTime.now()` yok,
/// aynı girdi her zaman aynı paketi verir.
WidgetPayload widgetYuku({
  required int skor,
  required DateTime gun,
  required String yorum,
}) {
  final String tarih = '${gun.day} ${TrStrings.ayAdlari[gun.month - 1]}';

  final String kirpik = yorum.trim();
  final int noktaIndeksi = kirpik.indexOf('.');
  final String teaser = kirpik.isEmpty
      ? WidgetStrings.yedekTeaser
      : (noktaIndeksi == -1 ? kirpik : kirpik.substring(0, noktaIndeksi))
            .trim();

  return WidgetPayload(skor: skor, tarih: tarih, teaser: teaser);
}
