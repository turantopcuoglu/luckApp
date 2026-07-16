import '../../core/localization/app_dil.dart';

/// Ana ekranın ve genel kullanımın metinleri (TR + EN).
///
/// Her üye aktif [AppDil]'i alır ve o dildeki dizeyi döndürür
/// (`dil.sec(tr, en)`). Böylece string seçimi saf bir fonksiyondur;
/// dil durumu yalnız Riverpod'da tutulur (anayasa kural 5).
abstract final class TrStrings {
  /// Haftanın günleri (DateTime.weekday: 1 = Pazartesi).
  static List<String> gunAdlari(AppDil dil) => dil.sec(
    const <String>[
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ],
    const <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ],
  );

  /// Ay adları (DateTime.month: 1 = Ocak).
  static List<String> ayAdlari(AppDil dil) => dil.sec(
    const <String>[
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
    ],
    const <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
  );

  /// Onboarding tamamlanana kadar kullanılan misafir ismi.
  ///
  /// Dil-nötr sabittir: tohuma girdiği için (kural 8) dile göre
  /// DEĞİŞMEZ; aksi hâlde misafirin skoru dile göre değişirdi.
  static const String misafirIsmi = 'Misafir';

  /// Skor halkasının altındaki etiket.
  static String genelSkorEtiketi(AppDil dil) =>
      dil.sec('GENEL SKOR', 'OVERALL SCORE');

  /// Skor yüklenirken gösterilen metin.
  static String yukleniyor(AppDil dil) =>
      dil.sec('Kaderin hesaplanıyor...', 'Reading your fortune...');

  /// Kapalı kader kartının altındaki dokunma ipucu.
  static String kartIpucu(AppDil dil) => dil.sec(
    'Bugünün kaderini görmek için kartına dokun',
    "Tap your card to see today's fortune",
  );

  /// Ana ekrandaki ayarlar dişli ikonunun erişilebilirlik ipucu.
  static String ayarlarIpucu(AppDil dil) => dil.sec('Ayarlar', 'Settings');

  /// Ana ekrandaki geçmiş takvim ikonunun erişilebilirlik ipucu.
  static String gecmisIpucu(AppDil dil) => dil.sec('Geçmiş', 'History');

  /// Ana ekrandaki koleksiyon (kader kartları) ikonunun ipucu.
  static String koleksiyonIpucu(AppDil dil) =>
      dil.sec('Koleksiyon', 'Collection');

  /// Beklenmeyen hata metni.
  static String hataMetni(AppDil dil) => dil.sec(
    'Bir şeyler ters gitti. Uygulamayı yeniden başlatmayı dene.',
    'Something went wrong. Try restarting the app.',
  );

  /// [gun] için tarih metni ("6 Temmuz 2026, Pazartesi").
  static String tarihMetni(AppDil dil, DateTime gun) =>
      '${gun.day} ${ayAdlari(dil)[gun.month - 1]} ${gun.year}, '
      '${gunAdlari(dil)[gun.weekday - 1]}';

  /// [isim] için selamlama metni üretir.
  static String selamlama(AppDil dil, String isim) =>
      dil.sec('Merhaba, $isim', 'Hello, $isim');

  /// Skor halkasının ekran okuyucu (erişilebilirlik) etiketi.
  ///
  /// Sayı ve etiketi tek anlamlı düğümde birleştirir; [etiket] zaten
  /// aktif dilde gelir, biçim dil-nötrdür.
  static String skorErisim(String etiket, int skor, int maks) =>
      '$etiket: $skor / $maks';

  /// Ana ekrandaki şefkatli seri (streak) rozetinin metni.
  ///
  /// Suçluluk yaratmaz: yalnız seri > 0 iken gösterilir.
  static String seriEtiketi(AppDil dil, int gun) =>
      dil.sec('$gun gündür buradasın 🔥', '$gun days in a row 🔥');

  /// Şans ögeleri kartındaki renk sütununun etiketi.
  static String sansRengiEtiketi(AppDil dil) =>
      dil.sec('Şans rengin', 'Your lucky color');

  /// Şans ögeleri kartındaki sayı sütununun etiketi.
  static String sansliSayiEtiketi(AppDil dil) =>
      dil.sec('Şanslı sayın', 'Your lucky number');

  /// Şans ögeleri kartındaki tavsiye satırının etiketi.
  static String tavsiyeEtiketi(AppDil dil) =>
      dil.sec('Günün tavsiyesi', 'Tip of the day');

  /// Sabah bildiriminin metin varyasyonları (günün numarasına göre
  /// deterministik seçilir).
  static List<String> sabahBildirimVaryasyonlari(AppDil dil) => dil.sec(
    const <String>[
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
    ],
    const <String>[
      "Today's fortune is ready ✨",
      'The stars have aligned for you, come see 🌟',
      'New day, new luck. Your score is waiting 🍀',
      'Your fate card is waiting to be opened 🎴',
      "Are you lucky today? There's only one way to find out 👀",
      "Don't head out before you look: your fortune is ready ☕",
      'What is the universe whispering today? Tap your card 🔮',
      'Your score is ready. Will you dare to look? 😏',
      "The moon phase did its part, now it's your turn 🌙",
      "Today's energy is measured. The result is inside ⚡",
      'Your fortune is at the door; only the one who opens it knows 🚪',
      'The luck fairies finished their shift, the report is ready 🧚',
    ],
  );

  /// Şanslı saat başladığında gösterilen bildirim varyasyonları.
  static List<String> sansliSaatBildirimVaryasyonlari(AppDil dil) => dil.sec(
    const <String>[
      'Şanslı saatin başladı — bu an senin ✨',
      'Şansın şimdi zirvede; kapıları çalmanın tam vakti ✨',
      'Rüzgâr tam arkanda — şanslı saatin başladı 🍃',
      'Yıldızlar şu an senden yana; anı değerlendir 🌟',
    ],
    const <String>[
      'Your lucky hour has begun — this moment is yours ✨',
      'Your luck is at its peak now; the perfect time to knock on doors ✨',
      'The wind is at your back — your lucky hour has begun 🍃',
      'The stars are on your side right now; seize the moment 🌟',
    ],
  );
}
