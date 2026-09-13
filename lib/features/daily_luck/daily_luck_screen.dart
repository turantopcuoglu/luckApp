import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/daily_experience.dart';
import '../../core/content/experience_dimension.dart';
import '../../core/localization/app_dil.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/cosmic_config.dart';
import '../../shared/widgets/app_illustrations.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/cosmic_scene.dart';
import '../../shared/widgets/kader_button.dart';
import '../../shared/widgets/kader_scaffold.dart';
import '../categories/category_detail_screen.dart';
import '../categories/entitlement.dart';
import '../categories/paywall_screen.dart';
import '../feedback/feedback_screen.dart';
import '../history/history_providers.dart';
import '../share/story_designer_screen.dart';
import 'daily_luck_providers.dart';
import 'reveal_controller.dart';
import 'today_providers.dart';
import 'today_strings.dart';
import 'tr_strings.dart';
import 'widgets/today_content.dart';
import 'widgets/today_opening_card.dart';

/// Bugün: ayrı yükleme/hata/kapalı/açık durumları ve maskelenmiş alan görünümü.
/// Skor, kalıcı açılış yazımı tamamlanmadan widget ağacına girmez.
class DailyLuckScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const DailyLuckScreen({super.key});

  @override
  ConsumerState<DailyLuckScreen> createState() => _DailyLuckScreenState();
}

