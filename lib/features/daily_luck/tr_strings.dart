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

  /// Ana ekrandaki ayarlar dişli ikonunun erişilebilirlik ipucu.
  static const String ayarlarIpucu = 'Ayarlar';

  /// Ana ekrandaki geçmiş takvim ikonunun erişilebilirlik ipucu.
  static const String gecmisIpucu = 'Geçmiş';

  /// Beklenmeyen hata metni.
  static const String hataMetni =
      'Bir şeyler ters gitti. Uygulamayı yeniden başlatmayı dene.';

  /// [gun] için "6 Temmuz 2026, Pazartesi" biçiminde tarih metni üretir.
  static String tarihMetni(DateTime gun) =>
      '${gun.day} ${ayAdlari[gun.month - 1]} ${gun.year}, '
      '${gunAdlari[gun.weekday - 1]}';

  /// [isim] için selamlama metni üretir.
  static String selamlama(String isim) => 'Merhaba, $isim';

  /// Ana ekrandaki şefkatli seri (streak) rozetinin metni.
  ///
  /// Suçluluk yaratmaz: yalnız seri > 0 iken gösterilir; "bozuldu"
  /// gibi bir ifade yoktur. Türkçe'de "1 gündür" de doğru okunur.
  static String seriEtiketi(int gun) => '$gun gündür buradasın 🔥';

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

  /// Şanslı saat başladığında gösterilen bildirim varyasyonları.
  ///
  /// Günün numarasına göre deterministik seçilir. Süreyi bilinçli
  /// olarak sayı ile yazmaz (magic number kaçınımı) — "bu an/şimdi".
  static const List<String> sansliSaatBildirimVaryasyonlari = <String>[
    'Şanslı saatin başladı — bu an senin ✨',
    'Şansın şimdi zirvede; kapıları çalmanın tam vakti ✨',
    'Rüzgâr tam arkanda — şanslı saatin başladı 🍃',
    'Yıldızlar şu an senden yana; anı değerlendir 🌟',
  ];
}
