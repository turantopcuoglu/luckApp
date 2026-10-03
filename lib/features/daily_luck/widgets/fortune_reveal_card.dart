import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../daily_luck_config.dart';
import '../tr_strings.dart';

/// [t]'nin [bas, son] dilimi içindeki 0-1 konumu (dışında kırpılır).
double _dilim(double t, double bas, double son) =>
    ((t - bas) / (son - bas)).clamp(0.0, 1.0);

/// Kader kartı: kapalıyken yörüngesinde bir gezegenle süzülür; açılınca
/// dört fazlı bir koreografiyle "kapı gibi" ikiye ayrılır.
///
/// Fazlar (tek [acilis] animasyonu 0→1, oranlar [DailyLuckConfig]'te):
/// 1. **Mühür** (0-250 ms): kart basılır gibi sıkışır, mühür parlar.
/// 2. **Işık** (250-650 ms): ortadaki altın dikişten ışık yükselir, kart
///    hafifçe öne gelir.
/// 3. **Açılış** (650-1300 ms): kart iki kanada ayrılıp izleyiciye doğru
///    açılır; aradan ışık patlar, kıvılcımlar ve ışık şeritleri saçılır,
///    [onYuz] (skor) belirir.
/// 4. **Yerleşme** (1300-2000 ms): kanatlar hafif geri yaylanıp dışa
///    kayar ve söner; arka plandaki sahnenin kapıları onların yerini alır.
///
/// [acilis] dışarıdan verilir: arka plan sahnesi ve kartın altındaki
/// metinler aynı zaman çizgisine bağlıdır. Bekleme hareketi (süzülme,
/// yörünge, mühür nefesi) bu widget'ın lokal animasyon state'idir ve
/// açılış başlayınca durur.
class FortuneRevealCard extends StatefulWidget {
  /// Açılış animasyonu, yüzler ve dokunma callback'i ile kart kurar.
  const FortuneRevealCard({
    required this.acilis,
    required this.arkaYuz,
    required this.onYuz,
    required this.onDokun,
    this.vurgu = AppColors.gold,
    super.key,
  });

  /// Açılış zaman çizgisi (0 = kapalı, 1 = yerleşmiş).
  final Animation<double> acilis;

  /// Kart boyutunda kapalı yüz; açılışta tam ortadan ikiye bölünür.
  final Widget arkaYuz;

  /// Kart boyutunda, zemini şeffaf açık yüz (skor). Yalnız açılış
  /// fazından itibaren ağaca eklenir.
  final Widget onYuz;

  /// Karta dokunulduğunda çağrılır (açılışı ebeveyn başlatır).
  final VoidCallback onDokun;

  /// Işık patlaması, şeritler ve kıvılcımların rengi (skor sahnesi).
  final Color vurgu;

  @override
  State<FortuneRevealCard> createState() => _FortuneRevealCardState();
}

