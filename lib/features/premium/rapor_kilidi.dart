import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/app_route.dart';
import 'magaza_servisi.dart';
import 'paywall_screen.dart';
import 'premium_config.dart';
import 'premium_kontrolcu.dart';
import 'premium_providers.dart';
import 'premium_strings.dart';

/// Numeroloji Raporu'nun kilitli bölümüne dokunulunca açılan seçenekler.
///
/// Döndürdüğü değer: rapor bu akışla açıldıysa true.
Future<bool> raporKilidiniGoster(BuildContext context) => _kilidiGoster(
  context,
  const _KilitIcerigi(
    urunId: PremiumConfig.raporUrunId,
    baslik: PremiumStrings.raporKilitBaslik,
    aciklama: PremiumStrings.raporKilitAciklama,
    premiumSecenegi: PremiumStrings.raporPremiumSecenegi,
  ),
);

/// [yil] Kişisel Yıl Raporu'nun kilitli bölümüne dokunulunca açılan
/// seçenekler.
///
/// Döndürdüğü değer: rapor bu akışla açıldıysa true.
Future<bool> yilRaporuKilidiniGoster(BuildContext context, int yil) =>
    _kilidiGoster(
      context,
      _KilitIcerigi(
        urunId: PremiumConfig.yilRaporuUrunId(yil),
        baslik: PremiumStrings.yilRaporuKilitBaslik(yil),
        aciklama: PremiumStrings.yilRaporuKilitAciklama,
        premiumSecenegi: PremiumStrings.yilRaporuPremiumSecenegi,
      ),
    );

Future<bool> _kilidiGoster(BuildContext context, _KilitIcerigi icerik) async {
  final bool? sonuc = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext _) => _TekSeferlikKilitSheet(icerik: icerik),
  );
  return sonuc ?? false;
}

/// Kilit sheet'inin ürüne özgü metinleri.
class _KilitIcerigi {
  const _KilitIcerigi({
    required this.urunId,
    required this.baslik,
    required this.aciklama,
    required this.premiumSecenegi,
  });

  final String urunId;
  final String baslik;
  final String aciklama;
  final String premiumSecenegi;
}

/// Tek seferlik bir raporun kilidi: ürünü fiyatıyla satın al ya da
/// Premium'a geç.
///
/// Ödüllü reklam seçeneği bilinçli olarak yoktur (bkz.
/// [raporAcikProvider]). Ürün açıldığında sheet kendiliğinden kapanır.
class _TekSeferlikKilitSheet extends ConsumerStatefulWidget {
  const _TekSeferlikKilitSheet({required this.icerik});

  final _KilitIcerigi icerik;

  @override
  ConsumerState<_TekSeferlikKilitSheet> createState() =>
      _TekSeferlikKilitSheetState();
}

class _TekSeferlikKilitSheetState
    extends ConsumerState<_TekSeferlikKilitSheet> {
  @override
  void initState() {
    super.initState();
    // Ürün açılışta yüklenemediyse (ör. ağ yoktu) burada yeniden denenir.
    final PremiumDurumu durum = ref.read(premiumKontrolcuProvider);
    if (!durum.tekSeferlikUrunler.containsKey(widget.icerik.urunId)) {
      unawaited(
        ref.read(premiumKontrolcuProvider.notifier).tekSeferlikUrunleriYukle(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final _KilitIcerigi icerik = widget.icerik;
    final PremiumDurumu durum = ref.watch(premiumKontrolcuProvider);
    final TekSeferlikUrun? urun = durum.tekSeferlikUrunler[icerik.urunId];

    ref.listen<bool>(tekSeferlikAcikProvider(icerik.urunId), (
      bool? eski,
      bool yeni,
    ) {
      if (yeni && !(eski ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(PremiumStrings.raporAcildi)),
        );
        Navigator.of(context).pop(true);
      }
    });

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Image.asset(
                AppImages.raporKitap,
                height: PaywallConfig.raporKitapBoyutu,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              icerik.baslik,
              style: yazi.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              icerik.aciklama,
              style: yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (durum.hataMesaji != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                durum.hataMesaji!,
                style: yazi.bodySmall?.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: urun == null || durum.islemde
                  ? null
                  : () => unawaited(
                      ref
                          .read(premiumKontrolcuProvider.notifier)
                          .tekSeferlikSatinAl(icerik.urunId),
                    ),
              child: durum.islemde
                  ? const SizedBox.square(
                      dimension: AppSpacing.md,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      urun == null
                          ? PremiumStrings.raporFiyatYukleniyor
                          : PremiumStrings.raporuSatinAl(urun.fiyatMetni),
                    ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                unawaited(
                  Navigator.of(
                    context,
                  ).push(fadeThroughRoute<void>(const PaywallScreen())),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.xxl),
                side: const BorderSide(color: AppColors.gold),
                foregroundColor: AppColors.gold,
              ),
              child: Text(icerik.premiumSecenegi),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              PremiumStrings.raporOdemeBilgisi,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
