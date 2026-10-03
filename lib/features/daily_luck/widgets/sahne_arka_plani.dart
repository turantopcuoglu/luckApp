import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_images.dart';
import '../daily_luck_config.dart';

/// Ana ekranın tam ekran, yaşayan arka planı.
///
/// Katmanlar (alttan üste):
/// 1. Kapalı sahne görseli ([AppImages.sahneKapali]).
/// 2. Skor sahnesi görseli ([acikSahne]); [gecis] 0→1 ile belirir.
/// 3. Parıldayan yıldızlar (CustomPainter).
/// 4. Alt karartma: okuma metinleri koyu zeminde kalsın.
/// 5. Kaydırma karartması: içerik kaydıkça sahne geri çekilir.
///
/// İki görsel de yavaş bir Ken Burns hareketiyle (yakınlaşma + hafif
/// kayma) nefes alır. Döngü controller'ı lokal animasyon state'idir
/// (kural 5); "Hareketi azalt" açıksa döngü hiç başlamaz.
class SahneArkaPlani extends StatefulWidget {
  /// [acikSahne] görseli ve [gecis] animasyonu ile arka plan kurar.
  const SahneArkaPlani({
    required this.acikSahne,
    required this.gecis,
    this.kaydirma,
    super.key,
  });

  /// Yalnız kapalı sahneyi gösteren (yükleme/hata durumları) arka plan.
  const SahneArkaPlani.kapali({super.key})
    : acikSahne = null,
      gecis = kAlwaysDismissedAnimation,
      kaydirma = null;

  /// Kart açılınca gelen skor sahnesi (asset yolu); null ise yalnız
  /// kapalı sahne çizilir.
  final String? acikSahne;

  /// Kapalı → açık sahne geçişi (0 = kapalı, 1 = açık).
  final Animation<double> gecis;

  /// Ekran kaydırıcısı; verilirse kaydırdıkça arka plan kararır.
  final ScrollController? kaydirma;

  @override
  State<SahneArkaPlani> createState() => _SahneArkaPlaniState();
}

class _SahneArkaPlaniState extends State<SahneArkaPlani>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dongu = AnimationController(
    vsync: this,
    duration: DailyLuckConfig.sahneDongusu,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Erişilebilirlik: hareket azaltılmışsa sahne sabit durur.
    if (MediaQuery.disableAnimationsOf(context)) {
      _dongu.stop();
    } else if (!_dongu.isAnimating) {
      _dongu.repeat();
    }
  }

  @override
  void dispose() {
    _dongu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? acikSahne = widget.acikSahne;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const ColoredBox(color: AppColors.background),
          // Görseller tek RepaintBoundary'de: Ken Burns her karede yalnız
          // bu katmanın transform'unu değiştirir.
          RepaintBoundary(
            child: _KenBurns(
              dongu: _dongu,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  const _SahneGorseli(yol: AppImages.sahneKapali),
                  if (acikSahne != null)
                    FadeTransition(
                      opacity: widget.gecis,
                      child: _SahneGorseli(yol: acikSahne),
                    ),
                ],
              ),
            ),
          ),
          RepaintBoundary(
            child: CustomPaint(painter: _YildizPainter(dongu: _dongu)),
          ),
          const _AltKarartma(),
          if (widget.kaydirma != null)
            _KaydirmaKarartmasi(kaydirma: widget.kaydirma!),
        ],
      ),
    );
  }
}

/// Tam ekranı kaplayan, kırpılarak ortalanmış sahne görseli.
class _SahneGorseli extends StatelessWidget {
  const _SahneGorseli({required this.yol});

  final String yol;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      yol,
      fit: BoxFit.cover,
      // Görsel yüklenirken zemin rengi görünür; ani beyaz parlama olmaz.
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }
}

/// Çocuğunu döngü boyunca yavaşça yakınlaştırıp hafifçe kaydırır.
class _KenBurns extends StatelessWidget {
  const _KenBurns({required this.dongu, required this.child});

