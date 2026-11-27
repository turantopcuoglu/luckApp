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
import 'dogum_yeri_verisi.dart';
import 'profile_config.dart';

/// Düzenleyicide seçili doğum saati (gece yarısından dakika; null =
/// bilinmiyor). Başlangıç değeri kayıtlı profildir.
final AutoDisposeStateProvider<int?> _secilenSaatProvider =
    StateProvider.autoDispose<int?>(
      (Ref ref) => ref.read(aktifProfilProvider).dogumSaatiDakika,
    );

/// Düzenleyicide seçili doğum ülkesi (ISO kodu). Başlangıç değeri kayıtlı
/// doğum yerinin ülkesi, yoksa Türkiye.
final AutoDisposeStateProvider<String> _secilenUlkeProvider =
    StateProvider.autoDispose<String>(
      (Ref ref) =>
          ref.read(aktifProfilProvider).dogumYeri?.ulkeKodu ??
          EngineConfig.turkiyeUlkeKodu,
    );

/// Düzenleyicide seçili doğum yeri (null = seçilmedi).
final AutoDisposeStateProvider<DogumYeri?> _secilenYerProvider =
    StateProvider.autoDispose<DogumYeri?>(
      (Ref ref) => ref.read(aktifProfilProvider).dogumYeri,
    );

/// Doğum saati ve yerini profile kaydeder; null değerler alanı temizler.
///
/// Bu bilgiler yalnızca doğum haritasını etkiler; skor tohumu değişmez.
void dogumBilgisiniKaydet(WidgetRef ref, {int? dakika, DogumYeri? yer}) {
  final UserProfile profil = ref.read(aktifProfilProvider);
  // Bellek içi kutu anında güncellenir; disk yazması beklenmez.
  unawaited(
    ref
        .read(userRepositoryProvider)
        .kaydet(
          profil.copyWith(
            dogumSaatiDakika: dakika,
            dogumSaatiniTemizle: dakika == null,
            dogumYeri: yer,
            dogumIliniTemizle: yer == null,
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
    final String ulke = ref.watch(_secilenUlkeProvider);
    final DogumYeri? yer = ref.watch(_secilenYerProvider);

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
              ulkeKodu: ulke,
              yer: yer,
              onSaat: (int? dakika) =>
                  ref.read(_secilenSaatProvider.notifier).state = dakika,
              onUlke: (String kod) {
                ref.read(_secilenUlkeProvider.notifier).state = kod;
                // Ülke değişince eski ülkenin şehri geçersizdir.
                ref.read(_secilenYerProvider.notifier).state = null;
              },
              onYer: (DogumYeri? secilen) =>
                  ref.read(_secilenYerProvider.notifier).state = secilen,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                dogumBilgisiniKaydet(ref, dakika: saat, yer: yer);
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

/// Doğum saati ve doğum yeri alanları: saat seçici satırı ("Bilmiyorum"
/// seçeneğiyle), ülke araması ve ülkeye göre il ya da şehir araması.
///
/// Türkiye seçiliyken 81 il listesi, başka ülkede GeoNames şehirleri
/// aranır (bkz. [sehirVerisiProvider]). Hem onboarding formunda hem
/// profildeki düzenleme sayfasında kullanılır; seçimi kendisi saklamaz,
/// [onSaat], [onUlke] ve [onYer] ile çağırana bildirir. Alanların hepsi
/// isteğe bağlıdır.
class DogumSaatiYeriAlanlari extends ConsumerWidget {
  /// Mevcut seçimler ve değişiklik geri çağrılarıyla alanları oluşturur.
  const DogumSaatiYeriAlanlari({
    required this.saat,
    required this.ulkeKodu,
    required this.yer,
    required this.onSaat,
    required this.onUlke,
    required this.onYer,
    super.key,
  });

  /// Seçili doğum saati (gece yarısından itibaren dakika); bilinmiyorsa
  /// null.
  final int? saat;

  /// Seçili doğum ülkesi (ISO kodu).
  final String ulkeKodu;

  /// Seçili doğum yeri; seçilmediyse null.
  final DogumYeri? yer;

  /// Saat seçildiğinde (ya da "Bilmiyorum" denince null ile) çağrılır.
  final ValueChanged<int?> onSaat;

  /// Ülke seçildiğinde ISO koduyla çağrılır. Çağıran, eski ülkenin yerini
  /// temizlemelidir.
  final ValueChanged<String> onUlke;

  /// İl ya da şehir seçildiğinde çağrılır.
  final ValueChanged<DogumYeri?> onYer;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final int? saat = this.saat;
    final bool turkiye = ulkeKodu == EngineConfig.turkiyeUlkeKodu;
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
        _UlkeAlani(ulkeKodu: ulkeKodu, onUlke: onUlke),
        const SizedBox(height: AppSpacing.sm),
        if (turkiye)
          _IlAlani(plaka: yer?.ilPlaka, onYer: onYer)
        else
          _SehirAlani(ulkeKodu: ulkeKodu, yer: yer, onYer: onYer),
      ],
    );
  }
}

/// Ülke araması (Türkçe ya da İngilizce adla).
class _UlkeAlani extends ConsumerWidget {
  const _UlkeAlani({required this.ulkeKodu, required this.onUlke});

  final String ulkeKodu;
  final ValueChanged<String> onUlke;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final String dil = Localizations.localeOf(context).languageCode;
    final List<Ulke> ulkeler =
        ref.watch(ulkelerProvider).valueOrNull ?? const <Ulke>[];
    final Ulke? secili = ulkeler
        .where((Ulke u) => u.kod == ulkeKodu)
        .firstOrNull;
    return Autocomplete<Ulke>(
      // Liste yüklenince ve ülke değişince alan seçili adla yeniden kurulur.
      key: ValueKey<String>('ulke-$ulkeKodu-${ulkeler.length}'),
      initialValue: TextEditingValue(text: secili?.ad(dil) ?? ''),
      optionsBuilder: (TextEditingValue v) => v.text.trim().isEmpty
          ? const Iterable<Ulke>.empty()
          : Ulkeler.ara(ulkeler, sorgu: v.text, dilKodu: dil),
      displayStringForOption: (Ulke u) => u.ad(dil),
      // Liste alanın üstüne açılır; not ve Kaydet görünür kalır.
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
      optionsViewBuilder: (_, onSecim, secenekler) => _OneriListesi<Ulke>(
        secenekler: secenekler,
        onSecim: onSecim,
        metin: (Ulke u) => u.ad(dil),
      ),
      onSelected: (Ulke u) => onUlke(u.kod),
      fieldViewBuilder:
          (
            BuildContext c,
            TextEditingController kontrol,
            FocusNode odak,
            VoidCallback gonder,
          ) => TextField(
            key: const Key('dogum-ulkesi-alani'),
            controller: kontrol,
            focusNode: odak,
            // Liste gelmeden yazılan harfe öneri çıkmaz; alan liste gelince
            // açılır (küçük dosya, anında).
            enabled: ulkeler.isNotEmpty,
            onSubmitted: (_) => gonder(),
            decoration: InputDecoration(
              labelText: l.profilDogumUlkesi,
              hintText: l.profilDogumUlkesiIpucu,
              prefixIcon: const Icon(Icons.language_outlined),
            ),
          ),
    );
  }
}

