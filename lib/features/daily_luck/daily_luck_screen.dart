import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/gunluk_okuma.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/daily_record.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/hero_tags.dart';
import '../ads/banner_reklam_alani.dart';
import '../categories/categories_strings.dart';
import '../categories/category_detail_screen.dart';
import '../categories/widgets/premium_gate.dart';
import '../feedback/feedback_screen.dart';
import '../home/ana_sekme.dart';
import '../legal/legal_texts.dart';
import '../premium/kilit_secenekleri.dart';
import '../premium/premium_providers.dart';
import '../premium/reklam_politikasi.dart';
import '../profile/yil_raporu_karti.dart';
import '../share/share_button.dart';
import 'daily_luck_config.dart';
import 'daily_luck_providers.dart';
import 'skor_sahnesi.dart';
import 'tr_strings.dart';
import 'widgets/category_card.dart';
import 'widgets/comment_card.dart';
import 'widgets/fortune_reveal_card.dart';
import 'widgets/gunun_puani.dart';
import 'widgets/kutu_acilisi.dart';
import 'widgets/lucky_row.dart';
import 'widgets/neden_cipleri.dart';
import 'widgets/sahne_arka_plani.dart';

/// Ana ekran: yaşayan bir gece sahnesinin önünde tarih + selamlama,
/// ortada kapalı kader kartı, altında kapalı kategori karoları; kart
/// açılınca skor sahnesi gelir ve kişiye özel bölümlü okuma belirir.
///
/// Akış: karta (ya da "Kartımı aç"a) dokun → mühür → ışık dikişi →
/// kart iki kanat hâlinde açılır, arka plan skor sahnesine geçer, skor
/// sayar → karolar tek tek flip'le açılır → okuma belirir.
class DailyLuckScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const DailyLuckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LuckResult> sonuc = ref.watch(gununSansiProvider);
    // Okuma saklanan sonuçtan senkron türetilir; iki provider birlikte
    // beklenir ki _Icerik null dalı olmadan tam veriyle kurulsun.
    final AsyncValue<GunlukOkuma> okuma = ref.watch(gunlukOkumaProvider);
    // Ana kabuk sekmeleri IndexedStack'te canlı kalır; sekme görünmezken
    // sahne/kart döngüleri durur ki pil harcanmasın.
    final bool gorunur =
        ref.watch(anaSekmeProvider) == AnaSekme.bugun.index;
    return TickerMode(
      enabled: gorunur,
      child: Scaffold(
        body: sonuc.when(
          data: (LuckResult veri) => okuma.when(
            data: (GunlukOkuma o) => _Icerik(sonuc: veri, okuma: o),
            loading: () => const _SahneliDurum(child: _Yukleniyor()),
            error: (Object hata, StackTrace iz) =>
                const _SahneliDurum(child: _Hata()),
          ),
          loading: () => const _SahneliDurum(child: _Yukleniyor()),
          error: (Object hata, StackTrace iz) =>
              const _SahneliDurum(child: _Hata()),
        ),
      ),
    );
  }
}

/// Yükleme/hata durumları: kapalı sahnenin önünde ortalanmış içerik.
class _SahneliDurum extends StatelessWidget {
  const _SahneliDurum({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(child: SahneArkaPlani.kapali()),
        SafeArea(child: child),
      ],
    );
  }
}

/// Başarılı durumda ekranın tam içeriği ve açılış orkestrasyonu.
///
/// İki controller burada yaşar: kart açılışı (arka plan sahnesi, kart ve
/// kartın altındaki metinler aynı zaman çizgisine bağlı) ve ardından
/// gelen karo/okuma açılışı. setState kullanılmaz — controller'ları
/// dinleyen alt widget'lar kendi kendini boyar (kural 5).
class _Icerik extends ConsumerStatefulWidget {
  const _Icerik({required this.sonuc, required this.okuma});

  final LuckResult sonuc;

  /// Günün kişiye özel okuması.
  final GunlukOkuma okuma;

  @override
  ConsumerState<_Icerik> createState() => _IcerikState();
}

