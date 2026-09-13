import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/content/experience_dimension.dart';
import '../../core/content/rare_sign_id.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Hazır üretim çizimleri ve eski ekranlar için geçici uyumluluk API'si.
abstract final class AppIllustrations {
  /// Tam kare gece mavisi sahnede sedef hilal ve yumuşak yıldız.
  static const String markAsset = 'assets/images/cosmic_mark_v4.png';

  /// Üretim ambleminin gerçek piksel genişliği.
  static const int markMasterWidth = 1254;

  /// Uygulama içindeki logo yüzeyinin köşe oranı.
  static const double markCornerRatio = .16;

  /// İnce metal kenarlarda küçük ikon aliasing'ini azaltan kaynak bütçesi.
  static const int markMinDecodeWidth = 256;

  /// Mühürlü kart; ön yüzdeki skor/arketipi yüklemez.
  static const String cardBackAsset = 'assets/svg/kader_card_back.svg';

  /// Dekoratif yollar.
  static const String patternAsset = 'assets/svg/kader_path_pattern.svg';

  /// Boş durum yolu.
  static const String emptyAsset = 'assets/svg/kader_empty_path.svg';

  /// Beş arketipin üretim eşlemesi; UI dosya adı birleştirmez.
  static const Map<ExperienceDimension, String>
  archetypeAssets = <ExperienceDimension, String>{
    ExperienceDimension.akis: 'assets/images/archetypes/archetype_akis.webp',
    ExperienceDimension.bag: 'assets/images/archetypes/archetype_bag.webp',
    ExperienceDimension.uretim:
        'assets/images/archetypes/archetype_uretim.webp',
    ExperienceDimension.cesaret:
        'assets/images/archetypes/archetype_cesaret.webp',
    ExperienceDimension.denge: 'assets/images/archetypes/archetype_denge.webp',
  };

  /// On iki nadir sahnenin üretim eşlemesi.
  static const Map<RareSignId, String> rareSignAssets = <RareSignId, String>{
    RareSignId.acikKapi: 'assets/images/rare_acik_kapi_v4.png',
    RareSignId.kesisenYollar: 'assets/images/rare_kesisen_yollar_v4.png',
    RareSignId.sessizTohum: 'assets/images/rare_sessiz_tohum_v4.png',
    RareSignId.ucanNot: 'assets/images/rare_ucan_not_v4.png',
    RareSignId.dengeliTas: 'assets/images/rare_dengeli_tas_v4.png',
    RareSignId.yeniPatika: 'assets/images/rare_yeni_patika_v4.png',
    RareSignId.geriDonenSerit: 'assets/images/rare_geri_donen_serit_v4.png',
    RareSignId.kucukKopru: 'assets/images/rare_kucuk_kopru_v4.png',
    RareSignId.acikPencere: 'assets/images/rare_acik_pencere_v4.png',
    RareSignId.beklenmedikDurak: 'assets/images/rare_beklenmedik_durak_v4.png',
    RareSignId.yanYanaIzler: 'assets/images/rare_yan_yana_izler_v4.png',
    RareSignId.parlakYol: 'assets/images/rare_parlak_yol_v4.png',
  };

