/// Ana ekranın Türkçe metinleri ve yorum şablonları.
///
/// Metinler koddan ayrı tutulur (plan Session 3, madde 2); ileride
/// çoklu dil gerekirse tek dokunma noktası burasıdır.
abstract final class TrStrings {
  /// Haftanın günleri (DateTime.weekday: 1 = Pazartesi).
  static const List<String> gunAdlari = <String>[
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  /// Ay adları (DateTime.month: 1 = Ocak).
  static const List<String> ayAdlari = <String>[
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  /// Onboarding tamamlanana kadar kullanılan misafir ismi.
  static const String misafirIsmi = 'Misafir';

  /// Skor halkasının altındaki etiket.
  static const String genelSkorEtiketi = 'GENEL SKOR';

  /// Skor yüklenirken gösterilen metin.
  static const String yukleniyor = 'Kaderin hesaplanıyor...';

  /// Kapalı kader kartının altındaki dokunma ipucu.
  static const String kartIpucu = 'Bugünün kaderini görmek için kartına dokun';

  /// Beklenmeyen hata metni.
  static const String hataMetni =
      'Bir şeyler ters gitti. Uygulamayı yeniden başlatmayı dene.';

  /// [gun] için "6 Temmuz 2026, Pazartesi" biçiminde tarih metni üretir.
  static String tarihMetni(DateTime gun) =>
      '${gun.day} ${ayAdlari[gun.month - 1]} ${gun.year}, '
      '${gunAdlari[gun.weekday - 1]}';

  /// [isim] için selamlama metni üretir.
  static String selamlama(String isim) => 'Merhaba, $isim';

  /// Şans ögeleri kartındaki renk sütununun etiketi.
  static const String sansRengiEtiketi = 'Şans rengin';

  /// Şans ögeleri kartındaki sayı sütununun etiketi.
  static const String sansliSayiEtiketi = 'Şanslı sayın';

  /// Şans ögeleri kartındaki tavsiye satırının etiketi.
  static const String tavsiyeEtiketi = 'Günün tavsiyesi';

  /// Sabah 08:30 bildiriminin metin varyasyonları (plan Session 8,
  /// madde 3: en az 10 varyasyon). Günün numarasına göre deterministik
  /// seçilir ki aynı gün hep aynı metin görünsün.
  static const List<String> sabahBildirimVaryasyonlari = <String>[
    'Bugünün kaderi hazır ✨',
    'Yıldızlar senin için dizildi, gel bak 🌟',
    'Yeni bir gün, yeni bir şans. Skorun seni bekliyor 🍀',
    'Kader kartın açılmayı bekliyor 🎴',
    'Bugün şanslı mısın? Öğrenmenin tek yolu var 👀',
    'Güne bakmadan çıkma: kaderin hesaplandı ☕',
    'Evren bugün ne fısıldıyor? Kartına dokun 🔮',
    'Skorun hazır. Cesaret edebilecek misin? 😏',
    'Ay evresi işini yaptı, sıra sende 🌙',
    'Bugünün enerjisi ölçüldü. Sonuç içeride ⚡',
    'Kaderin kapıda, açmayan bilemez 🚪',
    'Şans perileri mesaini tamamladı, rapor hazır 🧚',
  ];

  // ---- Günlük okuma ----

  /// Yorum geri bildirim sorusu.
  static const String seniAnlattiMi = 'Bu yorum seni anlattı mı?';

  /// Olumlu cevap ipucu.
  static const String evet = 'Evet';

  /// Olumsuz cevap ipucu.
  static const String hayir = 'Hayır';

  /// Olumlu bölüm cevabı teşekkürü.
  static const String anlattiTesekkur = 'Güzel! Bu tarz yorumları sevdiğini not ettik ✨';

  /// Olumsuz bölüm cevabı teşekkürü.
  static const String anlatmadiTesekkur =
      'Teşekkürler. Önümüzdeki günlerde bu yorumu sana tekrar göstermeyeceğiz.';

  /// "Neden bugün?" başlığı.
  static const String nedenBugun = 'Neden bugün?';

  /// Neden sayfasının alt notu.
  static const String nedenNotu =
      'Skorun ve yorumun bu hesaplardan gelir. Aynı gün, aynı sonucu verir.';

  /// Akşam kartı sorusu.
  static const String aksamKartiBaslik = 'Günün nasıldı?';

  /// Akşam kartı açıklaması.
  static const String aksamKartiAciklama =
      'Bugün gerçekten şanslı mıydın? Cevabın Kader\'in sana olan '
      'isabetini takip etmesine yardım eder.';

  /// Akşam kartı butonu.
  static const String aksamKartiButon = 'Cevapla';
}
