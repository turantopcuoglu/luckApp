import '../luck_engine/luck_engine.dart';

/// Uyum ekranının metin havuzları.
///
/// Yazım rehberi için bkz. `sayi_metinleri.dart`. Yer tutucular:
/// `{isim}`, `{digerIsim}`. Uyum yorumları hiçbir zaman "bu ilişki
/// yürümez" gibi hüküm bildirmez; düşük uyum "emek isteyen, geliştiren"
/// bir dinamik olarak anlatılır.
abstract final class UyumMetinleri {
  /// Yaşam yolu ilişkisine göre "Birlikte" paragrafı varyantları.
  static const Map<YasamYoluIliskisi, List<String>>
  yasamYolu = <YasamYoluIliskisi, List<String>>{
    YasamYoluIliskisi.ayna: <String>[
      '{isim} ve {digerIsim} aynı yaşam yolu sayısını taşıyor. Birbirinizi '
          'çoğu zaman söze gerek kalmadan anlarsınız; güçlü yanlarınız '
          'olduğu kadar gölgeleriniz de benzer. Birbirinize ayna tutmak '
          'büyütücüdür ama aynı inatla karşılaştığınızda biriniz nazikçe '
          'geri adım atmayı öğrenmeli.',
      'Aynı sayının iki taşıyıcısı olarak {isim} ve {digerIsim} benzer '
          'ritimde yürür. Bu, kolay bir anlaşma ve ortak bir dil demek. '
          'Tek risk, ikinizin de aynı konuda aynı anda tıkanması; o '
          'anlarda farklı bir bakış getirecek üçüncü bir kaynağa açık olun.',
    ],
    YasamYoluIliskisi.ayniGrup: <String>[
      '{isim} ve {digerIsim} numerolojide aynı doğal uyum grubunda. '
          'Hayattan istediğiniz şeyler farklı biçimlerde de olsa aynı '
          'kökten besleniyor. Birbirinizin kararlarını anlamak kolay, '
          'birlikte plan kurmak doğal. Bu rahatlık, ilişkinin ihmal '
          'edilmesine dönüşmesin diye küçük sürprizleri eksik etmeyin.',
      'Aynı uyum grubundaki sayılar birbirini tamamlar: {isim} ile '
          '{digerIsim} arasında güven kolay kurulur. Farklılıklarınız '
          'çatışmadan çok renk getirir. Ortak bir hedef belirlediğinizde '
          'birlikte olduğunuzdan çok daha hızlı ilerlersiniz.',
    ],
    YasamYoluIliskisi.destekleyici: <String>[
      '{isim} ve {digerIsim} farklı gruplardan ama birbirini besleyen '
          'sayılar taşıyor. Birinizin merakı ve bağımsızlığı, diğerinin '
          'duygusal sıcaklığı ve yaratıcılığıyla buluşuyor. Birbirinize '
          'eksik parçayı gösterirsiniz; yeter ki farklı olanı düzeltmeye '
          'değil anlamaya çalışın.',
      'Bu çiftte zihin ile kalp el sıkışıyor: {isim} ve {digerIsim} '
          'birbirinin dünyasına yeni kapılar açabilir. Başlangıçta ritimleriniz '
          'farklı gelebilir; zamanla bu fark ilişkinin en canlı yanı olur.',
    ],
    YasamYoluIliskisi.zorlayici: <String>[
      '{isim} ve {digerIsim} farklı ritimlerde yürüyen sayılar taşıyor. '
          'Biriniz güvenlik ve düzen ararken diğeri alan ve hareket isteyebilir. '
          'Bu uyum kendiliğinden değil emekle kurulur; ama emekle kurulan '
          'bağlar çoğu zaman en dayanıklı olanlardır. Beklentileri erken ve '
          'açıkça konuşmak ikinizi de rahatlatır.',
      'Bu çiftte öğretici bir dinamik var: {isim} ile {digerIsim} '
          'birbirine en çok ihtiyaç duyduğu dersleri getiriyor. Farklılıklar '
          'zaman zaman sürtünme yaratsa da, birbirinizin bakış açısını '
          'benimsediğiniz ölçüde ikiniz de büyürsünüz.',
    ],
  };

  /// Element ilişkisine göre kısa paragraf.
  static const Map<ElementIliskisi, String> element = <ElementIliskisi, String>{
    ElementIliskisi.ayni:
        'Burçlarınız aynı elementten: mizaçlarınız '
        'birbirine yakın, tepkileriniz tanıdık. Aynı enerjiyi paylaşmak '
        'huzur verir; arada bir farklı bir deneyimi birlikte denemek '
        'ilişkiye taze hava katar.',
    ElementIliskisi.tamamlayici:
        'Burçlarınızın elementleri birbirini '
        'besliyor: biri diğerinin ateşini canlandırıyor ya da toprağını '
        'suluyor. Birlikteyken ikiniz de daha iyi hissedersiniz.',
    ElementIliskisi.notr:
        'Burçlarınızın elementleri farklı dillerde '
        'konuşuyor ama çatışmıyor. Birbirinizin tarzını merak ettiğiniz '
        'sürece bu fark bir zenginlik olur.',
    ElementIliskisi.zit:
        'Burçlarınızın elementleri zıt uçlarda: biri '
        'hızlıyken diğeri yavaş, biri duygusalken diğeri mantıklı olabilir. '
        'Bu zıtlık başta çekici, zamanla sabır isteyen bir denge oyunudur.',
  };

  /// Ruh sayısı uyumu (iki tarafın tam adı biliniyorsa).
  static const Map<bool, String> ruh = <bool, String>{
    true:
        'Ruh sayılarınız aynı uyum grubunda: en derindeki istekleriniz '
        'benzer. Birbirinizin neden mutlu, neden kırgın olduğunu kolayca '
        'sezersiniz.',
    false:
        'Ruh sayılarınız farklı gruplarda: içinizden geçen istekler '
        'farklı biçimlerde ifade ediliyor. Birbirinize "sana ne iyi gelir?" '
        'diye sormak, tahmin etmekten çok daha iyi sonuç verir.',
  };

  /// Uyum derecesine göre tavsiye varyantları.
  static const Map<UyumDerecesi, List<String>>
  tavsiye = <UyumDerecesi, List<String>>{
    UyumDerecesi.guclu: <String>[
      'Güçlü uyum rehavet getirmesin: bu doğal akışı küçük ritüellerle '
          '(haftalık bir yürüyüş, ortak bir hobi) besleyin.',
      'Birbirinizi kolay anladığınız için sorunları konuşmayı ertelemeyin; '
          'küçükken çözülen her şey bağınızı güçlendirir.',
    ],
    UyumDerecesi.dengeli: <String>[
      'Dengeli bir uyumunuz var: farklı olduğunuz konuları sıraya koyup '
          'her birinde ortak bir orta yol bulmak ilişkinizi derinleştirir.',
      'Birbirinizin güçlü yanını takdir ettiğinizi söze dökün; dengeli '
          'uyum, fark edildiğinde parlar.',
    ],
    UyumDerecesi.gelistiren: <String>[
      'Geliştiren bir uyum emek ister: beklentilerinizi erken konuşun ve '
          'farklılıkları kişisel algılamayın.',
      'Bu bağda sabır en değerli araç. Birbirinizin ritmine alan tanıdığınızda, '
          'farklılıklarınız ikinizi de büyütebilir.',
    ],
  };
}
