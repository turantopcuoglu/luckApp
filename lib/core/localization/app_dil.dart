/// Uygulamanın desteklediği diller: Türkçe ve İngilizce.
///
/// Saf Dart (Flutter'sız): hem çekirdek içerik katmanı hem UI bu enum'u
/// açık parametre olarak alır (anayasa kural 5 — durum yalnız Riverpod'da,
/// string seçimi saf fonksiyon). Dil ASLA skoru/tohumu etkilemez (kural 8);
/// yalnız render edilen metni belirler.
enum AppDil {
  /// Türkçe.
  tr,

  /// İngilizce.
  en;

  /// `MaterialApp.locale` için dil kodu ('tr' / 'en').
  String get localeKodu => name;

  /// İki dilden aktif olana göre değer seçer.
  ///
  /// String sınıflarında ve içerik havuzlarında ikili seçim için tek
  /// yardımcı: `dil.sec('Ayarlar', 'Settings')`.
  T sec<T>(T turkce, T ingilizce) => this == AppDil.tr ? turkce : ingilizce;

  /// Cihaz dil kodundan uygulama dilini türetir.
  ///
  /// [dilKodu] 'tr' ile başlıyorsa Türkçe; aksi hâlde (null, 'en', 'de'…)
  /// varsayılan İngilizce. Kullanıcının açık tercihi yoksa bu kullanılır.
  static AppDil cihazdan(String? dilKodu) =>
      (dilKodu != null && dilKodu.toLowerCase().startsWith('tr'))
      ? AppDil.tr
      : AppDil.en;
}
