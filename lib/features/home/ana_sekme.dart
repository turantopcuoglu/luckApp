import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ana kabuğun sekmeleri (sıra = gezinme çubuğundaki sıra).
enum AnaSekme {
  /// Günlük kader.
  bugun(etiket: 'Bugün', ikon: Icons.auto_awesome_outlined),

  /// Kader Profili.
  profil(etiket: 'Profilim', ikon: Icons.person_outline_rounded),

  /// Uyum.
  uyum(etiket: 'Uyum', ikon: Icons.favorite_border_rounded),

  /// Keşfet araçları (isim, numara, bebek ismi).
  kesfet(etiket: 'Keşfet', ikon: Icons.explore_outlined),

  /// Ayarlar.
  ayarlar(etiket: 'Ayarlar', ikon: Icons.settings_outlined);

  const AnaSekme({required this.etiket, required this.ikon});

  /// Gezinme çubuğu etiketi.
  final String etiket;

  /// Gezinme çubuğu ikonu.
  final IconData ikon;
}

/// Seçili sekmenin indeksi.
///
/// Diğer ekranlar (ör. ana ekrandaki profil özeti) sekme değiştirmek
/// için bu provider'ı günceller.
final StateProvider<int> anaSekmeProvider =
    StateProvider<int>((Ref ref) => AnaSekme.bugun.index);
