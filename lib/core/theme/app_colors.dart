import 'package:flutter/material.dart';

/// Uygulamanın renk paleti.
///
/// Tüm renkler burada tanımlanır; widget'lar içinde ham hex değeri
/// kullanmak yasaktır (bkz. CLAUDE.md kural 6).
abstract final class AppColors {
  /// Derin lacivert zemin rengi.
  static const Color background = Color(0xFF0A0E1A);

  /// Zeminden bir tık açık yüzey rengi (kartlar, sheet'ler).
  static const Color surface = Color(0xFF131A2E);

  /// Altın vurgu rengi — skor halkası, CTA butonları.
  static const Color gold = Color(0xFFF4C95D);

  /// Altının açık tonu — skor halkası gradient'inin bitiş rengi.
  static const Color goldAcik = Color(0xFFFFE9B8);

  /// Soft mor ikincil vurgu — modifiyer etiketleri, ikincil butonlar.
  static const Color purple = Color(0xFF8B7EC8);

  /// Ana metin rengi.
  static const Color textPrimary = Color(0xFFF2F3F7);

  /// İkincil (soluk) metin rengi.
  static const Color textSecondary = Color(0xFF9AA1B5);

  /// Hata durumları.
  static const Color error = Color(0xFFE57373);
}
