import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_dil.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/cosmic_config.dart';
import '../../shared/widgets/cosmic_page.dart';
import '../../shared/widgets/kader_button.dart';
import '../categories/entitlement.dart';
import '../daily_luck/today_strings.dart';
import 'share_config.dart';
import 'share_service.dart';
import 'share_strings.dart';
import 'story_card.dart';
import 'story_style.dart';

/// Kayıtlı kartın üç gerçek 9:16 tasarımını gösterir; paylaşma açık eylemdir.
class StoryDesignerScreen extends ConsumerStatefulWidget {
  /// Bugün veya koleksiyondaki geçmiş bir sonuçtan açılır.
  const StoryDesignerScreen({
    required this.result,
    required this.language,
    super.key,
  });

  /// Skoru tekrar üretmeden paylaşılan sonuç.
  final LuckResult result;

  /// Açılan kartın dili.
  final AppDil language;
  @override
  ConsumerState<StoryDesignerScreen> createState() => _StoryDesignerState();
}

class _StoryDesignerState extends ConsumerState<StoryDesignerScreen> {
  StoryStyle _style = StoryStyle.portal;
  bool _sharing = false;
  bool _hideScore = false;
  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final Set<LuckCategory> locked = LuckCategory.values
          .where((LuckCategory k) => ref.read(kategoriKilitliProvider(k)))
          .toSet();
      await ref
          .read(shareServiceProvider)
          .paylas(
            sonuc: widget.result,
            dil: widget.language,
            kilitliKategoriler: locked,
            style: _style,
            hideScore: _hideScore,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(TodayStrings.shareError(widget.language))),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Set<LuckCategory> locked = LuckCategory.values
        .where((LuckCategory k) => ref.watch(kategoriKilitliProvider(k)))
        .toSet();
    return CosmicPage(
      tone: CosmicTone.fromScore(widget.result.genelSkor),
      appBar: AppBar(title: Text(ShareStrings.designer(widget.language))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      width: ShareConfig.designerPreviewWidth,
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: ShareConfig.kartBoyutu.width,
                              height: ShareConfig.kartBoyutu.height,
                              child: StoryCard(
                                sonuc: widget.result,
                                dil: widget.language,
                                kilitliKategoriler: locked,
                                style: _style,
                                hideScore: _hideScore,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final StoryStyle style in StoryStyle.values)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            child: Semantics(
                              selected: _style == style,
                              button: true,
                              child: InkWell(
                                onTap: _sharing
                                    ? null
                                    : () => setState(() => _style = style),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: ShareConfig.styleThumbnailHeight,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        border: Border.all(
                                          color: _style == style
                                              ? CosmicConfig.goldLight
                                              : Colors.white24,
                                          width: 2,
                                        ),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: <Widget>[
                                          Image.asset(
                                            style.sceneAsset,
                                            fit: BoxFit.cover,
                                            cacheWidth:
                                                ShareConfig.styleThumbnailWidth,
                                            excludeFromSemantics: true,
                                          ),
                                          if (_style == style)
                                            const Align(
                                              alignment: Alignment.bottomRight,
                                              child: Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: CosmicConfig.goldLight,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(style.label(widget.language)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.visibility_off_outlined),
                    title: Text(
                      widget.language.sec('Skorları gizle', 'Hide scores'),
                    ),
                    value: _hideScore,
                    onChanged: _sharing
                        ? null
                        : (bool value) => setState(() => _hideScore = value),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  KaderButton(
                    cosmic: true,
                    label: ShareStrings.export(widget.language),
                    isLoading: _sharing,
                    onPressed: () => unawaited(_share()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CosmicPanel(
                    child: Text(
                      ShareStrings.exportNote(widget.language),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
