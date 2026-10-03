import 'package:flutter/widgets.dart';

import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/gorsel_afis.dart';

/// Kişisel Yıl afişi: sağda yılın sahnesi (kemer içinde, yıl sayısına özgü
/// simge), solda koyu gökyüzüne yazılan [child] (sayı, lakap).
///
/// Yıl raporu başlığı ve ana ekrandaki tanıtım kartı ortak kullanır.
class YilAfisi extends StatelessWidget {
  /// [kisiselYil] (1-9) sahnesiyle afiş kurar.
  const YilAfisi({
    required this.kisiselYil,
    required this.child,
    this.yukseklik,
    super.key,
  });

  /// Kişisel yıl sayısı (1-9).
  final int kisiselYil;

  /// Sol taraftaki yazı içeriği.
  final Widget child;

  /// Sabit yükseklik (kart biçimi); null ise 3:2 oran.
  final double? yukseklik;

  @override
  Widget build(BuildContext context) => GorselAfis(
    gorsel: AppImages.yilAfisi(kisiselYil),
    yukseklik: yukseklik,
    child: child,
  );
}