/// Türkiye: 81 il araması (bugünkü haritalar bu listeyle hesaplanır).
class _IlAlani extends StatelessWidget {
  const _IlAlani({required this.plaka, required this.onYer});

  final int? plaka;
  final ValueChanged<DogumYeri?> onYer;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final int? plaka = this.plaka;
    final Il? il = plaka == null ? null : TurkiyeIlleri.plakadan(plaka);
    return Autocomplete<Il>(
      key: const ValueKey<String>('il'),
      initialValue: TextEditingValue(text: il?.ad ?? ''),
      optionsBuilder: (TextEditingValue v) => v.text.trim().isEmpty
          ? const Iterable<Il>.empty()
          : TurkiyeIlleri.ara(v.text),
      displayStringForOption: (Il il) => il.ad,
      // Liste alanın üstüne açılır; not ve Kaydet görünür kalır.
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
      optionsViewBuilder: (_, onSecim, secenekler) => _OneriListesi<Il>(
        secenekler: secenekler,
        onSecim: onSecim,
        metin: (Il il) => il.ad,
      ),
      onSelected: (Il secilen) => onYer(DogumYeri.il(secilen)),
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
              prefixIcon: const Icon(Icons.place_outlined),
            ),
          ),
    );
  }
}

/// Türkiye dışı: seçili ülkenin şehirlerinde arama (GeoNames).
class _SehirAlani extends ConsumerWidget {
  const _SehirAlani({
    required this.ulkeKodu,
    required this.yer,
    required this.onYer,
  });

