import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sürekli atmosfer ayrı kontrol edilir; statik yerleşim testleri kapatabilir.
final Provider<bool> cosmicMotionEnabledProvider = Provider<bool>(
  (Ref ref) => true,
);

/// Onaylı kozmik sahnenin merkezi asset, renk ve hareket bütçesi.
abstract final class CosmicConfig {
  /// Arka plan üretim görseli; metin veya kontrol içermez.
  static const String atmosphere = 'assets/images/quiet_night_v4.png';

  /// İki kanada ayrılabilen düz kart dokusu.
  static const String card = 'assets/images/card_luminous_v5.png';

  /// V5: görünür mimari ve ışık doğrudan sanatın içinde; koyu 2B kanat bindirilmez.
  static const String radiantPortal = 'assets/images/portal_radiant_v5.png';

  /// Düşük skorun ayrı, parlak lavanta/rose-gold sahnesi.
  static const String twilightPortal = 'assets/images/portal_twilight_v5.png';

  /// V6: başlıktan kategori alanına uzanan tek parça gece mimarisi.
  static const String sanctuarySealed = 'assets/images/sanctuary_sealed_v6.png';

  /// V6: aynı tam sayfa koordinatlarında ışıklı turkuaz kapı.
  static const String sanctuaryRadiant =
      'assets/images/sanctuary_radiant_v6.png';

  /// V6: aynı tam sayfa koordinatlarında lavanta kapı.
  static const String sanctuaryTwilight =
      'assets/images/sanctuary_twilight_v6.png';

  /// Sahne, hero'nun altında yorum ve kategori bölgesine bu kadar devam eder.
  static const double sceneUnderlayReach = 240;

  /// Üç V6 kaynağının gerçek genişliği; decoder kaynağı büyütmez.
  static const int sanctuaryMasterWidth = 948;

  /// Tam sayfa sahnenin cihaz pikseline göre sınırlı çözme genişliği.
  static int sanctuaryDecodeWidth(double width, double pixelRatio) =>
      (width * pixelRatio).ceil().clamp(1, sanctuaryMasterWidth);

