/// Ayarlar ekranının Türkçe metinleri.
abstract final class SettingsStrings {
  /// Ekran başlığı.
  static const String baslik = 'Ayarlar';

  /// İsim bölümü başlığı.
  static const String isimBolumu = 'Adın';

  /// İsim kaydetme butonu.
  static const String isimKaydet = 'Kaydet';

  /// İsim boş bırakıldığında gösterilen uyarı.
  static const String isimBosUyarisi = 'Adın boş bırakılamaz.';

  /// İsim değiştirme onay diyaloğu başlığı.
  static const String isimUyariBaslik = 'Adını değiştir';

  /// İsim değiştirme onay diyaloğu açıklaması.
  ///
  /// Skor tohumu isimden türediği için gelecekteki günlerin skoru
  /// değişir; bugünün skoru kayıtlı olduğundan sabit kalır.
  static const String isimUyariMetin =
      'Adını değiştirmek gelecekteki kader skorlarını yeniden '
      'hesaplar. Bugünün skoru değişmez.';

  /// Onay diyaloğu "devam et" butonu.
  static const String uyariDevam = 'Devam et';

  /// Onay diyaloğu "vazgeç" butonu.
  static const String uyariVazgec = 'Vazgeç';

  /// İsim kaydedildiğinde gösterilen bilgi.
  static const String isimKaydedildi = 'Adın güncellendi.';

  /// Bildirim bölümü başlığı.
  static const String bildirimBolumu = 'Bildirimler';

  /// Bildirim aç/kapa satırı.
  static const String bildirimAcik = 'Günlük hatırlatmalar';

  /// Akşam hatırlatması satırı.
  static const String aksamHatirlatma = 'Akşam hatırlatması';

  /// Sabah hatırlatması satırı.
  static const String sabahHatirlatma = 'Sabah hatırlatması';

  /// Hakkında bölümü başlığı.
  static const String hakkindaBolumu = 'Hakkında';

  /// Sürüm satırı etiketi.
  static const String surumEtiketi = 'Sürüm';

  /// Yasal uyum ibaresi — disclaimer'ın TEK doğruluk kaynağı.
  ///
  /// Hem onboarding karşılama ekranı hem de Ayarlar > Hakkında bunu
  /// kullanır (store reddi riskine karşı zorunlu ibare).
  static const String eglenceAmacli =
      'Bu uygulama yalnızca eğlence amaçlıdır.';
}