class _FortuneRevealCardState extends State<FortuneRevealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bekleme = AnimationController(
    vsync: this,
    duration: DailyLuckConfig.beklemeDongusu,
  );

  /// "Hareketi azalt" erişilebilirlik ayarı açık mı?
  bool _hareketAzaltilmis = false;

  @override
  void initState() {
    super.initState();
    widget.acilis.addListener(_beklemeyiGuncelle);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hareketAzaltilmis = MediaQuery.disableAnimationsOf(context);
    _beklemeyiGuncelle();
  }

  @override
  void didUpdateWidget(FortuneRevealCard eski) {
    super.didUpdateWidget(eski);
    if (eski.acilis != widget.acilis) {
      eski.acilis.removeListener(_beklemeyiGuncelle);
      widget.acilis.addListener(_beklemeyiGuncelle);
      _beklemeyiGuncelle();
    }
  }

  @override
  void dispose() {
    widget.acilis.removeListener(_beklemeyiGuncelle);
    _bekleme.dispose();
    super.dispose();
  }

  /// Bekleme döngüsü yalnız kart kapalıyken ve hareket serbestken döner;
  /// açılış başlayınca pil harcamamak için durdurulur.
  void _beklemeyiGuncelle() {
    final bool donsun = !_hareketAzaltilmis && widget.acilis.value == 0;
    if (donsun && !_bekleme.isAnimating) {
      _bekleme.repeat();
    } else if (!donsun && _bekleme.isAnimating) {
      _bekleme.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double w = DailyLuckConfig.kartGenisligi;
    const double h = DailyLuckConfig.kartYuksekligi;
    return Semantics(
      button: true,
      label: TrStrings.kartimiAc,
      child: GestureDetector(
        onTap: widget.onDokun,
        behavior: HitTestBehavior.opaque,
        // RepaintBoundary: açılış boyunca yalnızca kart katmanı boyanır.
        child: RepaintBoundary(
          child: SizedBox(
            width: w,
            height: h,
            child: AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[
                widget.acilis,
                _bekleme,
              ]),
              builder: (BuildContext context, Widget? child) =>
                  _sahne(widget.acilis.value, _bekleme.value),
            ),
          ),
        ),
      ),
    );
  }

  /// Tek karelik kart sahnesi: [t] açılış, [b] bekleme döngüsü (0-1).
  Widget _sahne(double t, double b) {
    const double w = DailyLuckConfig.kartGenisligi;

    final double muhur = _dilim(t, 0, DailyLuckConfig.muhurSonu);
    final double isik = _dilim(
      t,
      DailyLuckConfig.muhurSonu,
      DailyLuckConfig.isikSonu,
    );
    final double acilma = _dilim(
      t,
      DailyLuckConfig.isikSonu,
      DailyLuckConfig.acilisSonu,
    );
    final double yerlesme = _dilim(t, DailyLuckConfig.acilisSonu, 1);
    // Kanatların dışa kayması açılma + yerleşme boyunca tek parça sürer.
    final double kayma = Curves.easeInOutCubic.transform(
      _dilim(t, DailyLuckConfig.isikSonu, 1),
    );

    // Bekleme görünürlüğü: dokunuşla (mühür fazında) söner.
    final double bekleme = 1 - muhur;
    final double donguAcisi = b * 2 * pi;

    // Ölçek: mühürde basılıp bırakılır (sin tepesi), ışıkta öne gelir,
    // açılmada yerine döner.
    final double olcek = t <= DailyLuckConfig.muhurSonu
        ? 1 - (1 - DailyLuckConfig.muhurBasmaOlcegi) * sin(muhur * pi)
        : t <= DailyLuckConfig.isikSonu
        ? 1 +
              (DailyLuckConfig.isikYukselmeOlcegi - 1) *
                  Curves.easeOut.transform(isik)
        : DailyLuckConfig.isikYukselmeOlcegi +
              (1 - DailyLuckConfig.isikYukselmeOlcegi) * acilma;
    final double suzulme =
        sin(donguAcisi) * DailyLuckConfig.suzulmeGenligi * bekleme;

    // Mühür parıltısı: beklemede nefes alır, mühür + ışık fazında
    // dolup açılmada söner.
    final double nefes =
        DailyLuckConfig.muhurNefesMin +
        (DailyLuckConfig.muhurNefesMaks - DailyLuckConfig.muhurNefesMin) *
            (1 + sin(donguAcisi * DailyLuckConfig.muhurNefesKati)) /
            2;
    final double guc = t <= DailyLuckConfig.isikSonu
        ? Curves.easeOut.transform(_dilim(t, 0, DailyLuckConfig.isikSonu))
        : 1 - acilma;
    final double muhurParlakligi = max(nefes * bekleme, guc);

    // Kanat açısı: açılmada taşma açısına, yerleşmede son açıya yaylanır.
    final double kanatAcisi = t <= DailyLuckConfig.acilisSonu
        ? DailyLuckConfig.kanatTasmaAcisi *
              Curves.easeInOutCubic.transform(acilma)
        : DailyLuckConfig.kanatTasmaAcisi +
              (DailyLuckConfig.kanatSonAcisi -
                      DailyLuckConfig.kanatTasmaAcisi) *
                  Curves.easeOutBack.transform(yerlesme);
    final double kanatOpakligi =
        1 -
        (1 - DailyLuckConfig.kanatSonOpakligi) *
            Curves.easeIn.transform(yerlesme);
    final bool bolunmus = t > DailyLuckConfig.isikSonu;

    return Transform.translate(
      offset: Offset(0, suzulme),
      child: Transform.scale(
        scale: olcek,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: <Widget>[
            // Yörüngenin arka yarısı (kartın arkasından geçen kısım).
            if (bekleme > 0)
              CustomPaint(
                painter: _YorungePainter(
                  aci: donguAcisi,
                  opaklik: bekleme,
                  on: false,
                ),
              ),
            // Açık yüz ve aradan sızan ışık patlaması (kanatların altında).
            if (bolunmus) ...<Widget>[
              CustomPaint(
                painter: _PatlamaPainter(
                  ilerleme: acilma,
                  sonuk: yerlesme,
                  renk: widget.vurgu,
                ),
              ),
              Opacity(
                opacity: Curves.easeIn.transform(acilma),
                child: Transform.scale(
                  scale:
                      DailyLuckConfig.onYuzBaslangicOlcegi +
                      (1 - DailyLuckConfig.onYuzBaslangicOlcegi) *
                          Curves.easeOutCubic.transform(acilma),
                  child: widget.onYuz,
                ),
              ),
            ],
            if (!bolunmus)
              widget.arkaYuz
            else if (kanatOpakligi > 0) ...<Widget>[
              _Kanat(
                sol: true,
                aci: kanatAcisi,
                kayma: kayma * DailyLuckConfig.kanatKaymaOrani * w,
                opaklik: kanatOpakligi,
                kenarIsigi: sin(acilma * pi),
                renk: widget.vurgu,
                child: widget.arkaYuz,
              ),
              _Kanat(
                sol: false,
                aci: kanatAcisi,
                kayma: kayma * DailyLuckConfig.kanatKaymaOrani * w,
                opaklik: kanatOpakligi,
                kenarIsigi: sin(acilma * pi),
                renk: widget.vurgu,
                child: widget.arkaYuz,
              ),
            ],
            // Mühür parıltısı ve ışık dikişi kartın üstünde.
            if (!bolunmus || acilma < 1)
              CustomPaint(
                painter: _MuhurVeDikisPainter(
                  parlaklik: muhurParlakligi,
                  dikisBoyu: Curves.easeOutCubic.transform(isik),
                  dikisOpakligi: isik > 0 ? 1 - acilma : 0,
                ),
              ),
            if (bolunmus)
              CustomPaint(
                painter: _KivilcimPainter(
                  ilerleme: _dilim(t, DailyLuckConfig.isikSonu, 1),
                  renk: widget.vurgu,
                ),
              ),
            if (bolunmus)
              CustomPaint(
                painter: _SeritPainter(
                  ilerleme: _dilim(t, DailyLuckConfig.isikSonu, 1),
                  renk: widget.vurgu,
                ),
              ),
            // Yörüngenin ön yarısı (kartın önünden geçen kısım).
            if (bekleme > 0)
              CustomPaint(
                painter: _YorungePainter(
                  aci: donguAcisi,
                  opaklik: bekleme,
                  on: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Kartın bir yarısı: dış kenarından menteşelenip izleyiciye doğru açılır.
class _Kanat extends StatelessWidget {
  const _Kanat({
    required this.sol,
    required this.aci,
    required this.kayma,
    required this.opaklik,
    required this.kenarIsigi,
    required this.renk,
    required this.child,
  });

  /// Sol kanat mı (menteşe solda)?
  final bool sol;

  /// Dönüş açısı (radyan, 0 = kapalı).
  final double aci;

  /// Dışa kayma (piksel).
  final double kayma;

  /// Kanadın opaklığı (yerleşmede söner).
  final double opaklik;

  /// İç kenardaki ışık çizgisinin gücü (0-1).
  final double kenarIsigi;

  /// İç kenar ışığının rengi.
  final Color renk;

  /// Kartın tam kapalı yüzü (yarısı kırpılır).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const double w = DailyLuckConfig.kartGenisligi;
    const double h = DailyLuckConfig.kartYuksekligi;
    final Alignment mentese = sol
        ? Alignment.centerLeft
        : Alignment.centerRight;
    // Sol kanat +açıyla, sağ kanat -açıyla döner: ikisinin de iç kenarı
    // izleyiciye yaklaşır (perspektifte büyür).
    final double yonluAci = sol ? aci : -aci;
    final double yonluKayma = sol ? -kayma : kayma;
    final BorderRadius disKoseler = sol
        ? const BorderRadius.horizontal(left: Radius.circular(AppRadius.md))
        : const BorderRadius.horizontal(right: Radius.circular(AppRadius.md));

    return Positioned(
      left: sol ? 0 : w / 2,
      top: 0,
      width: w / 2,
      height: h,
      child: Transform(
        alignment: mentese,
        transform: Matrix4.identity()
          ..setEntry(3, 2, DailyLuckConfig.kartFlipPerspektifi)
          ..translateByDouble(yonluKayma, 0, 0, 1)
          ..rotateY(yonluAci),
        child: Opacity(
          opacity: opaklik,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Tam kartı kanat genişliğinde kırp: sol kanat sol yarıyı,
              // sağ kanat sağ yarıyı gösterir.
              ClipRect(
                child: OverflowBox(
                  alignment: mentese,
                  minWidth: w,
                  maxWidth: w,
                  minHeight: h,
                  maxHeight: h,
                  child: child,
                ),
              ),
              // Döndükçe kararan yüz: ışık kaynağı aradaki boşluk.
              ClipRRect(
                borderRadius: disKoseler,
                child: ColoredBox(
                  color: AppColors.golge.withValues(
                    alpha: DailyLuckConfig.kanatGolgeOpakligi * sin(aci),
                  ),
                ),
              ),
              // İç kenarda ince ışık çizgisi.
              Align(
                alignment: sol ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: DailyLuckConfig.dikisKalinligi,
                  decoration: BoxDecoration(
                    color: AppColors.isikCekirdegi.withValues(
                      alpha: kenarIsigi,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: renk.withValues(alpha: kenarIsigi),
                        blurRadius: DailyLuckConfig.dikisHaleBulanikligi,
                        spreadRadius: DailyLuckConfig.dikisKalinligi,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mühür parıltısı (merkezde radyal hale) ve dikey ışık dikişi.
class _MuhurVeDikisPainter extends CustomPainter {
  _MuhurVeDikisPainter({
    required this.parlaklik,
    required this.dikisBoyu,
    required this.dikisOpakligi,
  });

  /// Mühür halesinin gücü (0-1).
  final double parlaklik;

  /// Dikişin merkezden iki yöne uzanma oranı (0-1).
  final double dikisBoyu;

  /// Dikişin opaklığı (açılmada söner).
  final double dikisOpakligi;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset merkez = size.center(Offset.zero);

    if (parlaklik > 0) {
      final double r =
          size.width *
          DailyLuckConfig.muhurParlamaOrani *
          (DailyLuckConfig.muhurHaleMinCarpani +
              DailyLuckConfig.muhurHaleBuyumesi * parlaklik);
      canvas.drawCircle(
        merkez,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              AppColors.goldAcik.withValues(alpha: parlaklik),
              AppColors.gold.withValues(
                alpha: parlaklik * DailyLuckConfig.haleIcOpakligi,
              ),
              AppColors.gold.withValues(alpha: 0),
            ],
            stops: const <double>[0, DailyLuckConfig.haleIcDuragi, 1],
          ).createShader(Rect.fromCircle(center: merkez, radius: r))
          ..blendMode = BlendMode.plus,
      );
    }

    if (dikisBoyu > 0 && dikisOpakligi > 0) {
      final double yari = size.height / 2 * dikisBoyu;
      final Offset ust = merkez.translate(0, -yari);
      final Offset alt = merkez.translate(0, yari);
      // Önce geniş, bulanık hale; sonra ince beyaz çekirdek.
      canvas
        ..drawLine(
          ust,
          alt,
          Paint()
            ..color = AppColors.gold.withValues(alpha: dikisOpakligi)
            ..strokeWidth = DailyLuckConfig.dikisHaleKalinligi * dikisBoyu
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(
              BlurStyle.normal,
              DailyLuckConfig.dikisHaleBulanikligi,
            ),
        )
        ..drawLine(
          ust,
          alt,
          Paint()
            ..color = AppColors.isikCekirdegi.withValues(alpha: dikisOpakligi)
            ..strokeWidth = DailyLuckConfig.dikisKalinligi
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  @override
  bool shouldRepaint(_MuhurVeDikisPainter eski) =>
      eski.parlaklik != parlaklik ||
      eski.dikisBoyu != dikisBoyu ||
      eski.dikisOpakligi != dikisOpakligi;
}

/// Kanatlar aralanınca aradan taşan radyal ışık.
class _PatlamaPainter extends CustomPainter {
  _PatlamaPainter({
    required this.ilerleme,
    required this.sonuk,
    required this.renk,
  });

  /// Açılma fazı ilerlemesi (0-1): ışık büyür.
  final double ilerleme;

  /// Yerleşme fazı ilerlemesi (0-1): ışık söner.
  final double sonuk;

  /// Işığın dış rengi (skor sahnesi vurgusu).
  final Color renk;

  @override
  void paint(Canvas canvas, Size size) {
    final double guc = Curves.easeOut.transform(ilerleme) * (1 - sonuk);
    if (guc <= 0) {
      return;
    }
    final Offset merkez = size.center(Offset.zero);
    final double r =
        size.width *
        DailyLuckConfig.patlamaYaricapOrani *
        Curves.easeOutCubic.transform(ilerleme);
    canvas.drawCircle(
      merkez,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            AppColors.isikCekirdegi.withValues(alpha: guc),
            renk.withValues(alpha: guc * DailyLuckConfig.haleIcOpakligi),
            renk.withValues(alpha: 0),
          ],
          stops: const <double>[0, DailyLuckConfig.haleIcDuragi, 1],
        ).createShader(Rect.fromCircle(center: merkez, radius: r))
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(_PatlamaPainter eski) =>
      eski.ilerleme != ilerleme || eski.sonuk != sonuk || eski.renk != renk;
}

/// Merkezden dışa saçılan, yavaşlayıp sönen kıvılcımlar.
class _KivilcimPainter extends CustomPainter {
  _KivilcimPainter({required this.ilerleme, required this.renk});

  /// Açılma + yerleşme boyunca ilerleme (0-1).
  final double ilerleme;

  /// Kıvılcım halesinin rengi.
  final Color renk;

  /// (yön açısı, hız oranı, çap oranı, dikişe göre dikey konum)
  static final List<List<double>> _kivilcimlar = _uret();

  static List<List<double>> _uret() {
    final Random r = Random(DailyLuckConfig.kivilcimTohumu);
    return List<List<double>>.generate(
      DailyLuckConfig.kivilcimSayisi,
      (int i) => <double>[
        r.nextDouble() * 2 * pi,
        DailyLuckConfig.kivilcimMinHizOrani +
            r.nextDouble() * (1 - DailyLuckConfig.kivilcimMinHizOrani),
        DailyLuckConfig.kivilcimMinCapOrani +
            r.nextDouble() * (1 - DailyLuckConfig.kivilcimMinCapOrani),
        r.nextDouble() * 2 - 1,
      ],
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (ilerleme <= 0 || ilerleme >= 1) {
      return;
    }
    final Offset merkez = size.center(Offset.zero);
    final double yol = Curves.easeOutCubic.transform(ilerleme);
    final double sonum = pow(
      1 - ilerleme,
      DailyLuckConfig.kivilcimSonumUssu,
    ).toDouble();
    final Paint hale = Paint()
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        DailyLuckConfig.kivilcimBulanikligi,
      );
    final Paint cekirdek = Paint();
    for (final List<double> k in _kivilcimlar) {
      // Kıvılcımlar dikiş boyunca farklı yüksekliklerden doğar.
      final Offset dogum = merkez.translate(
        0,
        k[3] * size.height * DailyLuckConfig.kivilcimDogumYayilimi,
      );
      final double mesafe =
          k[1] * DailyLuckConfig.kivilcimMesafeOrani * size.width * yol;
      final Offset konum = dogum + Offset(cos(k[0]), sin(k[0])) * mesafe;
      final double cap = k[2] * DailyLuckConfig.kivilcimMaksCapi;
      hale.color = renk.withValues(alpha: sonum);
      cekirdek.color = AppColors.isikCekirdegi.withValues(alpha: sonum);
      canvas
        ..drawCircle(konum, cap * DailyLuckConfig.kivilcimHaleCarpani, hale)
        ..drawCircle(konum, cap, cekirdek);
    }
  }

  @override
  bool shouldRepaint(_KivilcimPainter eski) =>
      eski.ilerleme != ilerleme || eski.renk != renk;
}

/// Kartın önünden kıvrılarak geçen, çizilip sönen ışık şeritleri.
class _SeritPainter extends CustomPainter {
  _SeritPainter({required this.ilerleme, required this.renk});

  /// Açılma + yerleşme boyunca ilerleme (0-1).
  final double ilerleme;

  /// Şerit rengi.
  final Color renk;

  @override
  void paint(Canvas canvas, Size size) {
    final double guc = sin(ilerleme * pi);
    if (guc <= 0) {
      return;
    }
    final double cizim = Curves.easeOutCubic.transform(ilerleme);
    for (int i = 0; i < DailyLuckConfig.seritSayisi; i++) {
      // Şeritler kartın biraz dışından başlayıp öbür yana taşar; her biri
      // farklı fazda dalgalanır ve zıt yönde akar.
      final double faz = i * pi + ilerleme * pi;
      final double merkezY =
          size.height *
          (DailyLuckConfig.seritIlkMerkezY + DailyLuckConfig.seritAraligi * i);
      final Path yol = Path();
      const int adim = DailyLuckConfig.seritAdimSayisi;
      for (int j = 0; j <= adim; j++) {
        final double oran = j / adim;
        final double x =
            size.width *
            (DailyLuckConfig.seritBaslangicX +
                DailyLuckConfig.seritYatayBoyu * oran);
        final double y =
            merkezY +
            sin(oran * 2 * pi + faz) *
                size.height *
                DailyLuckConfig.seritGenligi;
        if (j == 0) {
          yol.moveTo(x, y);
        } else {
          yol.lineTo(x, y);
        }
      }
      // Şerit soldan sağa (ikincisi sağdan sola) çizilerek uzar.
      final PathMetric olcu = yol.computeMetrics().first;
      final double uzunluk = olcu.length * cizim;
      final Path parca = i.isEven
          ? olcu.extractPath(0, uzunluk)
          : olcu.extractPath(olcu.length - uzunluk, olcu.length);
      canvas
        ..drawPath(
          parca,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth =
                DailyLuckConfig.seritKalinligi *
                DailyLuckConfig.seritHaleCarpani
            ..color = renk.withValues(
              alpha: guc * DailyLuckConfig.seritHaleOpakligi,
            )
            ..maskFilter = const MaskFilter.blur(
              BlurStyle.normal,
              DailyLuckConfig.seritBulanikligi,
            ),
        )
        ..drawPath(
          parca,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = DailyLuckConfig.seritKalinligi
            ..strokeCap = StrokeCap.round
            ..color = AppColors.isikCekirdegi.withValues(
              alpha: guc * DailyLuckConfig.seritCekirdekOpakligi,
            ),
        );
    }
  }

  @override
  bool shouldRepaint(_SeritPainter eski) =>
      eski.ilerleme != ilerleme || eski.renk != renk;
}

/// Kapalı kartın etrafındaki eğik yörünge ve üzerinde dönen küçük gezegen.
///
/// İki kez çizilir: [on] = false kartın arkasına (elipsin üst yarısı),
/// [on] = true kartın önüne (alt yarısı). Gezegen de bulunduğu yarıya
/// göre kartın önünde ya da arkasında görünür: sahte 3B derinlik.
class _YorungePainter extends CustomPainter {
  _YorungePainter({required this.aci, required this.opaklik, required this.on});

  /// Gezegenin yörüngedeki açısı (radyan).
  final double aci;

  /// Bekleme görünürlüğü (0-1).
  final double opaklik;

  /// Ön yarı mı çiziliyor?
  final bool on;

  @override
  void paint(Canvas canvas, Size size) {
    final double a = size.width * DailyLuckConfig.yorungeGenislikOrani / 2;
    final double b = size.width * DailyLuckConfig.yorungeYukseklikOrani / 2;
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(DailyLuckConfig.yorungeEgimi);

    // Elipsin ön yarısı sin > 0 (alt) bölgesidir: 0..π; arka yarı π..2π.
    final Rect elips = Rect.fromCenter(
      center: Offset.zero,
      width: a * 2,
      height: b * 2,
    );
    canvas.drawArc(
      elips,
      on ? 0 : pi,
      pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = DailyLuckConfig.yorungeKalinligi
        ..color = AppColors.gold.withValues(
          alpha: DailyLuckConfig.yorungeOpakligi * opaklik,
        ),
    );

    final bool gezegenOnde = sin(aci) > 0;
    if (gezegenOnde == on) {
      final Offset konum = Offset(a * cos(aci), b * sin(aci));
      const double r = DailyLuckConfig.gezegenCapi / 2;
      canvas
        ..drawCircle(
          konum,
          r * DailyLuckConfig.gezegenHaleCarpani,
          Paint()
            ..color = AppColors.gold.withValues(
              alpha: DailyLuckConfig.gezegenHaleOpakligi * opaklik,
            )
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, r),
        )
        ..drawCircle(
          konum,
          r,
          Paint()
            ..shader = RadialGradient(
              center: DailyLuckConfig.gezegenIsikNoktasi,
              colors: <Color>[
                AppColors.isikCekirdegi.withValues(alpha: opaklik),
                AppColors.gold.withValues(alpha: opaklik),
                AppColors.surface.withValues(alpha: opaklik),
              ],
            ).createShader(Rect.fromCircle(center: konum, radius: r)),
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_YorungePainter eski) =>
      eski.aci != aci || eski.opaklik != opaklik || eski.on != on;
}
