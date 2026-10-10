// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get sekmeBugun => 'Bugün';

  @override
  String get sekmeProfil => 'Profilim';

  @override
  String get sekmeUyum => 'Uyum';

  @override
  String get sekmeKesfet => 'Keşfet';

  @override
  String get sekmeAyarlar => 'Ayarlar';

  @override
  String get ayarlarBaslik => 'Ayarlar';

  @override
  String get ayarlarProfil => 'Profil';

  @override
  String get ayarlarAd => 'Adın';

  @override
  String get ayarlarDogumTarihi => 'Doğum tarihin';

  @override
  String get ayarlarSabitAlanNotu =>
      'Günlük skorun bu iki bilgiden hesaplandığı için değiştirilemez. Yanlış girdiysen verilerini silip yeniden başlayabilirsin.';

  @override
  String get ayarlarTamAd => 'Doğumdaki tam adın';

  @override
  String get ayarlarTamAdYok => 'Eklenmedi — isim sayıların için ekle';

  @override
  String get ayarlarTercihler => 'Tanışma cevapların';

  @override
  String get ayarlarTercihlerAciklama =>
      'Yorumlarının sana uyması için verdiğin cevaplar';

  @override
  String get ayarlarPremium => 'Premium';

  @override
  String get ayarlarPremiumAktif => 'Premium aktif';

  @override
  String get ayarlarPremiumDegil => 'Ücretsiz sürüm';

  @override
  String get ayarlarPremiumaGec => 'Premium\'a geç';

  @override
  String get ayarlarAboneligiYonet => 'Aboneliğini yönet';

  @override
  String get ayarlarGeriYukle => 'Satın alımları geri yükle';

  @override
  String get ayarlarBildirimler => 'Bildirimler';

  @override
  String get ayarlarBildirimSaatleri => 'Sabah 08:30 · Akşam 21:00';

  @override
  String get ayarlarBildirimAciklama =>
      'Bildirimleri kapatmak için telefonunun Ayarlar > Uygulamalar > Kader > Bildirimler bölümünü kullanabilirsin.';

  @override
  String get ayarlarBildirimleriTazele => 'Bildirimleri yeniden kur';

  @override
  String get ayarlarBildirimlerKuruldu => 'Bildirimler yeniden kuruldu.';

  @override
  String get ayarlarDil => 'Dil';

  @override
  String get ayarlarDilCihaz => 'Cihaz dili';

  @override
  String get ayarlarGizlilikYasal => 'Gizlilik ve yasal';

  @override
  String get ayarlarReklamGizlilik => 'Reklam gizlilik tercihleri';

  @override
  String get ayarlarUyari => 'Uyarı: eğlence amaçlıdır';

  @override
  String get ayarlarVerileriSil => 'Verilerimi sil';

  @override
  String get ayarlarVerileriSilAciklama =>
      'Profilin, günlük kayıtların, geri bildirimlerin ve eklediğin kişiler bu cihazdan kalıcı olarak silinir. Premium aboneliğin Google Play\'de devam eder; iptal için Google Play\'i kullanmalısın.';

  @override
  String get ayarlarSilOnayBaslik => 'Tüm veriler silinsin mi?';

  @override
  String get ayarlarSil => 'Kalıcı olarak sil';

  @override
  String get ayarlarVazgec => 'Vazgeç';

  @override
  String get ayarlarTamam => 'Tamam';

  @override
  String get ayarlarGelistirici => 'Geliştirici (yalnızca debug)';

  @override
  String get ayarlarPremiumSimulasyonu => 'Premium simülasyonu';

  @override
  String get ayarlarRizaSifirla => 'Reklam rıza durumunu sıfırla';

  @override
  String get ayarlarRizaSifirlandi =>
      'Rıza durumu sıfırlandı; uygulamayı yeniden başlatınca form tekrar görünür.';

  @override
  String ayarlarSurum(String surum) {
    return 'Kader $surum';
  }
}
