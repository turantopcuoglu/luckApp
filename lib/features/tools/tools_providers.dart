import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Metin paylaşma fonksiyonu (testlerde sahtesiyle değiştirilir).
///
/// Keşfet sonuçları, sistem paylaşım menüsüne düz metin olarak verilir.
final Provider<Future<void> Function(String)> metinPaylasProvider =
    Provider<Future<void> Function(String)>(
      (Ref ref) =>
          (String metin) async => Share.share(metin),
    );
