// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sekmeBugun => 'Today';

  @override
  String get sekmeProfil => 'Profile';

  @override
  String get sekmeUyum => 'Match';

  @override
  String get sekmeKesfet => 'Explore';

  @override
  String get sekmeAyarlar => 'Settings';

  @override
  String get ayarlarBaslik => 'Settings';

  @override
  String get ayarlarProfil => 'Profile';

  @override
  String get ayarlarAd => 'Your name';

  @override
  String get ayarlarDogumTarihi => 'Your birth date';

  @override
  String get ayarlarSabitAlanNotu =>
      'Your daily score is calculated from these two details, so they can\'t be changed. If you entered them wrong, you can delete your data and start over.';

  @override
  String get ayarlarTamAd => 'Your full name at birth';

  @override
  String get ayarlarTamAdYok => 'Not added — add it for your name numbers';

  @override
  String get ayarlarTercihler => 'Your intro answers';

  @override
  String get ayarlarTercihlerAciklama =>
      'The answers that help your readings fit you';

  @override
  String get ayarlarPremium => 'Premium';

  @override
  String get ayarlarPremiumAktif => 'Premium is active';

  @override
  String get ayarlarPremiumDegil => 'Free version';

  @override
  String get ayarlarPremiumaGec => 'Go Premium';

  @override
  String get ayarlarAboneligiYonet => 'Manage your subscription';

  @override
  String get ayarlarGeriYukle => 'Restore purchases';

  @override
  String get ayarlarBildirimler => 'Notifications';

  @override
  String get ayarlarBildirimSaatleri => 'Morning 08:30 · Evening 21:00';

  @override
  String get ayarlarBildirimAciklama =>
      'To turn notifications off, go to Settings > Apps > Kader > Notifications on your phone.';

  @override
  String get ayarlarBildirimleriTazele => 'Set up notifications again';

  @override
  String get ayarlarBildirimlerKuruldu =>
      'Notifications have been set up again.';

  @override
  String get ayarlarDil => 'Language';

  @override
  String get ayarlarDilCihaz => 'Device language';

  @override
  String get ayarlarGizlilikYasal => 'Privacy and legal';

  @override
  String get ayarlarReklamGizlilik => 'Ad privacy preferences';

  @override
  String get ayarlarUyari => 'Notice: for entertainment only';

  @override
  String get ayarlarVerileriSil => 'Delete my data';

  @override
  String get ayarlarVerileriSilAciklama =>
      'Your profile, daily records, feedback and the people you added will be permanently deleted from this device. Your Premium subscription continues on Google Play; use Google Play to cancel it.';

  @override
  String get ayarlarSilOnayBaslik => 'Delete all data?';

  @override
  String get ayarlarSil => 'Delete permanently';

  @override
  String get ayarlarVazgec => 'Cancel';

  @override
  String get ayarlarTamam => 'OK';

  @override
  String get ayarlarGelistirici => 'Developer (debug only)';

  @override
  String get ayarlarPremiumSimulasyonu => 'Premium simulation';

  @override
  String get ayarlarRizaSifirla => 'Reset ad consent';

  @override
  String get ayarlarRizaSifirlandi =>
      'Consent reset; the form will appear again after you restart the app.';

  @override
  String ayarlarSurum(String surum) {
    return 'Kader $surum';
  }
}
