import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/altin_buton.dart';
import '../../shared/widgets/cam_panel.dart';
import 'paylasim_temasi.dart';
import 'share_config.dart';
import 'share_service.dart';
import 'share_strings.dart';
import 'story_card.dart';

/// Paylaşım ekranında seçili tema.
final AutoDisposeStateProvider<PaylasimTemasi> paylasimTemasiProvider =
    StateProvider.autoDispose<PaylasimTemasi>(
      (Ref ref) => PaylasimTemasi.gece,
    );

/// Paylaşım ekranında "Skoru gizle" anahtarı.
final AutoDisposeStateProvider<bool> skoruGizleProvider =
    StateProvider.autoDispose<bool>((Ref ref) => false);

/// "Kartını paylaş" ekranı (mockup `9635f67f` 1. ekran): hikâye kartının
/// canlı önizlemesi, üç tema (Gece / Işık / Mor), "Skoru gizle" ve altın
/// "Paylaş" butonu. Paylaş, kartı seçilen ayarlarla PNG'ye çevirip
/// sistem paylaşım menüsünü açar.
class PaylasimScreen extends ConsumerWidget {
  /// Günün [sonuc]u ve kişisel [baslik]ı ile ekran kurar.
  const PaylasimScreen({required this.sonuc, this.baslik, super.key});

  /// Paylaşılacak günün sonucu.
  final LuckResult sonuc;

  /// Günün kişisel başlığı.
  final String? baslik;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final PaylasimTemasi tema = ref.watch(paylasimTemasiProvider);
    final bool gizle = ref.watch(skoruGizleProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(ShareStrings.kartiniPaylas)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            // Önizleme: gerçek kart, ekrana sığacak kadar küçültülmüş.
            Center(
              child: SizedBox(
                // Genişlik ekranın oranıyla, yükseklik de ekranın yarısıyla
                // sınırlı: seçenekler ilk bakışta görünsün.
                width: min(
                  MediaQuery.sizeOf(context).width *
                      ShareConfig.onizlemeGenislikOrani,
                  MediaQuery.sizeOf(context).height *
                      ShareConfig.onizlemeYukseklikOrani *
                      ShareConfig.kartBoyutu.width /
                      ShareConfig.kartBoyutu.height,
                ),
                child: AspectRatio(
                  aspectRatio:
                      ShareConfig.kartBoyutu.width /
                      ShareConfig.kartBoyutu.height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: FittedBox(
                        child: StoryCard(
                          sonuc: sonuc,
                          baslik: baslik,
                          skoruGizle: gizle,
                          arkaPlan: Image.asset(
                            tema.gorsel,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                for (final PaylasimTemasi t in PaylasimTemasi.values)
                  _TemaSecenegi(
                    tema: t,
                    secili: t == tema,
                    onTap: () =>
                        ref.read(paylasimTemasiProvider.notifier).state = t,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            CamPanel(
              dolgu: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(
                  Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                title: Text(ShareStrings.skoruGizle, style: yazi.bodyLarge),
                value: gizle,
                activeThumbColor: AppColors.gold,
                onChanged: (bool yeni) =>
                    ref.read(skoruGizleProvider.notifier).state = yeni,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AltinButon(
              genislik: null,
              metin: ShareStrings.paylas,
              basIkon: Icons.ios_share,
              onPressed: () => unawaited(
                ref
                    .read(shareServiceProvider)
                    .paylas(
                      sonuc: sonuc,
                      baslik: baslik,
                      tema: tema,
                      skoruGizle: gizle,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ShareStrings.paylasimMenusunuAcar,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tema küçük resmi + adı; seçiliyse altın kenar ve onay rozeti.
class _TemaSecenegi extends StatelessWidget {
  const _TemaSecenegi({
    required this.tema,
    required this.secili,
    required this.onTap,
  });

  final PaylasimTemasi tema;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: secili,
      label: ShareStrings.temaSecimi(tema.etiket),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: ShareConfig.temaKucukGenislik,
                  height: ShareConfig.temaKucukYukseklik,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: secili ? AppColors.gold : AppColors.surface,
                      width: secili ? 2 : 1,
                    ),
                    image: DecorationImage(
                      image: AssetImage(tema.gorsel),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (secili)
                  const Positioned(
                    right: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.gold,
                      size: ShareConfig.temaRozetBoyutu,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ExcludeSemantics(
              child: Text(
                tema.etiket,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: secili ? AppColors.goldAcik : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