  final String ulkeKodu;
  final DogumYeri? yer;
  final ValueChanged<DogumYeri?> onYer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<SehirVerisi> veri = ref.watch(sehirVerisiProvider);
    final SehirVerisi? v = veri.valueOrNull;
    final DogumYeri? yer = this.yer;
    final String ilkMetin = yer != null && yer.ulkeKodu == ulkeKodu
        ? yer.ad
        : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Autocomplete<_SehirSecenegi>(
          // Ülke değişince alan boş olarak yeniden kurulur.
          key: ValueKey<String>('sehir-$ulkeKodu'),
          initialValue: TextEditingValue(text: ilkMetin),
          optionsBuilder: (TextEditingValue t) => v == null
              ? const Iterable<_SehirSecenegi>.empty()
              : DunyaSehirleri.ara(
                  v.sehirler,
                  ulkeKodu: ulkeKodu,
                  sorgu: t.text,
                ).map((DunyaSehri s) => _SehirSecenegi.kur(s, v, t.text)),
          // Alanda yalnız şehrin adı kalır; diğer ad yalnız listede.
          displayStringForOption: (_SehirSecenegi s) => s.ad,
          // Liste alanın üstüne açılır; not ve Kaydet görünür kalır.
          optionsViewOpenDirection: OptionsViewOpenDirection.up,
          optionsViewBuilder: (_, onSecim, secenekler) =>
              _OneriListesi<_SehirSecenegi>(
                secenekler: secenekler,
                onSecim: onSecim,
                metin: (_SehirSecenegi s) => s.gorunen,
              ),
          onSelected: (_SehirSecenegi s) => onYer(s.sehir.dogumYeri()),
          fieldViewBuilder:
              (
                BuildContext c,
                TextEditingController kontrol,
                FocusNode odak,
                VoidCallback gonder,
              ) => TextField(
                key: const Key('dogum-sehri-alani'),
                controller: kontrol,
                focusNode: odak,
                // Veri gelmeden yazılan harfe öneri çıkmaz (öneriler yalnız
                // metin değişince hesaplanır); alan veri gelince açılır.
                enabled: v != null,
                onSubmitted: (_) => gonder(),
                decoration: InputDecoration(
                  labelText: l.profilDogumSehri,
                  hintText: l.profilDogumSehriIpucu,
                  // Alanın parçası olan not, öneri listesi açıkken de
                  // listenin üstünde görünür kalır.
                  helperText: l.profilEnYakinSehir,
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.place_outlined),
                  errorText: veri.hasError ? l.profilSehirListesiYok : null,
                ),
              ),
        ),
      ],
    );
  }
}

/// Şehir listesindeki bir satır: şehir ve gösterilecek ad.
class _SehirSecenegi {
  const _SehirSecenegi(this.sehir, this.ad, this.gorunen);

  /// Gösterilecek ad: aynı adlı şehir varsa koordinatla; kullanıcı başka
  /// bir adla aradıysa o ad parantezde ("Munich (München)").
  factory _SehirSecenegi.kur(DunyaSehri s, SehirVerisi v, String sorgu) {
    final String? diger = DunyaSehirleri.eslesenDigerAd(s, sorgu);
    final String ad = v.gorunenAd(s);
    return _SehirSecenegi(s, ad, diger == null ? ad : '$ad ($diger)');
  }

  final DunyaSehri sehir;

  /// Alanda gösterilen ad (aynı adlılar koordinatla ayrılır).
  final String ad;

  /// Listede gösterilen ad.
  final String gorunen;
}

/// Doğum yeri alanlarının öneri listesi (alanın üstüne açılır): sayfa
/// yüzeyiyle aynı zemin, ince altın kenar, gölgesiz. Flutter'ın varsayılan
/// listesi koyu temada gölgesiyle siyah bir çerçeve ve zeminden koyu
/// satırlar çiziyordu.
class _OneriListesi<T extends Object> extends StatelessWidget {
  const _OneriListesi({
    required this.secenekler,
    required this.onSecim,
    required this.metin,
  });

  final Iterable<T> secenekler;
  final AutocompleteOnSelected<T> onSecim;
  final String Function(T) metin;

  @override
  Widget build(BuildContext context) {
    final int vurgu = AutocompleteHighlightedOption.of(context);
    final List<T> liste = secenekler.toList();
    return Align(
      // Liste yukarı açılır: alanın üst kenarına dayanır.
      alignment: AlignmentDirectional.bottomStart,
      child: Padding(
        // Alanın etiketinden küçük bir boşlukla ayrılır.
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Material(
          // Sayfadan bir ton açık zemin ve belirgin kenar: liste, kapattığı
          // içeriğin üstünde ayrı bir katman olarak okunur.
          color: Color.lerp(
            AppColors.surface,
            AppColors.textPrimary,
            ProfileConfig.oneriZeminAcikligi,
          ),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(
              color: AppColors.gold.withValues(
                alpha: ProfileConfig.oneriKenarOpakligi,
              ),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: ProfileConfig.oneriListesiEnFazlaYukseklik,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: liste.length,
              itemBuilder: (BuildContext c, int i) => InkWell(
                onTap: () => onSecim(liste[i]),
                child: Container(
                  color: i == vurgu
                      ? AppColors.purple.withValues(
                          alpha: ProfileConfig.oneriVurguOpakligi,
                        )
                      : null,
                  // Satır metni alandaki metinle aynı sol kenardan başlar
                  // (ön ikon kutusu + boşluk).
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    kMinInteractiveDimension + AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Text(metin(liste[i])),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
