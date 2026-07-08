import 'sans_rengi.dart';

/// Bir gün için üretilen tam metinsel içerik paketi.
///
/// Sayısal sonuç [LuckResult]'ta yaşar; bu sınıf yalnızca ondan ve
/// deterministik tohumdan türetilen, persist edilmeyen metinleri taşır.
class GununIcerigi {
  /// Tüm alanlarıyla bir içerik paketi oluşturur.
  const GununIcerigi({
    required this.yorum,
    required this.sansRengi,
    required this.sansliSayi,
    required this.tavsiye,
  });

  /// Üç cümlelik günlük fal yorumu (açılış + orta + kapanış).
  final String yorum;

  /// Günün şans rengi.
  final SansRengi sansRengi;

  /// Günün şanslı sayısı (1..99).
  final int sansliSayi;

  /// Günün tavsiyesi (yorumdan bağımsız tek cümle).
  final String tavsiye;

  @override
  bool operator ==(Object other) =>
      other is GununIcerigi &&
      other.yorum == yorum &&
      other.sansRengi == sansRengi &&
      other.sansliSayi == sansliSayi &&
      other.tavsiye == tavsiye;

  @override
  int get hashCode => Object.hash(yorum, sansRengi, sansliSayi, tavsiye);
}
