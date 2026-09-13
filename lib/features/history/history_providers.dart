import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/history/aylik_ozet.dart';
import '../../core/history/gecmis_ozeti.dart';
import '../../core/storage/daily_record.dart';
import '../../core/storage/providers.dart';
import '../daily_luck/daily_luck_providers.dart';

/// Kutudaki tüm günlük kayıtlar (güne göre artan).
///
/// Hive değişiklikleri izlenir; ekran açıkken de yeni kayıt ve feedback yansır.
final AutoDisposeProvider<List<DailyRecord>> tumKayitlarProvider =
    Provider.autoDispose<List<DailyRecord>>((Ref ref) {
      ref.watch(kayitDegisiklikleriProvider);
      return ref.watch(luckHistoryRepositoryProvider).tumKayitlar();
    });

/// Geçmiş kayıtlarından türetilen özet (heatmap üstü istatistikler +
/// Kanıt Döngüsü).
final AutoDisposeProvider<GecmisOzeti> gecmisOzetiProvider =
    Provider.autoDispose<GecmisOzeti>(
      (Ref ref) => gecmisiOzetle(
        ref.watch(tumKayitlarProvider),
        // Güncel seri için "bugün" gerekir; testte sabit güne override edilir.
        bugun: ref.watch(bugunProvider),
      ),
    );

/// İçinde bulunulan ayın Şans Raporu özeti (Phase 4).
final AutoDisposeProvider<AylikOzet> buAyinOzetiProvider =
    Provider.autoDispose<AylikOzet>((Ref ref) {
      final DateTime bugun = ref.watch(bugunProvider);
      return aylikOzet(
        ref.watch(tumKayitlarProvider),
        yil: bugun.year,
        ay: bugun.month,
      );
    });