  /// Yalnız en alttaki birleşim; başlık/kapı arasında maske veya kesim yok.
  static const LinearGradient sanctuaryEdgeBlend = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Colors.black, Colors.black, Colors.transparent],
    stops: <double>[0, .84, 1],
  );

  /// Skorun arkasındaki açık kapı sahnesi.
  static const String portal = 'assets/images/moon_path_v4.png';

  /// Dört günlük kart ailesinin ayrı sahneleri; skor motorunu etkilemez.
  static const String sanctuary = 'assets/images/story_violet_v4.png';

  /// Denge ailesinin gümüş-turkuaz gözlemevi.
  static const String observatory = 'assets/images/story_night_v4.png';

  /// Nadir görünümün radyal altın gökyüzü.
  static const String celestial = 'assets/images/story_light_v4.png';

  /// Premium bilgi ekranının ayrı üretim illüstrasyonu.
  static const String premium = 'assets/images/story_light_v4.png';

  /// Skor etiketinin okunaklı, yüksek opaklıklı zemini.
  static const Color textPlate = Color(0xF207162F);

  /// Canlı ana sahnede lacivert sis yerine nötr, hafif kenar karartması.
  static const LinearGradient vividBackdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0x26020710),
      Color(0x0D020710),
      Color(0xA6020710),
      Color(0xE6020710),
    ],
    stops: <double>[0, .40, .70, 1],
  );

  /// Form ve yardımcı sayfaların mevcut sakin atmosferi.
  static const LinearGradient subduedBackdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0x9E07162F), Color(0xCC07162F), Color(0xFF07162F)],
    stops: <double>[0, .55, 1],
  );

  /// Yalnız metin bölgesini korur; altın/turkuaz sahnenin üstünü boyamaz.
  static const Color focusedTextPlate = Color(0xED030A17);

  /// Başlık etrafındaki yerel ve nötr gölge.
  static const RadialGradient headingHalo = RadialGradient(
    radius: .85,
    colors: <Color>[Color(0xE6030A17), Color(0x00030A17)],
  );

  /// Büyük skorun koruması yereldir; kapının mimarisine yayılmaz.
  static const RadialGradient scoreHalo = RadialGradient(
    center: Alignment(0, -.15),
    radius: .52,
    colors: <Color>[Color(0x26030A17), Color(0x00030A17)],
  );

  /// Yalnız iki küçük etiketin arkasında; kapıyı veya büyük skoru örtmez.
  static const RadialGradient scoreCaptionHalo = RadialGradient(
    radius: .9,
    colors: <Color>[Color(0x99030812), Color(0x00030812)],
  );

  /// Küçük kategori yüzeyinde ışık rengi yerine koyu kontrast tabanı.
  static const Color categorySurface = Color(0xED061124);

  /// Ekranlar arası ortak başlık sahnesi yüksekliği.
  static const double pageHeroHeight = 180;

  /// Anahtarın tamamını gösteren Premium üretim sahnesi yüksekliği.
  static const double premiumHeroHeight = 280;

  /// Mobilde bitmap çözme üst sınırı.
  static const int decodeWidth = 768;

  /// Çözme tavanı; V5 kaynakları daha geniş olsa da mobil bellek bütçesi korunur.
  static const int sceneMasterWidth = 1024;

  /// Üretim sahneleri 1024×1536; cover hesabı uzun ekranı da dikkate alır.
  static const double sceneAspectRatio = 2 / 3;

  /// Ana sahneyi cihaz pikseline göre çözer, kaynak çözünürlüğünü aşmaz.
  static int sceneDecodeWidth(double width, double pixelRatio) =>
      (width * pixelRatio).ceil().clamp(1, sceneMasterWidth);

  /// Cover kırpmasında yalnız ekran genişliğine bakıp resmi büyütmez.
  static int backdropDecodeWidth(Size size, double pixelRatio) =>
      sceneDecodeWidth(
        size.width > size.height * sceneAspectRatio
            ? size.width
            : size.height * sceneAspectRatio,
        pixelRatio,
      );

  /// Bir sakin atmosfer çevrimi.
  static const Duration ambientLoop = Duration(seconds: 18);

  /// Sürekli sahnedeki sabit parçacık bütçesi.
  static const int particles = 28;

  /// Dış zemindeki ışık, metin ve kartla yarışmaz.
  static const double backgroundIntensity = .18;

  /// Tek odak çevresindeki canlı yıldız vurgusu.
  static const double stageIntensity = .55;

  /// Metnin altından geçen şerit sayısı ve sabit çizim bütçesi.
  static const int ribbonCount = 3;

  /// Yumuşak ışık halesi.
  static const double ribbonGlowWidth = 7;

  /// İnce ışık çekirdeği.
  static const double ribbonCoreWidth = .8;

  /// Parlak skorun alt sınırı; yalnız görsel sunumdur.
  static const int brightScore = 70;

  /// Sakin skorun üst sınırı (hariç).
  static const int calmScore = 40;

  /// Nadir ışık çerçevesinin alt sınırı.
  static const int rareScore = 92;

  /// Ana kart sahnesinin yüksekliği.
  static const double heroHeight = 340;

  /// Kart/kapı genişliği.
  static const double cardWidth = 210;

  /// Merkezi canlı sayı ve sayının kapı içindeki konumu.
  static const double scoreSize = 96;

  /// Skorun tek satır yükseklik bütçesi.
  static const double scoreHeight = 106;

  /// Başlık üstündeki açık gökyüzü oranı.
  static const double scoreTopRatio = .12;

  /// Yalnız üst/alt birleşim kenarı; orta %88, mimari ve renkler tam opak.
  static const LinearGradient portalEdgeBlend = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Colors.transparent,
      Colors.black,
      Colors.black,
      Colors.transparent,
    ],
    stops: <double>[0, .055, .935, 1],
  );

  /// Kategori kutuları aynı minimum yüksekliği korur.
  static const double categoryTileHeight = 94;

  /// İkonlar çerçeveli daire yerine renkli dolgu biçimindedir.
  static const double categoryIconSize = 24;

  /// Kategori değerinin serif punto büyüklüğü.
  static const double categoryScoreSize = 28;

  /// Kutudaki renk katmanının opaklığı.
  static const double categoryTint = .15;

  /// Metin ölçeği büyükken kutular iki sütuna geçer.
  static const double largeTextThreshold = 20;

  /// Beş sütunun sığacağı içerik genişliği.
  static const double categoryFiveColumnWidth = 280;

  /// Küçük adım panelindeki işaret.
  static const double missionIconSize = 44;

  /// İçeriğe gömülü, sınırları yumuşak alt menü.
  static const Color navigationSurface = Color(0xFF061421);

  /// Seçili sekmenin ışık izinin genişliği.
  static const double navigationLightWidth = 72;

  /// Menünün altındaki ince ışık çizgisi.
  static const double navigationLightHeight = 2;

  /// Dolan ışık küresinin çapı.
  static const double orbSize = 280;

  /// Cam kırılmaları bitmap, içindeki dolum ve ışıklar gerçek zamanlıdır.
  static const String glassOrb = 'assets/images/glass_orb_v4.png';

  /// Formdaki küçük amblem çapı.
  static const double emblemSize = 110;

  /// Küçük kategorilerin alt genişliği.
  static const double categoryMinWidth = 56;

  /// Büyük yazıda kategori alt genişliği.
  static const double categoryLargeWidth = 132;

  /// Altın folyo rengi.
  static const Color gold = Color(0xFFEBCB89);

  /// Altın yüzeyin parlak noktası.
  static const Color goldLight = Color(0xFFFFEAC1);

  /// Altın yüzeyin koyu noktası.
  static const Color goldShade = Color(0xFFA67837);

  /// Yüksek skor ışığı.
  static const Color cyan = Color(0xFF83E7ED);

  /// Düşük skorun sıcak vurgusu.
  static const Color copper = Color(0xFFF1BDAC);

  /// Düşük skorun sakin ışığı.
  static const Color violet = Color(0xFFB7A0E9);

  /// Aşk vurgusu.
  static const Color love = Color(0xFFF39ABF);

  /// Sağlık vurgusu.
  static const Color health = Color(0xFF8ED7B8);

  /// Sosyal vurgusu.
  static const Color social = Color(0xFF91CCFF);
}

