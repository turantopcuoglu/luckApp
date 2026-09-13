import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/experience_dimension.dart';
import '../../core/luck_engine/luck_engine.dart';
import 'categories_config.dart';

/// Premium yetki durumu — TEK doğruluk noktası (plan Session 9,
/// madde 3).
///
/// Şimdilik sabit false: satın alma entegrasyonu yok. RevenueCat
/// bağlanınca YALNIZCA bu provider'ın gövdesi değişecek; kilit
/// kontrolü yapan hiçbir widget'a dokunulmayacak.
final StateProvider<bool> entitlementProvider = StateProvider<bool>(
  (Ref ref) => false,
);

/// Deneyim alanı, ortak premium yetkisine göre şu an kilitli mi?
final ProviderFamily<bool, ExperienceDimension> alanKilitliProvider =
    Provider.family<bool, ExperienceDimension>(
      (Ref ref, ExperienceDimension alan) =>
          CategoriesConfig.kilitliAlanlar.contains(alan) &&
          !ref.watch(entitlementProvider),
    );

/// Eski kategori çağrılarını aynı deneyim alanı kilit politikasına bağlar.
final ProviderFamily<bool, LuckCategory> kategoriKilitliProvider =
    Provider.family<bool, LuckCategory>(
      (Ref ref, LuckCategory kategori) => ref.watch(
        alanKilitliProvider(ExperienceDimension.kategoriden(kategori)),
      ),
    );
