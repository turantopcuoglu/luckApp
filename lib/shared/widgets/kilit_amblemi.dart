import 'package:flutter/material.dart';

import 'app_images.dart';

/// Altın asma kilit amblemi ([AppImages.kilit]): kilitli kategori
/// karoları, kilitli rapor bölümleri ve kilit pencereleri ortak kullanır.
///
/// Ekran okuyucu için [etiket] okunur (varsayılan "Kilitli").
class KilitAmblemi extends StatelessWidget {
  /// [boyut] kenarlı kilit amblemi.
  const KilitAmblemi({required this.boyut, this.etiket = 'Kilitli', super.key});

  /// Kenar uzunluğu.
  final double boyut;

  /// Erişilebilirlik etiketi.
  final String etiket;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: etiket,
      image: true,
      child: Image.asset(
        AppImages.kilit,
        width: boyut,
        height: boyut,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}
