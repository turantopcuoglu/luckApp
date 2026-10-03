import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'parilti_sprite.dart';
import 'sahne_config.dart';

/// Tam ekran, yaşayan sahne arka planı (tüm yeni stil ekranların zemini).
///
/// Katmanlar (alttan üste):
/// 1. Ana sahne görseli ([gorsel]).
/// 2. İkinci sahne ([acikGorsel]); [gecis] 0→1 ile belirir (ör. ana
///    ekranda kapalı sahneden skor sahnesine geçiş).
/// 3. Parıldayan yıldızlar (CustomPainter; iri olanlar parıltı sprite'ı).
/// 4. Ön plan katmanı ([onPlan], opsiyonel): kenarlardaki sütunlar;
///    kaydırmada ve geçişte arka plandan farklı hızda hareket eder
///    (paralaks).
/// 5. Alt karartma: okuma metinleri koyu zeminde kalsın.
/// 6. Kaydırma karartması ([kaydirma] verilirse).
///
/// Görseller yavaş bir Ken Burns hareketiyle (yakınlaşma + hafif kayma)
/// nefes alır. Döngü controller'ı lokal animasyon state'idir (kural 5);
/// "Hareketi azalt" açıksa döngü hiç başlamaz.
class SahneArkaPlani extends StatefulWidget {
  /// [gorsel] sahnesiyle arka plan kurar; diğer katmanlar opsiyoneldir.
  const SahneArkaPlani({
    required this.gorsel,
    this.acikGorsel,
    this.gecis = kAlwaysDismissedAnimation,
    this.kaydirma,
    this.onPlan,
    this.yildizlar = true,
    this.altKarartmaBaslangici = SahneConfig.altKarartmaBaslangici,
    this.altKarartmaSonu = SahneConfig.altKarartmaSonu,
    this.hizalama = Alignment.center,
    super.key,
  });

  /// Ana sahne görseli (asset yolu).
  final String gorsel;

  /// [gecis] ile belirecek ikinci sahne (asset yolu); null ise yalnız
  /// [gorsel] çizilir.
  final String? acikGorsel;

  /// [gorsel] → [acikGorsel] geçişi (0 = ana, 1 = ikinci sahne).
  final Animation<double> gecis;

  /// Ekran kaydırıcısı; verilirse kaydırdıkça arka plan kararır ve ön
  /// plan paralaksla kayar.
  final ScrollController? kaydirma;

  /// En öndeki şeffaf çerçeve katmanı (asset yolu; ör. sütunlar).
  final String? onPlan;

  /// Parıldayan yıldızlar çizilsin mi?
  final bool yildizlar;

  /// Alt karartmanın başladığı yükseklik (ekran oranı, 0-1).
  final double altKarartmaBaslangici;

  /// Alt karartmanın tam opak olduğu yükseklik (ekran oranı, 0-1).
  final double altKarartmaSonu;

  /// Görsellerin kırpılma hizası (ör. odak üstteyse topCenter).
  final Alignment hizalama;

  @override
  State<SahneArkaPlani> createState() => _SahneArkaPlaniState();
}

class _SahneArkaPlaniState extends State<SahneArkaPlani>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dongu = AnimationController(
    vsync: this,
    duration: SahneConfig.sahneDongusu,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PariltiSprite.yukle(context);
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
    final String? acikGorsel = widget.acikGorsel;
    final String? onPlan = widget.onPlan;
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
              olcek: SahneConfig.kenBurnsOlcegi,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _SahneGorseli(yol: widget.gorsel, hizalama: widget.hizalama),
                  if (acikGorsel != null)
                    FadeTransition(
                      opacity: widget.gecis,
                      child: _SahneGorseli(
                        yol: acikGorsel,
                        hizalama: widget.hizalama,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.yildizlar)
            RepaintBoundary(
              child: CustomPaint(painter: _YildizPainter(dongu: _dongu)),
            ),
          if (onPlan != null)
            RepaintBoundary(
              child: _OnPlan(
                yol: onPlan,
                dongu: _dongu,
                gecis: widget.gecis,
                kaydirma: widget.kaydirma,
              ),
            ),
          _AltKarartma(
            baslangic: widget.altKarartmaBaslangici,
            son: widget.altKarartmaSonu,
          ),
          if (widget.kaydirma != null)
            _KaydirmaKarartmasi(kaydirma: widget.kaydirma!),
        ],
      ),
    );
  }
}

