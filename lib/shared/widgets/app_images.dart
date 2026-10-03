/// Raster görsellerin asset yolları.
///
/// Görseller `assets/images/` altındadır ve telefona göre küçültülmüştür:
/// opak sahne/kart görselleri JPEG, şeffaf katmanlar (mühür, ikon,
/// madalyon, çerçeve) alfa kanallı WebP'dir. Kaynak çizimler ve hangi
/// dosyanın nereden geldiği `GORSEL_URETIM_REHBERI.md` içinde listelenir.
abstract final class AppImages {
  // ---- Bugün ekranı ----

  /// Mühürsüz kart arka yüzü: lacivert mermer, altın kenar, ortadan dikey
  /// altın dikiş (kart buradan iki kanada ayrılır).
  static const String kartArkaYuzuMuhursuz =
      'assets/images/kart_arka_yuzu_muhursuz.jpg';

  /// Kartın ortasındaki altın pusula-yıldız mühür (şeffaf, ayrı katman:
  /// dokununca döner, ışık fazında kanatlarla ikiye ayrılır).
  static const String muhur = 'assets/images/muhur.webp';

  /// Kart açılmadan önceki sakin sahne: sütunlar, hilal, bulutlar.
  static const String sahneKapali = 'assets/images/sahne_kapali.jpg';

  /// Yüksek skor sahnesi: turkuaz ışıkla açılmış kapılar.
  static const String sahneYuksek = 'assets/images/sahne_yuksek.jpg';

  /// Orta skor sahnesi: altın ışıkla açılmış kapılar (diğer iki sahneyle
  /// aynı kompozisyon; kanatlar kapılara dönüşür).
  static const String sahneOrtaKapili = 'assets/images/sahne_orta_kapili.jpg';

  /// Düşük skor sahnesi: lavanta ışıklı, sakin kapılar.
  static const String sahneDusuk = 'assets/images/sahne_dusuk.jpg';

  /// Tam ekran sahnelerin en önündeki sütun + kemer çerçevesi (şeffaf,
  /// paralaks katmanı).
  static const String onPlanSutunlar = 'assets/images/on_plan_sutunlar.webp';

  /// Dört uçlu parıltı sprite'ı (kıvılcım, yıldız, buton parlaması).
  static const String parilti = 'assets/images/parilti.webp';

  /// Akşam sahnesi: alacakaranlıkta göl ve kemerler (geri bildirim).
  static const String sahneAksam = 'assets/images/sahne_aksam.jpg';

  /// Koyu mavi mermer doku (panel yüzeyleri).
  static const String mermerDoku = 'assets/images/mermer_doku.jpg';

  /// Hata/boş durum: hilali yarı örten bulut.
  static const String hataDurumu = 'assets/images/hata_durumu.webp';

  // ---- Marka ----

  // Uygulama ikonu Android/iOS kaynaklarında; burada asset yok.

  // ---- Onboarding ----

  /// Onboarding ortak arka planı: sütunlu kemerler, ayna göl.
  static const String sahneOnboarding = 'assets/images/sahne_onboarding.jpg';

  /// Astrolab çekirdeği: dört uçlu ışık kristali (şeffaf).
  static const String astrolabCekirdek = 'assets/images/astrolab_cekirdek.webp';

  /// Astrolab halkaları: üç eğik altın yörünge (şeffaf, döner).
  static const String astrolabHalkalar = 'assets/images/astrolab_halkalar.webp';

  /// Işık küresinin boş camı (şeffaf, en üst katman).
  static const String kureCam = 'assets/images/kure_cam.webp';

  /// Işık küresinin sıvısı: yıldızlı mavi ışık (şeffaf, maskelenir).
  static const String kureSivi = 'assets/images/kure_sivi.webp';

  /// Işık küresinin altın yörünge çerçevesi (şeffaf).
  static const String kureCerceve = 'assets/images/kure_cerceve.webp';