  /// Marka işaretini özgün renklerle, isteğe bağlı semantics etiketiyle sunar.
  static Widget kaderMark({double size = 120, String? semanticLabel}) =>
      SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * markCornerRatio),
          child: _ProductionImage(
            path: markAsset,
            aspectRatio: 1,
            masterWidth: markMasterWidth,
            width: size,
            semanticLabel: semanticLabel,
            fullResolution: false,
            minimumDecodeWidth: markMinDecodeWidth,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );

  /// Kartın özgün 2:3 oranını korur; skor veya arketip içermez.
  static Widget kaderCardBack({required double width, String? semanticLabel}) =>
      _svg(cardBackAsset, width, width * 3 / 2, semanticLabel);

  /// Yalnız dekoratif, ekran okuyucudan çıkarılmış desen.
  static Widget pathPattern({double size = 240}) =>
      _svg(patternAsset, size, size, null);

  /// Boş yol çizimi; anlamı bitişik metin veriyorsa etiket atlanmalıdır.
  static Widget emptyPath({double size = 160, String? semanticLabel}) =>
      _svg(emptyAsset, size, size, semanticLabel);

  static Widget _svg(String path, double width, double height, String? label) =>
      SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.contain,
        semanticsLabel: label,
        excludeFromSemantics: label == null,
      );

  /// Yalnız seçilen arketipi çözer; story için fullResolution seçilebilir.
  static Widget archetype(
    ExperienceDimension dimension, {
    double? width,
    String? semanticLabel,
    bool fullResolution = false,
  }) => _ProductionImage(
    path: archetypeAssets[dimension]!,
    aspectRatio: 4 / 3,
    masterWidth: 1024,
    width: width,
    semanticLabel: semanticLabel,
    fullResolution: fullResolution,
  );

  /// Lazy grid item içinde kullanılır; diğer kartları kendiliğinden yüklemez.
  static Widget rareSign(
    RareSignId id, {
    double? width,
    String? semanticLabel,
    bool fullResolution = false,
  }) => _ProductionImage(
    path: rareSignAssets[id]!,
    aspectRatio: 2 / 3,
    masterWidth: 1024,
    width: width,
    semanticLabel: semanticLabel,
    fullResolution: fullResolution,
  );

  /// Decode genişliğini cihaz piksel oranıyla hesaplar, master'da sınırlar.
  static int decodeWidth(
    double logicalWidth,
    double pixelRatio,
    int masterWidth,
  ) {
    if (!logicalWidth.isFinite ||
        logicalWidth <= 0 ||
        !pixelRatio.isFinite ||
        pixelRatio <= 0 ||
        masterWidth < 1) {
      throw ArgumentError(
        'Görsel ölçüsü ve piksel oranı pozitif ve sonlu olmalı.',
      );
    }
    return (logicalWidth * pixelRatio).ceil().clamp(1, masterWidth);
  }

  /// Yalnız hemen kullanılacak tek arketipi ısıtır; tüm havuzu dolaşmaz.
  static Future<void> precacheArchetype(
    BuildContext context,
    ExperienceDimension dimension, {
    required double logicalWidth,
  }) => _precache(context, archetypeAssets[dimension]!, logicalWidth, 1024);

  /// Yalnız sıradaki tek koleksiyon kartını thumbnail ölçüsünde ısıtır.
  static Future<void> precacheRareSign(
    BuildContext context,
    RareSignId id, {
    required double logicalWidth,
  }) => _precache(context, rareSignAssets[id]!, logicalWidth, 1024);

  static Future<void> _precache(
    BuildContext context,
    String path,
    double width,
    int masterWidth,
  ) async {
    Object? failure;
    StackTrace? stack;
    await precacheImage(
      _provider(
        path,
        decodeWidth(width, MediaQuery.devicePixelRatioOf(context), masterWidth),
      ),
      context,
      onError: (Object error, StackTrace? trace) {
        failure = error;
        stack = trace;
      },
    );
    if (failure != null) {
      Error.throwWithStackTrace(failure!, stack ?? StackTrace.current);
    }
  }

  static ImageProvider<Object> _provider(String path, int width) =>
      ResizeImage(AssetImage(path), width: width);

  /// Kristal küre illüstrasyonunun varsayılan boyutu.
  static const double kristalKureBoyutu = 120;

  /// Yıldız deseni karosunun kenar uzunluğu (SVG viewBox'ı ile aynı).
  static const double yildizKaroBoyutu = 200;

  /// Ana ekran köşeleri için soluk yıldız/parçacık deseni karosu.
  ///
  /// Desenin opaklığı SVG içinde sabittir (0.06); renk teması koyu
  /// olduğu için boyama gerektirmez.
  /// @deprecated Yeni yüzeyler pathPattern kullanmalı.
  static Widget yildizDeseni({double boyut = yildizKaroBoyutu}) {
    return SvgPicture.asset(
      'assets/svg/arka_plan_yildizlar.svg',
      width: boyut,
      height: boyut,
    );
  }

  /// Boş durum illüstrasyonu: minimal line-art kristal küre.
  /// @deprecated Yeni boş durumlar emptyPath kullanmalı.
  static Widget kristalKure({
    double boyut = kristalKureBoyutu,
    Color renk = AppColors.purple,
  }) {
    return SvgPicture.asset(
      'assets/svg/bos_durum_kristal_kure.svg',
      width: boyut,
      height: boyut,
      colorFilter: ColorFilter.mode(renk, BlendMode.srcIn),
    );
  }

  /// Uygulama ikonu taslağı (512x512 yonca); onboarding karşılama
  /// ekranında da kullanılacak. Renkleri SVG içinde sabittir.
  /// @deprecated Yeni marka yüzeyleri kaderMark kullanmalı.
  static Widget uygulamaIkonu({required double boyut}) {
    return SvgPicture.asset(
      'assets/svg/app_icon_yonca.svg',
      width: boyut,
      height: boyut,
    );
  }

  /// Kader kartının kapalı yüzü: mor zemin, altın işlemeler
  /// (ana ekran kart açılışı). Renkleri SVG içinde sabittir.
  /// @deprecated Yeni kapalı kart kaderCardBack kullanmalı.
  static Widget kartArkaYuzu({
    required double genislik,
    required double yukseklik,
  }) {
    return SvgPicture.asset(
      'assets/svg/kart_arka_yuzu.svg',
      width: genislik,
      height: yukseklik,
      fit: BoxFit.cover,
    );
  }
}

class _ProductionImage extends StatelessWidget {
  const _ProductionImage({
    required this.path,
    required this.aspectRatio,
    required this.masterWidth,
    this.width,
    this.semanticLabel,
    required this.fullResolution,
    this.minimumDecodeWidth = 1,
    this.filterQuality = FilterQuality.low,
  });
  final String path;
  final double aspectRatio;
  final int masterWidth;
  final double? width;
  final String? semanticLabel;
  final bool fullResolution;
  final int minimumDecodeWidth;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final double requested =
          width ??
          (constraints.hasBoundedWidth
              ? constraints.maxWidth
              : AppLayout.maxContentWidth);
      final double logical = constraints.hasBoundedWidth
          ? requested.clamp(0, constraints.maxWidth).toDouble()
          : requested;
      if (logical == 0) return const SizedBox.shrink();
      final int decode = AppIllustrations.decodeWidth(
        logical,
        MediaQuery.devicePixelRatioOf(context),
        masterWidth,
      );
      return SizedBox(
        width: logical,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image(
            image: AppIllustrations._provider(
              path,
              fullResolution
                  ? masterWidth
                  : decode.clamp(minimumDecodeWidth, masterWidth),
            ),
            filterQuality: filterQuality,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            semanticLabel: semanticLabel,
            excludeFromSemantics: semanticLabel == null,
            // Görsel değişirken önceki günün kartını göstermemek için false.
            gaplessPlayback: false,
          ),
        ),
      );
    },
  );
}
