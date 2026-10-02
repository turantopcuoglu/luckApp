import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/gunluk_okuma.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/daily_record.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/hero_tags.dart';
import '../ads/banner_reklam_alani.dart';
import '../categories/categories_strings.dart';
import '../categories/category_detail_screen.dart';
import '../categories/widgets/premium_gate.dart';
import '../feedback/feedback_screen.dart';
import '../legal/legal_texts.dart';
import '../premium/kilit_secenekleri.dart';
import '../premium/premium_providers.dart';
import '../premium/reklam_politikasi.dart';
import '../share/share_button.dart';
import 'daily_luck_config.dart';
import 'daily_luck_providers.dart';
import 'tr_strings.dart';
import 'widgets/animated_score_ring.dart';
import 'widgets/category_card.dart';
import 'widgets/comment_card.dart';
import 'widgets/fortune_reveal_card.dart';
import 'widgets/kutu_acilisi.dart';
import 'widgets/lucky_row.dart';
import 'widgets/neden_cipleri.dart';

/// Ana ekran: üstte tarih + selamlama + profil özeti, ortada kapalı kader
/// kartı, altında kapalı kategori kutuları; kart açılınca kişiye özel
/// bölümlü okuma belirir.
///
/// Akış: karta dokun → 3D flip → ekrana yaklaşıp "düşme" → skor
/// count-up → kutular tek tek flip'le açılır → okuma belirir.
class DailyLuckScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const DailyLuckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LuckResult> sonuc = ref.watch(gununSansiProvider);
    // Okuma saklanan sonuçtan senkron türetilir; iki provider birlikte
    // beklenir ki _Icerik null dalı olmadan tam veriyle kurulsun.
    final AsyncValue<GunlukOkuma> okuma = ref.watch(gunlukOkumaProvider);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const _YildizArkaPlani(),
          SafeArea(
            child: sonuc.when(
              data: (LuckResult veri) => okuma.when(
                data: (GunlukOkuma o) => _Icerik(sonuc: veri, okuma: o),
                loading: () => const _Yukleniyor(),
                error: (Object hata, StackTrace iz) => const _Hata(),
              ),
              loading: () => const _Yukleniyor(),
              error: (Object hata, StackTrace iz) => const _Hata(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Köşelerde soluk yıldız/parçacık deseni (Session 4 asset'i).
class _YildizArkaPlani extends StatelessWidget {
  const _YildizArkaPlani();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: DailyLuckConfig.yildizDesenTasmasi,
            right: DailyLuckConfig.yildizDesenTasmasi,
            child: AppIllustrations.yildizDeseni(
              boyut: DailyLuckConfig.yildizDesenBoyutu,
            ),
          ),
          Positioned(
            bottom: DailyLuckConfig.yildizDesenTasmasi,
            left: DailyLuckConfig.yildizDesenTasmasi,
            child: AppIllustrations.yildizDeseni(
              boyut: DailyLuckConfig.yildizDesenBoyutu,
            ),
          ),
        ],
      ),
    );
  }
}

/// Başarılı durumda ekranın tam içeriği ve açılış orkestrasyonu.
///
/// Kutu/okuma açılış controller'ı burada yaşar; kart açılışı bitince
/// (onAcilisTamam) tetiklenir. setState kullanılmaz — controller'ı
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
    with SingleTickerProviderStateMixin {
  /// Kutu açılışları + okuma belirmesinin toplam süresi.
  static final Duration _kutuKontrolSuresi =
      DailyLuckConfig.kutuGecikmesi * (LuckCategory.values.length - 1) +
          DailyLuckConfig.kutuAcilisSuresi +
          DailyLuckConfig.yorumBelirmeSuresi;

  late final AnimationController _kutuKontrol = AnimationController(
    vsync: this,
    duration: _kutuKontrolSuresi,
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

  @override
  void dispose() {
    _kutuKontrol.dispose();
    super.dispose();
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
    final bool aksamKarti = bugun.hour >= DailyLuckConfig.aksamKartiSaati &&
        kayit?.feedbackPozitif == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Üst blok: tarih, selamlama ve sabit profil özeti.
          Text(
            TrStrings.tarihMetni(bugun),
            style: yaziTemasi.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            TrStrings.selamlama(profil.isim),
            style: yaziTemasi.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Orta blok: kapalı kader kartı (deste kartı oranında).
          // Hero: onboarding'deki küçük halka bu karta uçar.
          Center(
            child: Hero(
              tag: HeroTags.skorHalkasi,
              child: FortuneRevealCard(
                arkaYuz: const _KapaliKartYuzu(),
                onYuz: _AcikKartYuzu(skor: widget.sonuc.genelSkor),
                onAcilisTamam: _kutuKontrol.forward,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Kategori kutuları — kapalı (yalnız ikon) başlar, kart açılınca
          // tek tek flip'le açılır.
          SizedBox(
            height: DailyLuckConfig.kategoriListeYuksekligi,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: LuckCategory.values.length,
              separatorBuilder: (BuildContext context, int i) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (BuildContext context, int i) {
                final LuckCategory kategori = LuckCategory.values[i];
                final bool kilitli =
                    ref.watch(kategoriKilitliProvider(kategori));
                return GestureDetector(
                  onTap: () => unawaited(_kategoriyeDokun(kategori)),
                  child: PremiumGate(
                    kilitli: kilitli,
                    child: KutuAcilisi(
                      animasyon: _kutuKontrol,
                      kontrolSuresi: _kutuKontrolSuresi,
                      indeks: i,
                      kapali: KapaliKategoriKutusu(kategori: kategori),
                      acik: CategoryCard(
                        kategori: kategori,
                        skor: widget.sonuc.kategoriSkorlari[kategori]!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Okuma + şans ögeleri + paylaş: kutular açıldıktan sonra
          // birlikte belirir.
          FadeTransition(
            opacity: _okumaOpakligi,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  okuma.baslik,
                  style: yaziTemasi.titleLarge?.copyWith(
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
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

/// Kader kartının kapalı yüzü: mor zemin, altın işlemeler (SVG).
class _KapaliKartYuzu extends StatelessWidget {
  const _KapaliKartYuzu();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AppIllustrations.kartArkaYuzu(
        genislik: DailyLuckConfig.kartGenisligi,
        yukseklik: DailyLuckConfig.kartYuksekligi,
      ),
    );
  }
}

/// Kader kartının açık yüzü: skor halkası (count-up kart açılırken
/// başlar, kart inişiyle birlikte sayar).
class _AcikKartYuzu extends StatelessWidget {
  const _AcikKartYuzu({required this.skor});

  final int skor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DailyLuckConfig.kartGenisligi,
      height: DailyLuckConfig.kartYuksekligi,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.gold),
      ),
      child: Center(
        child: AnimatedScoreRing(
          skor: skor,
          boyut: DailyLuckConfig.kartHalkaCapi,
          kalinlik: DailyLuckConfig.kartHalkaKalinligi,
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
