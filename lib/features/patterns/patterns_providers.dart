import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/history/patterns_analyzer.dart';
import '../../core/history/patterns_summary.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../history/history_providers.dart';

/// FAZ 13'te doğrulanmış ve saklanmış ilk paylaşım olayına bağlanacak giriş.
/// Şimdilik kanıt yoktur; paylaşım menüsünü açmak başarı kabul edilmez.
final Provider<DateTime?> firstShareEvidenceProvider = Provider<DateTime?>(
  (Ref ref) => null,
);

/// Hive kayıt akışı ve gün değişikliklerini izleyen yeni Desenlerim özeti.
/// Eski kanıt yüzdesi sağlayıcılarını tüketmez; skor motorunu çalıştırmaz.
final AutoDisposeProvider<PatternsSummary> patternsSummaryProvider =
    Provider.autoDispose<PatternsSummary>(
      (Ref ref) => analyzePatterns(
        ref.watch(tumKayitlarProvider),
        today: ref.watch(bugunProvider),
        firstSharedAt: ref.watch(firstShareEvidenceProvider),
      ),
    );
