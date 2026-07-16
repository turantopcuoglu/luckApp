import 'package:flutter/material.dart';

import '../../core/content/content_config.dart';
import '../../core/history/history_analiz_config.dart';
import '../../core/theme/app_colors.dart';

/// Geçmiş ekranı ve heatmap'inin görsel sabitleri.
///
/// Magic number/renk yasağı (kural 6) gereği hücre ölçüleri, pencere
/// uzunluğu ve bant→renk rampası burada tanımlıdır. Saf analiz eşiği
/// tek kaynaktan ([HistoryAnalizConfig]) re-export edilir.
abstract final class HistoryConfig {
  /// Heatmap hücresinin kenar uzunluğu.
  static const double hucreBoyutu = 14;

  /// Heatmap hücreleri arası boşluk.
  static const double hucreAraligi = 3;

  /// Heatmap'in kapsadığı gün sayısı (16 hafta).
  static const int pencereGunu = 112;

  /// Kanıt yüzdesi için gereken en az örnek (saf eşikten re-export).
  static const int enAzKanitGunu = HistoryAnalizConfig.enAzKanitGunu;

  // ---- Bant → renk rampası (navy → mor → altın) ----
  // Color.lerp const değildir; rampa adımları elle seçilmiş sabit
  // renklerdir. surface/purple/goldAcik mevcut temadan gelir, aradaki
  // iki adım (koyu-navy ve amber) yalnız heatmap için tanımlanır.

  /// Kayıtsız (ama pencere içindeki) günün rengi.
  static const Color bosGunRengi = AppColors.surface;

  /// "Çok düşük" bandın rengi: temadan bir tık açık derin navy.
  static const Color _cokDusukRengi = Color(0xFF1E2540);

  /// "Düşük" bandın rengi: mat mor.
  static const Color _dusukRengi = Color(0xFF4C4373);

  /// "Yüksek" bandın rengi: mor ile altın arası amber.
  static const Color _yuksekRengi = Color(0xFFC9A24B);

  /// Skor bandından heatmap hücre rengine eşleme.
  static const Map<SkorBandi, Color> bandRampasi = <SkorBandi, Color>{
    SkorBandi.cokDusuk: _cokDusukRengi,
    SkorBandi.dusuk: _dusukRengi,
    SkorBandi.orta: AppColors.purple,
    SkorBandi.yuksek: _yuksekRengi,
    SkorBandi.cokYuksek: AppColors.goldAcik,
  };
}
