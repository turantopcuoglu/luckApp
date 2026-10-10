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
