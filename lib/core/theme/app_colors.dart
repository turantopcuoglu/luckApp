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

  /// Işık dikişi ve kıvılcımların sıcak beyaz çekirdeği.
  static const Color isikCekirdegi = Color(0xFFFFF8E6);

  /// Cam kart yüzeyi: [surface] rengi %72 opak (sahne arkadan sezilir).
  static const Color camYuzey = Color(0xB8131A2E);

  /// Cam kart kenarı: [gold] rengi %22 opak.
  static const Color camKenar = Color(0x38F4C95D);

  /// Kart kanatlarının döndükçe kararan gölge rengi.
  static const Color golge = Color(0xFF000000);

  // ---- Skor sahnesi vurguları (ışık şeritleri, hale) ----

  /// Yüksek skor sahnesinin turkuaz ışığı.
  static const Color sahneYuksek = Color(0xFF6FE6DA);

  /// Orta skor sahnesinin altın ışığı.
  static const Color sahneOrta = Color(0xFFFFD27A);

  /// Düşük skor sahnesinin lavanta ışığı.
  static const Color sahneDusuk = Color(0xFFC3B2F5);

  // ---- Kategori karo renkleri ----

  /// Aşk kategorisi (pembe).
  static const Color kategoriAsk = Color(0xFFEC7BA6);

  /// Para kategorisi (sıcak altın).
  static const Color kategoriPara = Color(0xFFE8B957);

  /// Sağlık kategorisi (yeşil).
  static const Color kategoriSaglik = Color(0xFF72C98F);

  /// Sosyal kategorisi (mavi).
  static const Color kategoriSosyal = Color(0xFF6AAEEA);

  /// Risk kategorisi (turuncu).
  static const Color kategoriRisk = Color(0xFFF29A52);
}
