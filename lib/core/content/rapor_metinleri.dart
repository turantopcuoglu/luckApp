/// Derin numeroloji raporunun metin havuzları.
///
/// `NumerolojiRaporu`ndaki her sayının kalıcı yorumudur; günlük okumadan
/// farklı olarak bir kez okunur, bu yüzden varyant değil derinlik önceliklidir.
///
/// Yazım kuralları (bkz. `sayi_metinleri.dart`) ek olarak:
/// - Rapor açıkça numeroloji raporu olduğu için sayı adları (zirve,
///   zorluk, karmik borç) metinde ve başlıkta geçebilir.
/// - Gelecek kesin dille anlatılmaz: dönemler "tema" ve "eğilim" olarak
///   yazılır, olay kehaneti yapılmaz (ayrıca bkz. yasal uyarı ekranı).
/// - Her metin hem fırsatı hem de dikkat edilecek yanı taşır.
library;

import '../luck_engine/luck_engine.dart';

/// Bir zirve ya da zorluk sayısının iki uzunluktaki metni.
class DonemMetni {
  /// [kisa] ve [uzun] ile metin oluşturur.
  const DonemMetni({required this.kisa, required this.uzun});

  /// Zaman çizelgesinde gösterilen tek cümlelik özet.
  final String kisa;

  /// Dönem bölümünde gösterilen ayrıntılı metin.
  final String uzun;
}

/// Bir karmik borç sayısının lakabı ve metni.
class KarmikBorcMetni {
  /// [lakap] ve [metin] ile oluşturur.
  const KarmikBorcMetni({required this.lakap, required this.metin});

  /// Kısa lakap ("Emek ve sabır").
  final String lakap;

  /// Ayrıntılı metin.
  final String metin;
}

