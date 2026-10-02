/// Keşfet araçlarının (numara analizi, bebek ismi uyumu) metin havuzları.
///
/// İsim analizi yeni metin kullanmaz: profilin isim/ruh/kişilik metinleri
/// (`SayiMetinleri`) ve raporun karmik ders/gizli tutku/harf metinleri
/// (`RaporMetinleri`) aynen kullanılır; ikinci tekil hitap, analiz edilen
/// adın sahibiyle paylaşıldığında da doğal okunur.
///
/// Yazım kuralları (bkz. `sayi_metinleri.dart`) ek olarak:
/// - Numara metinleri telefon, ev ve araç için ortak yazılır; her biri üç
///   kullanıma da birer cümleyle değinir.
/// - "Uğurlu/uğursuz" dili yok; her sayı bir enerji ve küçük bir denge
///   önerisi taşır.
library;

import '../luck_engine/luck_engine.dart';

/// Bir numara sayısının lakabı ve metni.
class NumaraMetni {
  /// [lakap] ve [metin] ile oluşturur.
  const NumaraMetni({required this.lakap, required this.metin});

  /// Kısa lakap ("Öncü").
  final String lakap;

  /// Ayrıntılı metin.
  final String metin;
}

/// Bebek ismi uyum puanının bandı.
class UyumBandi {
  /// [etiket] ve [aciklama] ile oluşturur.
  const UyumBandi({required this.etiket, required this.aciklama});

  /// Kısa etiket ("Uyumlu").
  final String etiket;

  /// Tek cümlelik açıklama.
  final String aciklama;
}

/// Keşfet araçlarının metinleri.
abstract final class AracMetinleri {
  /// Numaranın sayısına göre (1-9, 11, 22, 33) lakap ve metin.
  static const Map<int, NumaraMetni> numaralar = <int, NumaraMetni>{
    1: NumaraMetni(
      lakap: 'Öncü',
      metin:
          'Bu numara başlangıçların ve bağımsızlığın enerjisini taşır. '
          'Telefonda kararlı ve doğrudan iletişime, evde kendi kurallarını '
          'koyan bir yaşama, araçta cesur yolculuklara yakışır. Yalnızlık '
          'eğilimini dengelemek için paylaşımı unutmamak iyi olur.',
    ),
    2: NumaraMetni(
      lakap: 'Uyum',
      metin:
          'Bu numara iş birliğinin ve incelikli ilişkilerin enerjisini taşır. '
          'Telefonda uzlaştırıcı konuşmalara, evde huzurlu bir ortak yaşama, '
          'araçta sakin ve paylaşımlı yolculuklara yakışır. Kararsızlık '
          'anlarında net olmak bu enerjiyi dengeler.',
    ),
    3: NumaraMetni(
      lakap: 'İfade',
      metin:
          'Bu numara neşenin, sosyal hayatın ve yaratıcılığın enerjisini '
          'taşır. Telefonda bol sohbete, evde misafirli ve renkli günlere, '
          'araçta müzikli yolculuklara yakışır. Dağınıklığa karşı küçük bir '
          'düzen iyi gelir.',
    ),
    4: NumaraMetni(
      lakap: 'Temel',
      metin:
          'Bu numara düzenin, güvenin ve emeğin enerjisini taşır. Telefonda iş '
          've sorumluluk konuşmalarına, evde sağlam ve istikrarlı bir yaşama, '
          'araçta güvenli ve planlı yolculuklara yakışır. Katılığa karşı biraz '
          'esneklik dengeyi korur.',
    ),
    5: NumaraMetni(
      lakap: 'Hareket',
      metin:
          'Bu numara değişimin, özgürlüğün ve keşfin enerjisini taşır. '
          'Telefonda hareketli bir sosyal çevreye, evde canlı ve değişken bir '
          'yaşama, araçta uzun yollara yakışır. Aceleye karşı dikkatli olmak '
          'bu enerjiyi güvenli kılar.',
    ),
    6: NumaraMetni(
      lakap: 'Yuva',
      metin:
          'Bu numara sevginin, ailenin ve sorumluluğun enerjisini taşır. '
          'Telefonda yakınlarla sıcak konuşmalara, evde aile ve misafir '
          'ağırlamaya, araçta aile yolculuklarına yakışır. Herkesin yükünü '
          'üstlenmemek bu enerjiyi hafif tutar.',
    ),
    7: NumaraMetni(
      lakap: 'Derinlik',
      metin:
          'Bu numara düşüncenin, sezginin ve iç huzurun enerjisini taşır. '
          'Telefonda az ama anlamlı konuşmalara, evde sakin ve dinlendirici '
          'bir yaşama, araçta düşünceli yolculuklara yakışır. Kendini fazla '
          'soyutlamamak dengeyi korur.',
    ),
    8: NumaraMetni(
      lakap: 'Güç',
      metin:
          'Bu numara başarının, bolluğun ve iş hayatının enerjisini taşır. '
          'Telefonda iş görüşmelerine ve pazarlıklara, evde maddi güven ve '
          'düzen kurmaya, araçta iş yolculuklarına yakışır. Çalışırken '
          'dinlenmeyi unutmamak bu enerjiyi sürdürülebilir kılar.',
    ),
    9: NumaraMetni(
      lakap: 'Tamamlama',
      metin:
          'Bu numara şefkatin, cömertliğin ve büyük resmin enerjisini taşır. '
          'Telefonda yardımlaşmaya ve geniş bir çevreye, evde paylaşıma açık '
          'bir yaşama, araçta anlamlı yolculuklara yakışır. Bitmesi '
          'gerekenleri bırakmak bu enerjiyi taze tutar.',
    ),
    11: NumaraMetni(
      lakap: 'Usta İlham',
      metin:
          "Bu numara usta sayı 11'in, yani sezginin ve ilhamın yüksek "
          'enerjisini taşır. Telefonda ilham veren konuşmalara, evde yaratıcı '
          've huzurlu bir ortama, araçta düşüncelerin berraklaştığı '
          'yolculuklara yakışır. Yoğun enerjisi bazen yorabilir; sade bir '
          'rutin dengeyi korur.',
    ),
    22: NumaraMetni(
      lakap: 'Usta Kurucu',
      metin:
          "Bu numara usta sayı 22'nin, yani büyük işler kurmanın enerjisini "
          'taşır. Telefonda önemli projelere ve iş bağlantılarına, evde uzun '
          'vadeli planlar kuran bir aileye, araçta sorumluluk taşıyan '
          'yolculuklara yakışır. Tüm yükü tek başına taşımamak bu enerjiyi '
          'hafifletir.',
    ),
    33: NumaraMetni(
      lakap: 'Usta Rehber',
      metin:
          "Bu numara usta sayı 33'ün, yani şefkatin ve rehberliğin enerjisini "
          'taşır. Telefonda destek arayanların ulaştığı bir numaraya, evde '
          'herkesin rahatladığı bir yuvaya, araçta sevdiklerini taşıyan '
          'yolculuklara yakışır. Kendine de şefkat göstermek dengeyi korur.',
    ),
  };