class _IcerikState extends ConsumerState<_Icerik>
    with TickerProviderStateMixin {
  /// Kutu açılışları + okuma belirmesinin toplam süresi.
  static final Duration _kutuKontrolSuresi =
      DailyLuckConfig.kutuGecikmesi * (LuckCategory.values.length - 1) +
          DailyLuckConfig.kutuAcilisSuresi +
          DailyLuckConfig.yorumBelirmeSuresi;

  /// Kart açılışının zaman çizgisi (Mühür → Işık → Açılış → Yerleşme).
  late final AnimationController _kartKontrol = AnimationController(
    vsync: this,
    duration: DailyLuckConfig.kartAcilisSuresi,
  );

  late final AnimationController _kutuKontrol = AnimationController(
    vsync: this,
    duration: _kutuKontrolSuresi,
  );

  /// Arka planın kapalı sahneden skor sahnesine geçişi.
  late final Animation<double> _sahneGecisi = CurvedAnimation(
    parent: _kartKontrol,
    curve: const Interval(
      DailyLuckConfig.sahneGecisBaslangici,
      DailyLuckConfig.sahneGecisSonu,
      curve: Curves.easeInOut,
    ),
  );

  /// Skor count-up'ı ve ışık kemeri çizimi.
  late final Animation<double> _skorSayaci = CurvedAnimation(
    parent: _kartKontrol,
    curve: const Interval(
      DailyLuckConfig.skorSayacBaslangici,
      1,
      curve: DailyLuckConfig.skorSayacEgrisi,
    ),
  );

  /// Okumanın belirme dilimi: sürenin sonundaki fade parçası.
  late final Animation<double> _okumaOpakligi = CurvedAnimation(
    parent: _kutuKontrol,
    curve: Interval(
      1 -
          DailyLuckConfig.yorumBelirmeSuresi.inMilliseconds /
              _kutuKontrolSuresi.inMilliseconds,
      1,
      curve: Curves.easeOut,
    ),
  );

  /// Arka planın kaydırmayla kararması için ekran kaydırıcısı.
  final ScrollController _kaydirma = ScrollController();

  /// Kanatlar açılırken verilen hafif titreşim bir kez çalsın.
  bool _kanatTitresimiVerildi = false;

  /// Günün skor sahnesi (görsel + vurgu rengi).
  SkorSahnesi get _sahne => SkorSahnesi.skordan(widget.sonuc.genelSkor);

  @override
  void initState() {
    super.initState();
    _kartKontrol
      ..addListener(_kanatTitresimi)
      ..addStatusListener((AnimationStatus durum) {
        if (durum == AnimationStatus.completed) {
          _kutuKontrol.forward();
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Açılışta görsel geç yüklenip sahne "boş" geçmesin diye önden çöz.
    unawaited(precacheImage(AssetImage(_sahne.gorsel), context));
    unawaited(
      precacheImage(const AssetImage(AppImages.kartArkaYuzu), context),
    );
  }

  @override
  void dispose() {
    _kartKontrol.dispose();
    _kutuKontrol.dispose();
    _kaydirma.dispose();
    super.dispose();
  }

  /// Kartı açar: yalnız kapalıyken; "tok dokunuş" titreşimiyle başlar.
  /// "Hareketi azalt" açıksa koreografi kısa bir geçişe iner.
  void _kartiAc() {
    if (_kartKontrol.value > 0 || _kartKontrol.isAnimating) {
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    _kartKontrol.duration = MediaQuery.disableAnimationsOf(context)
        ? DailyLuckConfig.azaltilmisAcilisSuresi
        : DailyLuckConfig.kartAcilisSuresi;
    _kartKontrol.forward();
  }

  /// Kanatlar ayrılmaya başladığı an hafif bir titreşim verir.
  void _kanatTitresimi() {
    if (!_kanatTitresimiVerildi &&
        _kartKontrol.value >= DailyLuckConfig.isikSonu) {
      _kanatTitresimiVerildi = true;
      unawaited(HapticFeedback.lightImpact());
    }
  }

  /// Kategori kutusuna dokunma: kilitliyse kilit seçenekleri, değilse
  /// detay; detaydan dönüşte (doğal ara) geçiş reklamı politikası denenir.
  Future<void> _kategoriyeDokun(LuckCategory kategori) async {
    if (ref.read(kategoriKilitliProvider(kategori))) {
      await kilitSecenekleriniGoster(
        context,
        ref,
        kilitAnahtari: KilitAnahtarlari.kategori(kategori),
        aciklama: CategoriesStrings.kilitAciklamasi(kategori.etiket),
      );
      return;
    }
    await Navigator.of(context).push(
      fadeThroughRoute<void>(CategoryDetailScreen(kategori: kategori)),
    );
    if (!mounted) {
      return;
    }
    await gecisReklamiDene(ref);
  }

  /// "Bu yorum seni anlattı mı?" cevabını okumanın tüm bölümleri için
  /// bugünün kaydına işler; "anlatmadı" denen varyantlar sonraki günlerde
  /// bu kişiye gösterilmez.
  ///
  /// Hive bellek içi durumu senkron güncellediği için disk yazması
  /// beklenmez; ekran cevabı anında yansıtır.
  void _okumayaCevapVer(GunlukOkuma okuma, {required bool anlatti}) {
    final DateTime gun = ref.read(bugunProvider);
    for (final OkumaBolumu bolum in okuma.bolumler) {
      unawaited(
        ref.read(luckHistoryRepositoryProvider).bolumGeriBildirimiKaydet(
              gun,
              bolumKimligi: bolum.kimlik,
              anlatti: anlatti,
            ),
      );
    }
    ref.invalidate(bugunKaydiProvider);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            anlatti ? TrStrings.anlattiTesekkur : TrStrings.anlatmadiTesekkur,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final DateTime bugun = ref.watch(bugunProvider);
    final UserProfile profil = ref.watch(aktifProfilProvider);
    final DailyRecord? kayit = ref.watch(bugunKaydiProvider);
    final GunlukOkuma okuma = widget.okuma;
    final SkorSahnesi sahne = _sahne;
    final bool aksamKarti = bugun.hour >= DailyLuckConfig.aksamKartiSaati &&
        kayit?.feedbackPozitif == null;

    return Stack(
      children: <Widget>[
        // Sabit, yaşayan arka plan: içerik üzerinde kayar.
        Positioned.fill(
          child: SahneArkaPlani(
            acikSahne: sahne.gorsel,
            gecis: _sahneGecisi,
            kaydirma: _kaydirma,
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            controller: _kaydirma,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Üst blok: tarih ve selamlama.
                Text(
                  TrStrings.tarihMetni(bugun),
                  textAlign: TextAlign.center,
                  style: yaziTemasi.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  TrStrings.selamlama(profil.isim),
                  textAlign: TextAlign.center,
                  style: yaziTemasi.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Orta blok: kader kartı (deste kartı oranında).
                // Hero: onboarding'deki küçük halka bu karta uçar.
                Center(
                  child: Hero(
                    tag: HeroTags.skorHalkasi,
                    child: FortuneRevealCard(
                      acilis: _kartKontrol,
                      vurgu: sahne.vurgu,
                      onDokun: _kartiAc,
                      arkaYuz: const _KapaliKartYuzu(),
                      onYuz: GununPuani(
                        skor: widget.sonuc.genelSkor,
                        ilerleme: _skorSayaci,
                        vurgu: sahne.vurgu,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Kartın altı: önce davet + "Kartımı aç", açılınca günün
                // başlığı.
                _KartAltiMetni(
                  acilis: _kartKontrol,
                  baslik: okuma.baslik,
                  onAc: _kartiAc,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Kategori karoları — kapalı (yalnız ikon) başlar, kart
                // açılınca tek tek flip'le açılır. Beşi bir satırı paylaşır.
                SizedBox(
                  height: DailyLuckConfig.kategoriKaroYuksekligi,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (int i = 0;
                          i < LuckCategory.values.length;
                          i++) ...<Widget>[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _KategoriKarosu(
                            indeks: i,
                            kategori: LuckCategory.values[i],
                            skor: widget.sonuc
                                .kategoriSkorlari[LuckCategory.values[i]]!,
                            animasyon: _kutuKontrol,
                            kontrolSuresi: _kutuKontrolSuresi,
                            onDokun: _kategoriyeDokun,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Okuma + şans ögeleri + paylaş: karolar açıldıktan sonra
                // birlikte belirir.
                FadeTransition(
                  opacity: _okumaOpakligi,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Mevcut yorum kartı korunur; içerik paragraflar hâlinde.
                      CommentCard(metin: okuma.kartMetni),
                      _AnlattiMiSatiri(
                        cevap: kayit?.bolumGeriBildirimleri[
                            okuma.bolumler.first.kimlik],
                        onCevap: (bool anlatti) =>
                            _okumayaCevapVer(okuma, anlatti: anlatti),
                      ),
                      NedenCipleri(nedenler: okuma.nedenler),
                      const SizedBox(height: AppSpacing.md),
                      SansOgeleriKarti(icerik: okuma),
                      const SizedBox(height: AppSpacing.md),
                      const YilRaporuKarti(),
                      if (aksamKarti) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        const _AksamKarti(),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: ShareButton(
                          sonuc: widget.sonuc,
                          baslik: okuma.baslik,
                        ),
                      ),
                      BannerReklamAlani(
                        goster: ref.watch(bannerGosterilebilirProvider),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        YasalMetinler.kisaNot,
                        style: yaziTemasi.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Tek kategori karosu: dokunma, premium kilidi ve sırası gelince flip.
class _KategoriKarosu extends ConsumerWidget {
  const _KategoriKarosu({
    required this.indeks,
    required this.kategori,
    required this.skor,
    required this.animasyon,
    required this.kontrolSuresi,
    required this.onDokun,
  });

  final int indeks;
  final LuckCategory kategori;
  final int skor;
  final Animation<double> animasyon;
  final Duration kontrolSuresi;
  final Future<void> Function(LuckCategory) onDokun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool kilitli = ref.watch(kategoriKilitliProvider(kategori));
    return GestureDetector(
      onTap: () => unawaited(onDokun(kategori)),
      child: PremiumGate(
        kilitli: kilitli,
        child: KutuAcilisi(
          animasyon: animasyon,
          kontrolSuresi: kontrolSuresi,
          indeks: indeks,
          kapali: KapaliKategoriKutusu(kategori: kategori),
          acik: CategoryCard(kategori: kategori, skor: skor),
        ),
      ),
    );
  }
}

/// Yorum kartının altındaki "Bu yorum seni anlattı mı? 👍 👎" satırı.
class _AnlattiMiSatiri extends StatelessWidget {
  const _AnlattiMiSatiri({required this.cevap, required this.onCevap});

  /// Bugün verilmiş cevap (null = yok).
  final bool? cevap;

  /// 👍 (true) / 👎 (false).
  final ValueChanged<bool> onCevap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          TrStrings.seniAnlattiMi,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        IconButton(
          tooltip: TrStrings.evet,
          onPressed: () => onCevap(true),
          icon: Icon(
            cevap == true
                ? Icons.thumb_up_alt_rounded
                : Icons.thumb_up_alt_outlined,
            color: cevap == true ? AppColors.gold : AppColors.textSecondary,
            size: DailyLuckConfig.bolumIkonBoyutu,
          ),
        ),
        IconButton(
          tooltip: TrStrings.hayir,
          onPressed: () => onCevap(false),
          icon: Icon(
            cevap == false
                ? Icons.thumb_down_alt_rounded
                : Icons.thumb_down_alt_outlined,
            color: cevap == false ? AppColors.purple : AppColors.textSecondary,
            size: DailyLuckConfig.bolumIkonBoyutu,
          ),
        ),
      ],
    );
  }
}

/// Akşam saatlerinde, geri bildirim verilmemişse görünen kart.
class _AksamKarti extends StatelessWidget {
  const _AksamKarti();

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(TrStrings.aksamKartiBaslik, style: yazi.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              TrStrings.aksamKartiAciklama,
              style: yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  fadeThroughRoute<void>(const FeedbackScreen()),
                ),
                child: const Text(TrStrings.aksamKartiButon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kader kartının kapalı yüzü: lacivert mermer, altın mühür ve ortadan
/// dikey altın dikiş (açılışta kart bu dikişten ikiye ayrılır).
class _KapaliKartYuzu extends StatelessWidget {
  const _KapaliKartYuzu();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.asset(
        AppImages.kartArkaYuzu,
        width: DailyLuckConfig.kartGenisligi,
        height: DailyLuckConfig.kartYuksekligi,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        excludeFromSemantics: true,
        // Yüklenene kadar koyu yüzey: kart yerinde "boş" görünmez.
        frameBuilder: (
          BuildContext context,
          Widget child,
          int? kare,
          bool senkronYuklendi,
        ) =>
            kare == null && !senkronYuklendi
                ? const ColoredBox(color: AppColors.surface)
                : child,
      ),
    );
  }
}

/// Kartın altındaki metin bloğu: kapalıyken "Bugünün kartı hazır" daveti
/// ve altın "Kartımı aç" butonu; açılınca günün başlığı.
///
/// İki blok aynı yerde üst üste durur (yükseklik sabit kalır, altındaki
/// karolar zıplamaz); [acilis] zaman çizgisine göre biri söner, öbürü
/// belirir. Görünmeyen blok dokunuş ve ekran okuyucudan gizlenir.
class _KartAltiMetni extends StatelessWidget {
  const _KartAltiMetni({
    required this.acilis,
    required this.baslik,
    required this.onAc,
  });

  /// Kart açılış zaman çizgisi.
  final Animation<double> acilis;

  /// Günün başlığı (okumanın başlığı).
  final String baslik;

  /// "Kartımı aç" dokunuşu.
  final VoidCallback onAc;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final Widget davet = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          TrStrings.kartHazir,
          textAlign: TextAlign.center,
          style: yazi.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          TrStrings.kendineBirDakika,
          textAlign: TextAlign.center,
          style: yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        _AltinButon(metin: TrStrings.kartimiAc, onPressed: onAc),
      ],
    );
    final Widget gununBasligi = Text(
      baslik,
      textAlign: TextAlign.center,
      style: yazi.headlineMedium,
    );

    return AnimatedBuilder(
      animation: acilis,
      builder: (BuildContext context, Widget? child) {
        final double t = acilis.value;
        // Davet dokunuşla (mühür fazında) söner; başlık yerleşmede belirir.
        final double davetOpakligi =
            1 - (t / DailyLuckConfig.muhurSonu).clamp(0.0, 1.0);
        final double baslikOpakligi = Curves.easeOut.transform(
          ((t - DailyLuckConfig.acilisSonu) / (1 - DailyLuckConfig.acilisSonu))
              .clamp(0.0, 1.0),
        );
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            IgnorePointer(
              ignoring: t > 0,
              child: ExcludeSemantics(
                excluding: t > 0,
                child: Opacity(opacity: davetOpakligi, child: davet),
              ),
            ),
            ExcludeSemantics(
              excluding: baslikOpakligi == 0,
              child: Opacity(
                opacity: baslikOpakligi,
                // Başlık yerleşirken hafifçe yukarı süzülür.
                child: Transform.translate(
                  offset: Offset(0, AppSpacing.sm * (1 - baslikOpakligi)),
                  child: gununBasligi,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Altın gradyanlı, hafif parlayan hap buton.
class _AltinButon extends StatelessWidget {
  const _AltinButon({required this.metin, required this.onPressed});

  final String metin;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DailyLuckConfig.acButonGenisligi,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          gradient: const LinearGradient(
            colors: <Color>[AppColors.goldAcik, AppColors.gold],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.gold.withValues(
                alpha: DailyLuckConfig.acButonGolgeOpakligi,
              ),
              blurRadius: DailyLuckConfig.acButonGolgesi,
            ),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(metin),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skor üretilirken gösterilen basit yükleme durumu.
class _Yukleniyor extends StatelessWidget {
  const _Yukleniyor();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(color: AppColors.gold),
          const SizedBox(height: AppSpacing.md),
          Text(
            TrStrings.yukleniyor,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Beklenmeyen hata durumu.
class _Hata extends StatelessWidget {
  const _Hata();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          TrStrings.hataMetni,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
