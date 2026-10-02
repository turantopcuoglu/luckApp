import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../share/arac_story_card.dart';
import '../share/share_service.dart';

/// Keşfet sonucunu paylaşma fonksiyonu (testlerde sahtesiyle değiştirilir).
///
/// Araç ekranı neyin paylaşılacağını [AracPaylasimi] ile tarif eder;
/// varsayılan uygulama story kartını PNG olarak çizip sistem paylaşım
/// menüsüne verir.
final Provider<Future<void> Function(AracPaylasimi)> aracPaylasProvider =
    Provider<Future<void> Function(AracPaylasimi)>(
      (Ref ref) => ref.read(shareServiceProvider).aracPaylas,
    );