  /// Numaranın toplamında karmik borç sayısı varsa eklenen not.
  static String numaraKarmikNotu(int sayi, String lakap) =>
      'Bu numaranın toplamında $sayi karmik sayısı görünüyor ($lakap). Bu bir '
      'uğursuzluk değil; numarayı kullanırken bu temaya biraz daha dikkat '
      'etmen için küçük bir hatırlatma.';

  /// Numara okuması başlığı ("Numaranın sayısı 11 · Usta İlham").
  static String numaraBasligi(int sayi, String lakap) =>
      'Numaranın sayısı $sayi · $lakap';

  /// Bebek ismi: isim sayısı ile bir kişinin yaşam yolu ilişkisinin
  /// cümlesi; `{digerIsim}` kişinin adı ya da rolüdür ("Anne").
  static const Map<YasamYoluIliskisi, String> bebekIliskileri =
      <YasamYoluIliskisi, String>{
        YasamYoluIliskisi.ayniGrup:
            '{digerIsim} ile aynı doğal ritimde: aralarında anlaşmak ve '
            'birbirini sezmek kolaylaşır.',
        YasamYoluIliskisi.ayna:
            '{digerIsim} ile aynı sayıyı taşıyor: birbirini aynada görmek '
            'gibi güçlü bir yakınlık; benzerlikler bazen inatlaşmaya da '
            'dönüşebilir.',
        YasamYoluIliskisi.destekleyici:
            '{digerIsim} ile birbirini besleyen ritimlerde: farklılıkları '
            'birbirini tamamlar ve büyütür.',
        YasamYoluIliskisi.zorlayici:
            '{digerIsim} ile farklı ritimlerde: aralarındaki bağ emek ve '
            'anlayışla derinleşen, öğretici bir uyum.',
      };

  /// Bebek ismi uyum bantları (yüksekten düşüğe; eşikler ContentConfig'te).
  static const List<UyumBandi> bebekBantlari = <UyumBandi>[
    UyumBandi(
      etiket: 'Çok uyumlu',
      aciklama: 'Bu isim ailenin doğal ritmiyle güçlü biçimde örtüşüyor.',
    ),
    UyumBandi(
      etiket: 'Uyumlu',
      aciklama: 'Bu isim ailenin ritmiyle büyük ölçüde aynı yönde.',
    ),
    UyumBandi(
      etiket: 'Dengeli',
      aciklama: 'Bu isim uyumlu ve öğretici yanları bir arada taşıyor.',
    ),
    UyumBandi(
      etiket: 'Öğretici',
      aciklama:
          'Bu isim aileye farklı bir ritim katıyor; farklılık da bir '
          'zenginliktir.',
    ),
  ];

  // ---- İsim analizi başlıkları ----

  /// İsim sayısı bölümü başlığı.
  static String isimBasligi(int sayi) => 'İsim sayısı $sayi';

  /// Ruh sayısı bölümü başlığı.
  static String ruhBasligi(int sayi) => 'Ruh sayısı $sayi';

  /// Kişilik sayısı bölümü başlığı.
  static String kisilikBasligi(int sayi) => 'Kişilik sayısı $sayi';
}