/// Rapor metin havuzları.
abstract final class RaporMetinleri {
  /// Zirve sayısına göre dönem teması (1-9, 11, 22, 33).
  static const Map<int, DonemMetni> zirveler = <int, DonemMetni>{
    1: DonemMetni(
      kisa:
          'Kendi ayakların üzerinde durmayı ve öncülük etmeyi öğrendiğin bir dönem.',
      uzun:
          'Bu dönem seni kendi yolunu çizmeye çağırıyor. Başkalarının onayını '
          'beklemeden karar vermek, bir işi sıfırdan başlatmak ya da '
          'sorumluluğu üstlenmek için koşullar senden yana. Bazen yalnız '
          'kaldığını hissedebilirsin; bu yalnızlık aslında kendi sesini '
          'duyman için açılan bir alan. Bu yıllarda kurduğun bağımsızlık, '
          'sonraki dönemlerin temelini oluşturur.',
    ),
    2: DonemMetni(
      kisa: 'İlişkilerin, iş birliklerinin ve sabrın öne çıktığı bir dönem.',
      uzun:
          'Bu dönemde en büyük kazançların tek başına değil, birlikte '
          'kurduğun bağlardan gelir. Ortaklıklar, yakın ilişkiler ve ekip '
          'çalışmaları hayatının merkezine yerleşir. Sonuçlar acele '
          'edenlerden çok bekleyebilenlere gelir; inceliğin ve sezgin bu '
          'yıllarda en güçlü araçların. Kendi ihtiyaçlarını başkalarınınkiyle '
          'dengelemeyi öğrenmek bu dönemin asıl hediyesi.',
    ),
    3: DonemMetni(
      kisa:
          'Kendini ifade ettiğin, yaratıcılığının ve çevrenin genişlediği bir dönem.',
      uzun:
          'Bu dönem sözlerin, fikirlerin ve yaratıcılığın için bir sahne '
          'kuruyor. Yazmak, konuşmak, tasarlamak ya da insanları bir araya '
          'getirmek sana hem keyif hem fırsat getirir. Çevren genişler, yeni '
          'dostluklar kurulur. Tek tuzak enerjini çok fazla yöne dağıtmak; '
          'ilgini çeken birkaç şeye derinlemesine odaklandığında bu yıllar '
          'çok verimli geçer.',
    ),
    4: DonemMetni(
      kisa:
          'Emek verdiğin, sağlam temeller kurduğun ve düzen oluşturduğun bir dönem.',
      uzun:
          'Bu dönem çalışkanlığını ve sabrını ödüllendiriyor. Bir meslekte '
          'derinleşmek, bir yuva ya da birikim kurmak, uzun soluklu bir işi '
          'adım adım ilerletmek bu yılların ana teması. Zaman zaman tempo '
          'ağır gelebilir; ama bu dönemde attığın her düzenli adım, '
          'hayatının geri kalanında üzerine basacağın bir taşa dönüşür. '
          'Dinlenmeyi de planının bir parçası yapmak dengeni korur.',
    ),
    5: DonemMetni(
      kisa:
          'Değişimin, hareketin ve yeni deneyimlerin hız kazandığı bir dönem.',
      uzun:
          'Bu dönem seni alışık olduğun kalıpların dışına çıkarıyor. '
          'Taşınmalar, yolculuklar, meslek değişiklikleri ya da beklenmedik '
          'fırsatlar gündemine gelebilir. Özgürlük ihtiyacın artar; '
          'kendini kısıtlanmış hissettiğin yerlerden uzaklaşmak '
          'isteyebilirsin. Esnek kaldığında bu yıllar sana çok şey öğretir; '
          'her yeni kapıya aynı hızla koşmamak ise enerjini korur.',
    ),
    6: DonemMetni(
      kisa:
          'Aile, yuva ve sorumlulukların hayatının merkezine yerleştiği bir dönem.',
      uzun:
          'Bu dönem sevgi ve sorumluluk temalarını öne çıkarıyor. Yuva '
          'kurmak, aileyle ilgilenmek, birine bakım vermek ya da topluluğuna '
          'hizmet etmek hayatında büyük yer tutabilir. Başkalarının sana '
          'güvendiğini ve sana yaslandığını hissedersin. Bu yılların dersi, '
          'verdiğin özeni kendine de gösterebilmek; dengeyi kurduğunda bu '
          'dönem sana derin bir aidiyet duygusu bırakır.',
    ),
    7: DonemMetni(
      kisa: 'İçe dönüşün, öğrenmenin ve kendini derinden tanımanın dönemi.',
      uzun:
          'Bu dönem seni yüzeyin altına bakmaya davet ediyor. Okumak, '
          'araştırmak, bir alanda uzmanlaşmak ya da hayatın anlamı üzerine '
          'düşünmek sana her zamankinden çekici gelir. Kalabalıklardan çok '
          'kendi iç dünyanda vakit geçirmek isteyebilirsin. Bu yıllarda '
          'edindiğin bilgelik hızlı sonuç vermeyebilir; ama sonraki '
          'dönemlerde verdiğin her kararın arkasında durur.',
    ),
    8: DonemMetni(
      kisa: 'Güç, başarı ve maddi hedeflerin öne çıktığı bir dönem.',
      uzun:
          'Bu dönem hırsını ve yönetme becerini sahneye çıkarıyor. Kariyerde '
          'yükselmek, kendi işini büyütmek ya da maddi güvenliğini '
          'sağlamlaştırmak için fırsatlar gelebilir. Sorumluluk arttıkça '
          'yetki de artar. Bu yılların dersi gücü dengeli kullanmak; başarıyı '
          'yalnızca rakamlarla değil, kurduğun ilişkiler ve koruduğun iç '
          'huzurla da ölçtüğünde dönem gerçekten verimli geçer.',
    ),
    9: DonemMetni(
      kisa:
          'Bir şeyleri tamamlamanın, paylaşmanın ve büyük resmi görmenin dönemi.',
      uzun:
          'Bu dönem seni kendi hikâyenin ötesine bakmaya çağırıyor. '
          'İnsanlara yardım etmek, bir amaca katkı sunmak ya da birikimini '
          'başkalarıyla paylaşmak sana anlam verir. Bazı ilişkiler, işler ya '
          'da alışkanlıklar doğal sonuna gelebilir; bırakmak bu yıllarda bir '
          'kayıp değil, bir arınmadır. Şefkatin ve hoşgörün bu dönemde en çok '
          'fark edilen yanın olur.',
    ),
    11: DonemMetni(
      kisa: 'Sezgilerin, ilhamın ve iç farkındalığın yükseldiği bir dönem.',
      uzun:
          'Bu dönem sezgilerini ve ilham verme gücünü öne çıkarıyor. İnsanlar '
          'yön bulmak için sana bakabilir; söylediğin bir söz ya da '
          'paylaştığın bir fikir beklediğinden geniş bir etki bırakabilir. '
          'Hassasiyetin artar; yoğun ortamlar seni çabuk yorabilir. Bu '
          'yıllarda ayağını yere basan bir rutin kurmak, ilhamını somut bir '
          'şeye dönüştürmeni sağlar.',
    ),
    22: DonemMetni(
      kisa: 'Büyük bir vizyonu somut bir yapıya dönüştürme fırsatının dönemi.',
      uzun:
          'Bu dönem sana büyük ölçekli bir şey inşa etme fırsatı sunuyor: bir '
          'kurum, bir topluluk, kalıcı bir eser ya da uzun soluklu bir proje. '
          'Hayallerin ile pratik becerilerin aynı yönde çalışır. Sorumluluk '
          'yükü ağır olabilir; tüm işi tek başına taşımak yerine doğru '
          'insanlarla çalışmak bu yılların anahtarı. Kurduğun yapı senden '
          'sonra da ayakta kalabilir.',
    ),
    33: DonemMetni(
      kisa:
          'Şefkatin, rehberliğin ve başkalarına hizmetin öne çıktığı bir dönem.',
      uzun:
          'Bu dönem seni bir öğretmen, rehber ya da destekçi rolüne '
          'taşıyabilir. İnsanlar zor anlarında sana gelir; senin desteğin '
          'onlar için bir dönüm noktası olabilir. Bu yılların en büyük '
          'sınavı, başkalarına verirken kendini tüketmemek. Sınır koymayı '
          'öğrendiğinde şefkatin hem sana hem çevrene uzun süre ışık tutar.',
    ),
  };

