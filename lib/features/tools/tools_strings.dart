/// Keşfet araçlarının Türkçe arayüz metinleri.
abstract final class ToolsStrings {
  // ---- Keşfet ana ekranı ----

  /// Sekme ekranı başlığı.
  static const String baslik = 'Keşfet';

  /// Başlık altı açıklama.
  static const String aciklama =
      'İsimlerin ve numaraların da birer sayısı var. Merak ettiğin bir adı, '
      'telefonunu ya da bebeğin için düşündüğün isimleri hesapla.';

  /// İsim analizi kartı.
  static const String isimBaslik = 'İsim Analizi';

  /// İsim analizi kartı açıklaması.
  static const String isimAciklama =
      'Herhangi bir adın isim, ruh ve kişilik sayıları.';

  /// Numara analizi kartı.
  static const String numaraBaslik = 'Numara Analizi';

  /// Numara analizi kartı açıklaması.
  static const String numaraAciklama =
      'Telefon, plaka ya da ev numaranın sayısı ve enerjisi.';

  /// Bebek ismi kartı.
  static const String bebekBaslik = 'Bebek İsmi';

  /// Bebek ismi kartı açıklaması.
  static const String bebekAciklama =
      'Aday isimlerin ailenle numerolojik uyumu.';

  // ---- Ortak ----

  /// Hesapla butonu.
  static const String hesapla = 'Hesapla';

  /// Paylaş butonu.
  static const String paylas = 'Paylaş';

  /// Geçersiz girdi uyarısı.
  static const String gecersiz = 'Hesaplanacak harf ya da rakam bulunamadı.';

  /// Paylaşım metninin son satırı.
  static const String paylasimImzasi = 'Kader uygulamasıyla hesaplandı ✨';

  // ---- İsim analizi ----

  /// Ad alanı etiketi.
  static const String adEtiketi = 'Ad soyad';

  /// Ad alanı ipucu.
  static const String adIpucu = 'Örn. Elif Yılmaz';

  // ---- Numara analizi ----

  /// Numara alanı etiketi.
  static const String numaraEtiketi = 'Numara';

  /// Numara türleri (segment etiketi, ipucu).
  static const List<(String, String)> numaraTurleri = <(String, String)>[
    ('Telefon', 'Örn. 0532 123 45 67'),
    ('Plaka', 'Örn. 34 ABC 123'),
    ('Ev', 'Örn. Daire 7 ya da 12/4'),
  ];

  /// Hesap satırı ("Toplam 38 → 11").
  static String hesapSatiri(List<int> zincir) => 'Toplam ${zincir.join(' → ')}';

  // ---- Bebek ismi ----

  /// Aday isimler alanı etiketi.
  static const String adaylarEtiketi = 'Aday isimler';

  /// Aday isimler alanı ipucu.
  static const String adaylarIpucu =
      'Her satıra bir ad soyad yaz.\nÖrn. Ada Yılmaz\nCan Yılmaz';

  /// Ebeveyn seçimi başlığı.
  static const String ebeveynBaslik = 'Kimlerle karşılaştıralım?';

  /// Ebeveyn seçimi açıklaması.
  static const String ebeveynAciklama =
      'Uyum sekmesine eklediğin kişiler de burada görünür.';

  /// Aktif kullanıcının çip etiketi ("Ben (Ayşe)").
  static String ben(String isim) => 'Ben ($isim)';

  /// En az bir kişi seçilmeli uyarısı.
  static const String kisiSec = 'En az bir kişi seç.';

  /// Uyum puanı satırı.
  static String puan(int puan) => 'Uyum $puan/100';

  /// Sıralı liste başlığı.
  static const String siralamaBaslik = 'Adayların sıralaması';

  /// Sıralı liste kilit açıklaması.
  static const String siralamaKilitli =
      'Tüm adayların uyum puanına göre sıralaması Premium üyelere açık.';

  /// Sıralı listede bir satır.
  static String siraSatiri(int sira, String ad, int puan) =>
      '$sira. $ad · $puan';
}