  final Animation<double> dongu;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dongu,
      child: child,
      builder: (BuildContext context, Widget? cocuk) {
        // Kosinüs dalgası: döngü başı ve sonu aynı noktada, sarsıntısız
        // başa sarar (0 → 1 → 0).
        final double dalga = (1 - cos(dongu.value * 2 * pi)) / 2;
        final double olcek = 1 + (DailyLuckConfig.kenBurnsOlcegi - 1) * dalga;
        final double kayma =
            sin(dongu.value * 2 * pi) *
            DailyLuckConfig.kenBurnsKaymasi *
            MediaQuery.sizeOf(context).width;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(kayma, 0, 0, 1)
            ..scaleByDouble(olcek, olcek, 1, 1),
          child: cocuk,
        );
      },
    );
  }
}

/// Üst bölgede rastgele (sabit tohumlu) yıldızların parıldaması.
class _YildizPainter extends CustomPainter {
  _YildizPainter({required this.dongu}) : super(repaint: dongu);

  final Animation<double> dongu;

  /// Yıldızlar bir kez üretilir: (x, y, çap, faz) — oranlar 0-1.
  static final List<_Yildiz> _yildizlar = _uret();

  static List<_Yildiz> _uret() {
    final Random r = Random(DailyLuckConfig.yildizTohumu);
    return List<_Yildiz>.generate(
      DailyLuckConfig.yildizSayisi,
      (int i) => _Yildiz(
        x: r.nextDouble(),
        y: r.nextDouble() * DailyLuckConfig.yildizBolgesiOrani,
        cap:
            (DailyLuckConfig.yildizMinCapOrani +
                r.nextDouble() * (1 - DailyLuckConfig.yildizMinCapOrani)) *
            DailyLuckConfig.yildizMaksCapi,
        faz: r.nextDouble(),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint boya = Paint();
    for (final _Yildiz y in _yildizlar) {
      // Her yıldız döngüde parildamaKati kez parlar; faz kaydırması
      // yıldızların aynı anda yanıp sönmesini engeller.
      final double t =
          (dongu.value * DailyLuckConfig.parildamaKati + y.faz) % 1;
      final double parlaklik = pow(
        sin(t * pi),
        DailyLuckConfig.parildamaKeskinligi,
      ).toDouble();
      if (parlaklik < DailyLuckConfig.yildizCizimEsigi) {
        continue;
      }
      final Offset merkez = Offset(y.x * size.width, y.y * size.height);
      boya
        ..color = AppColors.isikCekirdegi.withValues(alpha: parlaklik)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          DailyLuckConfig.yildizBulanikligi,
        );
      // Sönükken küçük, parlarken tam çap: göz kırpma hissi.
      final double capOrani =
          DailyLuckConfig.yildizSonukCapOrani +
          (1 - DailyLuckConfig.yildizSonukCapOrani) * parlaklik;
      canvas.drawCircle(merkez, y.cap * capOrani, boya);
    }
  }

  @override
  bool shouldRepaint(_YildizPainter eski) => eski.dongu != dongu;
}

/// Tek bir parıldayan yıldızın sabit özellikleri.
class _Yildiz {
  const _Yildiz({
    required this.x,
    required this.y,
    required this.cap,
    required this.faz,
  });

  final double x;
  final double y;
  final double cap;
  final double faz;
}

/// Ekranın alt kısmını zemin rengine indiren dikey gradyan.
class _AltKarartma extends StatelessWidget {
  const _AltKarartma();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.background.withValues(alpha: 0),
            AppColors.background,
          ],
          stops: const <double>[
            DailyLuckConfig.altKarartmaBaslangici,
            DailyLuckConfig.altKarartmaSonu,
          ],
        ),
      ),
    );
  }
}

/// Kaydırma miktarıyla koyulaşan düz karartma (okuma odağı).
class _KaydirmaKarartmasi extends StatelessWidget {
  const _KaydirmaKarartmasi({required this.kaydirma});

  final ScrollController kaydirma;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: kaydirma,
      builder: (BuildContext context, Widget? child) {
        final double ofset = kaydirma.hasClients ? kaydirma.offset : 0;
        final double oran = (ofset / DailyLuckConfig.kaydirmaKarartmaMesafesi)
            .clamp(0, 1);
        return ColoredBox(
          color: AppColors.background.withValues(
            alpha: oran * DailyLuckConfig.kaydirmaKarartmaMaks,
          ),
        );
      },
    );
  }
}
