import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/history/gecmis_ozeti.dart';
import '../../core/storage/daily_record.dart';
import '../../core/storage/providers.dart';

/// Kutudaki tüm günlük kayıtlar (güne göre artan).
///
/// autoDispose: daily_records kutusu reaktif değildir; ekran her
/// açılışta taze okuma yapar (yeni feedback/skorlar yansır).
final AutoDisposeProvider<List<DailyRecord>> tumKayitlarProvider =
    Provider.autoDispose<List<DailyRecord>>(
  (Ref ref) => ref.watch(luckHistoryRepositoryProvider).tumKayitlar(),
);

/// Geçmiş kayıtlarından türetilen özet (heatmap üstü istatistikler +
/// Kanıt Döngüsü).
final AutoDisposeProvider<GecmisOzeti> gecmisOzetiProvider =
    Provider.autoDispose<GecmisOzeti>(
  (Ref ref) => gecmisiOzetle(ref.watch(tumKayitlarProvider)),
);
