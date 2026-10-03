/// Yasal metinlerde geçen, geliştiricinin doldurması gereken bilgiler.
///
/// YAYIN ÖNCESİ ZORUNLU: Aşağıdaki köşeli parantezli değerleri kendi
/// bilgilerinle değiştir. Aynı değerleri web sitendeki gizlilik politikası
/// sayfasına ve Google Play Console'daki "Gizlilik politikası" alanına
/// da girmelisin. Değerler derleme sırasında `--dart-define` ile de
/// verilebilir (ör. `--dart-define=KADER_DESTEK_EPOSTA=destek@site.com`).
abstract final class LegalConfig {
  /// Veri sorumlusu / geliştirici adı (şahıs ya da şirket unvanı).
  static const String gelistiriciAdi = String.fromEnvironment(
    'KADER_GELISTIRICI',
    defaultValue: '[Geliştirici adı / şirket unvanı]',
  );

  /// Destek ve KVKK başvuruları için e-posta adresi.
  static const String destekEposta = String.fromEnvironment(
    'KADER_DESTEK_EPOSTA',
    defaultValue: '[destek@alanadiniz.com]',
  );

  /// Web sitesindeki gizlilik politikası adresi.
  static const String gizlilikUrl = String.fromEnvironment(
    'KADER_GIZLILIK_URL',
    defaultValue: 'https://[alanadiniz.com]/gizlilik',
  );

  /// Web sitesindeki kullanım koşulları adresi.
  static const String kosullarUrl = String.fromEnvironment(
    'KADER_KOSULLAR_URL',
    defaultValue: 'https://[alanadiniz.com]/kosullar',
  );

  /// Metinlerin son güncellenme tarihi.
  static const String sonGuncelleme = '13 Eylül 2026';

  /// Kullanıcının kabul ettiği uyarı/koşullar sürümü.
  ///
  /// Koşullar önemli ölçüde değişirse bu sayı artırılır; mevcut
  /// kullanıcılar bir sonraki açılışta metni yeniden onaylar.
  static const int uyariSurumu = 1;

  /// Uygulamanın kullanıcıya gösterilen sürümü (ayarlar ekranı).
  static const String uygulamaSurumu = '1.0.0';

  /// Uyarı ekranı sahnesinin alt karartmasının başladığı yükseklik.
  static const double karartmaBaslangici = 0.08;

  /// Uyarı ekranı sahnesinin tam opak olduğu yükseklik.
  static const double karartmaSonu = 0.40;

  /// Uyarı başlığının üstündeki parıltının boyutu.
  static const double uyariParilti = 56;
}
