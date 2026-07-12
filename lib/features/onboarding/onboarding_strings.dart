import '../../core/localization/app_dil.dart';

/// Onboarding akışının metinleri (TR + EN).
abstract final class OnboardingStrings {
  /// Uygulama adı (karşılama başlığı, marka).
  static const String uygulamaAdi = 'Kader';

  /// Karşılama sloganı.
  static String slogan(AppDil dil) => dil.sec(
    'Şansın her sabah yeniden yazılır.',
    'Your luck is rewritten every morning.',
  );

  /// Karşılama ekranı ana butonu.
  static String basla(AppDil dil) => dil.sec('Başla', 'Start');

  /// İsim alanı etiketi.
  static String isimEtiketi(AppDil dil) => dil.sec('Adın', 'Your name');

  /// İsim alanı yer tutucusu.
  static String isimIpucu(AppDil dil) => dil.sec('Adını yaz', 'Type your name');

  /// Doğum tarihi bölümü etiketi.
  static String dogumTarihiEtiketi(AppDil dil) =>
      dil.sec('Doğum tarihin', 'Your birth date');

  /// Form ekranı ana butonu.
  static String kaderimiHesapla(AppDil dil) =>
      dil.sec('Kaderimi hesapla', 'Calculate my fortune');

  /// İsim boş bırakıldığında gösterilen uyarı.
  static String isimBosUyarisi(AppDil dil) => dil.sec(
    'Devam etmek için adını yazmalısın.',
    'You must enter your name to continue.',
  );

  /// Sahte hesaplama ekranındaki metin.
  static String hesaplaniyor(AppDil dil) =>
      dil.sec('Kaderin hesaplanıyor...', 'Reading your fortune...');
}
