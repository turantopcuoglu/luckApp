import '../../core/localization/app_dil.dart';

/// Onboarding akışının metinleri (TR + EN).
abstract final class OnboardingStrings {
  /// Uygulama adı (karşılama başlığı, marka).
  static const String uygulamaAdi = 'Kader';

  /// Karşılama sloganı.
  static String slogan(AppDil dil) => dil.sec(
    'Gününe merakla başla. Kendine küçük bir alan aç.',
    'Start your day with curiosity. Make a little space for yourself.',
  );

  /// Karşılama ekranı ana butonu.
  static String basla(AppDil dil) => dil.sec('Başla', 'Start');

  /// İsim alanı etiketi.
  static String isimEtiketi(AppDil dil) =>
      dil.sec('Adın veya rumuzun', 'Name or nickname');

  /// İsim alanı yer tutucusu.
  static String isimIpucu(AppDil dil) =>
      dil.sec('Sana nasıl seslenelim?', 'What should we call you?');

  /// Form ekranı ana butonu.
  static String kaderimiHesapla(AppDil dil) =>
      dil.sec('Kartımı hazırla', 'Prepare my card');

  /// İsim boş bırakıldığında gösterilen uyarı.
  static String isimBosUyarisi(AppDil dil) => dil.sec(
    'Devam etmek için bir ad veya rumuz yaz.',
    'Enter a name or nickname to continue.',
  );

  /// Kart hazırlama geçişindeki metin; kehanet veya sahte yüzde sunmaz.
  static String hesaplaniyor(AppDil dil) =>
      dil.sec('Kartın hazırlanıyor', 'Preparing your card');

  /// Hazırlama animasyonunun kısa açıklaması.
  static String hazirlamaAciklama(AppDil dil) => dil.sec(
    'Kendine küçük bir alan aç.',
    'Make a little space for yourself.',
  );

  /// Kalıcı kayıt başarısızsa gösterilir.
  static String hazirlamaHatasi(AppDil dil) => dil.sec(
    'Hazırlık tamamlanamadı. Yeniden deneyebilirsin.',
    'We couldn’t finish preparing. You can try again.',
  );

  /// Başarısız hazırlığı yeniden deneme.
  static String tekrarDene(AppDil dil) => dil.sec('Tekrar dene', 'Try again');

  /// Tek alanlı başlangıç formunun başlığı.
  static String formBasligi(AppDil dil) =>
      dil.sec('Seni tanıyalım', 'A little about you');

  /// Gerçek kimlik bilgisi gerekmediğini anlatır.
  static String formAciklama(AppDil dil) => dil.sec(
    'Adını ve doğum tarihini ekle. Bilgilerin cihazında kalır.',
    'Add your name and birth date. Your details stay on your device.',
  );

  /// Yerel saklama ve bildirim tercihi hakkında kısa açıklama.
  static String yerelVeriAciklama(AppDil dil) => dil.sec(
    'Bilgilerin cihazında saklanır. Bildirimleri daha sonra Profil’den açabilirsin.',
    'Your details stay on your device. You can enable reminders later in Profile.',
  );

  /// Legacy tohumun bu adımda değişmeyeceğini açıklar.
  static String eskiProfilAciklama(AppDil dil) => dil.sec(
    'Mevcut profilinle devam edeceksin. Adını daha sonra Profil’den değiştirebilirsin.',
    'Continue with your existing profile. You can change your name later in Profile.',
  );

  /// Disk yazması sırasında buton metni.
  static String kaydediliyor(AppDil dil) => dil.sec('Kaydediliyor', 'Saving');

  /// Yazma hatasında kullanıcı taslağı korunur.
  static String profilKayitHatasi(AppDil dil) => dil.sec(
    'Profilin kaydedilemedi. Bilgilerin burada; tekrar deneyebilirsin.',
    'Your profile couldn’t be saved. Your entry is still here; please try again.',
  );

  /// Doğum tarihi alanı.
  static String birthDate(AppDil dil) => dil.sec('Doğum tarihin', 'Birth date');

  /// Henüz tarih seçilmediğinde gösterilen davet.
  static String chooseDate(AppDil dil) =>
      dil.sec('Tarihini seç', 'Choose your date');

  /// Kullanıcı varsayılan bir tarihi açıkça onaylamadan kayıt oluşmaz.
  static String confirmDate(AppDil dil) =>
      dil.sec('Bu tarihi seç', 'Use this date');

  /// Tarih doğrulaması.
  static String dateError(AppDil dil) =>
      dil.sec('Geçerli bir doğum tarihi seç.', 'Choose a valid birth date.');
}
