import 'dart:ui';

import '../../core/content/content_config.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_images.dart';

/// Kart açılınca arka plana gelen sahne: skor bandına göre üç ton.
///
/// Bant eşikleri [SkorBandi]'ndan gelir (içerik tonu ile görsel ton
/// aynı kalsın diye ayrı eşik tanımlanmaz). Seçim skordan saf olarak
/// türer: aynı skor her zaman aynı sahneyi verir.
enum SkorSahnesi {
  /// 60 ve üstü: turkuaz ışıkla açılmış kapılar.
  yuksek(gorsel: AppImages.sahneYuksek, vurgu: AppColors.sahneYuksek),

  /// 40..59: altın kemer ardında gün doğumu.
  orta(gorsel: AppImages.sahneOrta, vurgu: AppColors.sahneOrta),

  /// 39 ve altı: lavanta ışıklı, sakin kapılar.
  dusuk(gorsel: AppImages.sahneDusuk, vurgu: AppColors.sahneDusuk);

  const SkorSahnesi({required this.gorsel, required this.vurgu});

  /// Sahnenin tam ekran arka plan görseli (asset yolu).
  final String gorsel;

  /// Işık şeritleri, kıvılcımlar ve skor halesinin rengi.
  final Color vurgu;

  /// [skor] (0-100) için sahneyi döndürür.
  static SkorSahnesi skordan(int skor) => switch (SkorBandi.bandiBul(skor)) {
    SkorBandi.cokYuksek || SkorBandi.yuksek => SkorSahnesi.yuksek,
    SkorBandi.orta => SkorSahnesi.orta,
    SkorBandi.dusuk || SkorBandi.cokDusuk => SkorSahnesi.dusuk,
  };
}
