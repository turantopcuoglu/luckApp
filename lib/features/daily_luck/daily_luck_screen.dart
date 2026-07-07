import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/hero_tags.dart';
import 'comment_builder.dart';
import 'daily_luck_config.dart';
import 'daily_luck_providers.dart';
import 'tr_strings.dart';
import 'widgets/animated_score_ring.dart';
import 'widgets/category_card.dart';
import 'widgets/comment_card.dart';
import 'widgets/flip_reveal_card.dart';
import 'widgets/staggered_entrance.dart';

/// Ana ekran: tarih + selamlama, animasyonlu skor halkası, flip ile
/// açılan yorum kartı ve staggered giren kategori mini kartları
/// (plan Session 3 düzeni + Session 5 animasyon katmanı).
class DailyLuckScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const DailyLuckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LuckResult> sonuc = ref.watch(gununSansiProvider);
    return Scaffold(
      // Stack: en altta köşelere yerleşen soluk yıldız deseni,
      // üstte asıl içerik. Desen dokunuşları yutmasın diye
      // IgnorePointer ile sarılıdır.
      body: Stack(
        children: <Widget>[
          const _YildizArkaPlani(),
          SafeArea(
            child: sonuc.when(
              data: (LuckResult veri) => _Icerik(sonuc: veri),
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

/// Başarılı durumda ekranın tam içeriği.
class _Icerik extends ConsumerWidget {
  const _Icerik({required this.sonuc});

  final LuckResult sonuc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final DateTime bugun = ref.watch(bugunProvider);
    final String isim = ref.watch(aktifProfilProvider).isim;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Üst blok: tarih ve selamlama.
          Text(
            TrStrings.tarihMetni(bugun),
            style: yaziTemasi.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(TrStrings.selamlama(isim), style: yaziTemasi.headlineMedium),
          const SizedBox(height: AppSpacing.xl),

          // Orta blok: count-up animasyonlu skor göstergesi. Hero:
          // onboarding'in hesaplama ekranındaki küçük halka buraya
          // büyüyerek uçar (Session 6, madde 3).
          Center(
            child: Hero(
              tag: HeroTags.skorHalkasi,
              child: AnimatedScoreRing(skor: sonuc.genelSkor),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Yorum kartı: dokununca 3D flip ile açılır.
          FlipRevealCard(
            onYuz: CommentCard(metin: gunYorumu(sonuc)),
            arkaYuz: const _KapaliYorumKarti(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Alt blok: kategori kartları staggered girişle.
          _KategoriListesi(sonuc: sonuc),
        ],
      ),
    );
  }
}

/// Flip kartının kapalı yüzü: davet metni.
class _KapaliYorumKarti extends StatelessWidget {
  const _KapaliYorumKarti();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            TrStrings.kartArkaYuzMetni,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gold,
                ),
          ),
        ),
      ),
    );
  }
}

/// Kategori kartlarını tek controller'dan beslenen staggered
/// girişle listeler (öğe başına 80ms gecikme).
class _KategoriListesi extends StatefulWidget {
  const _KategoriListesi({required this.sonuc});

  final LuckResult sonuc;

  @override
  State<_KategoriListesi> createState() => _KategoriListesiState();
}

class _KategoriListesiState extends State<_KategoriListesi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol = AnimationController(
    vsync: this,
    duration: StaggeredEntrance.toplamSure(LuckCategory.values.length),
  );

  @override
  void initState() {
    super.initState();
    _kontrol.forward();
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DailyLuckConfig.kategoriListeYuksekligi,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: LuckCategory.values.length,
        separatorBuilder: (BuildContext context, int i) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int i) {
          final LuckCategory kategori = LuckCategory.values[i];
          return StaggeredEntrance(
            animasyon: _kontrol,
            indeks: i,
            toplam: LuckCategory.values.length,
            child: CategoryCard(
              kategori: kategori,
              skor: widget.sonuc.kategoriSkorlari[kategori]!,
            ),
          );
        },
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
