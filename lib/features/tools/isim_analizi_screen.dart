import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/arac_okumalari.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_route.dart';
import '../premium/paywall_screen.dart';
import '../premium/premium_providers.dart';
import '../profile/kilitli_bolum_karti.dart';
import '../share/arac_story_card.dart';
import 'tools_providers.dart';

/// Hesaplanmak üzere gönderilen ad (null: henüz gönderilmedi).
final AutoDisposeStateProvider<String?> isimGirdisiProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);

/// Gönderilen adın analizi (harf yoksa null).
final AutoDisposeProvider<IsimAnalizi?> isimAnaliziProvider =
    Provider.autoDispose<IsimAnalizi?>((Ref ref) {
      final String? girdi = ref.watch(isimGirdisiProvider);
      return girdi == null ? null : IsimAnalizi.hesapla(girdi);
    });

/// İsim Analizi: herhangi bir adın sayıları ve (Premium) derin bölümleri.
class IsimAnaliziScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const IsimAnaliziScreen({super.key});

  @override
  ConsumerState<IsimAnaliziScreen> createState() => _IsimAnaliziScreenState();
}

class _IsimAnaliziScreenState extends ConsumerState<IsimAnaliziScreen> {
  final TextEditingController _ad = TextEditingController();

  @override
  void dispose() {
    _ad.dispose();
    super.dispose();
  }

  void _hesapla() {
    FocusScope.of(context).unfocus();
    ref.read(isimGirdisiProvider.notifier).state = _ad.text;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final String? girdi = ref.watch(isimGirdisiProvider);
    final IsimAnalizi? analiz = ref.watch(isimAnaliziProvider);
    final bool premium = ref.watch(entitlementProvider);
    final List<AracBolumu> bolumler = analiz == null
        ? const <AracBolumu>[]
        : isimOkumasi(analiz);

    return Scaffold(
      appBar: AppBar(title: Text(l.araclarIsimBaslik)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            TextField(
              controller: _ad,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _hesapla(),
              decoration: InputDecoration(
                labelText: l.araclarAdEtiketi,
                hintText: l.araclarAdIpucu,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _hesapla,
              child: Text(l.araclarHesapla),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (girdi != null && analiz == null)
              Text(
                l.araclarGecersiz,
                style: yazi.bodyMedium?.copyWith(color: AppColors.error),
              ),
            if (analiz != null) ...<Widget>[
              Text(analiz.tamAd, style: yazi.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              for (final AracBolumu b in bolumler)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: KilitliBolumKarti(
                    baslik: b.baslik,
                    metin: b.metin,
                    kilitli: b.premium && !premium,
                    onKilidiAc: () => unawaited(
                      Navigator.of(
                        context,
                      ).push(fadeThroughRoute<void>(const PaywallScreen())),
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () =>
                    unawaited(ref.read(aracPaylasProvider)(_paylasim(analiz, l))),
                icon: const Icon(Icons.ios_share_rounded),
                label: Text(l.araclarPaylas),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Kart: isim sayısı ve (ücretsiz) isim sayısı metni; etiketler [l]
  /// dilinde.
  AracPaylasimi _paylasim(IsimAnalizi analiz, AppLocalizations l) =>
      AracPaylasimi(
    ustEtiket: l.araclarIsimKartEtiketi,
    baslik: analiz.tamAd,
    sayi: '${analiz.isim.deger}',
    sayiEtiketi: l.araclarIsimSayisiEtiketi,
    metin: isimOkumasi(analiz).first.metin,
  );
}
