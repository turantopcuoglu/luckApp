import '../../core/localization/app_dil.dart';

/// Ayarlar ekranının metinleri (TR + EN).
abstract final class SettingsStrings {
  /// Ekran başlığı.
  static String baslik(AppDil dil) => dil.sec('Ayarlar', 'Settings');

  /// İsim bölümü başlığı.
  static String isimBolumu(AppDil dil) => dil.sec('Adın', 'Your name');

  /// İsim kaydetme butonu.
  static String isimKaydet(AppDil dil) => dil.sec('Kaydet', 'Save');

  /// İsim boş bırakıldığında gösterilen uyarı.
  static String isimBosUyarisi(AppDil dil) =>
      dil.sec('Adın boş bırakılamaz.', 'Your name cannot be empty.');

  /// İsim değiştirme onay diyaloğu başlığı.
  static String isimUyariBaslik(AppDil dil) =>
      dil.sec('Adını değiştir', 'Change your name');

  /// İsim değiştirme onay diyaloğu açıklaması.
  static String isimUyariMetin(AppDil dil) => dil.sec(
    'Adını değiştirmek gelecekteki kader skorlarını yeniden '
        'hesaplar. Bugünün skoru değişmez.',
    'Changing your name recalculates your future fortune scores. '
        "Today's score stays the same.",
  );

  /// Onay diyaloğu "devam et" butonu.
  static String uyariDevam(AppDil dil) => dil.sec('Devam et', 'Continue');

  /// Onay diyaloğu "vazgeç" butonu.
  static String uyariVazgec(AppDil dil) => dil.sec('Vazgeç', 'Cancel');

  /// İsim kaydedildiğinde gösterilen bilgi.
  static String isimKaydedildi(AppDil dil) =>
      dil.sec('Adın güncellendi.', 'Your name has been updated.');

  /// Bildirim bölümü başlığı.
  static String bildirimBolumu(AppDil dil) =>
      dil.sec('Bildirimler', 'Notifications');

  /// Bildirim aç/kapa satırı.
  static String bildirimAcik(AppDil dil) =>
      dil.sec('Günlük hatırlatmalar', 'Daily reminders');

  /// Akşam hatırlatması satırı.
  static String aksamHatirlatma(AppDil dil) =>
      dil.sec('Akşam hatırlatması', 'Evening reminder');

  /// Sabah hatırlatması satırı.
  static String sabahHatirlatma(AppDil dil) =>
      dil.sec('Sabah hatırlatması', 'Morning reminder');

  /// Dil bölümü başlığı.
  static String dilBolumu(AppDil dil) => dil.sec('Dil', 'Language');

  /// Türkçe seçeneği etiketi (kendi dilinde gösterilir).
  static const String dilTurkce = 'Türkçe';

  /// İngilizce seçeneği etiketi (kendi dilinde gösterilir).
  static const String dilIngilizce = 'English';

  /// Hakkında bölümü başlığı.
  static String hakkindaBolumu(AppDil dil) => dil.sec('Hakkında', 'About');

  /// Sürüm satırı etiketi.
  static String surumEtiketi(AppDil dil) => dil.sec('Sürüm', 'Version');

  /// Yasal uyum ibaresi — disclaimer'ın TEK doğruluk kaynağı.
  ///
  /// Hem onboarding karşılama ekranı hem de Ayarlar > Hakkında bunu
  /// kullanır (store reddi riskine karşı zorunlu ibare).
  static String eglenceAmacli(AppDil dil) => dil.sec(
    'Bu uygulama yalnızca eğlence amaçlıdır.',
    'This app is for entertainment purposes only.',
  );
}
