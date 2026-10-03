import 'package:flutter/painting.dart';

import '../../core/theme/app_colors.dart';

/// Paylaşım (story kartı) özelliğine özgü ölçü sabitleri.
///
/// Kart, Instagram story formatında (1080x1920) tek seferde
/// off-screen render edilir; buradaki puntolar o tuvale görealdır.
abstract final class ShareConfig {
  /// Story kartının tuval boyutu (piksel = mantıksal, pixelRatio 1).
  static const Size kartBoyutu = Size(1080, 1920);

  /// Kart kenar boşluğu.
  static const double kenarBoslugu = 96;

  /// Paylaşılan dosyanın adı.
  static const String dosyaAdi = 'kader_gunun_sansi.png';

  /// Tarih metni puntosu.
  static const double tarihPunto = 44;

  /// Dev skor sayısının puntosu.
  static const double skorPunto = 300;

  /// Skor gizliyken ortadaki gün başlığının puntosu.
  static const double gizliBaslikPunto = 110;

  /// Skor etiketinin harf aralığı.
  static const double skorEtiketHarfAraligi = 8;

  /// Metinlerin parlak sahne üstünde okunması için yumuşak gölge.
  static const List<Shadow> yaziGolgesi = <Shadow>[
    Shadow(color: AppColors.background, blurRadius: 24),
  ];

  /// Dev skorun altın halesi.
  static const List<Shadow> skorGolgesi = <Shadow>[
    Shadow(color: AppColors.background, blurRadius: 40),
    Shadow(color: AppColors.gold, blurRadius: 60),
  ];

  /// Üst karartmanın opaklığı (tarih ve başlık okunur kalsın).
  static const double ustKarartma = 0.55;

  /// Alt karartmanın opaklığı (kategori paneli ve marka).
  static const double altKarartma = 0.85;

  /// Karartma gradyanının durakları (üst, orta açık bölge, alt).
  static const List<double> karartmaDuraklari = <double>[0, 0.22, 0.55, 1];

  /// Kategori panelinin zemin opaklığı.
  static const double panelOpakligi = 0.55;

  /// Kategori panelinin köşe yarıçapı.
  static const double panelYaricapi = 48;

  /// Kategori paneli kenar çizgisinin opaklığı.
  static const double panelKenarOpakligi = 0.35;

  /// Kategori paneli kenar çizgisinin kalınlığı.
  static const double panelKenarKalinligi = 3;

  // ---- Paylaşım ekranı (önizleme + seçenekler) ----

  /// Tema küçük resminin genişliği.
  static const double temaKucukGenislik = 92;

  /// Tema küçük resminin yüksekliği.
  static const double temaKucukYukseklik = 112;

  /// Seçili tema rozetinin boyutu.
  static const double temaRozetBoyutu = 22;

  /// Önizlemenin ekran genişliğine oranı (kalan alan seçeneklere).
  static const double onizlemeGenislikOrani = 0.62;

  /// Önizlemenin ekran yüksekliğine azami oranı.
  static const double onizlemeYukseklikOrani = 0.5;

  /// "GENEL SKOR" etiket puntosu.
  static const double skorEtiketPunto = 40;

  /// Kategori satırı yüksekliği.
  static const double kategoriSatirYuksekligi = 88;

  /// Kategori etiket puntosu.
  static const double kategoriPunto = 42;

  /// Kategori etiket sütunu genişliği.
  static const double kategoriEtiketGenisligi = 220;

  /// Kategori skor sütunu genişliği.
  static const double kategoriSkorGenisligi = 96;

  /// Kategori barının kalınlığı.
  static const double barYuksekligi = 18;

  /// Tarihin altındaki kişisel gün başlığının puntosu.
  static const double baslikPunto = 72;

  /// Alt köşedeki marka yazısının puntosu.
  static const double markaPunto = 52;

  /// Kart zemininin çapraz gradyanı (lacivertten mora).
  static const List<Color> gradyanRenkleri = <Color>[
    AppColors.background,
    Color(0xFF231C4E),
    Color(0xFF43317A),
  ];

  /// Üst etiketin harf aralığı.
  static const double etiketHarfAraligi = 2;

  // ---- Keşfet aracı kartı ----

  /// Araç kartında tema görselinin üstündeki düz karartma opaklığı.
  static const double aracKarartma = 0.5;

  /// Araç kartı dosya adı.
  static const String aracDosyaAdi = 'kader_kesfet.png';

  /// Dev sayının altındaki etiket puntosu ("Usta İlham").
  static const double aracEtiketPunto = 64;

  /// Kısa yorumun puntosu.
  static const double aracMetinPunto = 44;

  /// Kısa yorumun satır yüksekliği çarpanı.
  static const double aracMetinSatirYuksekligi = 1.4;

  /// Kısa yorumun en fazla satır sayısı.
  static const int aracMetinSatiri = 8;
}