  /// Zorluk sayısına göre dönemin dersi (0-8).
  static const Map<int, DonemMetni> zorluklar = <int, DonemMetni>{
    0: DonemMetni(
      kisa: 'Belirgin bir engel yok; asıl sınav, seçimlerini bilinçli yapmak.',
      uzun:
          'Bu dönemin zorluk sayısı 0: önüne tek bir belirgin engel çıkmıyor. '
          'Bu bir özgürlük gibi görünse de kendi sınavını taşır: her yöne '
          'gidebildiğinde hangi yolu seçeceğine karar vermek zorlaşabilir. '
          'Değerlerini netleştirmek ve seçimlerinin sorumluluğunu almak bu '
          'yılların asıl dersi.',
    ),
    1: DonemMetni(
      kisa: 'Kendine güvenmeyi ve kendi sesini duyurmayı öğrenmek.',
      uzun:
          'Bu dönemin dersi kendi ayakların üzerinde durmak. Başkalarının '
          'fikirlerinin gölgesinde kalmak ile fazla inatçı olmak arasında '
          'gidip gelebilirsin. Kendi kararını verip sonucunu üstlendiğin her '
          'an bu zorluğu biraz daha hafifletir. Hedef, kibre kaçmadan sağlam '
          'bir özgüven kurmak.',
    ),
    2: DonemMetni(
      kisa: 'Hassasiyetini yönetmeyi ve sınır koymayı öğrenmek.',
      uzun:
          'Bu dönemin dersi duygusal hassasiyetle barışmak. Eleştiriler seni '
          'olduğundan derin yaralayabilir, başkalarının ruh hali gününü '
          'belirleyebilir. Her şeyi kişisel algılamamak ve gerektiğinde nazik '
          'bir sınır çizmek bu yıllarda kazanacağın en değerli beceri. '
          'Hassasiyetin bir zayıflık değil; yönetildiğinde en güçlü sezgi '
          'kaynağın.',
    ),
    3: DonemMetni(
      kisa: 'Kendini ifade ederken dağılmamayı öğrenmek.',
      uzun:
          'Bu dönemin dersi duygularını ve fikirlerini sağlıklı bir şekilde '
          'ifade etmek. Ya içine kapanıp söylemen gerekenleri yutabilir ya da '
          'enerjini birçok yöne dağıtıp hiçbirini tamamlayamayabilirsin. '
          'Yaratıcılığına bir disiplin eklediğinde, söylediklerin hem duyulur '
          'hem de kalıcı olur.',
    ),
    4: DonemMetni(
      kisa: 'Düzen ile esneklik arasında denge kurmayı öğrenmek.',
      uzun:
          'Bu dönemin dersi emek ve düzenle ilgili. Ya sorumluluklar altında '
          'ezildiğini hissedebilir ya da düzen kurmakta zorlanabilirsin. '
          'Küçük ama düzenli adımlar bu zorluğun panzehiri. Aynı zamanda her '
          'şeyi kontrol etme isteğini gevşetmek, planların aksadığı anlarda '
          'seni korur.',
    ),
    5: DonemMetni(
      kisa: 'Özgürlük ile sorumluluk arasında denge kurmayı öğrenmek.',
      uzun:
          'Bu dönemin dersi değişimle sağlıklı bir ilişki kurmak. Her şeyi '
          'bir anda değiştirme isteği ile değişimden korkup yerinde saymak '
          'arasında gidip gelebilirsin. Aşırılıklardan uzak durmak ve '
          'özgürlüğünü sorumluluklarınla birlikte taşımak bu yılların '
          'anahtarı. Yeniliği bir kaçış yolu olarak değil, bilinçli bir seçim '
          'olarak kullandığında bu dönem seni ileri taşır.',
    ),
    6: DonemMetni(
      kisa: 'Başkalarının yükünü taşırken kendini kaybetmemeyi öğrenmek.',
      uzun:
          'Bu dönemin dersi sorumluluk ve mükemmeliyetçilikle ilgili. '
          'Herkesin sorununu çözmeye çalışmak, sevdiklerinin hayatına fazla '
          'karışmak seni yorabilir. Kendinden ve başkalarından beklentilerini '
          'gerçekçi tutmak, sevgiyi kontrol etmeden gösterebilmek bu yıllarda '
          'öğrenilecek en önemli şey. Yardım etmek ile her şeyi üstlenmek '
          'arasındaki farkı gördüğünde ilişkilerin de hafifler.',
    ),
    7: DonemMetni(
      kisa: 'Güvenmeyi ve içini açmayı öğrenmek.',
      uzun:
          'Bu dönemin dersi güvenle ilgili. Kendini geri çekmek, insanlara '
          'mesafe koymak ya da her şeyi tek başına çözmeye çalışmak sana '
          'güvenli gelebilir. Ama bu yıllarda asıl büyüme, birine içini '
          'açtığında ve yardım istemeyi göze aldığında gerçekleşir. '
          'Şüpheciliğin seni korur; aşırısı ise yalnızlaştırır.',
    ),
    8: DonemMetni(
      kisa: 'Güç ve parayla dengeli bir ilişki kurmayı öğrenmek.',
      uzun:
          'Bu dönemin dersi güç, kontrol ve maddi konularla ilgili. Parayı ve '
          'başarıyı hayatının merkezine koymak ile onlarla ilgilenmekten '
          'kaçınmak arasında gidip gelebilirsin; ikisi de dengesizlik '
          'yaratır. Maddi hedeflerini değerlerinle uyumlu tutmak ve gücü '
          'paylaşmayı öğrenmek bu yılları dönüştürür.',
    ),
  };

