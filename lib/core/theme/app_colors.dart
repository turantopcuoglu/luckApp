import 'package:flutter/material.dart';

/// Uygulamanın renk paleti.
///
/// Tüm renkler burada tanımlanır; widget'lar içinde ham hex değeri
/// kullanmak yasaktır (bkz. CLAUDE.md kural 6).
abstract final class AppColors {
  /// Modern Tesadüf ana koyu zemini.
  static const Color ink = Color(0xFF07162F);

  /// Koyu kart yüzeyi.
  static const Color inkSurface = Color(0xFF10213B);

  /// Açık ekran zemini.
  static const Color warmCream = Color(0xFFF7F0E5);

  /// Açık kart yüzeyi.
  static const Color creamSurface = Color(0xFFFFF9F0);

  /// Ana eylem vurgusu; üstünde ink metin kullanılır.
  static const Color electricLime = Color(0xFFD8F04A);

  /// Sıcak vurgu; açık zeminde küçük metin olarak kullanılmaz.
  static const Color warmCoral = Color(0xFFFF8B73);

  /// İkincil vurgu yüzeyi.
  static const Color iris = Color(0xFF9B8AF2);

  /// Sakin vurgu yüzeyi.
  static const Color iceBlue = Color(0xFFBFE5F2);

  /// İnce folyo ve mühür vurgusu; ana eylem rengi değildir.
  static const Color softGold = Color(0xFFD3A953);

  /// Lacivert üstünde ana metin.
  static const Color textOnInk = Color(0xFFF8F2E8);

  /// Krem üstünde ana metin.
  static const Color textOnCream = Color(0xFF12203A);

  /// Krem üstünde AA kontrastlı ikincil metin (en az 5.27:1).
  static const Color mutedOnCream = Color(0xFF596477);

  /// Lacivert üstünde ikincil metin.
  static const Color mutedOnInk = Color(0xFFAEBBCD);

  /// Açık yüzeyde kontrol sınırı ve klavye odağı.
  static const Color outlineOnCream = Color(0xFF687181);

  /// Koyu yüzeyde kontrol sınırı ve klavye odağı.
  static const Color outlineOnInk = Color(0xFF7F90A9);

  /// Açık kartlar arasında yalnız dekoratif ayırıcı.
  static const Color dividerOnCream = Color(0xFFDED6C9);

  /// Koyu kartlar arasında yalnız dekoratif ayırıcı.
  static const Color dividerOnInk = Color(0xFF31425C);

  /// Açık zeminde hata metni.
  static const Color errorOnCream = Color(0xFFB53838);

  /// Koyu zeminde hata metni.
  static const Color errorOnInk = Color(0xFFFFB4AB);

  // Eski ekranlar kendi fazlarında taşınana kadar uyumluluk adları.
  /// Derin lacivert zemin rengi.
  static const Color background = ink;

  /// Zeminden bir tık açık yüzey rengi (kartlar, sheet'ler).
  static const Color surface = inkSurface;

  /// Altın vurgu rengi — skor halkası, CTA butonları.
  static const Color gold = softGold;

  /// Altının açık tonu — skor halkası gradient'inin bitiş rengi.
  static const Color goldAcik = Color(0xFFFFE9B8);

  /// Soft mor ikincil vurgu — modifiyer etiketleri, ikincil butonlar.
  static const Color purple = iris;

  /// Ana metin rengi.
  static const Color textPrimary = textOnInk;

  /// İkincil (soluk) metin rengi.
  static const Color textSecondary = mutedOnInk;

  /// Hata durumları.
  static const Color error = errorOnInk;
}