/// Tam ekranı kaplayan, kırpılarak hizalanmış sahne görseli.
class _SahneGorseli extends StatelessWidget {
  const _SahneGorseli({required this.yol, required this.hizalama});

  final String yol;
  final Alignment hizalama;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      yol,
      fit: BoxFit.cover,
      alignment: hizalama,
      // Görsel yüklenirken zemin rengi görünür; ani beyaz parlama olmaz.
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }
}

/// Çocuğunu döngü boyunca yavaşça yakınlaştırıp hafifçe kaydırır.
class _KenBurns extends StatelessWidget {
  const _KenBurns({
    required this.dongu,
    required this.olcek,
    required this.child,
  });

  final Animation<double> dongu;

  /// Döngünün tepe noktasındaki ölçek.
  final double olcek;

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
        final double s = 1 + (olcek - 1) * dalga;
        final double kayma =
            sin(dongu.value * 2 * pi) *
            SahneConfig.kenBurnsKaymasi *
            MediaQuery.sizeOf(context).width;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(kayma, 0, 0, 1)
            ..scaleByDouble(s, s, 1, 1),
          child: cocuk,
        );
      },
    );
  }
}

/// Ön plan sütunları: ekranın üst kısmına, kenarlardan taşacak genişlikte
/// oturur. Kaydırınca içerikten yavaş, arka plandan hızlı yukarı kayar;
/// sahne geçişinde hafifçe yaklaşır (kapıdan içeri girme hissi).
class _OnPlan extends StatelessWidget {
  const _OnPlan({
    required this.yol,
    required this.dongu,
    required this.gecis,
    required this.kaydirma,
  });

  final String yol;
  final Animation<double> dongu;
  final Animation<double> gecis;
  final ScrollController? kaydirma;

