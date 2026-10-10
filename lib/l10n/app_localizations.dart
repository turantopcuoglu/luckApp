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