  /// Karmik borç sayılarının metinleri (13, 14, 16, 19).
  static const Map<int, KarmikBorcMetni> karmikBorclar = <int, KarmikBorcMetni>{
    13: KarmikBorcMetni(
      lakap: 'Emek ve sabır',
      metin:
          'Bu borç emeğin ve sabrın dersini taşır. Kestirme yollar sana '
          'çoğu zaman beklediğin sonucu vermez; işler ancak adım adım ve '
          'özenle yapıldığında oturur. Bazen başkalarının daha kolay '
          'ilerlediğini hissedip hayal kırıklığına uğrayabilirsin. Oysa '
          'senin için kalıcı başarı, düzenli emekle kurulan başarıdır. '
          'Odaklanmayı ve bir işi sonuna kadar götürmeyi öğrendiğinde bu '
          'borç bir güce dönüşür.',
    ),
    14: KarmikBorcMetni(
      lakap: 'Özgürlük ve ölçü',
      metin:
          'Bu borç özgürlüğü ölçüyle yaşamanın dersini taşır. Değişime, '
          'yeniliğe ve deneyime güçlü bir çekim duyarsın; ama aşırılıklar '
          've ani kararlar seni zaman zaman zor durumda bırakabilir. '
          'Alışkanlık hâline gelen kaçış yollarına karşı dikkatli olmak '
          'senin için önemlidir. Esnekliğini korurken bir çapa bulduğunda '
          'değişim seni savurmak yerine büyütür.',
    ),
    16: KarmikBorcMetni(
      lakap: 'Yıkım ve yeniden doğuş',
      metin:
          'Bu borç gururun ve kibrin bırakılmasıyla ilgili bir dönüşüm '
          'dersini taşır. Hayatında kurduğun bazı yapılar beklenmedik '
          'şekilde sarsılabilir; bu anlar ilk bakışta kayıp gibi görünse '
          'de seni daha sahici bir hâle taşır. Gururunu bir kenara bırakıp '
          'alçakgönüllülükle yeniden başlayabildiğinde, her sarsıntının '
          'ardından daha sağlam bir zemin kurarsın.',
    ),
    19: KarmikBorcMetni(
      lakap: 'Bağımsızlık ve yardımlaşma',
      metin:
          'Bu borç güç ile bağımsızlığı doğru kullanmanın dersini taşır. '
          'Her şeyi tek başına yapma eğilimin güçlü olabilir; yardım '
          'istemek sana zayıflık gibi gelebilir. Oysa bu borcun özü, kendi '
          'ayakların üzerinde dururken başkalarına da yer açmayı '
          'öğrenmek. Desteği kabul ettiğinde liderliğin daha geniş bir '
          'çevreye ulaşır.',
    ),
  };

  /// Karmik borcun görüldüğü hesabın bulunma hâli ("doğum gününde").
  static const Map<KarmikKaynak, String> karmikKaynaklar =
      <KarmikKaynak, String>{
        KarmikKaynak.yasamYolu: 'yaşam yolu hesabında',
        KarmikKaynak.dogumGunu: 'doğum gününde',
        KarmikKaynak.isim: 'isim sayında',
        KarmikKaynak.ruh: 'ruh sayında',
        KarmikKaynak.kisilik: 'kişilik sayında',
      };

  /// Hiç karmik borç yoksa gösterilen metin.
  static const String karmikBorcYok =
      'Hesaplarında karmik borç sayısı (13, 14, 16, 19) görünmüyor. Bu, '
      'geçmişten taşıdığın belirgin bir yük olmadığı ve enerjini daha çok bu '
      'hayatın kendi derslerine ayırabileceğin şeklinde yorumlanır.';

  /// İsimde hiç geçmeyen sayının dersi (1-9).
  static const Map<int, String> karmikDersler = <int, String>{
    1:
        'İsminde 1 sayısı yok: kendi adına karar vermek, inisiyatif almak ve '
        "'ben' diyebilmek öğrenmen gereken bir alan olabilir. Başkalarının "
        'yönlendirmesini beklemek yerine küçük kararları kendin vermek bu '
        'dersi güçlendirir.',
    2:
        'İsminde 2 sayısı yok: sabır, iş birliği ve ince ayrıntılara dikkat '
        'senin için çaba gerektiren alanlar olabilir. Başkalarının bakış '
        'açısını dinlemeye ve ortak kararlar almaya zaman ayırmak bu dersi '
        'güçlendirir.',
    3:
        'İsminde 3 sayısı yok: duygularını ifade etmek ve kendini rahatça '
        'göstermek sana zor gelebilir. Yazmak, konuşmak ya da yaratıcı bir '
        'uğraş edinmek içindekileri dışarı taşımanı kolaylaştırır.',
    4:
        'İsminde 4 sayısı yok: düzen, rutin ve uzun soluklu emek senin için '
        'öğrenilmesi gereken alanlar olabilir. Küçük ama düzenli alışkanlıklar '
        'kurmak bu dersi adım adım güçlendirir.',
    5:
        'İsminde 5 sayısı yok: değişime uyum sağlamak ve bilinmeyene adım '
        'atmak sana tedirginlik verebilir. Kontrollü küçük yenilikler denemek '
        'esnekliğini zamanla büyütür.',
    6:
        'İsminde 6 sayısı yok: sorumluluk almak ve yakın ilişkilerde bağlılık '
        'göstermek öğrenmen gereken bir alan olabilir. Sevdiklerine düzenli '
        'zaman ayırmak bu dersi derinleştirir.',
    7:
        'İsminde 7 sayısı yok: derinlemesine düşünmek, sorgulamak ve kendi iç '
        'sesine güvenmek senin için gelişime açık alanlar olabilir. Yalnız '
        'kalıp düşünmeye zaman ayırmak bu dersi güçlendirir.',
    8:
        'İsminde 8 sayısı yok: para, güç ve kendi değerini savunmak sana '
        'yabancı gelebilir. Maddi konuları ertelemeden ele almak ve emeğinin '
        'karşılığını istemek bu dersi güçlendirir.',
    9:
        'İsminde 9 sayısı yok: hoşgörü, affetmek ve olaylara geniş bir '
        'pencereden bakmak senin için öğrenme alanı olabilir. Kendinden farklı '
        'insanları anlamaya çalışmak bu dersi derinleştirir.',
  };

