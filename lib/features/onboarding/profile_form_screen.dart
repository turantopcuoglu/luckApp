import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_dil.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/cosmic_scene.dart';
import '../../shared/widgets/kader_button.dart';
import '../../shared/widgets/kader_scaffold.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../settings/settings_strings.dart';
import 'calculating_screen.dart';
import 'card_preparation_motion.dart';
import 'onboarding_config.dart';
import 'onboarding_strings.dart';
import 'profile_form_state.dart';

/// Ad ve doğum tarihini açık seçimle isteyen, klavye güvenli başlangıç.
class ProfileFormScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const ProfileFormScreen({super.key});
  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  bool _advancing = false;
  late final TextEditingController _name = TextEditingController(
    text: ref.read(profileFormProvider).name,
  );
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_advancing) return;
    _advancing = true;
    final bool saved = await ref.read(profileFormProvider.notifier).save();
    if (!mounted || !saved) {
      _advancing = false;
      return;
    }
    FocusScope.of(context).unfocus();
    await Navigator.of(
      context,
    ).push(fadeThroughRoute<void>(const CalculatingScreen()));
    _advancing = false;
  }

  Future<void> _chooseDate() async {
    final ProfileFormState state = ref.read(profileFormProvider);
    if (state.legacy || state.saving) return;
    FocusScope.of(context).unfocus();
    final DateTime now = ref.read(birthDateTodayProvider);
    DateTime draft = state.birthDate ?? DateTime(2000, 1, 1);
    final AppDil language = ref.read(dilProvider);
    final DateTime? selected = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                OnboardingStrings.birthDate(language),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(
                height: 200,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.dark),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: draft,
                    minimumDate: DateTime(1900),
                    maximumDate: DateTime(now.year, now.month, now.day),
                    onDateTimeChanged: (DateTime value) => draft = value,
                  ),
                ),
              ),
              KaderButton(
                cosmic: true,
                label: OnboardingStrings.confirmDate(language),
                onPressed: () => Navigator.of(sheetContext).pop(draft),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && selected != null) {
      ref.read(profileFormProvider.notifier).changeBirthDate(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileFormState state = ref.watch(profileFormProvider);
    final AppDil language = ref.watch(dilProvider);
    final TextTheme text = Theme.of(context).textTheme;
    final Color muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return PopScope(
      canPop: !state.saving,
      child: KaderScaffold(
        background: const CosmicBackdrop(),
        appBar: AppBar(),
        scrollable: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: SizedBox(
                height: OnboardingConfig.ikonBoyutu,
                child: const FittedBox(
                  child: CardPreparationMotion(
                    animation: AlwaysStoppedAnimation<double>(.55),
                    reducedMotion: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              OnboardingStrings.formBasligi(language),
              style: text.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              OnboardingStrings.formAciklama(language),
              style: text.bodyLarge?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _name,
              readOnly: state.legacy || state.saving,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              maxLength: OnboardingConfig.isimMaksUzunluk,
              onChanged: ref.read(profileFormProvider.notifier).changeName,
              onSubmitted: (_) => unawaited(_continue()),
              decoration: InputDecoration(
                labelText: OnboardingStrings.isimEtiketi(language),
                hintText: OnboardingStrings.isimIpucu(language),
                errorText: state.invalidName
                    ? OnboardingStrings.isimBosUyarisi(language)
                    : null,
                errorMaxLines: OnboardingConfig.hataMaksSatir,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(OnboardingStrings.birthDate(language), style: text.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              key: const ValueKey<String>('birth-date-button'),
              onPressed: state.legacy || state.saving ? null : _chooseDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                state.birthDate == null
                    ? OnboardingStrings.chooseDate(language)
                    : MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(state.birthDate!),
              ),
            ),
            if (state.invalidBirthDate)
              Text(
                OnboardingStrings.dateError(language),
                style: text.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            if (state.legacy) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                OnboardingStrings.eskiProfilAciklama(language),
                style: text.bodyMedium?.copyWith(color: muted),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              OnboardingStrings.yerelVeriAciklama(language),
              style: text.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (state.failed) ...<Widget>[
              Semantics(
                liveRegion: true,
                child: Text(
                  OnboardingStrings.profilKayitHatasi(language),
                  style: text.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            KaderButton(
              cosmic: true,
              label: state.failed
                  ? OnboardingStrings.tekrarDene(language)
                  : OnboardingStrings.kaderimiHesapla(language),
              isLoading: state.saving,
              loadingLabel: OnboardingStrings.kaydediliyor(language),
              onPressed: () => unawaited(_continue()),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              SettingsStrings.eglenceAmacli(language),
              style: text.bodySmall?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
