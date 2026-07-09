import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/gunun_icerigi.dart';
import '../../core/history/gecmis_ozeti.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/hero_tags.dart';
import '../categories/category_detail_screen.dart';
import '../categories/entitlement.dart';
import '../categories/paywall_screen.dart';
import '../categories/widgets/premium_gate.dart';
import '../history/history_providers.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
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

/// Ana ekran: üstte tarih + selamlama, ortada (hafif yukarıda) kapalı
/// kader kartı, altında kapalı kategori kutuları.
///
/// Akış: karta dokun → 3D flip → ekrana yaklaşıp "düşme" → skor
/// count-up → kutular tek tek flip'le açılır → yorum belirir.
class DailyLuckScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const DailyLuckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LuckResult> sonuc = ref.watch(gununSansiProvider);
    // İçerik saklanan sonuçtan senkron türetilir; sonuc data olduğunda
    // bir mikrotask sonra hazırdır. İki provider birlikte beklenir ki
    // _Icerik null dalı olmadan tam veriyle kurulsun.
    final AsyncValue<GununIcerigi> icerik = ref.watch(gununIcerigiProvider);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const _YildizArkaPlani(),
          SafeArea(
            child: sonuc.when(
              data: (LuckResult veri) => icerik.when(
                data: (GununIcerigi paket) =>
                    _Icerik(sonuc: veri, icerik: paket),
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
/// Kutu/yorum açılış controller'ı burada yaşar; kart açılışı bitince
/// (onAcilisTamam) tetiklenir. setState kullanılmaz — controller'ı
/// dinleyen alt widget'lar kendi kendini boyar (kural 5).
class _Icerik extends ConsumerStatefulWidget {
  const _Icerik({required this.sonuc, required this.icerik});

  final LuckResult sonuc;

  /// Günün metinsel içerik paketi (yorum, renk, sayı, tavsiye).
  final GununIcerigi icerik;

  @override
  ConsumerState<_Icerik> createState() => _IcerikState();
}

class _IcerikState extends ConsumerState<_Icerik>
    with SingleTickerProviderStateMixin {
  /// Kutu açılışları + yorum belirmesinin toplam süresi.
  static final Duration _kutuKontrolSuresi =
      DailyLuckConfig.kutuGecikmesi * (LuckCategory.values.length - 1) +
          DailyLuckConfig.kutuAcilisSuresi +
          DailyLuckConfig.yorumBelirmeSuresi;

  late final AnimationController _kutuKontrol = AnimationController(
    vsync: this,
    duration: _kutuKontrolSuresi,
  );

  /// Yorumun belirme dilimi: sürenin sonundaki fade parçası.
  late final Animation<double> _yorumOpakligi = CurvedAnimation(
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

  /// Şefkatli seri rozeti: yalnız güncel seri > 0 iken görünür.
  ///
  /// Suçluluk yok — seri sıfırsa (ya da sönmüşse) hiçbir şey gösterilmez,
  /// "bozuldu" gibi bir ifade kullanılmaz.
  Widget _seriRozeti(BuildContext context) {
    final GecmisOzeti ozet = ref.watch(gecmisOzetiProvider);
    if (ozet.guncelSeri <= 0) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            TrStrings.seriEtiketi(ozet.guncelSeri),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.gold,
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final DateTime bugun = ref.watch(bugunProvider);
    final String isim = ref.watch(aktifProfilProvider).isim;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Üst blok: tarih + selamlama solda, ayarlar dişlisi sağda.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      TrStrings.tarihMetni(bugun),
                      style: yaziTemasi.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      TrStrings.selamlama(isim),
                      style: yaziTemasi.headlineMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.textSecondary,
                ),
                tooltip: TrStrings.gecmisIpucu,
                onPressed: () => Navigator.of(context).push(
                  fadeThroughRoute<void>(const HistoryScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_rounded,
                  color: AppColors.textSecondary,
                ),
                tooltip: TrStrings.ayarlarIpucu,
                onPressed: () => Navigator.of(context).push(
                  fadeThroughRoute<void>(const SettingsScreen()),
                ),
              ),
            ],
          ),
          _seriRozeti(context),
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

          // Alt blok: kategori kutuları — kapalı (yalnız ikon) başlar,
          // kart açılınca tek tek flip'le açılır.
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
                // Gate görseli tüm kutuyu (kapalı/açık yüz) sarar;
                // dokunuş kilide göre paywall'a ya da detaya gider.
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    fadeThroughRoute<void>(
                      kilitli
                          ? const PaywallScreen()
                          : CategoryDetailScreen(kategori: kategori),
                    ),
                  ),
                  child: PremiumGate(
                    kilitli: kilitli,
                    child: KutuAcilisi(
                      animasyon: _kutuKontrol,
                      kontrolSuresi: _kutuKontrolSuresi,
                      indeks: i,
                      kapali: KapaliKategoriKutusu(kategori: kategori),
                      acik: CategoryCard(
                        kategori: kategori,
                        // Kilitliyken gerçek skor karta hiç verilmez;
                        // kart maske metni ve boş bar çizer.
                        skor: kilitli
                            ? 0
                            : widget.sonuc.kategoriSkorlari[kategori]!,
                        kilitli: kilitli,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Yorum + şans ögeleri + paylaş: kutular açıldıktan sonra
          // birlikte belirir.
          FadeTransition(
            opacity: _yorumOpakligi,
            child: Column(
              children: <Widget>[
                CommentCard(metin: widget.icerik.yorum),
                const SizedBox(height: AppSpacing.md),
                SansOgeleriKarti(icerik: widget.icerik),
                const SizedBox(height: AppSpacing.md),
                Center(child: ShareButton(sonuc: widget.sonuc)),
              ],
            ),
          ),
        ],
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