  /// İsimde 1-9 arası tüm sayılar geçiyorsa gösterilen metin.
  static const String karmikDersYok =
      "İsminde 1'den 9'a kadar tüm sayılar en az bir kez geçiyor. Bu, farklı "
      'durumlara uyum sağlayabilen dengeli bir yapıya işaret eder; belirgin '
      'bir eksik alan yerine her yöne açılabilen bir esneklik taşıyorsun.';

  /// İsimde en sık geçen sayının anlattığı iç motivasyon (1-9).
  static const Map<int, String> gizliTutkular = <int, String>{
    1:
        'İçinde güçlü bir bağımsızlık ve öncülük arzusu var. Bir işin başında '
        'olmak, kendi kararlarını vermek ve iz bırakmak seni derinden motive '
        'eder.',
    2:
        'Uyum, yakınlık ve birlikte olma arzusu seni yönlendirir. Huzurlu '
        'ilişkiler ve güvendiğin bir ortak, başarıdan bile değerli '
        'gelebilir.',
    3:
        'Kendini ifade etme ve yaratma arzun güçlü. Sözler, sanat, eğlence ve '
        'insanlarla paylaşım içindeki ateşi canlı tutar.',
    4:
        'Güvenlik, düzen ve kalıcı bir şey inşa etme arzusu seni yönlendirir. '
        'Sağlam temeller ve öngörülebilir bir hayat sana derin bir huzur '
        'verir.',
    5:
        'Özgürlük, macera ve deneyim arzun baskın. Yeni yerler, yeni insanlar '
        've değişim seni canlı hissettirir.',
    6:
        'Sevmek, korumak ve bir yuva kurmak en derin arzularından biri. '
        'Sevdiklerinin iyi olduğunu bilmek sana her şeyden çok huzur verir.',
    7:
        'Bilgi, anlam ve hakikat arayışı içindeki en güçlü itki. Bir şeyi '
        'gerçekten anlamak sana başka hiçbir şeyin vermediği bir tatmin '
        'sağlar.',
    8:
        'Başarı, güç ve maddi bağımsızlık arzun güçlü. Hedef koymak ve onu '
        'gerçekleştirmek seni ayakta tutan motorlardan biri.',
    9:
        'İnsanlığa katkı sunma ve dünyayı biraz daha iyi bırakma arzusu '
        'taşıyorsun. Bir amaca hizmet ettiğinde kendini en anlamlı '
        'hissedersin.',
  };

  /// Gizli tutku girişi: tek sayı ya da eşit sıklıkta birden çok sayı.
  static String gizliTutkuGirisi(List<int> sayilar) => sayilar.length == 1
      ? 'İsminde en sık tekrar eden sayı ${sayilar.single}.'
      : 'İsminde ${_birlestir(sayilar.map((int s) => '$s'))} sayıları '
            'eşit sıklıkta öne çıkıyor.';

  /// Olgunluk sayısına göre hayatın ikinci yarısının teması.
  static const Map<int, String> olgunluk = <int, String>{
    1:
        'Yaş aldıkça daha bağımsız, daha kararlı ve kendi yolunu çizmekten '
        'daha az çekinen biri olursun. Hayatının ikinci yarısında kendi adına '
        'bir şey başlatma isteği güçlenebilir.',
    2:
        'Yaş aldıkça ilişkiler, ortaklıklar ve iç huzur senin için daha '
        'önemli hâle gelir. İkinci yarıda daha sabırlı, daha diplomatik ve '
        'daha sezgisel bir sen ortaya çıkar.',
    3:
        'Yaş aldıkça kendini ifade etme isteğin artar. Yaratıcı uğraşlar ve '
        'sosyal çevren hayatının ikinci yarısını renklendirebilir.',
    4:
        'Yaş aldıkça güvenlik ve düzen ihtiyacın belirginleşir. İkinci yarıda '
        'kalıcı bir şey inşa etmek ve emeğinin meyvelerini toplamak öne '
        'çıkar.',
    5:
        'Yaş aldıkça hayat sana daha çok özgürlük ve hareket alanı açar. '
        'İkinci yarıda yolculuklar, değişim ve yeni deneyimler ağırlık '
        'kazanabilir.',
    6:
        'Yaş aldıkça ailen, yuvan ve topluluğun için sorumluluk alma isteğin '
        'artar. İkinci yarıda sevdiklerinin merkezinde sıcak bir rol '
        'üstlenebilirsin.',
    7:
        'Yaş aldıkça içe dönüş ve anlam arayışın derinleşir. İkinci yarıda '
        'bilgelik, uzmanlık ve hayata dair büyük sorular hayatında daha çok '
        'yer tutar.',
    8:
        'Yaş aldıkça yönetme gücün ve maddi farkındalığın artar. İkinci '
        'yarıda emeklerinin somut karşılığını görmek ve söz sahibi olmak öne '
        'çıkabilir.',
    9:
        'Yaş aldıkça daha hoşgörülü ve paylaşımcı biri olursun. İkinci yarıda '
        'deneyimlerini başkalarına aktarmak sana derin bir anlam verir.',
    11:
        'Yaş aldıkça sezgilerin güçlenir ve insanlara ilham verme yeteneğin '
        'belirginleşir. İkinci yarıda çevrende bir rehber ya da öğretmen gibi '
        'görülebilirsin.',
    22:
        'Yaş aldıkça büyük ölçekli düşünme ve bunu hayata geçirme kapasiten '
        'artar. İkinci yarıda kalıcı bir eser ya da yapı ortaya koyma fırsatı '
        'doğabilir.',
    33:
        'Yaş aldıkça şefkatin ve sorumluluk duygun derinleşir. İkinci yarıda '
        'başkalarının hayatına dokunan bir destek ya da rehberlik rolü '
        'üstlenebilirsin.',
  };

