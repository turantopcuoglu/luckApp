import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'ads_config.dart';

/// İçeriğin EN ALTINA yerleştirilen uyarlanabilir banner.
///
/// Politika: banner hiçbir butonun veya gezinme çubuğunun yanına konmaz
/// (kazara tıklama AdMob politikası ihlalidir); üstünde "Reklam" etiketi
/// ve boşluk bulunur. [goster] false ise (premium, rıza yok, SDK hazır
/// değil) hiç yer kaplamaz ve reklam isteği yapılmaz.
class BannerReklamAlani extends StatefulWidget {
  /// [goster] ile alan oluşturur.
  const BannerReklamAlani({required this.goster, super.key});

  /// Reklam gösterilmeli mi?
  final bool goster;

  @override
  State<BannerReklamAlani> createState() => _BannerReklamAlaniState();
}

class _BannerReklamAlaniState extends State<BannerReklamAlani> {
  BannerAd? _banner;

  /// Yalnızca yükleme durumu için lokal state (kural 5 istisnası:
  /// widget'a özgü, paylaşılmayan görsel durum).
  bool _yuklendi = false;
  bool _istendi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _yukleGerekirse();
  }

  @override
  void didUpdateWidget(BannerReklamAlani eski) {
    super.didUpdateWidget(eski);
    if (!widget.goster) {
      _temizle();
    } else {
      _yukleGerekirse();
    }
  }

  Future<void> _yukleGerekirse() async {
    if (!widget.goster || _istendi) {
      return;
    }
    _istendi = true;
    final int genislik = MediaQuery.sizeOf(context).width.truncate();
    final AnchoredAdaptiveBannerAdSize? boyut =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
      Orientation.portrait,
      genislik,
    );
    if (!mounted || boyut == null) {
      return;
    }
    final BannerAd banner = BannerAd(
      adUnitId: AdsConfig.bannerBirim,
      size: boyut,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad reklam) {
          if (mounted) {
            setState(() => _yuklendi = true);
          }
        },
        onAdFailedToLoad: (Ad reklam, LoadAdError hata) {
          reklam.dispose();
          if (mounted) {
            setState(() {
              _banner = null;
              _yuklendi = false;
            });
          }
        },
      ),
    );
    _banner = banner;
    await banner.load();
  }

  void _temizle() {
    _banner?.dispose();
    _banner = null;
    _yuklendi = false;
    _istendi = false;
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BannerAd? banner = _banner;
    if (!widget.goster || !_yuklendi || banner == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          Text(
            'Reklam',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ],
      ),
    );
  }
}
