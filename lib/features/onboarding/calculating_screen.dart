import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/dil_providers.dart';
import '../../main.dart';
import '../../shared/widgets/altin_buton.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/hero_tags.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../feedback/notification_service.dart';
import '../home/ana_kabuk.dart';
import '../home/ana_sekme.dart';
import 'onboarding_config.dart';
import 'widgets/isik_kuresi.dart';
import 'widgets/onboarding_zemini.dart';

/// Onboarding son adımı (mockup `ee9545f3` 2. ve 3. ekran):
///
/// 1. **Işık dolumu** (2,5 sn): cam küre yıldızlı ışıkla dolar, ilerleme
///    çubuğu ilerler, üç adımlı kontrol listesi sırayla tamamlanır.
/// 2. **Kartın hazır**: dolum bitince onboarding tamamlanır, bildirim izni
///    istenir; ışıklı kart belirir. "Kartıma geç" ana ekrana gider ve kart
///    Hero ile ana ekrandaki kader kartına uçar.
///
/// İki faz iki controller'la sürülür; görünüm controller değerinden türer
/// (setState yok, kural 5). Geri tuşu bilinçli olarak kapalıdır
/// (PopScope): akış ileri doğru akar.
class CalculatingScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const CalculatingScreen({super.key});

  @override
  ConsumerState<CalculatingScreen> createState() => _CalculatingScreenState();
}