  /// Temel taşı: ismin ilk harfine göre hayata yaklaşım (Türk alfabesi;
  /// Ğ hiçbir ismin başında olmadığı için yer almaz).
  static const Map<String, String> temelTaslari = <String, String>{
    'A':
        'A ile başlayan isimler hayata cesur ve atılgan bir başlangıçla '
        'yaklaşır. Yeni bir duruma girerken ilk adımı atmaktan çekinmezsin; '
        'sabırsızlığını yönetmek seni daha da güçlü kılar.',
    'B':
        'B harfi hayata duyarlı ve sıcak bir yaklaşımı anlatır. İnsanlarla '
        'yakınlık kurmaya, güvenli ve huzurlu ortamlar yaratmaya önem '
        'verirsin; bazen karar vermeden önce fazla beklersin.',
    'C':
        'C harfi neşeli, iletişime açık ve yaratıcı bir başlangıç enerjisi '
        'taşır. Yeni bir ortama girdiğinde sohbeti başlatan sen olursun; '
        'düşüncelerini toparlamak ise zaman zaman çaba ister.',
    'Ç':
        "Ç harfi, C'nin yaratıcı enerjisine bir kararlılık ekler. Fikirlerini "
        'söylemekle kalmaz, onları uygulamaya da dökersin; kendini ifade '
        'ederken netlik senin en büyük gücün.',
    'D':
        'D harfi sağlam, disiplinli ve güvenilir bir yaklaşımı anlatır. Bir '
        'işe giriştiğinde onu yarım bırakmazsın; esneklik göstermeyi '
        'öğrendiğinde bu kararlılık çok daha verimli olur.',
    'E':
        'E harfi meraklı, hareketli ve özgür bir ruhu temsil eder. Yeni '
        'deneyimlere ve insanlara açıksın; ilgini dağıtmadan bir konuda '
        'derinleşmek seni daha da ileri taşır.',
    'F':
        'F harfi şefkatli, sorumluluk sahibi ve yuvasına bağlı bir yaklaşımı '
        'anlatır. Sevdiklerine özen göstermek senin için doğal; kendine de '
        'aynı özeni göstermeyi unutmamak önemli.',
    'G':
        'G harfi düşünceli, gözlemci ve derin bir başlangıç taşır. Bir şeye '
        'girişmeden önce iyice düşünürsün; sezgilerine güvendiğinde '
        'kararların çok isabetli olur.',
    'H':
        'H harfi hırslı, girişimci ve sonuç odaklı bir yaklaşımı anlatır. '
        'Maddi ve mesleki hedefler seni harekete geçirir; dinlenmeyi ihmal '
        'etmemek dengeni korur.',
    'I':
        'I harfi içe dönük, duyarlı ve derin hisleri olan bir yapıyı anlatır. '
        'Duygularını herkese açmasan da onları yoğun yaşarsın; kendini ifade '
        'etmenin bir yolunu bulduğunda rahatlarsın.',
    'İ':
        'İ harfi şefkatli, idealist ve duyarlı bir başlangıç taşır. İnsanların '
        'derdini anlamakta ustasın; başkalarının yükünü sırtlanırken kendi '
        'sınırlarını korumak önemli.',
    'J':
        'J harfi adil, dürüst ve hedef odaklı bir yaklaşımı anlatır. Söz '
        'verdiğinde tutarsın; aynı dürüstlüğü başkalarından beklerken biraz '
        'esneklik göstermek ilişkilerini kolaylaştırır.',
    'K':
        'K harfi sezgisel, ilham verici ve güçlü bir başlangıç enerjisi '
        'taşır. Çevrendekiler senin enerjinden etkilenir; uçlarda gezen '
        'duygularını dengelemek seni daha da etkili kılar.',
    'L':
        'L harfi düşünceli, adil ve ilişkilere önem veren bir yaklaşımı '
        'anlatır. Kararlarını tartarak verirsin; bazen fazla tartmak harekete '
        'geçmeni geciktirebilir.',
    'M':
        'M harfi çalışkan, güvenilir ve evine bağlı bir yaklaşımı anlatır. '
        'Emek vermekten kaçınmazsın; kendine dinlenme alanı tanımak bu '
        'enerjiyi uzun ömürlü kılar.',
    'N':
        'N harfi yaratıcı, sezgisel ve hayal gücü geniş bir yaklaşımı '
        'anlatır. Fikirlerin özgün ve canlıdır; onları somut adımlara '
        'dönüştürdüğünde parlarsın.',
    'O':
        'O harfi sorumluluk sahibi, koruyucu ve sadık bir yaklaşımı anlatır. '
        'Sevdiklerin için güvenli bir liman olursun; kendi duygularını da '
        'dile getirmeyi unutmamalısın.',
    'Ö':
        "Ö harfi, O'nun koruyucu sıcaklığına özgün ve bağımsız bir ruh ekler. "
        'Hem sevdiklerine bağlısın hem de kendi yolunu çizmekten çekinmezsin.',
    'P':
        'P harfi zeki, meraklı ve bilgiye aç bir yaklaşımı anlatır. Bir konuyu '
        'derinlemesine anlamadan rahat etmezsin; fikirlerini paylaştığında '
        'insanlar senden çok şey öğrenir.',
    'R':
        'R harfi enerjik, cömert ve tutkulu bir başlangıç taşır. Bir şeye '
        'inandığında tüm gücünle sarılırsın; öfkeni yönetmeyi öğrenmek bu '
        'tutkuyu daha verimli kılar.',
    'S':
        'S harfi çekici, duygusal ve yeniliklere açık bir yaklaşımı anlatır. '
        'İnsanlar sende bir sıcaklık hisseder; ani duygu değişimlerini fark '
        'etmek seni daha dengeli kılar.',
    'Ş':
        "Ş harfi, S'nin çekiciliğine neşe ve sosyal bir enerji ekler. Ortama "
        'renk katan, insanları bir araya getiren biri olursun.',
    'T':
        'T harfi duyarlı, hareketli ve hayatı yoğun yaşayan bir yaklaşımı '
        'anlatır. Hem içinde hem çevrende hareketi seversin; kendine sakin '
        'anlar yaratmak dengeni korur.',
    'U':
        'U harfi sezgisel, yaratıcı ve fırsatlara açık bir yaklaşımı anlatır. '
        'Fırsatları yakalama konusunda doğal bir yeteneğin var; kararsızlık '
        'anlarında iç sesine güvenmek işini kolaylaştırır.',
    'Ü':
        "Ü harfi, U'nun sezgisel yaratıcılığına zarif ve incelikli bir dokunuş "
        'ekler. Ayrıntılara gösterdiğin özen, yaptığın her işe senin imzanı '
        'taşır.',
    'V':
        'V harfi vizyoner, çalışkan ve büyük düşünen bir yaklaşımı anlatır. '
        'Hayallerini somut planlara dönüştürmekte güçlüsün; her şeyi kontrol '
        'etme isteğini gevşetmek seni rahatlatır.',
    'Y':
        'Y harfi özgürlüğüne düşkün, sezgisel ve kendi yolunu arayan bir '
        'yaklaşımı anlatır. Kalıplara sığmayı sevmezsin; karar anlarında '
        'kararsızlığı aşmak senin için önemli bir beceri.',
    'Z':
        'Z harfi iyimser, kararlı ve diplomatik bir yaklaşımı anlatır. Zor '
        'durumlarda bile umut görmeyi bilirsin; sabrınla en karmaşık işleri '
        'çözebilirsin.',
  };

