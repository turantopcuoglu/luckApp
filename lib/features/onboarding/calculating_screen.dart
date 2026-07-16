import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_dil.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../main.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/hero_tags.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../daily_luck/daily_luck_screen.dart';
import '../feedback/feedback_strings.dart';
import '../feedback/notification_service.dart';
import 'onboarding_config.dart';
import 'onboarding_strings.dart';

/// Onboarding adım 3: "Kaderin hesaplanıyor..." sahte hesaplama ekranı.
///
/// 2.5 sn'lik parçacık animasyonu (50 partikül merkezden dağılıp
/// toplanır) biter bitmez onboarding tamamlanır ve ana ekrana Hero
/// geçişiyle gidilir: ortadaki küçük halka, ana ekrandaki skor
/// halkasına büyüyerek uçar.
///
/// Geri tuşu bilinçli olarak kapalıdır (PopScope): yarım hesaplama
/// deneyimi yarıda kesilmez, akış ileri doğru akar.
class CalculatingScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const CalculatingScreen({super.key});

  @override
  ConsumerState<CalculatingScreen> createState() => _CalculatingScreenState();
}

class _CalculatingScreenState extends ConsumerState<CalculatingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol = AnimationController(
    vsync: this,
    duration: OnboardingConfig.hesaplamaSuresi,
  );

  @override
  void initState() {
    super.initState();
    _kontrol.addStatusListener(
      (AnimationStatus d) => unawaited(_animasyonBitti(d)),
    );
    _kontrol.forward();
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  /// Animasyon tamamlanınca onboarding bayrağı yazılır, bildirim izni
  /// istenir ve tüm onboarding yığını temizlenerek ana ekrana geçilir
  /// (geri tuşu artık onboarding'e dönemez).
  Future<void> _animasyonBitti(AnimationStatus durum) async {
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
    final bool izinVerildi = await bildirimler.izinIste();
    if (!mounted) {
      return;
    }

    // Ana ekran provider'ları misafir profiliyle değerlenmiş olabilir;
    // ŞANSLI SAATİ okumadan ÖNCE tazelenir ki bugünün kaydı ve şanslı
    // saat gerçek seed'le hesaplansın (misafir seed'iyle değil).
    ref
      ..invalidate(aktifProfilProvider)
      ..invalidate(gununSansiProvider);

    final AppDil dil = ref.read(dilProvider);
    if (izinVerildi) {
      final int sansliSaat = await ref.read(gununSansliSaatiProvider.future);
      unawaited(
        bildirimler.gunlukBildirimleriPlanla(
          simdi: DateTime.now(),
          sansliSaatBaslangiciSaati: sansliSaat,
          dil: dil,
        ),
      );
    } else {
      anaMesajciAnahtari.currentState?.showSnackBar(
        SnackBar(content: Text(FeedbackStrings.izinReddiMesaji(dil))),
      );
    }
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      fadeThroughRoute<void>(const DailyLuckScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              // Parçacık sistemi tüm ekranı kaplar; repaint yalnızca
              // controller tick'lerinde ve bu katmanda olur.
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _ParcacikPainter(animasyon: _kontrol),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Ana ekrandaki skor halkasına uçacak Hero tohumu.
                    Hero(
                      tag: HeroTags.skorHalkasi,
                      child: Container(
                        width: OnboardingConfig.heroHalkaBoyutu,
                        height: OnboardingConfig.heroHalkaBoyutu,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold,
                            width: OnboardingConfig.heroHalkaKalinligi,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      OnboardingStrings.hesaplaniyor(ref.watch(dilProvider)),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tek bir parçacığın sabit özellikleri (koreografisi).
class _Parcacik {
  const _Parcacik({
    required this.aci,
    required this.yaricapOrani,
    required this.boyut,
    required this.fazKaymasi,
  });

  /// Merkezden uçuş yönü (radyan).
  final double aci;

  /// Azami yarıçapın parçacığa özgü çarpanı (0-1).
  final double yaricapOrani;

  /// Parçacığın çapı.
  final double boyut;

  /// Saçılma zamanlamasındaki kişisel kayma (0-1): hepsi aynı anda
  /// hareket etmesin, bulut gibi dalgalanarak dağılsın.
  final double fazKaymasi;
}

/// Merkezden dağılıp geri toplanan 50 parçacığı çizen painter.
///
/// `repaint: animasyon` sayesinde her tick'te yalnızca boyama çalışır;
/// widget ağacı yeniden inşa edilmez (Session 5 performans kuralı).
class _ParcacikPainter extends CustomPainter {
  _ParcacikPainter({required this.animasyon}) : super(repaint: animasyon);

  /// 0→1 ilerleyen hesaplama animasyonu.
  final Animation<double> animasyon;

  /// Sabit tohumla üretilen parçacık kadrosu: her açılışta aynı,
  /// dolayısıyla test edilebilir ve titremesiz.
  static final List<_Parcacik> _parcaciklar = _uret();

  static List<_Parcacik> _uret() {
    final Random rnd = Random(OnboardingConfig.parcacikTohumu);
    return List<_Parcacik>.generate(
      OnboardingConfig.parcacikSayisi,
      (int i) => _Parcacik(
        aci: rnd.nextDouble() * 2 * pi,
        yaricapOrani: 0.4 + rnd.nextDouble() * 0.6,
        boyut:
            OnboardingConfig.parcacikMinBoyut +
            rnd.nextDouble() *
                (OnboardingConfig.parcacikMaksBoyut -
                    OnboardingConfig.parcacikMinBoyut),
        fazKaymasi: rnd.nextDouble() * 0.2,
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset merkez = size.center(Offset.zero);
    final double azamiYaricap =
        size.shortestSide * OnboardingConfig.parcacikYaricapOrani;
    final Paint boya = Paint()..color = AppColors.gold;

    for (final _Parcacik p in _parcaciklar) {
      // Faz kaymalı ilerleme: her parçacık kendi zaman diliminde
      // 0→1 tamamlar (kayma kadar geç başlar, o kadar erken biter).
      final double t = ((animasyon.value - p.fazKaymasi) / (1 - p.fazKaymasi))
          .clamp(0.0, 1.0);
      // sin(pi*t): 0'da merkezde, 0.5'te en dışta, 1'de merkeze döner —
      // "dağıl ve toplan" koreografisinin tamamı tek fonksiyonda.
      final double uzaklik = sin(pi * t) * azamiYaricap * p.yaricapOrani;
      final Offset konum =
          merkez + Offset(cos(p.aci) * uzaklik, sin(p.aci) * uzaklik);

      // Dışa açıldıkça hafif solar, dönüşte tekrar parlar.
      boya.color = AppColors.gold.withValues(alpha: 1 - 0.6 * sin(pi * t));
      canvas.drawCircle(konum, p.boyut / 2, boya);
    }
  }

  @override
  bool shouldRepaint(_ParcacikPainter onceki) => false;
}