class _DailyLuckScreenState extends ConsumerState<DailyLuckScreen> {
  final ScrollController _scroll = ScrollController();
  int? _sceneDecodeWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int width = CosmicConfig.sanctuaryDecodeWidth(
      MediaQuery.sizeOf(context).width.clamp(0, AppLayout.maxContentWidth),
      MediaQuery.devicePixelRatioOf(context),
    );
    if (_sceneDecodeWidth == width) return;
    _sceneDecodeWidth = width;
    // Tüm sahneler sonuçtan bağımsız yüklenir; kapalı kartın verisini okumaz.
    for (final String asset in <String>[
      CosmicConfig.sanctuarySealed,
      CosmicConfig.sanctuaryRadiant,
      CosmicConfig.sanctuaryTwilight,
    ]) {
      unawaited(
        precacheImage(ResizeImage(AssetImage(asset), width: width), context),
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    if (ref.read(todaySharingProvider)) return;
    ref.read(todaySharingProvider.notifier).state = true;
    try {
      // Açık ekranın mevcut sonucunu paylaş; yeniden yükleme/yazım başlatma.
      final LuckResult? result = ref.read(gununSansiProvider).valueOrNull;
      if (result == null) throw StateError('Günün sonucu hazır değil.');
      await Navigator.of(context).push(
        fadeThroughRoute<void>(
          StoryDesignerScreen(result: result, language: ref.read(dilProvider)),
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TodayStrings.shareError(ref.read(dilProvider))),
          ),
        );
      }
    } finally {
      if (context.mounted) {
        ref.read(todaySharingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppDil language = ref.watch(dilProvider);
    final String name = ref.watch(aktifProfilProvider).isim;
    final AsyncValue<DailyExperience> experience = ref.watch(
      dailyExperienceProvider,
    );
    final TextTheme text = Theme.of(context).textTheme;
    final DailyExperience? current = experience.valueOrNull;
    final bool visibleResult =
        current != null &&
        ref.watch(revealControllerProvider(current.date)).phase ==
            RevealPhase.revealed;
    return KaderScaffold(
      padding: const EdgeInsets.all(AppSpacing.md),
      background: CosmicBackdrop(
        vivid: true,
        animated: ref.watch(cosmicMotionEnabledProvider),
        tone: visibleResult
            ? CosmicTone.fromScore(current.score)
            : CosmicTone.sealed,
      ),
      scrollable: true,
      scrollController: _scroll,
      body: experience.when(
        // Yenileme/eski cache sırasında kapalı içerik yanlışlıkla gösterilmez.
        skipLoadingOnRefresh: false,
        data: (DailyExperience data) {
          final RevealState reveal = ref.watch(
            revealControllerProvider(data.date),
          );
          final bool opened = reveal.phase == RevealPhase.revealed;
          ref.listen<RevealState>(revealControllerProvider(data.date), (
            RevealState? before,
            RevealState after,
          ) {
            if (before?.phase != RevealPhase.revealed &&
                after.phase == RevealPhase.revealed &&
                after.fresh) {
              if (_scroll.hasClients) _scroll.jumpTo(0);
              if (TickerMode.valuesOf(context).enabled &&
                  (WidgetsBinding.instance.lifecycleState == null ||
                      WidgetsBinding.instance.lifecycleState ==
                          AppLifecycleState.resumed) &&
                  !AppMotion.reduceMotion(context)) {
                unawaited(ref.read(revealHapticsProvider).result());
              }
            }
          });
          final int streak = ref.watch(gecmisOzetiProvider).guncelSeri;
          final Widget header = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DecoratedBox(
                key: const ValueKey<String>('today-heading-halo'),
                decoration: const BoxDecoration(
                  gradient: CosmicConfig.headingHalo,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      TodayStrings.brand,
                      textAlign: TextAlign.center,
                      style: text.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      TrStrings.tarihMetni(language, data.date),
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      TrStrings.selamlama(language, name),
                      textAlign: TextAlign.center,
                      style: text.headlineMedium,
                    ),
                  ],
                ),
              ),
              if (streak > 0) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  TrStrings.seriEtiketi(language, streak),
                  textAlign: TextAlign.center,
                  style: text.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (!opened)
                TodayOpeningCard(
                  key: ValueKey<DateTime>(data.date),
                  day: data.date,
                  header: header,
                  language: language,
                  onStart: () {
                    if (_scroll.hasClients) _scroll.jumpTo(0);
                  },
                )
              else
                TodayResultEntrance(
                  key: ValueKey<DateTime>(data.date),
                  animate: reveal.fresh,
                  child: TodayRevealedContent(
                    language: language,
                    header: header,
                    score: data.score,
                    title: TodayStrings.scoreTitle(language, data.score),
                    dimension: data.dominantDimension,
                    reflection: TodayStrings.scoreReflection(
                      language,
                      data.score,
                    ),
                    mission: data.score < CosmicConfig.calmScore
                        ? TodayStrings.gentleStep(language)
                        : data.microMission,
                    // Kilitli sayılar görünüm bileşenlerinin nesnelerine dahi girmez.
                    dimensions: <TodayDimensionData>[
                      for (final DimensionScore item in data.orderedDimensions)
                        TodayDimensionData(
                          dimension: item.dimension,
                          score: ref.watch(alanKilitliProvider(item.dimension))
                              ? null
                              : item.score,
                        ),
                    ],
                    onDimension: (ExperienceDimension dimension) =>
                        Navigator.of(context).push(
                          fadeThroughRoute<void>(
                            ref.read(alanKilitliProvider(dimension))
                                ? const PaywallScreen()
                                : CategoryDetailScreen(
                                    kategori: dimension.kategori,
                                  ),
                          ),
                        ),
                    onShare: () => unawaited(_share(context, ref)),
                    sharing: ref.watch(todaySharingProvider),
                    onFeedback: () => Navigator.of(
                      context,
                    ).push(fadeThroughRoute<void>(const FeedbackScreen())),
                  ),
                ),
            ],
          );
        },
        loading: () => Column(
          children: <Widget>[
            const SizedBox(height: AppSpacing.xxl),
            AppIllustrations.kaderMark(),
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              liveRegion: true,
              child: Text(
                TodayStrings.loading(language),
                style: text.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        error: (Object error, StackTrace stack) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: AppSpacing.xxl),
            Center(child: AppIllustrations.emptyPath()),
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              liveRegion: true,
              child: Text(
                TodayStrings.error(language),
                style: text.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            KaderButton(
              label: TodayStrings.retry(language),
              onPressed: () => ref.invalidate(gununSansiProvider),
            ),
          ],
        ),
      ),
    );
  }
}