  /// Türk alfabesinde olmayan bir harfle (Q, W, X…) başlayan isimler için
  /// harf değerine göre temel taşı metni (1-9).
  static const Map<int, String> temelTasiDegere = <int, String>{
    1:
        'İsminin ilk harfi hayata cesur ve bağımsız bir başlangıçla '
        'yaklaştığını gösterir; ilk adımı atmaktan çekinmezsin.',
    2:
        'İsminin ilk harfi hayata nazik ve uyumlu bir yaklaşımı anlatır; '
        'yeni bir durumda önce ortamı ve insanları hissedersin.',
    3:
        'İsminin ilk harfi hayata neşeli ve iletişime açık bir başlangıç '
        'enerjisi taşır; yeni ortamlarda çabuk kaynaşırsın.',
    4:
        'İsminin ilk harfi hayata planlı ve sağlam bir yaklaşımı anlatır; '
        'bir işe sağlam bir zemin kurmadan girmezsin.',
    5:
        'İsminin ilk harfi hayata meraklı ve özgür bir başlangıç enerjisi '
        'taşır; yeni deneyimlere kolayca açılırsın.',
    6:
        'İsminin ilk harfi hayata şefkatli ve sorumluluk sahibi bir '
        'yaklaşımı anlatır; önce sevdiklerini düşünürsün.',
    7:
        'İsminin ilk harfi hayata düşünceli ve gözlemci bir yaklaşımı '
        'anlatır; bir şeye girişmeden önce onu iyice anlamak istersin.',
    8:
        'İsminin ilk harfi hayata hırslı ve sonuç odaklı bir yaklaşımı '
        'anlatır; hedefini görmeden yola çıkmazsın.',
    9:
        'İsminin ilk harfi hayata geniş görüşlü ve şefkatli bir yaklaşımı '
        'anlatır; olaylara büyük resimden bakarsın.',
  };

