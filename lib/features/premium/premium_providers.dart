import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/providers.dart';
import '../ads/ads_providers.dart';
import '../daily_luck/daily_luck_providers.dart';
import 'premium_config.dart';
import 'premium_kontrolcu.dart';

/// Premium yetki durumu — kilit kontrollerinin TEK doğruluk noktası.
///
/// Kilit kontrolü yapan widget'lar yalnızca bunu (veya aşağıdaki türev
/// provider'ları) dinler; mağaza ayrıntılarını bilmez.
final Provider<bool> entitlementProvider = Provider<bool>(
  (Ref ref) => ref.watch(premiumKontrolcuProvider).aktif,
);

/// Premium olmadan kilitli görünen kategoriler.
const Set<LuckCategory> kilitliKategoriler = <LuckCategory>{
  LuckCategory.ask,
  LuckCategory.para,
};

/// Ödüllü reklamla açılabilen içeriklerin gün bazlı kilit anahtarları.
abstract final class KilitAnahtarlari {
  /// [kategori] detay/kutusu.
  static String kategori(LuckCategory kategori) => 'kategori:${kategori.name}';

  /// Kader Profili'nin premium bölümleri.
  static const String profil = 'profil';
}

/// [anahtar] içeriği bugün reklamla açılmış mı?
final ProviderFamily<bool, String> reklamKilidiAcikProvider =
    Provider.family<bool, String>(
      (Ref ref, String anahtar) => ref
          .watch(luckHistoryRepositoryProvider)
          .reklamKilidiAcikMi(ref.watch(bugunProvider), anahtar),
    );

/// [kategori] şu an kilitli mi? (kilitli listede + premium değil +
/// bugün reklamla açılmamış).
final ProviderFamily<bool, LuckCategory> kategoriKilitliProvider =
    Provider.family<bool, LuckCategory>(
      (Ref ref, LuckCategory kategori) =>
          kilitliKategoriler.contains(kategori) &&
          !ref.watch(entitlementProvider) &&
          !ref.watch(
            reklamKilidiAcikProvider(KilitAnahtarlari.kategori(kategori)),
          ),
    );

/// Profilin premium bölümleri şu an kilitli mi?
final Provider<bool> profilKilitliProvider = Provider<bool>(
  (Ref ref) =>
      !ref.watch(entitlementProvider) &&
      !ref.watch(reklamKilidiAcikProvider(KilitAnahtarlari.profil)),
);

/// [urunId] tek seferlik ürününün içeriği açık mı? (Premium ya da o
/// ürünün satın alımı).
///
/// Ödüllü reklamla AÇILMAZ: raporlar ayrı satılan ürünlerdir; günlük
/// reklam kilidi onları değersizleştirirdi.
final ProviderFamily<bool, String> tekSeferlikAcikProvider =
    Provider.family<bool, String>(
      (Ref ref, String urunId) =>
          ref.watch(entitlementProvider) ||
          ref.watch(
            premiumKontrolcuProvider.select(
              (PremiumDurumu d) => d.sahipMi(urunId),
            ),
          ),
    );

/// Numeroloji Raporu'nun tamamı açık mı?
final Provider<bool> raporAcikProvider = Provider<bool>(
  (Ref ref) => ref.watch(tekSeferlikAcikProvider(PremiumConfig.raporUrunId)),
);

/// [yil] Kişisel Yıl Raporu'nun tamamı açık mı?
final ProviderFamily<bool, int> yilRaporuAcikProvider =
    Provider.family<bool, int>(
      (Ref ref, int yil) => ref.watch(
        tekSeferlikAcikProvider(PremiumConfig.yilRaporuUrunId(yil)),
      ),
    );

/// Numeroloji Raporu'nun premium bölümleri şu an kilitli mi?
final Provider<bool> raporKilitliProvider = Provider<bool>(
  (Ref ref) => !ref.watch(raporAcikProvider),
);

/// Banner reklam gösterilebilir mi? (premium değil + SDK hazır)
final Provider<bool> bannerGosterilebilirProvider = Provider<bool>(
  (Ref ref) =>
      !ref.watch(entitlementProvider) && ref.watch(reklamHazirProvider),
);

/// Bugün reklamla bir içerik açıldığında ilgili provider'ları tazeler.
void kilitleriTazele(WidgetRef ref) => ref.invalidate(reklamKilidiAcikProvider);
