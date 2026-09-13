import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kader/features/daily_luck/reveal_controller.dart';

/// Yerleşim testlerinin FakeAsync bölgesinde disk I/O'su beklenmez.
/// Gerçek kalıcılık reveal_controller_test.dart içinde Hive ile test edilir.
final Override layoutOnlyRevealWriter = revealWriterProvider.overrideWithValue(
  (DateTime day, DateTime time) async {},
);