  /// Tepe taşı: ilk adın son harfinin değerine göre işleri bitirme biçimi.
  static const Map<int, String> tepeTaslari = <int, String>{
    1:
        'İşleri kararlı ve hızlı bir şekilde bitirirsin; başladığın şeyi '
        'sonuçlandırmak için kendi inisiyatifini kullanırsın.',
    2:
        'İşleri uyum içinde ve başkalarıyla birlikte tamamlamayı seversin; '
        'bitişlerde herkesin memnun kalmasına özen gösterirsin.',
    3:
        'Bir işi bitirirken ona kendi yaratıcı dokunuşunu eklersin; sonuç '
        'çoğu zaman beklenenden daha renkli olur.',
    4:
        'İşleri titizlikle ve eksiksiz tamamlarsın; yarım kalmış bir iş seni '
        'gerçekten rahatsız eder.',
    5:
        'Bir işi bitirmeden yenisine geçme eğilimin olabilir; heyecanını sona '
        'kadar korumak senin için küçük bir sınav.',
    6:
        'Bir işi bitirirken sorumluluk duygusuyla hareket edersin; başkalarını '
        'da düşünerek özenli bir kapanış yaparsın.',
    7:
        'İşleri bitirmeden önce her ayrıntıyı tartarsın; bitişlerin '
        'düşünülmüş ve sağlamdır.',
    8:
        'İşleri sonuç odaklı bitirirsin; bir hedefe ulaştığında bunu somut bir '
        'başarıya dönüştürmeyi bilirsin.',
    9:
        'Bir dönemi kapatmayı bilirsin; bitişleri bir kayıp değil, yeni bir '
        'başlangıca hazırlık olarak görürsün.',
  };

  /// Denge sayısına göre zor anlarda dengeyi bulma biçimi (1-9).
  static const Map<int, String> dengeler = <int, String>{
    1:
        'Zor anlarda kendi gücüne yaslanmak dengeni bulmanın yolu; ama tek '
        'başına savaşmak yerine yardım istemek de bir güç göstergesi.',
    2:
        'Zor anlarda diplomatik ve sakin kalmak sana en çok kazandırır; '
        'çatışmadan kaçmak yerine nazikçe konuşmak dengeni korur.',
    3:
        'Zor anlarda neşeni ve iletişim becerini kullanmak seni toparlar; '
        'duygularını paylaşmak yükünü hafifletir.',
    4:
        'Zor anlarda bir plan yapmak ve adım adım ilerlemek sana güven verir; '
        'düzen, karmaşanın panzehiridir.',
    5:
        'Zor anlarda esnek kalmak ve farklı bir bakış açısı denemek seni '
        'rahatlatır; kaçmak yerine durumla yüzleşmek önemli.',
    6:
        'Zor anlarda sevdiklerinden destek almak ve sorumluluğu paylaşmak '
        'dengeni sağlar; her şeyi tek başına çözmek zorunda değilsin.',
    7:
        'Zor anlarda geri çekilip düşünmek sana netlik kazandırır; ama '
        'tamamen içine kapanmadan güvendiğin biriyle konuşmak da önemli.',
    8:
        'Zor anlarda gücünü ve kararlılığını kullanmak işe yarar; kontrolü '
        'bırakmaktan korkmadan görev paylaşmak ise seni rahatlatır.',
    9:
        'Zor anlarda büyük resme bakmak ve olaylara şefkatle yaklaşmak seni '
        'sakinleştirir; affetmek dengeyi yeniden kurar.',
  };

  // ---- Başlıklar ve etiketler ----

  /// Aktif dönemin zirve bölümü başlığı.
  static String aktifZirveBasligi(int zirve) =>
      'Şu anki dönemin · Zirve $zirve';

  /// Aktif dönemin zorluk bölümü başlığı.
  static String aktifZorlukBasligi(int zorluk) =>
      'Bu dönemin dersi · Zorluk $zorluk';

  /// Sıradaki dönemin bölüm başlığı.
  static String sonrakiDonemBasligi(String yasAraligi) =>
      'Sıradaki dönem · $yasAraligi';

  /// Karmik borç bölümü başlığı.
  static String karmikBorcBasligi(int sayi, String lakap) =>
      'Karmik borç $sayi · $lakap';

  /// Karmik borç yoksa bölüm başlığı.
  static const String karmikBorcYokBasligi = 'Karmik borç';

  /// Karmik dersler bölümü başlığı.
  static const String karmikDersBasligi = 'Karmik derslerin';

  /// Gizli tutku bölümü başlığı.
  static const String gizliTutkuBasligi = 'Gizli tutkun';

  /// Olgunluk bölümü başlığı.
  static String olgunlukBasligi(int sayi) => 'Olgunluk sayısı $sayi';

  /// İlk ve son harf bölümü başlığı.
  static String harfBasligi(String ilk, String son) =>
      'İsminin ilk ve son harfi · $ilk … $son';

  /// Denge bölümü başlığı.
  static String dengeBasligi(int sayi) => 'Denge sayısı $sayi';

  /// Karmik borcun görüldüğü hesapları anlatan giriş cümlesi.
  static String karmikKaynakCumlesi(List<KarmikKaynak> kaynaklar) =>
      'Bu sayı ${_birlestir(kaynaklar.map((KarmikKaynak k) => karmikKaynaklar[k]!))} '
      'görülüyor.';

  /// Dönemin yaş aralığı etiketi ("Doğumdan 32 yaşa", "32-41 yaş",
  /// "50 yaş ve sonrası").
  static String yasAraligi(YasamDonemi d) {
    if (d.bitisYasi == null) {
      return '${d.baslangicYasi} yaş ve sonrası';
    }
    if (d.baslangicYasi == 0) {
      return 'Doğumdan ${d.bitisYasi} yaşa';
    }
    return '${d.baslangicYasi}-${d.bitisYasi} yaş';
  }

  /// Öğeleri Türkçe sıralama bağlacıyla birleştirir: "a", "a ve b",
  /// "a, b ve c".
  static String _birlestir(Iterable<String> ogeler) {
    final List<String> l = ogeler.toList(growable: false);
    if (l.length <= 1) {
      return l.join();
    }
    return '${l.sublist(0, l.length - 1).join(', ')} ve ${l.last}';
  }
}
