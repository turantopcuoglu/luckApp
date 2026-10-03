/// Onboarding akışına özgü ölçü ve animasyon sabitleri.
///
/// Magic number yasağı gereği (CLAUDE.md kural 6).
abstract final class OnboardingConfig {
  /// Doğum tarihi seçicisinin yüksekliği.
  static const double tarihSeciciYuksekligi = 200;

  /// Varsayılan doğum tarihi (seçici ilk açıldığında).
  static final DateTime varsayilanDogumTarihi = DateTime(2000);

  /// Seçilebilir en eski doğum yılı.
  static const int enEskiDogumYili = 1920;

  // ---- Ortak zemin ----

  /// Onboarding sahnesinin alt karartmasının başladığı yükseklik
  /// (ekran oranı): form alanları koyu zemine otursun.
  static const double karartmaBaslangici = 0.40;

  /// Alt karartmanın tam opak olduğu yükseklik (ekran oranı).
  static const double karartmaSonu = 0.78;

  /// Yoğun metinli ekranlarda karartmanın başladığı yükseklik.
  static const double yogunKarartmaBaslangici = 0.12;

  /// Yoğun metinli ekranlarda karartmanın tam opak olduğu yükseklik.
  static const double yogunKarartmaSonu = 0.42;

  /// "Ritüel" alt notunun yan çizgilerinin opaklığı.
  static const double notCizgiOpakligi = 0.4;

  // ---- Astrolab (karşılama / form kahramanı) ----

  /// Karşılama ekranındaki astrolabın kenar uzunluğu.
  static const double astrolabBuyuk = 220;

  /// Form ve tanışma ekranlarındaki küçük astrolabın kenar uzunluğu.
  static const double astrolabKucuk = 120;

  /// Işık kristalinin (çekirdek) halkalara göre boyu.
  static const double astrolabCekirdekOrani = 0.6;

  /// Halkaların bir tam tur dönüş süresi.
  static const Duration astrolabTurSuresi = Duration(seconds: 40);

  /// Çekirdeğin nefes (parlama) döngüsü sayısı (bir turda).
  static const int astrolabNefesKati = 8;

  /// Çekirdeğin nefesle büyüme payı (ölçek).
  static const double astrolabNefesOlcegi = 0.06;

  /// Astrolabın süzülme genliği (piksel).
  static const double astrolabSuzulme = 5;

  /// Bir turda kaç kez süzülüp döndüğü.
  static const int astrolabSuzulmeKati = 5;

  // ---- Işık küresi ("Kartın hazırlanıyor") ----

  /// Işık dolumunun süresi (eski sahte hesaplama süresiyle aynı).
  static const Duration hesaplamaSuresi = Duration(milliseconds: 2500);

  /// "Kartın hazır" belirme süresi.
  static const Duration hazirBelirmeSuresi = Duration(milliseconds: 900);

  /// Küre camının çapı.
  static const double kureCapi = 220;

  /// Sıvının cam çapına oranı (camın kenar kalınlığı içinde kalsın).
  static const double kureSiviOrani = 0.93;

  /// Altın yörünge çerçevesi görselinin cam çapına oranı (halka camın
  /// dışından geçer, ışın hüzmeleri üst/alta uzanır).
  static const double kureCerceveOrani = 1.24;

  /// Sıvı yüzeyi dalgasının genliği (küre çapı oranı).
  static const double dalgaGenligi = 0.035;

  /// Dalga döngüsü süresi (yüzeyin bir kez akması).
  static const Duration dalgaDongusu = Duration(milliseconds: 2200);

  /// İlerleme 0 iken bile görünen sıvı (dip ışığı) oranı.
  static const double siviTabanOrani = 0.08;

  /// Sıvı yüzeyindeki ışık çizgisinin kalınlığı.
  static const double yuzeyCizgiKalinligi = 2;

  /// Yüzey ışığı halesinin kalınlığının çizgiye oranı.
  static const double yuzeyHaleCarpani = 3;

  /// Yüzey ışığı halesinin opaklığı.
  static const double yuzeyHaleOpakligi = 0.6;

  /// Yüzey ışığı halesinin bulanıklığı.
  static const double yuzeyHaleBulanikligi = 6;

  /// İlerleme çubuğunun yüksekliği.
  static const double ilerlemeCubuguYuksekligi = 8;

  /// Kontrol listesi adımlarının tamamlandığı ilerleme eşikleri.
  static const List<double> adimEsikleri = <double>[0.2, 0.62, 0.96];

  /// Kontrol listesi işaret dairesinin çapı.
  static const double adimIsaretCapi = 26;

  // ---- "Kartın hazır" ----

  /// Hazır kartın genişliği (ana ekrandaki kartla aynı oran 2:3).
  static const double hazirKartGenisligi = 200;

  /// Hazır kartın yüksekliği.
  static const double hazirKartYuksekligi = 300;

  /// Hazır kartın arkasındaki ışık halesinin bulanıklığı.
  static const double hazirHaleBulanikligi = 60;

  /// Hazır kart halesinin tepe opaklığı.
  static const double hazirHaleOpakligi = 0.45;

  /// Hazır kart belirirken başladığı ölçek.
  static const double hazirBaslangicOlcegi = 0.86;
}