class _CalculatingScreenState extends ConsumerState<CalculatingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _dolum = AnimationController(
    vsync: this,
    duration: OnboardingConfig.hesaplamaSuresi,
  );

  late final AnimationController _hazir = AnimationController(
    vsync: this,
    duration: OnboardingConfig.hazirBelirmeSuresi,
  );

  @override
  void initState() {
    super.initState();
    _dolum
      ..addStatusListener((AnimationStatus d) => unawaited(_dolumBitti(d)))
      ..forward();
  }

  @override
  void dispose() {
    _dolum.dispose();
    _hazir.dispose();
    super.dispose();
  }

  /// Dolum tamamlanınca onboarding bayrağı yazılır, bildirim izni istenir
  /// ve "Kartın hazır" fazı başlar.
  Future<void> _dolumBitti(AnimationStatus durum) async {
    if (durum != AnimationStatus.completed || !mounted) {
      return;
    }
    // Hive yazması await edilmez: bellek içi kutu anında günceldir.
    unawaited(ref.read(userRepositoryProvider).onboardingTamamla());

    // Bildirim izni akışı onboarding'in sonundadır (plan S8, madde 4):
    // sistem diyaloğu bu ekranın üzerinde görünür, cevaba göre ya
    // bildirimler planlanır ya da nazik bir hatırlatma gösterilir.
    final NotificationService bildirimler = ref.read(
      notificationServiceProvider,
    );
    final AppLocalizations metinler = ref.read(arayuzMetinleriProvider);
    final bool izinVerildi = await bildirimler.izinIste();
    if (izinVerildi) {
      unawaited(
        bildirimler.gunlukBildirimleriPlanla(
          simdi: DateTime.now(),
          metinler: metinler,
        ),
      );
    } else {
      anaMesajciAnahtari.currentState?.showSnackBar(
        SnackBar(content: Text(metinler.geriBildirimIzinReddi)),
      );
    }
    if (!mounted) {
      return;
    }
    _hazir.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : OnboardingConfig.hazirBelirmeSuresi;
    unawaited(_hazir.forward());
  }

  /// Tüm onboarding yığını temizlenerek ana ekrana geçilir (geri tuşu
  /// artık onboarding'e dönemez).
  void _kartimaGec() {
    // Ana ekran provider'ları misafir profiliyle değerlenmiş olabilir;
    // yeni profil okunsun diye tazelenir.
    ref
      ..invalidate(aktifProfilProvider)
      ..invalidate(gununSansiProvider)
      ..invalidate(anaSekmeProvider);
    Navigator.of(context).pushAndRemoveUntil(
      fadeThroughRoute<void>(const AnaKabuk()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget hazirlanma = _Hazirlanma(dolum: _dolum);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: OnboardingZemini(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AnimatedBuilder(
                animation: _hazir,
                builder: (BuildContext context, Widget? child) {
                  final double t = _hazir.value;
                  if (t == 0) {
                    return hazirlanma;
                  }
                  // Dolum görünümü söner, hazır kart belirir.
                  return Stack(
                    children: <Widget>[
                      if (t < 1)
                        IgnorePointer(
                          child: ExcludeSemantics(
                            child: Opacity(opacity: 1 - t, child: hazirlanma),
                          ),
                        ),
                      Opacity(
                        opacity: Curves.easeOut.transform(t),
                        child: _KartHazir(belirme: t, onGec: _kartimaGec),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Işık dolumu görünümü: küre, ilerleme çubuğu, başlık, kontrol listesi.
class _Hazirlanma extends StatelessWidget {
  const _Hazirlanma({required this.dolum});

  final Animation<double> dolum;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);
    // Sırası [OnboardingConfig.adimEsikleri] ile eşleşir.
    final List<String> adimlar = <String>[
      l.onboardingHazirlikProfil,
      l.onboardingHazirlikKart,
      l.onboardingHazirlikSon,
    ];
    return Column(
      children: <Widget>[
        const Spacer(),
        IsikKuresi(ilerleme: dolum),
        const SizedBox(height: AppSpacing.lg),
        _IlerlemeCubugu(ilerleme: dolum),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l.onboardingKartHazirlaniyor,
          style: yazi.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedBuilder(
          animation: dolum,
          builder: (BuildContext context, Widget? child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < adimlar.length; i++)
                _Adim(metin: adimlar[i], durum: _adimDurumu(i, dolum.value)),
            ],
          ),
        ),
        const Spacer(),
        RituelNotu(metin: l.onboardingKendineAlanAc),
      ],
    );
  }

  /// [i]. adımın [v] ilerlemesindeki durumu: önceki adım bittiyse aktif,
  /// kendi eşiğini geçtiyse tamam.
  static _AdimDurumu _adimDurumu(int i, double v) {
    if (v >= OnboardingConfig.adimEsikleri[i]) {
      return _AdimDurumu.tamam;
    }
    final double onceki = i == 0 ? 0 : OnboardingConfig.adimEsikleri[i - 1];
    return v >= onceki ? _AdimDurumu.aktif : _AdimDurumu.bekliyor;
  }
}

/// Kontrol listesi adımının durumu.
enum _AdimDurumu { bekliyor, aktif, tamam }

/// Kontrol listesinin tek satırı: işaret dairesi + metin.
class _Adim extends StatelessWidget {
  const _Adim({required this.metin, required this.durum});

  final String metin;
  final _AdimDurumu durum;

  @override
  Widget build(BuildContext context) {
    final bool tamam = durum == _AdimDurumu.tamam;
    final bool aktif = durum == _AdimDurumu.aktif;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: OnboardingConfig.adimIsaretCapi,
            height: OnboardingConfig.adimIsaretCapi,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: tamam || aktif
                    ? AppColors.gold
                    : AppColors.textSecondary.withValues(
                        alpha: OnboardingConfig.notCizgiOpakligi,
                      ),
              ),
              boxShadow: aktif
                  ? <BoxShadow>[
                      BoxShadow(
                        color: AppColors.goldAcik.withValues(
                          alpha: OnboardingConfig.notCizgiOpakligi,
                        ),
                        blurRadius: AppSpacing.sm,
                      ),
                    ]
                  : null,
            ),
            child: tamam
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.gold,
                    size: AppSpacing.md,
                  )
                : aktif
                ? const Center(
                    child: Icon(
                      Icons.circle,
                      color: AppColors.goldAcik,
                      size: AppSpacing.sm,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            metin,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: durum == _AdimDurumu.bekliyor
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cam görünümlü, turkuaz-altın dolan ilerleme çubuğu.
class _IlerlemeCubugu extends StatelessWidget {
  const _IlerlemeCubugu({required this.ilerleme});

  final Animation<double> ilerleme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: OnboardingConfig.ilerlemeCubuguYuksekligi,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.gold.withValues(
            alpha: OnboardingConfig.notCizgiOpakligi,
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: ilerleme,
        builder: (BuildContext context, Widget? child) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: ilerleme.value,
          child: child,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            gradient: const LinearGradient(
              colors: <Color>[AppColors.sahneYuksek, AppColors.isikCekirdegi],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.sahneYuksek.withValues(
                  alpha: OnboardingConfig.yuzeyHaleOpakligi,
                ),
                blurRadius: AppSpacing.sm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Kartın hazır" görünümü: ışık halesi içinde kart (Hero tohumu),
/// başlık, tamamlandı rozeti ve "Kartıma geç".
class _KartHazir extends StatelessWidget {
  const _KartHazir({required this.belirme, required this.onGec});

  /// Belirme ilerlemesi (0-1): kart hafifçe büyüyerek oturur.
  final double belirme;

  /// "Kartıma geç" dokunuşu.
  final VoidCallback onGec;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);
    final double olcek =
        OnboardingConfig.hazirBaslangicOlcegi +
        (1 - OnboardingConfig.hazirBaslangicOlcegi) *
            Curves.easeOutBack.transform(belirme);
    return Column(
      children: <Widget>[
        const Spacer(),
        Transform.scale(
          scale: olcek,
          child: DecoratedBox(
            // Kartın arkasından taşan sıcak ışık.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.goldAcik.withValues(
                    alpha: OnboardingConfig.hazirHaleOpakligi * belirme,
                  ),
                  blurRadius: OnboardingConfig.hazirHaleBulanikligi,
                ),
              ],
            ),
            // Ana ekrandaki kader kartına uçar.
            child: Hero(
              tag: HeroTags.skorHalkasi,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.asset(
                  AppImages.kartHazir,
                  width: OnboardingConfig.hazirKartGenisligi,
                  height: OnboardingConfig.hazirKartYuksekligi,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l.onboardingKartinHazir,
          style: yazi.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l.onboardingKartinHazirAlt,
          style: yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: AppColors.gold.withValues(
                alpha: OnboardingConfig.notCizgiOpakligi,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.gold,
                size: AppSpacing.md + AppSpacing.xs,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.onboardingHazirlikTamamlandi,
                style: yazi.bodySmall?.copyWith(color: AppColors.goldAcik),
              ),
            ],
          ),
        ),
        const Spacer(),
        AltinButon(
          genislik: null,
          metin: l.onboardingKartimaGec,
          onPressed: belirme < 1 ? null : onGec,
        ),
      ],
    );
  }
}
