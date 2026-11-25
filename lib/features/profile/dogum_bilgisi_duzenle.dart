import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../daily_luck/daily_luck_providers.dart';

/// Düzenleyicide seçili doğum saati (gece yarısından dakika; null =
/// bilinmiyor). Başlangıç değeri kayıtlı profildir.
final AutoDisposeStateProvider<int?> _secilenSaatProvider =
    StateProvider.autoDispose<int?>(
      (Ref ref) => ref.read(aktifProfilProvider).dogumSaatiDakika,
    );

/// Düzenleyicide seçili doğum ili (plaka; null = seçilmedi).
final AutoDisposeStateProvider<int?> _secilenIlProvider =
    StateProvider.autoDispose<int?>(
      (Ref ref) => ref.read(aktifProfilProvider).dogumIliPlaka,
    );

/// Doğum saati ve ilini profile kaydeder; null değerler alanı temizler.
///
/// Bu bilgiler yalnızca doğum haritasını etkiler; skor tohumu değişmez.
void dogumBilgisiniKaydet(WidgetRef ref, {int? dakika, int? plaka}) {
  final UserProfile profil = ref.read(aktifProfilProvider);
  // Bellek içi kutu anında güncellenir; disk yazması beklenmez.
  unawaited(
    ref
        .read(userRepositoryProvider)
        .kaydet(
          profil.copyWith(
            dogumSaatiDakika: dakika,
            dogumSaatiniTemizle: dakika == null,
            dogumIliPlaka: plaka,
            dogumIliniTemizle: plaka == null,
          ),
        ),
  );
  ref.invalidate(aktifProfilProvider);
}

/// Doğum saati ve ili düzenleyicisini (alt sayfa) açar.
Future<void> dogumBilgisiniDuzenle(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext _) => const _DogumBilgisiSheet(),
    );

class _DogumBilgisiSheet extends ConsumerWidget {
  const _DogumBilgisiSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final int? saat = ref.watch(_secilenSaatProvider);
    final int? plaka = ref.watch(_secilenIlProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(l.profilDogumBilgisiBaslik, style: yazi.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.profilDogumBilgisiAciklama,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            DogumSaatiYeriAlanlari(
              saat: saat,
              plaka: plaka,
              onSaat: (int? dakika) =>
                  ref.read(_secilenSaatProvider.notifier).state = dakika,
              onIl: (int secilen) =>
                  ref.read(_secilenIlProvider.notifier).state = secilen,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                dogumBilgisiniKaydet(ref, dakika: saat, plaka: plaka);
                Navigator.of(context).pop();
              },
              child: Text(l.profilKaydet),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gece yarısından beri geçen [dakika]yı "08:05" biçiminde yazar
/// (24 saat; iki dilde aynı).
String _saatMetni(int dakika) =>
    '${(dakika ~/ Duration.minutesPerHour).toString().padLeft(2, '0')}:'
    '${(dakika % Duration.minutesPerHour).toString().padLeft(2, '0')}';

/// Doğum saati ve doğum ili alanları: saat seçici satırı ("Bilmiyorum"
/// seçeneğiyle) ve il araması.
///
/// Hem onboarding formunda hem profildeki düzenleme sayfasında kullanılır;
/// seçimi kendisi saklamaz, [onSaat] ve [onIl] ile çağırana bildirir. İki
/// alan da isteğe bağlıdır: saat bilinmiyorsa null kalır, il seçilmezse
/// (ör. Türkiye dışında doğanlar) null kalır.
class DogumSaatiYeriAlanlari extends StatelessWidget {
  /// Mevcut seçimler ve değişiklik geri çağrılarıyla alanları oluşturur.
  const DogumSaatiYeriAlanlari({
    required this.saat,
    required this.plaka,
    required this.onSaat,
    required this.onIl,
    super.key,
  });

  /// Seçili doğum saati (gece yarısından itibaren dakika); bilinmiyorsa
  /// null.
  final int? saat;

  /// Seçili doğum ilinin plaka kodu; seçilmediyse null.
  final int? plaka;

  /// Saat seçildiğinde (ya da "Bilmiyorum" denince null ile) çağrılır.
  final ValueChanged<int?> onSaat;

  /// İl seçildiğinde plaka koduyla çağrılır.
  final ValueChanged<int> onIl;

  Future<void> _saatSec(BuildContext context) async {
    final int? mevcut = saat;
    final TimeOfDay? secim = await showTimePicker(
      context: context,
      initialTime: mevcut == null
          ? const TimeOfDay(hour: EngineConfig.bilinmeyenSaat, minute: 0)
          : TimeOfDay(
              hour: mevcut ~/ Duration.minutesPerHour,
              minute: mevcut % Duration.minutesPerHour,
            ),
      builder: (BuildContext c, Widget? cocuk) => MediaQuery(
        data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
        child: cocuk!,
      ),
    );
    if (secim != null) {
      onSaat(secim.hour * Duration.minutesPerHour + secim.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final int? saat = this.saat;
    final int? plaka = this.plaka;
    final Il? il = plaka == null ? null : TurkiyeIlleri.plakadan(plaka);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule_rounded, color: AppColors.gold),
          title: Text(l.profilDogumSaati),
          subtitle: Text(
            saat == null ? l.profilSaatBilinmiyor : _saatMetni(saat),
          ),
          trailing: Wrap(
            spacing: AppSpacing.xs,
            children: <Widget>[
              if (saat != null)
                TextButton(
                  onPressed: () => onSaat(null),
                  child: Text(l.profilSaatBilinmiyor),
                ),
              TextButton(
                onPressed: () => unawaited(_saatSec(context)),
                child: Text(l.profilSaatSec),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Autocomplete<Il>(
          initialValue: TextEditingValue(text: il?.ad ?? ''),
          optionsBuilder: (TextEditingValue v) => v.text.trim().isEmpty
              ? const Iterable<Il>.empty()
              : TurkiyeIlleri.ara(v.text),
          displayStringForOption: (Il il) => il.ad,
          onSelected: (Il secilen) => onIl(secilen.plaka),
          fieldViewBuilder:
              (
                BuildContext c,
                TextEditingController kontrol,
                FocusNode odak,
                VoidCallback gonder,
              ) => TextField(
                key: const Key('dogum-ili-alani'),
                controller: kontrol,
                focusNode: odak,
                onSubmitted: (_) => gonder(),
                decoration: InputDecoration(
                  labelText: l.profilDogumIli,
                  hintText: l.profilDogumIliIpucu,
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
        ),
      ],
    );
  }
}
