import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ana kabuğun sekmeleri (sıra = gezinme çubuğundaki sıra).
enum AnaSekme {
  /// Günlük kader.
  bugun(
    etiket: 'Bugün',
    ikon: Icons.wb_sunny_outlined,
    seciliIkon: Icons.wb_sunny_rounded,
  ),

  /// Kader Profili.
  profil(
    etiket: 'Profilim',
    ikon: Icons.person_outline_rounded,
    seciliIkon: Icons.person_rounded,
  ),

  /// Uyum.
  uyum(
    etiket: 'Uyum',
    ikon: Icons.favorite_border_rounded,
    seciliIkon: Icons.favorite_rounded,
  ),

  /// Keşfet araçları (isim, numara, bebek ismi).
  kesfet(
    etiket: 'Keşfet',
    ikon: Icons.explore_outlined,
    seciliIkon: Icons.explore_rounded,
  ),

  /// Ayarlar.
  ayarlar(
    etiket: 'Ayarlar',
    ikon: Icons.settings_outlined,
    seciliIkon: Icons.settings_rounded,
  );

  const AnaSekme({
    required this.etiket,
    required this.ikon,
    required this.seciliIkon,
  });

  /// Gezinme çubuğu etiketi.
  final String etiket;

  /// Gezinme çubuğu ikonu (seçili değilken).
  final IconData ikon;

  /// Seçiliyken gösterilen dolu ikon.
  final IconData seciliIkon;
}

/// Seçili sekmenin indeksi.
///
/// Diğer ekranlar (ör. ana ekrandaki profil özeti) sekme değiştirmek
/// için bu provider'ı günceller.
final StateProvider<int> anaSekmeProvider =
    StateProvider<int>((Ref ref) => AnaSekme.bugun.index);