  @override
  Widget build(BuildContext context) {
    final double genislik =
        MediaQuery.sizeOf(context).width * SahneConfig.onPlanGenislikOrani;
    final Widget gorsel = Opacity(
      opacity: SahneConfig.onPlanOpakligi,
      child: Image.asset(
        yol,
        width: genislik,
        fit: BoxFit.fitWidth,
        gaplessPlayback: true,
        excludeFromSemantics: true,
      ),
    );
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable?>[dongu, gecis, kaydirma]),
      child: gorsel,
      builder: (BuildContext context, Widget? cocuk) {
        final double ofset = (kaydirma?.hasClients ?? false)
            ? kaydirma!.offset
            : 0;
        final double dalga = (1 - cos(dongu.value * 2 * pi)) / 2;
        final double olcek =
            (1 + (SahneConfig.onPlanKenBurnsOlcegi - 1) * dalga) *
            (1 + (SahneConfig.onPlanGecisOlcegi - 1) * gecis.value);
        return OverflowBox(
          alignment: Alignment.topCenter,
          minWidth: genislik,
          maxWidth: genislik,
          child: Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(0, -ofset * SahneConfig.onPlanKaydirmaCarpani),
              child: Transform.scale(
                scale: olcek,
                alignment: Alignment.topCenter,
                child: cocuk,
              ),
            ),
          ),
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
    final Random r = Random(SahneConfig.yildizTohumu);
    return List<_Yildiz>.generate(SahneConfig.yildizSayisi, (int i) {
      final double capOrani =
          SahneConfig.yildizMinCapOrani +
          r.nextDouble() * (1 - SahneConfig.yildizMinCapOrani);
      return _Yildiz(
        x: r.nextDouble(),
        y: r.nextDouble() * SahneConfig.yildizBolgesiOrani,
        cap: capOrani * SahneConfig.yildizMaksCapi,
        faz: r.nextDouble(),
        sprite: capOrani >= SahneConfig.spriteYildizEsigi,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint boya = Paint()
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        SahneConfig.yildizBulanikligi,
      );
    for (final _Yildiz y in _yildizlar) {
      // Her yıldız döngüde parildamaKati kez parlar; faz kaydırması
      // yıldızların aynı anda yanıp sönmesini engeller.
      final double t = (dongu.value * SahneConfig.parildamaKati + y.faz) % 1;
      final double parlaklik = pow(
        sin(t * pi),
        SahneConfig.parildamaKeskinligi,
      ).toDouble();
      if (parlaklik < SahneConfig.yildizCizimEsigi) {
        continue;
      }
      final Offset merkez = Offset(y.x * size.width, y.y * size.height);
      // Sönükken küçük, parlarken tam çap: göz kırpma hissi.
      final double capOrani =
          SahneConfig.yildizSonukCapOrani +
          (1 - SahneConfig.yildizSonukCapOrani) * parlaklik;
      if (y.sprite) {
        PariltiSprite.ciz(
          canvas,
          merkez,
          y.cap * capOrani * SahneConfig.spriteYildizCarpani,
          AppColors.isikCekirdegi,
          parlaklik,
        );
      } else {
        boya.color = AppColors.isikCekirdegi.withValues(alpha: parlaklik);
        canvas.drawCircle(merkez, y.cap * capOrani, boya);
      }
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
    required this.sprite,
  });

  final double x;
  final double y;
  final double cap;
  final double faz;

  /// İri yıldız: nokta yerine dört uçlu parıltı sprite'ı.
  final bool sprite;
}

/// Ekranın alt kısmını zemin rengine indiren dikey gradyan.
class _AltKarartma extends StatelessWidget {
  const _AltKarartma({required this.baslangic, required this.son});

  final double baslangic;
  final double son;

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
          stops: <double>[baslangic, son],
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
        final double oran = (ofset / SahneConfig.kaydirmaKarartmaMesafesi)
            .clamp(0, 1);
        return ColoredBox(
          color: AppColors.background.withValues(
            alpha: oran * SahneConfig.kaydirmaKarartmaMaks,
          ),
        );
      },
    );
  }
}

/// Sahne arka planının önüne içerik koyan kısa yol: tam ekran
/// [SahneArkaPlani] + üstünde şeffaf bir Material içinde [child].
///
/// Şeffaf Material, içerikteki ListTile/InkWell dalga efektlerinin sahne
/// görselinin altında kalmamasını sağlar.
class SahneliZemin extends StatelessWidget {
  /// [gorsel] sahnesinin önüne [child] koyar.
  const SahneliZemin({
    required this.gorsel,
    required this.child,
    this.altKarartmaBaslangici = SahneConfig.altKarartmaBaslangici,
    this.altKarartmaSonu = SahneConfig.altKarartmaSonu,
    this.kaydirma,
    super.key,
  });

  /// Sahne görselinin asset yolu.
  final String gorsel;

  /// Sahnenin önündeki içerik.
  final Widget child;

  /// Alt karartmanın başladığı yükseklik (ekran oranı).
  final double altKarartmaBaslangici;

  /// Alt karartmanın tam opak olduğu yükseklik (ekran oranı).
  final double altKarartmaSonu;

  /// İçeriğin kaydırıcısı; verilirse kaydırdıkça sahne kararır.
  final ScrollController? kaydirma;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: SahneArkaPlani(
            gorsel: gorsel,
            hizalama: Alignment.topCenter,
            altKarartmaBaslangici: altKarartmaBaslangici,
            altKarartmaSonu: altKarartmaSonu,
            kaydirma: kaydirma,
          ),
        ),
        Positioned.fill(
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ],
    );
  }
}
