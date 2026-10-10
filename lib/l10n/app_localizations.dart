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
