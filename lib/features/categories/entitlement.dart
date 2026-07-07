import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/luck_engine/luck_engine.dart';
import 'categories_config.dart';

/// Premium yetki durumu — TEK doğruluk noktası (plan Session 9,
/// madde 3).
///
/// Şimdilik sabit false: satın alma entegrasyonu yok. RevenueCat
/// bağlanınca YALNIZCA bu provider'ın gövdesi değişecek; kilit
/// kontrolü yapan hiçbir widget'a dokunulmayacak.
final StateProvider<bool> entitlementProvider =
    StateProvider<bool>((Ref ref) => false);

/// [kategori] şu an kilitli mi? (kilitli listede + premium değil).
final ProviderFamily<bool, LuckCategory> kategoriKilitliProvider =
    Provider.family<bool, LuckCategory>(
  (Ref ref, LuckCategory kategori) =>
      CategoriesConfig.kilitliKategoriler.contains(kategori) &&
      !ref.watch(entitlementProvider),
);
