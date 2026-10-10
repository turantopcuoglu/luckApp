import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Alt gezinme: günlük kader sekmesi.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get sekmeBugun;

  /// Alt gezinme: Kader Profili sekmesi.
  ///
  /// In tr, this message translates to:
  /// **'Profilim'**
  String get sekmeProfil;

  /// Alt gezinme: uyum sekmesi.
  ///
  /// In tr, this message translates to:
  /// **'Uyum'**
  String get sekmeUyum;

  /// Alt gezinme: araçlar (isim, numara, bebek ismi) sekmesi.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get sekmeKesfet;

  /// Alt gezinme: ayarlar sekmesi.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get sekmeAyarlar;

  /// Ayarlar ekranı başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get ayarlarBaslik;

  /// Ayarlar bölüm başlığı: profil.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get ayarlarProfil;

  /// Profil satırı: kullanıcının adı.
  ///
  /// In tr, this message translates to:
  /// **'Adın'**
  String get ayarlarAd;

  /// Profil satırı: doğum tarihi.
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihin'**
  String get ayarlarDogumTarihi;

  /// Ad ve doğum tarihinin neden değiştirilemediği.
  ///
  /// In tr, this message translates to:
  /// **'Günlük skorun bu iki bilgiden hesaplandığı için değiştirilemez. Yanlış girdiysen verilerini silip yeniden başlayabilirsin.'**
  String get ayarlarSabitAlanNotu;

  /// Profil satırı: numeroloji için tam ad.
  ///
  /// In tr, this message translates to:
  /// **'Doğumdaki tam adın'**
  String get ayarlarTamAd;

  /// Tam ad boşken alt yazı.
  ///
  /// In tr, this message translates to:
  /// **'Eklenmedi — isim sayıların için ekle'**
  String get ayarlarTamAdYok;

  /// Onboarding tercih cevaplarını düzenleme satırı.
  ///
  /// In tr, this message translates to:
  /// **'Tanışma cevapların'**
  String get ayarlarTercihler;

  /// Tercihler satırının alt yazısı.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlarının sana uyması için verdiğin cevaplar'**
  String get ayarlarTercihlerAciklama;

  /// Ayarlar bölüm başlığı: premium.
  ///
  /// In tr, this message translates to:
  /// **'Premium'**
  String get ayarlarPremium;

  /// Abonelik açıkken durum satırı.
  ///
  /// In tr, this message translates to:
  /// **'Premium aktif'**
  String get ayarlarPremiumAktif;

  /// Abonelik yokken durum satırı.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz sürüm'**
  String get ayarlarPremiumDegil;

  /// Paywall'a götüren alt yazı.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a geç'**
  String get ayarlarPremiumaGec;

  /// Abonelik açıkken alt yazı.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliğini yönet'**
  String get ayarlarAboneligiYonet;

  /// Satın alımları mağazadan geri yükleme satırı.
  ///
  /// In tr, this message translates to:
  /// **'Satın alımları geri yükle'**
  String get ayarlarGeriYukle;

  /// Ayarlar bölüm başlığı: bildirimler.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get ayarlarBildirimler;

  /// Günlük bildirim saatleri.
  ///
  /// In tr, this message translates to:
  /// **'Sabah 08:30 · Akşam 21:00'**
  String get ayarlarBildirimSaatleri;

  /// Bildirimlerin nasıl kapatılacağı.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri kapatmak için telefonunun Ayarlar > Uygulamalar > Kader > Bildirimler bölümünü kullanabilirsin.'**
  String get ayarlarBildirimAciklama;

  /// Bildirim planlarını yeniden kurma satırı.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri yeniden kur'**
  String get ayarlarBildirimleriTazele;

  /// Bildirimler kurulunca SnackBar.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler yeniden kuruldu.'**
  String get ayarlarBildirimlerKuruldu;

  /// Ayarlar bölüm başlığı: uygulama dili.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get ayarlarDil;

  /// Dil seçeneği: telefonun dilini izle.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz dili'**
  String get ayarlarDilCihaz;

  /// Ayarlar bölüm başlığı: gizlilik ve yasal.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve yasal'**
  String get ayarlarGizlilikYasal;

  /// Reklam rıza formunu açan satır.
  ///
  /// In tr, this message translates to:
  /// **'Reklam gizlilik tercihleri'**
  String get ayarlarReklamGizlilik;

  /// Eğlence amaçlı uyarı metnini açan satır.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı: eğlence amaçlıdır'**
  String get ayarlarUyari;

  /// Tüm yerel verileri silme satırı.
  ///
  /// In tr, this message translates to:
  /// **'Verilerimi sil'**
  String get ayarlarVerileriSil;

  /// Silme onay penceresinin açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Profilin, günlük kayıtların, geri bildirimlerin ve eklediğin kişiler bu cihazdan kalıcı olarak silinir. Premium aboneliğin Google Play\'de devam eder; iptal için Google Play\'i kullanmalısın.'**
  String get ayarlarVerileriSilAciklama;

  /// Silme onay penceresinin başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Tüm veriler silinsin mi?'**
  String get ayarlarSilOnayBaslik;

  /// Silme onay düğmesi.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı olarak sil'**
  String get ayarlarSil;

  /// İptal düğmesi.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get ayarlarVazgec;

  /// Bilgi penceresini kapatma düğmesi.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ayarlarTamam;

  /// Yalnız debug derlemede görünen bölüm başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici (yalnızca debug)'**
  String get ayarlarGelistirici;

  /// Debug: premium'u taklit eden anahtar.
  ///
  /// In tr, this message translates to:
  /// **'Premium simülasyonu'**
  String get ayarlarPremiumSimulasyonu;

  /// Debug: reklam rıza durumunu sıfırlama.
  ///
  /// In tr, this message translates to:
  /// **'Reklam rıza durumunu sıfırla'**
  String get ayarlarRizaSifirla;

  /// Debug: rıza sıfırlanınca SnackBar.
  ///
  /// In tr, this message translates to:
  /// **'Rıza durumu sıfırlandı; uygulamayı yeniden başlatınca form tekrar görünür.'**
  String get ayarlarRizaSifirlandi;

  /// Ekranın altındaki sürüm satırı.
  ///
  /// In tr, this message translates to:
  /// **'Kader {surum}'**
  String ayarlarSurum(String surum);

  /// Karşılama ekranı başlığı: uygulama adı (çevrilmez).
  ///
  /// In tr, this message translates to:
  /// **'Kader'**
  String get onboardingUygulamaAdi;

  /// Karşılama sloganı.
  ///
  /// In tr, this message translates to:
  /// **'Şansın her sabah yeniden yazılır.'**
  String get onboardingSlogan;

  /// Karşılama ekranının alt açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihin ve adından hesaplanan sayılarınla, her gün sana özel yazılmış bir okuma.'**
  String get onboardingKarsilamaAciklama;

  /// Karşılama ekranı ana butonu.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get onboardingBasla;

  /// Profil formu: isim alanı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Sana nasıl hitap edelim?'**
  String get onboardingIsimEtiketi;

  /// Profil formu: isim alanı yer tutucusu.
  ///
  /// In tr, this message translates to:
  /// **'Adın'**
  String get onboardingIsimIpucu;

  /// Profil formu: numeroloji için tam ad alanı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Doğumdaki tam adın (isteğe bağlı)'**
  String get onboardingTamAdEtiketi;

  /// Profil formu: tam ad alanı yer tutucusu.
  ///
  /// In tr, this message translates to:
  /// **'Ad Göbek adı Soyad'**
  String get onboardingTamAdIpucu;

  /// Profil formu: tam adın neden istendiği.
  ///
  /// In tr, this message translates to:
  /// **'İsim, ruh ve kişilik sayıların nüfus kaydındaki tam adından hesaplanır. Boş bırakırsan bunları daha sonra profilinden ekleyebilirsin.'**
  String get onboardingTamAdAciklama;

  /// Profil formu: doğum tarihi bölümü etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihin'**
  String get onboardingDogumTarihiEtiketi;

  /// Profil formu: doğum tarihinin neden doğru girilmesi gerektiği.
  ///
  /// In tr, this message translates to:
  /// **'Yaşam yolu sayın ve burcun bu tarihten hesaplanır; lütfen doğru gir.'**
  String get onboardingDogumTarihiAciklama;

  /// Profil formu ana butonu.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get onboardingDevam;

  /// Tanışma ekranı: hesaplamayı başlatan buton.
  ///
  /// In tr, this message translates to:
  /// **'Kaderimi hesapla'**
  String get onboardingKaderimiHesapla;

  /// Tanışma ekranı (Ayarlar'dan düzenleme modu): kaydet butonu.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get onboardingKaydet;

  /// Tanışma ekranı: soruları atlama butonu.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik atla'**
  String get onboardingAtla;

  /// İsim boşken gösterilen SnackBar.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için adını yazmalısın.'**
  String get onboardingIsimBosUyarisi;

  /// Karşılama ekranının alt notu.
  ///
  /// In tr, this message translates to:
  /// **'Günlük bir ilham ritüeli.'**
  String get onboardingRituelNotu;

  /// Işık dolumu ekranının başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Kartın hazırlanıyor'**
  String get onboardingKartHazirlaniyor;

  /// Işık dolumu kontrol listesi, 1. adım.
  ///
  /// In tr, this message translates to:
  /// **'Profil hazır'**
  String get onboardingHazirlikProfil;

  /// Işık dolumu kontrol listesi, 2. adım.
  ///
  /// In tr, this message translates to:
  /// **'Günlük kart hazırlanıyor'**
  String get onboardingHazirlikKart;

  /// Işık dolumu kontrol listesi, 3. adım.
  ///
  /// In tr, this message translates to:
  /// **'Son dokunuşlar'**
  String get onboardingHazirlikSon;

  /// Işık dolumu ekranının alt notu.
  ///
  /// In tr, this message translates to:
  /// **'Kendine küçük bir alan aç.'**
  String get onboardingKendineAlanAc;

  /// Hazır kart başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Kartın hazır'**
  String get onboardingKartinHazir;

  /// Hazır kart alt başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Bugün kendin için küçük bir adım seç.'**
  String get onboardingKartinHazirAlt;

  /// Hazır kart rozeti.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlık tamamlandı'**
  String get onboardingHazirlikTamamlandi;

  /// Ana ekrana geçiş butonu.
  ///
  /// In tr, this message translates to:
  /// **'Kartıma geç'**
  String get onboardingKartimaGec;

  /// Tanışma ekranı başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Seni biraz tanıyalım'**
  String get onboardingTanismaBaslik;

  /// Tanışma ekranı açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Cevapların yorumlarının sana gerçekten uymasını sağlar: bir öğrenciye iş yeri, bekar birine partner cümlesi göstermeyiz. Hepsi isteğe bağlı ve sonradan Ayarlar\'dan değiştirilebilir.'**
  String get onboardingTanismaAciklama;

  /// Tanışma sorusu: enerji tarzı.
  ///
  /// In tr, this message translates to:
  /// **'Enerjini nasıl toplarsın?'**
  String get onboardingSoruEnerji;

  /// Tanışma sorusu: karar tarzı.
  ///
  /// In tr, this message translates to:
  /// **'Karar verirken…'**
  String get onboardingSoruKarar;

  /// Tanışma sorusu: ilişki durumu.
  ///
  /// In tr, this message translates to:
  /// **'İlişki durumun'**
  String get onboardingSoruIliski;

  /// Tanışma sorusu: günlük uğraş.
  ///
  /// In tr, this message translates to:
  /// **'Günlerini en çok ne dolduruyor?'**
  String get onboardingSoruUgras;

  /// Tanışma ekranı gizlilik notu.
  ///
  /// In tr, this message translates to:
  /// **'Cevapların yalnızca bu cihazda saklanır.'**
  String get onboardingTanismaGizlilik;

  /// Uyarı/onay ekranı başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Başlamadan önce'**
  String get yasalUyariBaslik;

  /// Uyarı ekranı: onay sonrası devam butonu.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get yasalDevam;

  /// Yasal belge adı ve ekran başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get yasalGizlilikPolitikasi;

  /// Yasal belge adı ve ekran başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get yasalKullanimKosullari;

  /// intl DateFormat deseni: tam tarih (ör. 6 Temmuz 2026, Pazartesi). Harfler çevrilmez, yalnız sıra ve noktalama dile göre değişir.
  ///
  /// In tr, this message translates to:
  /// **'d MMMM y, EEEE'**
  String get tarihDeseni;

  /// intl DateFormat deseni: haftanın günü olmadan tarih (ör. 6 Temmuz 2026).
  ///
  /// In tr, this message translates to:
  /// **'d MMMM y'**
  String get kisaTarihDeseni;

  /// Skor halkasının altındaki etiket (büyük harf).
  ///
  /// In tr, this message translates to:
  /// **'GENEL SKOR'**
  String get gunlukGenelSkor;

  /// Skor yüklenirken gösterilen metin.
  ///
  /// In tr, this message translates to:
  /// **'Kaderin hesaplanıyor...'**
  String get gunlukYukleniyor;

  /// Kapalı kartın altındaki başlık.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün kartı hazır'**
  String get gunlukKartHazir;

  /// Kapalı kartın altındaki davet cümlesi.
  ///
  /// In tr, this message translates to:
  /// **'Kendine bir dakika ayır.'**
  String get gunlukKendineBirDakika;

  /// Kartı açan buton ve kartın erişilebilirlik etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Kartımı aç'**
  String get gunlukKartimiAc;

  /// Açık karttaki skorun altındaki etiket.
  ///
  /// In tr, this message translates to:
  /// **'Günün şans puanı'**
  String get gunlukSansPuani;

  /// Skorun paydası.
  ///
  /// In tr, this message translates to:
  /// **'/ {maks}'**
  String gunlukPuanPaydasi(int maks);

  /// Ekran okuyucu için skor cümlesi.
  ///
  /// In tr, this message translates to:
  /// **'Günün şans puanı: {skor} / {maks}'**
  String gunlukPuanSemantik(int skor, int maks);

  /// Skor ya da okuma yüklenemezse gösterilen hata metni.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti. Uygulamayı yeniden başlatmayı dene.'**
  String get gunlukHata;

  /// Ana ekran selamlaması.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba, {isim}'**
  String gunlukSelamlama(String isim);

  /// Şans ögeleri kartı: renk sütunu etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Şans rengin'**
  String get gunlukSansRengi;

  /// Şans ögeleri kartı: sayı sütunu etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Şanslı sayın'**
  String get gunlukSansliSayi;

  /// Şans ögeleri kartı: tavsiye satırı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Günün tavsiyesi'**
  String get gunlukTavsiye;

  /// Yorum bölümünün altındaki geri bildirim sorusu.
  ///
  /// In tr, this message translates to:
  /// **'Bu yorum seni anlattı mı?'**
  String get gunlukSeniAnlattiMi;

  /// Olumlu cevap düğmesinin ipucu.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get gunlukEvet;

  /// Olumsuz cevap düğmesinin ipucu.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get gunlukHayir;

  /// Olumlu cevap sonrası SnackBar.
  ///
  /// In tr, this message translates to:
  /// **'Güzel! Bu tarz yorumları sevdiğini not ettik ✨'**
  String get gunlukAnlattiTesekkur;

  /// Olumsuz cevap sonrası SnackBar.
  ///
  /// In tr, this message translates to:
  /// **'Teşekkürler. Önümüzdeki günlerde bu yorumu sana tekrar göstermeyeceğiz.'**
  String get gunlukAnlatmadiTesekkur;

  /// Skorun nedenlerini açan başlık.
  ///
  /// In tr, this message translates to:
  /// **'Neden bugün?'**
  String get gunlukNedenBugun;

  /// Neden sayfasının alt notu.
  ///
  /// In tr, this message translates to:
  /// **'Skorun ve yorumun bu hesaplardan gelir. Aynı gün, aynı sonucu verir.'**
  String get gunlukNedenNotu;

  /// Akşam geri bildirim kartının başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Günün nasıldı?'**
  String get gunlukAksamBaslik;

  /// Akşam geri bildirim kartının açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Bugün gerçekten şanslı mıydın? Cevabın Kader\'in sana olan isabetini takip etmesine yardım eder.'**
  String get gunlukAksamAciklama;

  /// Akşam kartından geri bildirim ekranını açan buton.
  ///
  /// In tr, this message translates to:
  /// **'Cevapla'**
  String get gunlukAksamButon;

  /// Kategori detayı: şanslı saat kartının başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Şanslı saat aralığın'**
  String get kategoriSansliSaat;

  /// Kilitli kategorinin kilit seçenekleri sayfasındaki açıklama.
  ///
  /// In tr, this message translates to:
  /// **'{kategori} kategorisinin bugünkü skoru, sana özel yorumu ve şanslı saati Premium üyelere açık. İstersen kısa bir reklam izleyerek yalnızca bugün için de açabilirsin.'**
  String kategoriKilitAciklamasi(String kategori);

  /// Akşam bildiriminin ve geri bildirim ekranının ana sorusu.
  ///
  /// In tr, this message translates to:
  /// **'Bugün gerçekten şanslı mıydın?'**
  String get geriBildirimAksamSorusu;

  /// Geri bildirim ekranının başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Günün nasıldı?'**
  String get geriBildirimBaslik;

  /// İsteğe bağlı emoji bölümünün başlığı.
  ///
  /// In tr, this message translates to:
  /// **'İstersen bir emoji bırak'**
  String get geriBildirimEmojiBaslik;

  /// Geri bildirim ekranının kaydet butonu.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get geriBildirimKaydet;

  /// Kayıt sonrası teşekkür.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi, yarın görüşürüz ✨'**
  String get geriBildirimTesekkur;

  /// Bildirim izni reddedilince gösterilen nazik hatırlatma.
  ///
  /// In tr, this message translates to:
  /// **'Sorun değil! İstersen bildirimleri daha sonra telefon ayarlarından açabilirsin.'**
  String get geriBildirimIzinReddi;

  /// Android bildirim kanalı adı (telefon ayarlarında görünür).
  ///
  /// In tr, this message translates to:
  /// **'Günlük Hatırlatmalar'**
  String get bildirimKanalAd;

  /// Android bildirim kanalı açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Sabah kader hazır ve akşam geri bildirim hatırlatmaları'**
  String get bildirimKanalAciklama;

  /// Sabah bildirimi varyasyonu 1/12. Sıra iki dilde aynı kalmalı (gün → indeks).
  ///
  /// In tr, this message translates to:
  /// **'Bugünün kaderi hazır ✨'**
  String get bildirimSabah1;

  /// Sabah bildirimi varyasyonu 2/12.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızlar senin için dizildi, gel bak 🌟'**
  String get bildirimSabah2;

  /// Sabah bildirimi varyasyonu 3/12.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir gün, yeni bir şans. Skorun seni bekliyor 🍀'**
  String get bildirimSabah3;

  /// Sabah bildirimi varyasyonu 4/12.
  ///
  /// In tr, this message translates to:
  /// **'Kader kartın açılmayı bekliyor 🎴'**
  String get bildirimSabah4;

  /// Sabah bildirimi varyasyonu 5/12.
  ///
  /// In tr, this message translates to:
  /// **'Bugün şanslı mısın? Öğrenmenin tek yolu var 👀'**
  String get bildirimSabah5;

  /// Sabah bildirimi varyasyonu 6/12.
  ///
  /// In tr, this message translates to:
  /// **'Güne bakmadan çıkma: kaderin hesaplandı ☕'**
  String get bildirimSabah6;

  /// Sabah bildirimi varyasyonu 7/12.
  ///
  /// In tr, this message translates to:
  /// **'Evren bugün ne fısıldıyor? Kartına dokun 🔮'**
  String get bildirimSabah7;

  /// Sabah bildirimi varyasyonu 8/12.
  ///
  /// In tr, this message translates to:
  /// **'Skorun hazır. Cesaret edebilecek misin? 😏'**
  String get bildirimSabah8;

  /// Sabah bildirimi varyasyonu 9/12.
  ///
  /// In tr, this message translates to:
  /// **'Ay evresi işini yaptı, sıra sende 🌙'**
  String get bildirimSabah9;

  /// Sabah bildirimi varyasyonu 10/12.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün enerjisi ölçüldü. Sonuç içeride ⚡'**
  String get bildirimSabah10;

  /// Sabah bildirimi varyasyonu 11/12.
  ///
  /// In tr, this message translates to:
  /// **'Kaderin kapıda, açmayan bilemez 🚪'**
  String get bildirimSabah11;

  /// Sabah bildirimi varyasyonu 12/12.
  ///
  /// In tr, this message translates to:
  /// **'Şans perileri mesaini tamamladı, rapor hazır 🧚'**
  String get bildirimSabah12;

  /// Paylaş butonu.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get paylasimPaylas;

  /// Story kartının köşesindeki uygulama imzası (çevrilmez).
  ///
  /// In tr, this message translates to:
  /// **'Kader ✨'**
  String get paylasimMarka;

  /// Story kartındaki skor etiketi (büyük harf).
  ///
  /// In tr, this message translates to:
  /// **'GÜNÜN ŞANS PUANI'**
  String get paylasimGenelSkor;

  /// Paylaşım menüsüne eklenen kısa metin; kişisel başlık yoksa kartta da görünür.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü kaderim ✨'**
  String get paylasimMetni;

  /// Keşfet aracı kartının altındaki davet.
  ///
  /// In tr, this message translates to:
  /// **'Sen de hesapla: Kader uygulaması'**
  String get paylasimAracDavet;

  /// Paylaşım ekranının başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Kartını paylaş'**
  String get paylasimKartiniPaylas;

  /// Skoru karttan gizleme anahtarı.
  ///
  /// In tr, this message translates to:
  /// **'Skoru gizle'**
  String get paylasimSkoruGizle;

  /// Paylaş butonunun altındaki açıklama.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım menüsünü açar'**
  String get paylasimMenusunuAcar;

  /// Tema seçicinin erişilebilirlik etiketi.
  ///
  /// In tr, this message translates to:
  /// **'{tema} teması'**
  String paylasimTemaSecimi(String tema);

  /// Paylaşım teması adı.
  ///
  /// In tr, this message translates to:
  /// **'Gece'**
  String get paylasimTemaGece;

  /// Paylaşım teması adı.
  ///
  /// In tr, this message translates to:
  /// **'Işık'**
  String get paylasimTemaIsik;

  /// Paylaşım teması adı.
  ///
  /// In tr, this message translates to:
  /// **'Mor'**
  String get paylasimTemaMor;

  /// Kader Profili ekran başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Kader Profilin'**
  String get profilBaslik;

  /// Profil başlığının altındaki açıklama.
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihin ve adından hesaplanan, zamanla değişmeyen sayıların. Her sayıya dokunarak nasıl hesaplandığını görebilirsin.'**
  String get profilAciklama;

  /// Sayı karosu etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Yaşam Yolu'**
  String get profilYasamYolu;

  /// Sayı karosu etiketi: isim sayısı.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get profilIsimSayisi;

  /// Sayı karosu etiketi: ruh sayısı.
  ///
  /// In tr, this message translates to:
  /// **'Ruh'**
  String get profilRuhSayisi;

  /// Sayı karosu etiketi: kişilik sayısı.
  ///
  /// In tr, this message translates to:
  /// **'Kişilik'**
  String get profilKisilikSayisi;

  /// Tam ad yokken sayı karosundaki metin.
  ///
  /// In tr, this message translates to:
  /// **'Tam adını ekle'**
  String get profilTamAdEkle;

  /// Tam ad eksik kartının başlığı.
  ///
  /// In tr, this message translates to:
  /// **'İsim sayıların eksik'**
  String get profilTamAdEksikBaslik;

  /// Tam ad eksik kartının açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'İsim, ruh ve kişilik sayıların doğumdaki tam adından hesaplanır. Tam adını eklersen profiline iki yeni bölüm açılır.'**
  String get profilTamAdEksikAciklama;

  /// Hesap ayrıntısı başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl hesaplandı?'**
  String get profilNasilHesaplandi;

  /// Hesap sistemi notu (harf tablosu iki dilde aynıdır, D6).
  ///
  /// In tr, this message translates to:
  /// **'Kader, Pitagor numeroloji sistemini kullanır: A=1 … I=9, J=1 … R=9, S=1 … Z=8. Türkçe harfler Latin karşılıklarının değerini alır (Ç=3, Ğ=7, I/İ=9, Ö=6, Ş=1, Ü=3). 11, 22 ve 33 usta sayı olarak korunur. Farklı numeroloji sistemleri farklı sonuçlar verebilir.'**
  String get profilSistemNotu;

  /// Hesap adımı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Doğum ayı'**
  String get profilAdimAy;

  /// Hesap adımı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Doğum günü'**
  String get profilAdimGun;

  /// Hesap adımı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Doğum yılı'**
  String get profilAdimYil;

  /// Hesap adımı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get profilAdimToplam;

  /// Hesap adımı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Tüm harfler'**
  String get profilAdimHarfler;

  /// Hesap adımı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Sesli harfler'**
  String get profilAdimSesliler;

  /// Hesap adımı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz harfler'**
  String get profilAdimSessizler;

  /// Usta sayı notu (11, 22, 33).
  ///
  /// In tr, this message translates to:
  /// **'Usta sayı'**
  String get profilUstaSayi;

  /// Kilitli bölüm butonu.
  ///
  /// In tr, this message translates to:
  /// **'Kilidi aç'**
  String get profilKilidiAc;

  /// Profil kilit seçenekleri açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Profilinin tamamı — gölge yanın, aşk ve iş hayatın, yaşam dersin, iç sesin ve bu yılın teması — Premium üyelere açık. İstersen kısa bir reklam izleyerek bugün için de açabilirsin.'**
  String get profilKilitAciklamasi;

  /// Burç sınır günü uyarı çipi.
  ///
  /// In tr, this message translates to:
  /// **'Burç sınırı'**
  String get profilSinirGunu;

  /// Profilden rapora giriş kartının başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Numeroloji Raporun'**
  String get profilRaporGirisBaslik;

  /// Rapora giriş kartının açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Hayatının dört dönemi, karmik sayıların ve isminin gizli anlamları.'**
  String get profilRaporGirisAciklama;

  /// Numeroloji raporu ekran başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Numeroloji Raporun'**
  String get profilRaporBaslik;

  /// Numeroloji raporu ekran açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihin ve tam adından hesaplanan, hayatının uzun dönemlerine dair temalar. Bu rapor bir eğilim haritasıdır; olayları değil, dönemlerin sana neyi öğretmeye çalıştığını anlatır.'**
  String get profilRaporAciklama;

  /// Zaman çizelgesi başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Hayatının dört dönemi'**
  String get profilZamanCizelgesiBaslik;

  /// Zaman çizelgesinde aktif dönem etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Şu an'**
  String get profilSuAn;

  /// Zaman çizelgesinde zirve sayısı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Zirve {zirve}'**
  String profilZirve(int zirve);

  /// Büyük Üçlü kartı ve ekran başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Büyük Üçlün'**
  String get profilBuyukUcluBaslik;

  /// Büyük Üçlü kartı açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Güneş burcun kim olduğunu, Ay burcun nasıl hissettiğini, Yükselenin dünyaya nasıl göründüğünü anlatır.'**
  String get profilBuyukUcluAciklama;

  /// Büyük Üçlü sütun etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Güneş'**
  String get profilGunes;

  /// Büyük Üçlü sütun etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Ay'**
  String get profilAy;

  /// Büyük Üçlü sütun etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Yükselen'**
  String get profilYukselen;

  /// Yükselen bilinmiyorken düğme.
  ///
  /// In tr, this message translates to:
  /// **'Yükselenini öğren'**
  String get profilYukseleniniOgren;

  /// Harita ekranına giden düğme.
  ///
  /// In tr, this message translates to:
  /// **'Haritanı oku'**
  String get profilHaritaniOku;

  /// Harita ekranında Güneş bölümü başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Güneş burcun · {burc}'**
  String profilGunesBasligi(String burc);

  /// Harita kilit açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Yükselen yorumun Premium üyelere açık. İstersen kısa bir reklam izleyerek bugün için de açabilirsin.'**
  String get profilHaritaKilitAciklamasi;

  /// Doğum bilgisi düzenleyici başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Doğum saatin ve yerin'**
  String get profilDogumBilgisiBaslik;

  /// Doğum bilgisi düzenleyici açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Yükselen burcun doğum saatine ve doğduğun yere göre değişir. Nüfus kaydındaki ya da ailenin hatırladığı saati gir; birkaç dakikalık fark bile Yükseleni değiştirebilir.'**
  String get profilDogumBilgisiAciklama;

  /// Doğum saati satırı.
  ///
  /// In tr, this message translates to:
  /// **'Doğum saati'**
  String get profilDogumSaati;

  /// Doğum saati bilinmiyor seçeneği.
  ///
  /// In tr, this message translates to:
  /// **'Bilmiyorum'**
  String get profilSaatBilinmiyor;

  /// Doğum saati seçme düğmesi.
  ///
  /// In tr, this message translates to:
  /// **'Saat seç'**
  String get profilSaatSec;

  /// Doğum yeri alanı (il listesi şimdilik Türkiye illeri).
  ///
  /// In tr, this message translates to:
  /// **'Doğduğun il'**
  String get profilDogumIli;

  /// Doğum yeri alanı ipucu.
  ///
  /// In tr, this message translates to:
  /// **'İl adı yaz (ör. İzmir)'**
  String get profilDogumIliIpucu;

  /// Doğum bilgisi düzenleyici kaydet butonu.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get profilKaydet;

  /// Ana ekran yıl raporu tanıtım kartı başlığı.
  ///
  /// In tr, this message translates to:
  /// **'{yil} Kişisel Yıl Raporun'**
  String profilYilRaporuKartBaslik(int yil);

  /// Yıl raporu tanıtım kartı açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'{yil} senin için {yilLakabi}. Yılın fırsatları, akışta olduğun aylar ve ay ay rehberin hazır.'**
  String profilYilRaporuKartAciklama(int yil, String yilLakabi);

  /// Yıl raporu ekran başlığı.
  ///
  /// In tr, this message translates to:
  /// **'{yil} Raporun'**
  String profilYilRaporuBaslik(int yil);

  /// Yıl raporu üst bilgisindeki etiket.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel yılın'**
  String get profilKisiselYilEtiketi;

  /// Yıl raporu ay ay bölümü başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Ay ay {yil}'**
  String profilAyAyBaslik(int yil);

  /// Akış ayı çipi.
  ///
  /// In tr, this message translates to:
  /// **'Akışta'**
  String get profilAkisCipi;

  /// Zorlu ay çipi.
  ///
  /// In tr, this message translates to:
  /// **'Zorlayıcı'**
  String get profilZorluCipi;

  /// Tam ad yokken rapor kartı başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Raporun yarım kaldı'**
  String get profilRaporTamAdEksikBaslik;

  /// Tam ad yokken rapor kartı açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Karmik derslerin, gizli tutkun, olgunluk sayın ve isminin harfleri doğumdaki tam adından hesaplanır. Tam adını eklersen raporuna beş yeni bölüm açılır.'**
  String get profilRaporTamAdEksikAciklama;

  /// Tam ad diyaloğu başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Doğumdaki tam adın'**
  String get tamAdBaslik;

  /// Tam ad diyaloğu açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Nüfus kaydındaki gibi, göbek adların dahil yaz (ör. Ayşe Nur Yılmaz). Kısaltma ve lakap kullanma; isim sayıları bu adla hesaplanır. Günlük skorun değişmez.'**
  String get tamAdAciklama;

  /// Tam ad alanı ipucu.
  ///
  /// In tr, this message translates to:
  /// **'Ad Göbek adı Soyad'**
  String get tamAdIpucu;

  /// Tam ad diyaloğu kaydet.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get tamAdKaydet;

  /// Tam adı kaldırma.
  ///
  /// In tr, this message translates to:
  /// **'Kaldır'**
  String get tamAdKaldir;

  /// Tam ad diyaloğunu kapatma.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get tamAdVazgec;

  /// Paywall başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Kader Premium'**
  String get premiumBaslik;

  /// Paywall alt başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Kaderinin tamamını gör: her gün, her kategori, reklamsız.'**
  String get premiumAltBaslik;

  /// Paywall özellik listesi, 1/7.
  ///
  /// In tr, this message translates to:
  /// **'Aşk ve Para kategorileri her gün açık'**
  String get premiumOzellik1;

  /// Paywall özellik listesi, 2/7.
  ///
  /// In tr, this message translates to:
  /// **'Tam Kader Profili: gölge yanın, aşk, iş, yaşam dersin, iç sesin'**
  String get premiumOzellik2;

  /// Paywall özellik listesi, 3/7.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel yıl okuması ve yılın teması'**
  String get premiumOzellik3;

  /// Paywall özellik listesi, 4/7.
  ///
  /// In tr, this message translates to:
  /// **'Numeroloji Raporunun tamamı: hayatının dört dönemi ve karmik sayıların'**
  String get premiumOzellik4;

  /// Paywall özellik listesi, 5/7.
  ///
  /// In tr, this message translates to:
  /// **'Her yıl Kişisel Yıl Raporu: ay ay rehberin'**
  String get premiumOzellik5;

  /// Paywall özellik listesi, 6/7.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız uyum hesabı'**
  String get premiumOzellik6;

  /// Paywall özellik listesi, 7/7.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız deneyim'**
  String get premiumOzellik7;

  /// Yıllık plan etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get premiumYillik;

  /// Aylık plan etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get premiumAylik;

  /// Yıllık plan rozeti.
  ///
  /// In tr, this message translates to:
  /// **'En avantajlı'**
  String get premiumEnAvantajli;

  /// Yıllık planın aylık karşılığı.
  ///
  /// In tr, this message translates to:
  /// **'aylık yaklaşık {fiyat}'**
  String premiumAyliginaDusen(String fiyat);

  /// Deneme süresi metni.
  ///
  /// In tr, this message translates to:
  /// **'{gun} gün ücretsiz dene'**
  String premiumDeneme(int gun);

  /// Fiyatın dönem son eki: yıllık.
  ///
  /// In tr, this message translates to:
  /// **'/ yıl'**
  String get premiumDonemYil;

  /// Fiyatın dönem son eki: aylık.
  ///
  /// In tr, this message translates to:
  /// **'/ ay'**
  String get premiumDonemAy;

  /// Satın alma butonu.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliği başlat'**
  String get premiumAbonelikBaslat;

  /// Deneme varsa satın alma butonu.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz denemeyi başlat'**
  String get premiumDenemeBaslat;

  /// Geri yükleme butonu.
  ///
  /// In tr, this message translates to:
  /// **'Satın alımları geri yükle'**
  String get premiumGeriYukle;

  /// Planlar yüklenirken.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik seçenekleri yükleniyor…'**
  String get premiumYukleniyor;

  /// Mağaza yoksa ya da ürün bulunamadıysa.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik seçenekleri şu an görüntülenemiyor. Uygulamanın Google Play üzerinden yüklendiğinden ve internet bağlantının açık olduğundan emin ol.'**
  String get premiumPlanYok;

  /// Tekrar dene butonu.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get premiumTekrarDene;

  /// Otomatik yenileme ve iptal bilgisi (Play politikası gereği zorunlu).
  ///
  /// In tr, this message translates to:
  /// **'Abonelik, dönem bitmeden en az 24 saat önce iptal edilmezse aynı süre ve fiyatla otomatik yenilenir. Ücretsiz deneme bitmeden iptal edilmezse ücretli döneme geçilir. Aboneliğini Google Play > Ödemeler ve abonelikler bölümünden istediğin zaman iptal edebilirsin.'**
  String get premiumYenilemeBilgisi;

  /// Paywall dipnotu.
  ///
  /// In tr, this message translates to:
  /// **'Premium, şans puanını değiştirmez.'**
  String get premiumPuanNotu;

  /// Zaten premium olan kullanıcıya.
  ///
  /// In tr, this message translates to:
  /// **'Premium üyeliğin aktif ✨'**
  String get premiumZatenPremium;

  /// Premium açıldı mesajı.
  ///
  /// In tr, this message translates to:
  /// **'Premium açıldı. Keyfini çıkar ✨'**
  String get premiumBasarili;

  /// Kilit sayfası başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Bu içerik Premium'**
  String get premiumKilitBaslik;

  /// Kilit sayfası: Premium seçeneği.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a geç'**
  String get premiumPremiumaGec;

  /// Kilit sayfası: reklam seçeneği.
  ///
  /// In tr, this message translates to:
  /// **'Reklam izle, bugün için aç'**
  String get premiumReklamlaAc;

  /// Kilit sayfası: reklam yok.
  ///
  /// In tr, this message translates to:
  /// **'Şu an gösterilecek reklam bulunamadı. Biraz sonra tekrar deneyebilirsin.'**
  String get premiumReklamYok;

  /// Kilit sayfası: reklam yarıda kaldı.
  ///
  /// In tr, this message translates to:
  /// **'Reklam tamamlanmadığı için içerik açılamadı.'**
  String get premiumOdulYok;

  /// Kilit sayfası: içerik açıldı.
  ///
  /// In tr, this message translates to:
  /// **'Bugün için açıldı ✨'**
  String get premiumAcildi;

  /// Uyum kişi sınırı mesajı.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz sürümde bir kişiyle uyum hesaplayabilirsin. Sınırsız kişi için Premium\'a geçebilirsin.'**
  String get premiumKisiSiniri;

  /// Numeroloji raporu kilit sayfası başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Raporunun tamamını aç'**
  String get premiumRaporKilitBaslik;

  /// Numeroloji raporu kilit sayfası açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Bu dönemin dersi, sıradaki dönemin, karmik borçların, isminde eksik sayıların, gizli tutkun, olgunluk sayın ve isminin harfleri — raporunun tamamı tek seferlik bir ödemeyle kalıcı olarak açılır.'**
  String get premiumRaporKilitAciklama;

  /// Rapor satın alma butonu.
  ///
  /// In tr, this message translates to:
  /// **'Raporu aç · {fiyat}'**
  String premiumRaporuSatinAl(String fiyat);

  /// Rapor fiyatı yüklenirken buton metni.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat yükleniyor…'**
  String get premiumRaporFiyatYukleniyor;

  /// Rapor kilit sayfası: Premium seçeneği.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a geç — rapor dahil'**
  String get premiumRaporPremiumSecenegi;

  /// Tek seferlik ödeme bilgisi.
  ///
  /// In tr, this message translates to:
  /// **'Tek seferlik ödemedir, abonelik değildir. Rapor bu Google hesabında kalıcı olarak açık kalır; cihaz değiştirdiğinde \"Satın alımları geri yükle\" ile yeniden açabilirsin.'**
  String get premiumRaporOdemeBilgisi;

  /// Yıl raporu kilit sayfası başlığı.
  ///
  /// In tr, this message translates to:
  /// **'{yil} raporunun tamamını aç'**
  String premiumYilRaporuKilitBaslik(int yil);

  /// Yıl raporu kilit sayfası açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Yılın fırsatları ve tuzakları, aşk ile iş ve para rehberin, akışta olduğun ve zorlanabileceğin aylar, ay ay okuma ve yılın sorusu — tek seferlik bir ödemeyle kalıcı olarak açılır.'**
  String get premiumYilRaporuKilitAciklama;

  /// Yıl raporu kilit sayfası: Premium seçeneği.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a geç — her yılın raporu dahil'**
  String get premiumYilRaporuPremiumSecenegi;

  /// Rapor açıldı mesajı.
  ///
  /// In tr, this message translates to:
  /// **'Raporun açıldı ✨'**
  String get premiumRaporAcildi;

  /// Abonelik yönetimi bilgisi.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliğini Google Play Store uygulamasında Profil > Ödemeler ve abonelikler > Abonelikler bölümünden yönetebilir veya iptal edebilirsin.'**
  String get premiumYonetimBilgisi;

  /// Hata: planlar yüklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik seçenekleri şu an yüklenemedi. İnternet bağlantını kontrol edip tekrar dene.'**
  String get premiumHataPlanlar;

  /// Hata: satın alma akışı başlamadı.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma başlatılamadı. Google Play hesabının açık olduğundan emin olup tekrar dene.'**
  String get premiumHataSatinAlmaBaslamadi;

  /// Hata: satın alma sırasında hata.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma tamamlanamadı. Ücret alınmadıysa tekrar deneyebilirsin.'**
  String get premiumHataSatinAlma;

  /// Hata: ödeme beklemede.
  ///
  /// In tr, this message translates to:
  /// **'Ödemen onay bekliyor. Onaylandığında Premium otomatik açılacak.'**
  String get premiumHataOdemeBekleniyor;

  /// Hata: tek seferlik ürün mağazada bulunamadı.
  ///
  /// In tr, this message translates to:
  /// **'Rapor şu an satın alınamıyor. Uygulamanın Google Play üzerinden yüklendiğinden ve internet bağlantının açık olduğundan emin ol.'**
  String get premiumHataRaporUrunuYok;

  /// Hata: geri yükleme.
  ///
  /// In tr, this message translates to:
  /// **'Satın alımlar geri yüklenemedi. Aynı Google hesabıyla giriş yaptığından emin ol.'**
  String get premiumHataGeriYukleme;

  /// Keşfet sekmesi ekran başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get araclarBaslik;

  /// Keşfet başlığı altındaki açıklama.
  ///
  /// In tr, this message translates to:
  /// **'İsimlerin ve numaraların da birer sayısı var. Merak ettiğin bir adı, telefonunu ya da bebeğin için düşündüğün isimleri hesapla.'**
  String get araclarAciklama;

  /// İsim analizi kartı ve ekran başlığı.
  ///
  /// In tr, this message translates to:
  /// **'İsim Analizi'**
  String get araclarIsimBaslik;

  /// İsim analizi kartı açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Herhangi bir adın isim, ruh ve kişilik sayıları.'**
  String get araclarIsimAciklama;

  /// Numara analizi kartı ve ekran başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Numara Analizi'**
  String get araclarNumaraBaslik;

  /// Numara analizi kartı açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Telefon, plaka ya da ev numaranın sayısı ve enerjisi.'**
  String get araclarNumaraAciklama;

  /// Bebek ismi kartı ve ekran başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Bebek İsmi'**
  String get araclarBebekBaslik;

  /// Bebek ismi kartı açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Aday isimlerin ailenle numerolojik uyumu.'**
  String get araclarBebekAciklama;

  /// Hesapla butonu.
  ///
  /// In tr, this message translates to:
  /// **'Hesapla'**
  String get araclarHesapla;

  /// Araç sonucunu paylaş butonu.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get araclarPaylas;

  /// Geçersiz girdi uyarısı.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplanacak harf ya da rakam bulunamadı.'**
  String get araclarGecersiz;

  /// Paylaşım kartı üst etiketi (büyük harf, dilin kurallarıyla).
  ///
  /// In tr, this message translates to:
  /// **'İSİM ANALİZİ'**
  String get araclarIsimKartEtiketi;

  /// Paylaşım kartı üst etiketi.
  ///
  /// In tr, this message translates to:
  /// **'NUMARA ANALİZİ'**
  String get araclarNumaraKartEtiketi;

  /// Paylaşım kartı üst etiketi.
  ///
  /// In tr, this message translates to:
  /// **'BEBEK İSMİ'**
  String get araclarBebekKartEtiketi;

  /// Paylaşım kartında isim sayısı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'İsim sayısı'**
  String get araclarIsimSayisiEtiketi;

  /// İsim analizi ad alanı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad'**
  String get araclarAdEtiketi;

  /// İsim analizi ad alanı ipucu.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Elif Yılmaz'**
  String get araclarAdIpucu;

  /// Numara alanı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Numara'**
  String get araclarNumaraEtiketi;

  /// Numara türü segmenti.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get araclarTurTelefon;

  /// Telefon numarası ipucu.
  ///
  /// In tr, this message translates to:
  /// **'Örn. 0532 123 45 67'**
  String get araclarTurTelefonIpucu;

  /// Numara türü segmenti.
  ///
  /// In tr, this message translates to:
  /// **'Plaka'**
  String get araclarTurPlaka;

  /// Plaka ipucu.
  ///
  /// In tr, this message translates to:
  /// **'Örn. 34 ABC 123'**
  String get araclarTurPlakaIpucu;

  /// Numara türü segmenti.
  ///
  /// In tr, this message translates to:
  /// **'Ev'**
  String get araclarTurEv;

  /// Ev numarası ipucu.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Daire 7 ya da 12/4'**
  String get araclarTurEvIpucu;

  /// Numara hesap satırı (zincir: "38 → 11").
  ///
  /// In tr, this message translates to:
  /// **'Toplam {zincir}'**
  String araclarHesapSatiri(String zincir);

  /// Bebek ismi aday alanı etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Aday isimler'**
  String get araclarAdaylarEtiketi;

  /// Bebek ismi aday alanı ipucu (çok satırlı).
  ///
  /// In tr, this message translates to:
  /// **'Her satıra bir ad soyad yaz.\nÖrn. Ada Yılmaz\nCan Yılmaz'**
  String get araclarAdaylarIpucu;

  /// Ebeveyn seçimi başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Kimlerle karşılaştıralım?'**
  String get araclarEbeveynBaslik;

  /// Ebeveyn seçimi açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Uyum sekmesine eklediğin kişiler de burada görünür.'**
  String get araclarEbeveynAciklama;

  /// Aktif kullanıcının çip etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Ben ({isim})'**
  String araclarBen(String isim);

  /// Kişi seçilmeden hesaplanınca uyarı.
  ///
  /// In tr, this message translates to:
  /// **'En az bir kişi seç.'**
  String get araclarKisiSec;

  /// Aday uyum puanı satırı.
  ///
  /// In tr, this message translates to:
  /// **'Uyum {puan}/100'**
  String araclarPuan(int puan);

  /// Sıralı liste başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Adayların sıralaması'**
  String get araclarSiralamaBaslik;

  /// Sıralı liste kilit açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Tüm adayların uyum puanına göre sıralaması Premium üyelere açık.'**
  String get araclarSiralamaKilitli;

  /// Sıralı listede bir satır.
  ///
  /// In tr, this message translates to:
  /// **'{sira}. {ad} · {puan}'**
  String araclarSiraSatiri(int sira, String ad, int puan);

  /// Uyum ekranı başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Uyum'**
  String get uyumBaslik;

  /// Uyum ekranı açıklaması.
  ///
  /// In tr, this message translates to:
  /// **'Partnerin, hoşlandığın biri, bir arkadaşın ya da ailenden biriyle sayılarınızın ve burçlarınızın uyumunu gör.'**
  String get uyumAciklama;

  /// Kişi yokken boş durum.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kimseyi eklemedin. İlk kişiyi ekleyerek uyumunuzu keşfet.'**
  String get uyumBosDurum;

  /// Kişi ekle butonu.
  ///
  /// In tr, this message translates to:
  /// **'Kişi ekle'**
  String get uyumKisiEkle;

  /// Kişi formu başlığı.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kişi'**
  String get uyumFormBaslik;

  /// Kişi formu ad alanı.
  ///
  /// In tr, this message translates to:
  /// **'Tam adı'**
  String get uyumAdEtiketi;

  /// Kişi formu ad ipucu.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad (varsa göbek adıyla)'**
  String get uyumAdIpucu;

  /// Kişi formu doğum tarihi etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihi'**
  String get uyumDogumEtiketi;

  /// Kişi formu rol etiketi.
  ///
  /// In tr, this message translates to:
  /// **'Senin için kim?'**
  String get uyumRolEtiketi;

  /// Kişi formu kaydet butonu.
  ///
  /// In tr, this message translates to:
  /// **'Uyumu hesapla'**
  String get uyumKaydet;

  /// Ad boşken uyarı.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için adı yazmalısın.'**
  String get uyumAdBos;

  /// Kişi formu bilgi notu.
  ///
  /// In tr, this message translates to:
  /// **'Bilgiler yalnızca bu cihazda saklanır. Başka birinin bilgilerini eklerken onun da haberdar olmasına özen göster.'**
  String get uyumRizaNotu;

  /// Silme onayı başlığı.
  ///
  /// In tr, this message translates to:
  /// **'{ad} silinsin mi?'**
  String uyumSilBaslik(String ad);

  /// Silme onayı butonu.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get uyumSil;

  /// Silme onayı vazgeç.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get uyumVazgec;

  /// Sonuç ekranı skor etiketi (büyük harf).
  ///
  /// In tr, this message translates to:
  /// **'UYUM'**
  String get uyumEtiketi;

  /// Sonuç ekranı notu.
  ///
  /// In tr, this message translates to:
  /// **'Uyum; iki kişinin yaşam yolu sayıları, burç elementleri ve (tam adlar biliniyorsa) ruh sayıları üzerinden geleneksel numeroloji kurallarıyla hesaplanır. İlişkinin geleceği hakkında hüküm vermez; eğlence amaçlıdır.'**
  String get uyumSonucNotu;

  /// Kişi kartı alt satırı.
  ///
  /// In tr, this message translates to:
  /// **'{rol} · {burc} · Yaşam yolu {yasamYolu}'**
  String uyumKisiOzeti(String rol, String burc, int yasamYolu);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
