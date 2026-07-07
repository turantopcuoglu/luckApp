import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/luck_history_repository.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../daily_luck/daily_luck_providers.dart';
import 'feedback_config.dart';
import 'feedback_strings.dart';

/// Kullanıcının 👍/👎 seçimi (null = henüz seçmedi).
///
/// Form durumu Riverpod'da tutulur (CLAUDE.md kural 5); ekran her
/// açılışta temiz başlasın diye autoDispose.
final AutoDisposeStateProvider<bool?> feedbackPozitifProvider =
    StateProvider.autoDispose<bool?>((Ref ref) => null);

/// Opsiyonel duygu emojisi seçimi.
final AutoDisposeStateProvider<String?> feedbackEmojiProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);

/// Akşam geri bildirim ekranı: 👍/👎 + opsiyonel emoji
/// (plan Session 8, madde 2). Bildirime dokununca açılır.
class FeedbackScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const FeedbackScreen({super.key});

  /// Seçimi bugünün kaydına işler ve ekranı kapatır.
  ///
  /// Bildirim, skor hiç üretilmeden de gelebilir; bu yüzden önce
  /// bugünün kaydı garanti edilir (getirVeyaUret), sonra feedback
  /// yazılır. Hive bellek içi durumu senkron güncellediği için akış
  /// yazmayı beklemez (unawaited).
  void _kaydet(BuildContext context, WidgetRef ref, {required bool pozitif}) {
    final DateTime gun = ref.read(bugunProvider);
    final LuckHistoryRepository repo =
        ref.read(luckHistoryRepositoryProvider);
    final String? emoji = ref.read(feedbackEmojiProvider);

    unawaited(() async {
      await repo.getirVeyaUret(
        motor: ref.read(luckEngineProvider),
        kullanici: ref.read(aktifProfilProvider).seed,
        gun: gun,
      );
      await repo.feedbackKaydet(gun, pozitif: pozitif, emoji: emoji);
    }());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(FeedbackStrings.tesekkur)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final bool? pozitif = ref.watch(feedbackPozitifProvider);
    final String? emoji = ref.watch(feedbackEmojiProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(FeedbackStrings.baslik)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                FeedbackStrings.aksamSorusu,
                style: yaziTemasi.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _SecimButonu(
                    emoji: FeedbackStrings.evetEmoji,
                    secili: pozitif ?? false,
                    onTap: () => ref
                        .read(feedbackPozitifProvider.notifier)
                        .state = true,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _SecimButonu(
                    emoji: FeedbackStrings.hayirEmoji,
                    secili: pozitif == false,
                    onTap: () => ref
                        .read(feedbackPozitifProvider.notifier)
                        .state = false,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                FeedbackStrings.emojiBaslik,
                style: yaziTemasi.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: <Widget>[
                  for (final String secenek
                      in FeedbackStrings.emojiSecenekleri)
                    ChoiceChip(
                      label: Text(secenek),
                      selected: emoji == secenek,
                      // Tekrar dokunmak seçimi kaldırır (emoji opsiyonel).
                      onSelected: (bool secildi) => ref
                          .read(feedbackEmojiProvider.notifier)
                          .state = secildi ? secenek : null,
                    ),
                ],
              ),
              const Spacer(),
              FilledButton(
                // 👍/👎 seçilmeden kaydedilemez; emoji opsiyoneldir.
                onPressed: pozitif == null
                    ? null
                    : () => _kaydet(context, ref, pozitif: pozitif),
                child: const Text(FeedbackStrings.kaydet),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Büyük 👍/👎 seçim butonu; seçiliyken altın çerçeve alır.
class _SecimButonu extends StatelessWidget {
  const _SecimButonu({
    required this.emoji,
    required this.secili,
    required this.onTap,
  });

  final String emoji;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: FeedbackConfig.secimButonBoyutu,
        height: FeedbackConfig.secimButonBoyutu,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: secili ? AppColors.gold : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(
              fontSize: FeedbackConfig.secimEmojiPunto,
            ),
          ),
        ),
      ),
    );
  }
}