  /// "Kartın hazır" kart ön yüzü: kemerli pencereden ışık kapısı.
  static const String kartHazir = 'assets/images/kart_hazir.jpg';

  // ---- Paylaşım ----

  /// Hikâye kartı teması: lacivert gece, hilal.
  static const String paylasimGece = 'assets/images/paylasim_gece.jpg';

  /// Hikâye kartı teması: altın-beyaz ışık.
  static const String paylasimIsik = 'assets/images/paylasim_isik.jpg';

  /// Hikâye kartı teması: mor bulutsu.
  static const String paylasimMor = 'assets/images/paylasim_mor.jpg';

  // ---- Profil ----

  /// Profil başlık sahnesi: göl üstünde altın zodyak halkası (yatay).
  static const String sahneProfil = 'assets/images/sahne_profil.jpg';

  /// Büyük Üçlü: Güneş madalyonu.
  static const String madalyonGunes = 'assets/images/madalyon_gunes.webp';

  /// Büyük Üçlü: Ay madalyonu.
  static const String madalyonAy = 'assets/images/madalyon_ay.webp';

  /// Büyük Üçlü: Yükselen madalyonu.
  static const String madalyonYukselen =
      'assets/images/madalyon_yukselen.webp';

  /// Burç madalyonu; [ad] `Burc` enum adıdır (koc, boga, ... balik).
  static String burc(String ad) => 'assets/images/burc_$ad.webp';

  /// Sekiz ay evresi; [indeks] `AyEvresi.index` (0 = yeni ay).
  static String ayEvresi(int indeks) => 'assets/images/ay_evresi_$indeks.webp';

  // ---- Raporlar ----

  /// Kişisel Yıl afişi (yatay; sol %45 yazı için boş); [yil] 1-9.
  static String yilAfisi(int yil) => 'assets/images/yil_$yil.jpg';

  /// Işık sızan mermer kapaklı rapor kitabı (şeffaf).
  static const String raporKitap = 'assets/images/rapor_kitap.webp';

  /// Altın asma kilit amblemi (şeffaf).
  static const String kilit = 'assets/images/kilit.webp';

  /// Numeroloji sayılarının boş madalyon çerçevesi (şeffaf).
  static const String sayiMadalyonu = 'assets/images/sayi_madalyonu.webp';

  // ---- Uyum ----

  /// Uyum boş durum/kahraman: kesişen yörüngelerde iki ışık (şeffaf).
  static const String uyumBos = 'assets/images/uyum_bos.webp';

  /// Uyum sonucu: güçlü (parlak altın-turkuaz köprü).
  static const String uyumGuclu = 'assets/images/uyum_guclu.jpg';

  /// Uyum sonucu: dengeli (yumuşak amber köprü).
  static const String uyumDengeli = 'assets/images/uyum_dengeli.jpg';

  /// Uyum sonucu: geliştiren (oluşmakta olan lavanta köprü).
  static const String uyumGelistiren = 'assets/images/uyum_gelistiren.jpg';

  // ---- Keşfet ----

  /// İsim analizi kartı görseli (yatay; sol yarı yazı).
  static const String aracIsim = 'assets/images/arac_isim.jpg';

  /// Numara analizi kartı görseli.
  static const String aracNumara = 'assets/images/arac_numara.jpg';

  /// Bebek ismi kartı görseli.
  static const String aracBebek = 'assets/images/arac_bebek.jpg';

  // ---- Koleksiyon ----

  /// Koleksiyon kartı görseli; [ad] katalogdaki kart kimliğidir.
  static String koleksiyonKarti(String ad) =>
      'assets/images/koleksiyon_$ad.jpg';

  /// Normal koleksiyon kartı çerçevesi (şeffaf, kartla aynı tuval).
  static const String cerceveNormal = 'assets/images/cerceve_normal.webp';

  /// Nadir koleksiyon kartı çerçevesi (şeffaf, kartla aynı tuval).
  static const String cerceveNadir = 'assets/images/cerceve_nadir.webp';
}
