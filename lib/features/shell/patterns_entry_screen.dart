import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/content/rare_sign_id.dart';
import '../../core/history/rare_sign_progress.dart';
import '../../core/localization/app_dil.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/cosmic_config.dart';
import '../../shared/widgets/app_illustrations.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/cosmic_page.dart';
import '../collection/collection_config.dart';
import '../collection/collection_screen.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../history/history_screen.dart';
import '../patterns/patterns_providers.dart';
import '../patterns/patterns_strings.dart';
import 'shell_strings.dart';

/// Gerçek geçmişin uygunluk koşullarıyla beslenen on iki sahnelik koleksiyon.
class PatternsEntryScreen extends ConsumerWidget {
  /// Günlük kayıtlar ayrı rotada korunur; sahte ödül veya ilerleme üretmez.
  const PatternsEntryScreen({super.key});

  void _details(BuildContext context, RareSignProgress sign, AppDil language) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF06182A),
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: CollectionConfig.sceneDetailHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.asset(
                    AppIllustrations.rareSignAssets[sign.id]!,
                    fit: BoxFit.contain,
                    cacheWidth: CollectionConfig.sceneDetailWidth,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                PatternsStrings.rareTitle(sign.id, language),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                PatternsStrings.rareCondition(sign, language),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                !sign.evidenceAvailable
                    ? language.sec(
                        'Paylaşım doğrulaması henüz bağlı değil.',
                        'Share verification is not connected yet.',
                      )
                    : sign.isUnlocked
                    ? language.sec('Koleksiyonunda', 'In your collection')
                    : '${sign.current} / ${sign.target}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppDil language = ref.watch(dilProvider);
    final List<RareSignProgress> signs = ref
        .watch(patternsSummaryProvider)
        .rareSigns;
    final List<RareSignProgress> unlocked = signs
        .where((s) => s.isUnlocked)
        .toList();
    final RareSignProgress hero =
        unlocked.where((s) => s.id == RareSignId.sessizTohum).firstOrNull ??
        unlocked.lastOrNull ??
        signs.first;
    final bool largeText =
        MediaQuery.textScalerOf(context).scale(16) >
        CollectionConfig.largeTextThreshold;
    final TextTheme text = Theme.of(context).textTheme;
    return CosmicPage(
      appBar: AppBar(
        title: Text(ShellStrings.patterns(language)),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: Text(
                '${unlocked.length} / ${signs.length}',
                style: text.bodyMedium,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    Semantics(
                      button: true,
                      label: PatternsStrings.rareTitle(hero.id, language),
                      child: GestureDetector(
                        onTap: () => _details(context, hero, language),
                        child: Container(
                          height: CollectionConfig.sceneHeroHeight,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: CosmicConfig.cyan.withValues(alpha: .55),
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Image.asset(
                                AppIllustrations.rareSignAssets[hero.id]!,
                                fit: BoxFit.cover,
                                alignment: const Alignment(0, -.2),
                                cacheWidth: CosmicConfig.sceneDecodeWidth(
                                  MediaQuery.sizeOf(context).width,
                                  MediaQuery.devicePixelRatioOf(context),
                                ),
                                excludeFromSemantics: true,
                              ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      Colors.transparent,
                                      Color(0xF2031020),
                                    ],
                                    stops: <double>[.5, 1],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0xCC08253C),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      hero.isUnlocked
                                          ? language.sec('Nadir', 'Rare')
                                          : language.sec(
                                              'Sıradaki kart',
                                              'Next card',
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Text(
                                    PatternsStrings.rareTitle(
                                      hero.id,
                                      language,
                                    ),
                                    textAlign: TextAlign.center,
                                    style: text.headlineSmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      PatternsStrings.rareCondition(hero, language),
                      textAlign: TextAlign.center,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverGrid.builder(
                itemCount: signs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: largeText
                      ? CollectionConfig.buyukYaziSutunSayisi
                      : CollectionConfig.sutunSayisi,
                  mainAxisExtent: largeText
                      ? CollectionConfig.sceneLargeTileHeight
                      : CollectionConfig.sceneTileHeight,
                  crossAxisSpacing: CollectionConfig.sceneColumnGap,
                  mainAxisSpacing: CollectionConfig.sceneRowGap,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final RareSignProgress sign = signs[index];
                  final String label = PatternsStrings.rareTitle(
                    sign.id,
                    language,
                  );
                  return Semantics(
                    button: true,
                    label:
                        '$label, ${sign.isUnlocked ? language.sec("Koleksiyonunda", "Unlocked") : language.sec("Kilitli", "Locked")}',
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: () => _details(context, sign, language),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                                border: Border.all(
                                  color: sign.isUnlocked
                                      ? CosmicConfig.goldLight.withValues(
                                          alpha: .6,
                                        )
                                      : Colors.white24,
                                ),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  Image.asset(
                                    AppIllustrations.rareSignAssets[sign.id]!,
                                    fit: BoxFit.cover,
                                    cacheWidth:
                                        CollectionConfig.sceneThumbnailWidth,
                                    color: sign.isUnlocked
                                        ? null
                                        : const Color(0xAA061729),
                                    colorBlendMode: BlendMode.srcATop,
                                    excludeFromSemantics: true,
                                  ),
                                  if (!sign.isUnlocked)
                                    const Center(
                                      child: Icon(
                                        Icons.lock_rounded,
                                        color: Color(0xFFE1EAF2),
                                        size: 28,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.calendar_month_outlined),
                      title: Text(ShellStrings.history(language)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(
                        context,
                      ).push(fadeThroughRoute<void>(const HistoryScreen())),
                    ),
                    ListTile(
                      leading: const Icon(Icons.collections_bookmark_outlined),
                      title: Text(ShellStrings.collection(language)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(
                        context,
                      ).push(fadeThroughRoute<void>(const CollectionScreen())),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