/// Skor motorunu değiştirmeyen görsel atmosfer seçimi.
enum CosmicTone {
  /// Açılmamış kartın nötr ışığı.
  sealed,

  /// Düşük skorda sakin, korkutmayan ışık.
  calm,

  /// Orta skorda dengeli mavi-altın ışık.
  balanced,

  /// Yüksek skorda canlı turkuaz-altın.
  bright,

  /// 92+ skorda ek folyo halkası.
  rare;

  /// Yalnız açılmış genel skordan türetilir.
  static CosmicTone fromScore(int score) => score >= CosmicConfig.rareScore
      ? rare
      : score >= CosmicConfig.brightScore
      ? bright
      : score < CosmicConfig.calmScore
      ? calm
      : balanced;

  /// Ana ışık; yazı/ikon renk kodlamasının tek kaynağı değildir.
  Color get light => this == calm ? CosmicConfig.copper : CosmicConfig.gold;

  /// İkincil atmosfer rengi.
  Color get mist => this == calm ? CosmicConfig.violet : CosmicConfig.cyan;

  /// Ana sayfanın aydınlık kompozisyonları; eski koleksiyon/Story eşlemesi bağımsızdır.
  String get homeSceneAsset =>
      this == calm ? CosmicConfig.twilightPortal : CosmicConfig.radiantPortal;

  /// İkincil sayfaların mevcut aile eşlemesi; ana kapı homeSceneAsset kullanır.
  String get sceneAsset => switch (this) {
    calm => CosmicConfig.sanctuary,
    balanced => CosmicConfig.observatory,
    rare => CosmicConfig.celestial,
    sealed || bright => CosmicConfig.portal,
  };
}
