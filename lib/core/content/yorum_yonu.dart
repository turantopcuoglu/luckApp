/// Kişiye özel yorumun YÖNÜNÜ belirleyen içerik.
///
/// v2'deki sorun: yorum, birbirinden bağımsız havuzlardan seçilen mecazlı
/// cümlelerin ("terazi", "rüzgâr", "9 yılındasın") yan yana dizilmesiydi;
/// cümleler birbirine bağlanmıyor, kişiden bahsetmiyor ve numeroloji
/// terimleri kullanıcıya anlamsız geliyordu.
///
/// v3 yaklaşımı — her paragraf tek bir mantık zinciri izler:
/// 1. Bugün nasıl bir gün? (günün teması × günün tonu, günlük dille)
/// 2. Bu gün SENİN doğanla nasıl buluşuyor? (yaşam yolu karakteri ×
///    günün teması → uyumlu / dengeli / zorlayıcı)
/// 3. Hayatında nerede görünür? (günün teması × günlük uğraş)
/// 4. Ne yapmalısın? (karakterin güçlü/gölge yanı × buluşma türü)
///
/// Kategori yorumları da aynı mantıkla kurulur: durum (kategori × ton ×
/// kişinin durumu) + günün temasının bu alana etkisi + kişinin bu alandaki
/// tarzı. Numeroloji terimleri (kişisel gün, yaşam yolu sayısı, ay evresi)
/// ana metinde KULLANILMAZ; yalnızca "Neden bugün?" açıklamalarındadır.
///
/// v4 (tekrar denetimi): v3'te öneri, kategori tarzı ve dönem cümleleri
/// tek varyantlıydı; bir kullanıcı 30 günde okuduğu cümlelerin yarıdan
/// fazlasını ikinci kez görüyordu. Artık her havuz döngüsel seçilen
/// birden çok varyant taşır, yalnızca açılış cümlesi "Bugün" der ve
/// sahne/tema cümleleri tek kalıba ("… anlamına gelebilir", "Günün …
/// havası") dayanmaz. Ölçütler `test/content/tekrar_denetimi_test.dart`
/// içindedir.
///
/// Yer tutucular: `{isim}`, `{doga}`, `{gunIstegi}`, `{saat}`.
library;

import '../luck_engine/luck_engine.dart';
import 'content_config.dart';
import 'dongu_metinleri.dart';
import 'karakter_yonleri.dart';
import 'kategori_durumlari.dart';
import 'okuyucu.dart';

/// Günün teması ile kişinin doğası arasındaki buluşma türü.
enum BulusmaTuru {
  /// Gün, kişinin zaten iyi yaptığı şeyi istiyor.
  uyumlu,

  /// Gün, kişinin doğasını tamamlayan bir şey istiyor.
  dengeli,

  /// Gün, kişinin gölge yanına dokunan bir şey istiyor.
  zorlayici,
}

/// Bir yaşam yolu karakterinin günlük yoruma yön veren özellikleri.
class KarakterYonu {
  /// Tüm alanlarıyla karakter yönü oluşturur.
  const KarakterYonu({
    required this.doga,
    required this.uyumluGunler,
    required this.zorlayiciGunler,
    required this.gucTavsiyeleri,
    required this.golgeTavsiyeleri,
    required this.dengeTavsiyeleri,
    required this.kategoriTarzi,
  });

  /// Kişinin doğası, mastar öbeği ("harekete geçmek ve yön vermek").
  final String doga;

  /// Temasını doğal bulduğu kişisel gün sayıları (1-9).
  final Set<int> uyumluGunler;

  /// Temasında zorlandığı kişisel gün sayıları (1-9).
  final Set<int> zorlayiciGunler;

  /// Uyumlu günde: güçlü yanını kullanma önerileri.
  final List<String> gucTavsiyeleri;

  /// Zorlayıcı günde: gölge yanını yönetme önerileri.
  final List<String> golgeTavsiyeleri;

  /// Dengeli günde: iki yanı birleştirme önerileri.
  final List<String> dengeTavsiyeleri;

  /// Her kategoride kişinin tipik tarzı (tondan bağımsız varyantlar).
  final Map<LuckCategory, List<String>> kategoriTarzi;

  /// [kisiselGun] temasıyla buluşma türü.
  BulusmaTuru bulusma(int kisiselGun) {
    if (uyumluGunler.contains(kisiselGun)) {
      return BulusmaTuru.uyumlu;
    }
    if (zorlayiciGunler.contains(kisiselGun)) {
      return BulusmaTuru.zorlayici;
    }
    return BulusmaTuru.dengeli;
  }

  /// Buluşma türüne göre öneri varyantları.
  List<String> tavsiyeler(BulusmaTuru tur) => switch (tur) {
    BulusmaTuru.uyumlu => gucTavsiyeleri,
    BulusmaTuru.dengeli => dengeTavsiyeleri,
    BulusmaTuru.zorlayici => golgeTavsiyeleri,
  };
}

/// Kişisel gün (1-9) temasının günlük dildeki anlatımı.
class GunTemasi {
  /// Tüm alanlarıyla tema oluşturur.
  const GunTemasi({required this.istek, required this.durum});

  /// Günün kişiden istediği, mastar öbeği ("işleri düzene sokmak …").
  final String istek;

  /// Tona göre günün tarifi (her tonda en az iki varyant).
  final Map<GunTonu, List<String>> durum;
}

/// v3/v4 yorum içerikleri.
abstract final class YorumYonu {
  /// Kişisel gün temaları.
  ///
  /// Durum cümleleri okumanın AÇILIŞIDIR: "bugün" kelimesi yalnızca
  /// burada doğal olarak geçer.
  static const Map<int, GunTemasi> gunTemalari = <int, GunTemasi>{
    1: GunTemasi(
      istek: 'yeni bir şeye cesaretle başlamak',
      durum: <GunTonu, List<String>>{
        GunTonu.dusuk: <String>[
          '{isim}, bugün yeni bir şeye başlama isteğin olabilir ama koşullar henüz tam hazır değil.',
          'Bugün içinde bir başlangıç kıpırtısı var; yine de büyük adımlar yerine küçük bir hazırlık daha doğru olur.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün yeni bir sayfa açmak için makul bir gün; küçük ve somut bir başlangıç yeterli.',
          'Bugün ertelediğin bir işe başlamak için yeterli enerjin var, yeter ki mükemmel anı bekleme.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün yeni bir şeye başlamak, bir teklifte bulunmak ya da ilk adımı atmak için rüzgâr arkanda.',
          'Bugün cesaretin karşılık bulduğu bir gün; aklındaki başlangıcı ertelemek için iyi bir sebebin yok.',
        ],
      },
    ),
    2: GunTemasi(
      istek: 'sabırlı olmak ve başkalarıyla uyum içinde ilerlemek',
      durum: <GunTonu, List<String>>{
        GunTonu.dusuk: <String>[
          '{isim}, bugün duyguların biraz daha hassas; küçük bir söz ya da gecikme seni olduğundan fazla etkileyebilir.',
          'Bugün beklemek zorunda kaldığın şeyler olabilir; işlerin senin istediğin hızda ilerlemesi zor.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün tek başına zorlamak yerine birlikte hareket ettiğinde işler daha kolay akıyor.',
          'Bugün küçük ayrıntılar ve nazik tavırlar, büyük hamlelerden daha çok işe yarıyor.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün iş birliği, anlaşma ve yakınlaşma kolaylaşıyor; insanlar sana karşı daha açık.',
          'Bugün bir konuşmada ya da ortaklıkta beklediğinden daha kolay uzlaşı sağlayabilirsin.',
        ],
      },
    ),
    3: GunTemasi(
      istek: 'kendini ifade etmek ve insanlarla bağ kurmak',
      durum: <GunTonu, List<String>>{
        GunTonu.dusuk: <String>[
          '{isim}, bugün söylemek istediklerin çok ama sözlerin yanlış anlaşılmaya açık.',
          'Bugün enerjin dağılmaya meyilli; aynı anda birçok işe dokunup hiçbirini bitirememe riski var.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün kendini ifade etmek ve insanlarla temas kurmak seni canlandıracak.',
          'Bugün bir fikri paylaşmak ya da uzun zamandır görmediğin biriyle konuşmak için kapılar açık.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün sözlerin ve fikirlerin karşılık buluyor; paylaşım ya da yaratıcı bir iş için güzel bir gün.',
          'Bugün insanlar seni dinlemeye ve seninle vakit geçirmeye daha istekli.',
        ],
      },
    ),
    4: GunTemasi(
      istek: 'işleri düzene sokmak ve sabırla emek vermek',
      durum: <GunTonu, List<String>>{
        GunTonu.dusuk: <String>[
          '{isim}, bugün yapılacaklar göründüğünden ağır gelebilir ve planlar kolay aksayabilir.',
          'Bugün emeğinin karşılığını hemen görememek seni sabırsızlandırabilir.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün dağınık duran işleri toplamanın ve bir planı adım adım ilerletmenin tam zamanı.',
          'Bugün hızdan çok istikrar kazandırıyor; ertelediğin küçük işleri bitirmek içini rahatlatır.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün odaklandığın işte somut ilerleme görebileceğin verimli bir gün.',
          'Bugün kurduğun düzen ve verdiğin emek görünür oluyor; uzun süredir uğraştığın bir işte ilerleme mümkün.',
        ],
      },
    ),
    5: GunTemasi(
      istek: 'esnek olmak ve değişime açılmak',
      durum: <GunTonu, List<String>>{
        GunTonu.dusuk: <String>[
          '{isim}, bugün planların son dakikada değişebilir ve bu seni huzursuz edebilir.',
          'Bugün içinde her şeyi bir anda değiştirme isteği olabilir; ani kararlar için doğru zaman değil.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün rutini biraz esnetmek ve farklı bir şey denemek zihnini tazeler.',
          'Bugün beklenmedik küçük değişiklikler olabilir; esnek kaldıkça gün kolaylaşır.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün yeni bir deneyim, kısa bir yolculuk ya da beklenmedik bir teklif için açık bir gün.',
          'Bugün değişim senin lehine işliyor; farklı bir yol denemekten çekinme.',
        ],
      },
    ),
    6: GunTemasi(
      istek: 'sorumluluk almak ve sevdiklerine özen göstermek',
      durum: <GunTonu, List<String>>{
        GunTonu.dusuk: <String>[
          '{isim}, bugün başkalarının ihtiyaçları ve sorumluluklar omzuna olduğundan fazla binebilir.',
          'Bugün ev, aile ya da yakın çevrenle ilgili küçük gerginlikler yaşanabilir.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün sevdiklerinle ilgilenmek ve yaşadığın alanı düzenlemek seni rahatlatacak.',
          'Bugün yakınlarına göstereceğin küçük bir ilgi beklediğinden çok karşılık bulur.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün yakın ilişkilerin güçlendiği, sevgi ve desteğin karşılıklı aktığı bir gün.',
          'Bugün aile, ev ve yakın ilişkiler konusunda güzel gelişmelere açık bir gün.',
        ],
      },
    ),
    7: GunTemasi(
      istek: 'yavaşlamak ve kendi iç sesini dinlemek',
      durum: <GunTonu, List<String>>{
        GunTonu.dusuk: <String>[
          '{isim}, bugün zihnin yorgun ve kalabalıktan çabuk sıkılabilirsin.',
          'Bugün kafanda kurduğun senaryolar gerçekte olduğundan daha büyük görünebilir.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün biraz yavaşlamak, düşünmek ve kendine vakit ayırmak seni toparlayacak.',
          'Bugün bir konuyu derinlemesine incelemek ya da bir şey öğrenmek için zihnin hazır.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün sezgilerin güçlü; uzun süredir düşündüğün bir konuda netlik bulabilirsin.',
          'Bugün öğrenmek, araştırmak ve kendinle baş başa kalmak sana beklediğinden fazlasını kazandırır.',
        ],
      },
    ),
    8: GunTemasi(
      istek: 'net kararlar almak ve somut sonuç peşinde koşmak',
      durum: <GunTonu, List<String>>{
        GunTonu.dusuk: <String>[
          '{isim}, bugün iş ve para konularında engeller öne çıkabilir; aceleyle karar vermemek seni korur.',
          'Bugün kontrol edemediğin şeyler seni gerebilir; zorlamak yerine hesaplı hareket etmek daha doğru.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün net bir hedef belirleyip ona odaklandığında sonuç almak mümkün.',
          'Bugün iş ve para konularını gözden geçirip önceliklerini netleştirmenin tam zamanı.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün emeğinin karşılığını istemek, bir görüşme yapmak ya da önemli bir karar almak için güçlü bir gün.',
          'Bugün kararlılığın ve netliğin sonuç getiriyor; sorumluluk almaktan çekinme.',
        ],
      },
    ),
    9: GunTemasi(
      istek: 'bir şeyi tamamlamak ve artık gerekmeyeni bırakmak',
      durum: <GunTonu, List<String>>{
        GunTonu.dusuk: <String>[
          '{isim}, bugün eski konular ya da kırgınlıklar yeniden aklına gelebilir.',
          'Bugün bir şeyin bitmesi ya da istediğin gibi sonuçlanmaması canını sıkabilir.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün yarım kalan işleri bitirip gereksiz yüklerden hafiflemenin zamanı.',
          'Bugün yeni bir şeye başlamaktan çok elindekileri tamamlamak seni rahatlatacak.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün uzun süredir uğraştığın bir konunun güzelce sonuçlanabileceği bir gün.',
          'Bugün affetmek, rahatlamak ve bir sayfayı kapatmak her zamankinden kolay.',
        ],
      },
    ),
  };

  /// Buluşma türüne göre "bu gün seninle nasıl buluşuyor" cümleleri.
  ///
  /// Her gün kullanıldıkları için tür başına en az
  /// [ContentConfig.enAzBulusmaVaryanti] varyant vardır.
  static const Map<BulusmaTuru, List<String>>
  bulusmaCumleleri = <BulusmaTuru, List<String>>{
    BulusmaTuru.uyumlu: <String>[
      'Günün senden istediği şey, yani {gunIstegi}, zaten doğanda var; bu yüzden gün sana ağır değil, tanıdık gelecek.',
      'Doğanda {doga} olduğu için günün temposuna kolayca uyum sağlarsın; başkalarının zorlandığı yerde sen rahat olabilirsin.',
      'Gün tam da senin dilinden konuşuyor: {gunIstegi}. Bu, en iyi yaptığın şeyi göstermen için bir alan.',
      'Bu tür günlerde rahat edersin, çünkü {gunIstegi} senin için çaba değil, alışkanlık.',
      'Sende zaten var olan {doga} eğilimi günün ritmiyle aynı yönde akıyor; zorlamadan ilerleyebilirsin.',
    ],
    BulusmaTuru.dengeli: <String>[
      'Öne çıkan şey {gunIstegi}; bu senin ilk tercihin olmasa da doğandaki {doga} isteğini güzelce tamamlayabilir.',
      'Senden {gunIstegi} bekleniyor; bunu kendi tarzınla, yani {doga} yoluyla yaparsan gün dengeli ve verimli geçer.',
      'Gün sana alışık olduğundan biraz farklı bir şey öneriyor: {gunIstegi}. Kendi doğanla birleştirdiğinde ortaya iyi bir karışım çıkar.',
      'Senin doğan {doga} yönünde çalışıyor, gün ise {gunIstegi} istiyor; ikisi çatışmıyor, birbirini tamamlıyor.',
      'Alışık olduğun ritimle günün ritmi arasında küçük bir fark var; bu fark sana yeni bir bakış açısı kazandırabilir.',
    ],
    BulusmaTuru.zorlayici: <String>[
      'Senin doğanda {doga} var; gün ise senden {gunIstegi} istiyor. Bu yüzden gün boyunca hafif bir sürtünme hissedersen şaşırma.',
      'Senden {gunIstegi} bekleniyor, oysa senin rahat ettiğin alan {doga}. Ritmin biraz zorlanabilir; bu kötü bir gün değil, farklı bir gün.',
      'Gün, alışık olduğun yoldan biraz uzak bir şey istiyor: {gunIstegi}. Bazı anlarda kendini yavaşlamış ya da sabırsız hissedebilirsin.',
      'Doğal eğilimin {doga} olsa da gün başka bir kasını çalıştırmanı istiyor; zor gelen kısım aynı zamanda seni büyüten kısım.',
      'Günün ritmi senin içgüdülerinle tam örtüşmüyor; bunu bilmek küçük aksiliklere daha sakin bakmanı sağlar.',
    ],
  };

  /// Günün temasının kişinin gündelik hayatında nerede görüneceği
  /// (tema × uğraş). Anahtar: [Ugras.name] ya da [genelAnahtar].
  ///
  /// Her temanın iki varyantı farklı cümle kalıpları kullanır; aynı
  /// uğraştaki okur, tema ve varyant değiştikçe farklı bir yapı okur.
  /// Varyantlar kişisel gün adımıyla döner (tema ~9 günde bir gelir).
  static const Map<int, Map<String, List<String>>>
  gunSahneleri = <int, Map<String, List<String>>>{
    1: <String, List<String>>{
      'calisiyor': <String>[
        'İş tarafında bu, yeni bir görev üstlenmek ya da bir öneri sunmakla başlayabilir.',
        'Toplantıda ilk söz alan ya da yeni bir fikri masaya koyan sen olabilirsin.',
      ],
      'ogrenci': <String>[
        'Derslerinde bu, yeni bir konuya ya da yeni bir çalışma düzenine geçmekle kendini gösterebilir.',
        'Uzun süredir ertelediğin bir konuya giriş yapmak sana hız kazandırabilir.',
      ],
      'isArayan': <String>[
        'İş arayışında bu, yeni bir başvuru yapmak ya da daha önce denemediğin bir alana bakmakla başlayabilir.',
        'Daha önce çekindiğin bir şirkete ya da kişiye ilk mesajı atmak sana cesaret verebilir.',
      ],
      'girisimci': <String>[
        'İşinde bu, aklındaki yeni bir fikri denemek ya da ilk kez bir müşteriyle görüşmekle kendini gösterebilir.',
        'Kafandaki yeni ürün ya da hizmet fikrinin ilk taslağını çıkarmak için içinde bir istek var.',
      ],
      'evde': <String>[
        'Evde bu, uzun süredir düşündüğün bir değişikliğe ya da kendine ait yeni bir alışkanlığa başlamakla kendini gösterebilir.',
        'Evde yeni bir düzen ya da yeni bir hobi için ilk malzemeyi almak güzel bir başlangıç olabilir.',
      ],
      'genel': <String>[
        'Pratikte bu, uzun süredir ertelediğin bir işe ilk adımı atmakla başlayabilir.',
        'Küçük de olsa yeni bir şeyin ilk adımını atmak gününe yön verebilir.',
      ],
    },
    2: <String, List<String>>{
      'calisiyor': <String>[
        'İş tarafında bunun karşılığı, bir iş arkadaşınla birlikte çalışmak ya da gergin bir konuyu nazikçe konuşmak olabilir.',
        'Bir iş arkadaşının fikrini önemsediğini göstermek ekipteki havayı yumuşatabilir.',
      ],
      'ogrenci': <String>[
        'Derslerinde bunun karşılığı, bir arkadaşınla birlikte çalışmak ya da takıldığın bir konuyu birine sormak olabilir.',
        'Bir grup çalışmasında fikirleri bir araya getiren kişi olmak sana iyi bir rol kazandırabilir.',
      ],
      'isArayan': <String>[
        'İş arayışında bunun karşılığı, tanıdıklarından destek istemek ya da bir referans rica etmek olabilir.',
        'Bir görüşmede karşındakini dikkatle dinlemek, konuşmaktan daha çok etki bırakabilir.',
      ],
      'girisimci': <String>[
        'İşinde bunun karşılığı, bir ortak, tedarikçi ya da müşteriyle anlaşma zemini aramak olabilir.',
        'Bir müşterinin ya da ortağın gerçekte ne istediğini sormak yeni bir anlaşmanın kapısını aralayabilir.',
      ],
      'evde': <String>[
        'Evde bunun karşılığı, bir konuyu birlikte konuşup ortak karar almak olabilir.',
        'Ev halkıyla birlikte yapılacak küçük bir iş aranızdaki uyumu güçlendirebilir.',
      ],
      'genel': <String>[
        'Gündelik hayatta bunun karşılığı, bir konuyu tek başına çözmeye çalışmak yerine birinden destek istemek olabilir.',
        'Birini dinlemek için ayıracağın birkaç dakika aranızdaki bağı sandığından çok güçlendirebilir.',
      ],
    },
    3: <String, List<String>>{
      'calisiyor': <String>[
        'Bunu en çok bir fikrini paylaşırken, sunum yaparken ya da ekiple konuşurken fark edebilirsin.',
        'Bir e-postada ya da toplantıda fikrini net ve sıcak bir dille anlatman fark yaratabilir.',
      ],
      'ogrenci': <String>[
        'Bunu en çok bir sunumda, grup çalışmasında ya da yaratıcı bir ödevde fark edebilirsin.',
        'Derste soru sormak ya da bir tartışmaya katılmak düşündüğünden daha çok dikkat çekebilir.',
      ],
      'isArayan': <String>[
        'Bunu en çok özgeçmişini güncellerken ya da çevrene ne aradığını anlatırken fark edebilirsin.',
        'Kendini anlatan kısa bir tanıtım cümlesi hazırlamak görüşmelerde işine yarayabilir.',
      ],
      'girisimci': <String>[
        'Bunu en çok işini tanıtırken, paylaşım yaparken ya da yeni insanlarla tanışırken fark edebilirsin.',
        'Müşterilerine işinin hikâyesini anlatmak reklamdan daha çok etki bırakabilir.',
      ],
      'evde': <String>[
        'Bunu en çok arkadaşlarla görüşürken ya da yaratıcı bir uğraşa vakit ayırırken fark edebilirsin.',
        'Bir arkadaşını arayıp uzun uzun sohbet etmek ya da bir şey üretmek ruhunu canlandırabilir.',
      ],
      'genel': <String>[
        'Bunu en çok bir arkadaşınla konuşurken ya da seni ifade eden bir işe vakit ayırırken fark edebilirsin.',
        'Bir duygunu ya da fikrini söze dökmek içindeki enerjiyi açığa çıkarabilir.',
      ],
    },
    4: <String, List<String>>{
      'calisiyor': <String>[
        'Somut bir başlangıç: biriken e-postaları, dosyaları ya da yarım işleri toparlamak.',
        'Yapılacaklar listeni sıraya koymak ve bir işi baştan sona bitirmek sana kontrol hissi verebilir.',
      ],
      'ogrenci': <String>[
        'Somut bir başlangıç: notlarını düzenlemek, bir çalışma planı yapmak ya da ertelediğin ödevi bitirmek.',
        'Haftalık bir ders programı çıkarmak kafandaki dağınıklığı toparlayabilir.',
      ],
      'isArayan': <String>[
        'Somut bir başlangıç: başvurularını bir listeye dökmek ve düzenli bir arama planı yapmak.',
        'Her gün aynı saatte ilanlara bakmak gibi küçük bir düzen süreci daha az yorucu hâle getirebilir.',
      ],
      'girisimci': <String>[
        'Somut bir başlangıç: hesapları, süreçleri ve yapılacaklar listesini düzene koymak.',
        'Bir süreci yazıya dökmek ya da bir şablon hazırlamak ileride zaman kazandırabilir.',
      ],
      'evde': <String>[
        'Somut bir başlangıç: evde bir köşeyi düzenlemek ya da haftanın planını çıkarmak.',
        'Bir dolabı ya da çekmeceyi düzenlemek zihnindeki dağınıklığı da toparlayabilir.',
      ],
      'genel': <String>[
        'Somut bir başlangıç: masandaki, telefonundaki ya da aklındaki birikmiş işleri toparlamak.',
        'Küçük bir düzen kurmak kafandaki kalabalığı da sadeleştirebilir.',
      ],
    },
    5: <String, List<String>>{
      'calisiyor': <String>[
        'İşte bir yöntemi değiştirmek ya da farklı bir görevde yer almak zihnini tazeleyebilir.',
        'Plan dışı bir görev ya da beklenmedik bir talep sana yeni bir beceri kazandırabilir.',
      ],
      'ogrenci': <String>[
        'Çalışma yerini ya da yöntemini değiştirmek dikkatini tazeleyebilir.',
        'Farklı bir kaynaktan ya da yöntemle çalışmak zor bir konuyu çözmeni kolaylaştırabilir.',
      ],
      'isArayan': <String>[
        'Daha önce düşünmediğin bir sektöre ya da pozisyona göz atmak arayışına yeni bir yön verebilir.',
        'Esnek ya da uzaktan çalışma seçeneklerine bakmak sana yeni kapılar gösterebilir.',
      ],
      'girisimci': <String>[
        'Ürününde ya da yaklaşımında küçük bir değişiklik denemek işine taze bir soluk getirebilir.',
        'Yeni bir satış kanalı ya da iş birliği fikri denemek işine hareket getirebilir.',
      ],
      'evde': <String>[
        'Rutinin dışına çıkmak, kısa bir gezinti yapmak ya da yeni bir tarif denemek evdeki günü tazeleyebilir.',
        'Eşyaların yerini değiştirmek ya da yakında yeni bir mekân keşfetmek gününe hareket katabilir.',
      ],
      'genel': <String>[
        'Rutinin dışına çıkmak, farklı bir yoldan gitmek ya da yeni bir şey denemek zihnini tazeleyebilir.',
        'Alışık olmadığın bir şeye evet demek gününe beklenmedik bir renk katabilir.',
      ],
    },
    6: <String, List<String>>{
      'calisiyor': <String>[
        'Bir iş arkadaşına yardım etmek ya da ekipte bir sorumluluğu üstlenmek küçük ama anlamlı bir adım olabilir.',
        'Ekipte yükü ağır olan birine el uzatmak iş ortamındaki güveni büyütebilir.',
      ],
      'ogrenci': <String>[
        'Bir arkadaşına ders konusunda yardım etmek ya da ailene vakit ayırmak küçük ama anlamlı bir adım olabilir.',
        'Evde ya da yurtta ortak alan için küçük bir sorumluluk almak çevrene iyi hissettirebilir.',
      ],
      'isArayan': <String>[
        'Bu süreçte seni destekleyen insanlarla vakit geçirip moral toplamak küçük ama anlamlı bir adım olabilir.',
        'Ailenle ya da yakın bir arkadaşınla süreci paylaşmak yükünü hafifletebilir.',
      ],
      'girisimci': <String>[
        'Müşterilerinle ya da ekibinle ilgilenip onların ihtiyaçlarını dinlemek küçük ama anlamlı bir adım olabilir.',
        'Ekibine ya da müşterine gösterdiğin özen işinin en güçlü reklamı olabilir.',
      ],
      'evde': <String>[
        'Ev ve aile için yapacağın küçük bir güzellik sandığından anlamlı bir adım olabilir.',
        'Sıcak bir sofra ya da birlikte geçirilen bir akşam evin havasını değiştirebilir.',
      ],
      'genel': <String>[
        'Bir yakınını aramak ya da evde küçük bir düzenleme yapmak küçük ama anlamlı bir adım olabilir.',
        'Sevdiğin birine küçük bir iyilik yapmak sana da huzur verebilir.',
      ],
    },
    7: <String, List<String>>{
      'calisiyor': <String>[
        'Kalabalık toplantılardan çok, odaklanarak tek başına yürüttüğün işler sana daha çok şey kazandırır.',
        'Bir sorunu çözmek için kalabalıktan uzaklaşıp tek başına düşünmek sana netlik kazandırabilir.',
      ],
      'ogrenci': <String>[
        'Sessiz bir ortamda zor bir konuyu gerçekten anlamaya çalışmak sana beklediğinden fazlasını kazandırır.',
        'Ezberlemek yerine bir konunun mantığını kavramaya çalışmak sana kalıcı bir kazanç sağlayabilir.',
      ],
      'isArayan': <String>[
        'Hangi işi gerçekten istediğini düşünmek ve bir alanda kendini geliştirmek arayışını netleştirir.',
        'Güçlü yanlarını bir kâğıda dökmek hangi işe yöneleceğini netleştirebilir.',
      ],
      'girisimci': <String>[
        'Verileri incelemek, araştırma yapmak ve stratejini gözden geçirmek işine yön verir.',
        'Rakiplerini ya da pazarını sakin kafayla incelemek sana yeni bir bakış açısı kazandırabilir.',
      ],
      'evde': <String>[
        'Kendine sessiz bir saat ayırmak, kitap okumak ya da yürüyüş yapmak seni beklediğinden çok toparlar.',
        'Telefonsuz geçirilen sakin bir saat zihnini dinlendirebilir.',
      ],
      'genel': <String>[
        'Kendine sessiz bir zaman ayırmak ya da ilgini çeken bir konuyu araştırmak zihnini berraklaştırır.',
        'Aklını kurcalayan bir soruya yazarak cevap aramak düşüncelerini netleştirebilir.',
      ],
    },
    8: <String, List<String>>{
      'calisiyor': <String>[
        'Odaklanabileceğin şey belli: bir talebini dile getirmek, sorumluluk istemek ya da önemli bir görüşmeyi yapmak.',
        'Hedeflerini yöneticinle ya da ekibinle netleştirmek emeğinin görünür olmasını sağlayabilir.',
      ],
      'ogrenci': <String>[
        'Odaklanabileceğin şey belli: hedeflerini netleştirmek ve sınav ya da proje takvimini ciddi bir plana bağlamak.',
        'Notlarını ve hedeflerini gözden geçirip gerçekçi bir başarı planı yapmak motivasyonunu artırabilir.',
      ],
      'isArayan': <String>[
        'Odaklanabileceğin şey belli: görüşmelere hazırlanmak ve beklentini netleştirmek.',
        'Maaş ve çalışma koşulları konusunda beklentini netleştirmek görüşmelerde elini güçlendirebilir.',
      ],
      'girisimci': <String>[
        'Odaklanabileceğin şey belli: fiyatlandırma, tahsilat ya da büyüme kararlarını ele almak.',
        'Gelir ve giderlerine kısa bir bakış atmak sana daha güçlü kararlar aldırabilir.',
      ],
      'evde': <String>[
        'Odaklanabileceğin şey belli: ev bütçesini gözden geçirmek ve maddi bir kararı netleştirmek.',
        'Ev için uzun vadeli bir hedef belirleyip ilk adımını planlamak sana güç verebilir.',
      ],
      'genel': <String>[
        'Odaklanabileceğin şey belli: maddi konularını gözden geçirmek ve bir hedefi netleştirmek.',
        'Bir hedefi yazıya dökmek ve ona bir tarih vermek kararlılığını artırabilir.',
      ],
    },
    9: <String, List<String>>{
      'calisiyor': <String>[
        'Yarım kalan bir işi teslim etmek ya da artık işine yaramayan bir yükü bırakmak içini rahatlatabilir.',
        'Bitmiş bir projeyi gözden geçirip ondan ne öğrendiğini not etmek seni bir sonraki işe hazırlar.',
      ],
      'ogrenci': <String>[
        'Bir konuyu tamamlamak ya da eski notları ayıklamak içini rahatlatabilir.',
        'Biten bir dönemi ya da sınavı geride bırakıp yeni hedefe odaklanmak sana hafiflik verebilir.',
      ],
      'isArayan': <String>[
        'Olmayan bir başvuruyu geride bırakıp enerjini yeni seçeneklere çevirmek içini rahatlatabilir.',
        'Sonuçlanmayan bir süreçten ders çıkarıp sayfayı çevirmek yeni fırsatlara yer açabilir.',
      ],
      'girisimci': <String>[
        'Kazandırmayan bir işi ya da süreci sonlandırmayı düşünmek içini rahatlatabilir.',
        'Artık işine yaramayan bir ürünü ya da hizmeti bırakmak enerjini yeni fırsatlara yönlendirebilir.',
      ],
      'evde': <String>[
        'Kullanmadığın eşyaları ayıklamak ya da bir konuyu kapatmak içini rahatlatabilir.',
        'Evde uzun zamandır duran bir eşyayı ihtiyacı olan birine vermek seni hafifletebilir.',
      ],
      'genel': <String>[
        'Yarım kalan bir işi bitirmek ya da artık gerekmeyen bir şeyi bırakmak içini rahatlatabilir.',
        'Sana artık iyi gelmeyen bir alışkanlığa veda etmek yeni bir sayfa açabilir.',
      ],
    },
  };

  /// Uğraşı bilinmeyen okuyucu için sahne anahtarı.
  static const String genelAnahtar = 'genel';

  /// Yaşam yolu karakterleri (1-9, 11, 22, 33).
  static const Map<int, KarakterYonu> karakterler = KarakterYonleri.hepsi;

  /// Kategori × kişinin durumu × ton: o alanda bugün ne oluyor.
  ///
  /// Durum anahtarı [durumAnahtari] ile bulunur; her kategoride
  /// [genelAnahtar] her zaman vardır.
  static const Map<LuckCategory, Map<String, Map<KategoriTonu, List<String>>>>
  kategoriDurumlari = KategoriDurumlari.hepsi;

  /// Günün temasının her kategoriye etkisi (tema × kategori).
  static const Map<int, Map<LuckCategory, String>>
  temaKategori = <int, Map<LuckCategory, String>>{
    1: <LuckCategory, String>{
      LuckCategory.ask:
          'Başlangıç enerjisi aşkta yeni bir tanışmaya ya da ilişkinde yeni bir sayfaya kapı aralıyor.',
      LuckCategory.para:
          'Yeni bir gelir fikrini ya da birikim alışkanlığını başlatmak için zemin hazır.',
      LuckCategory.saglik:
          'Yeni bir spora ya da sağlıklı bir alışkanlığa başlamak için içinde bir kıpırtı var.',
      LuckCategory.risk: 'İlk adımı atma cesaretin her zamankinden yüksek.',
      LuckCategory.sosyal: 'Yeni insanlarla tanışmak bu sefer daha kolay.',
    },
    2: <LuckCategory, String>{
      LuckCategory.ask:
          'Sabır ve anlayış isteyen konuşmalar aşkta daha yumuşak ilerliyor.',
      LuckCategory.para:
          'Ortaklık, anlaşma ve pazarlıklarda uzlaşmacı tavrın işine yarar.',
      LuckCategory.saglik:
          'Sakin tempo bedenine dinlenme ve denge fırsatı veriyor.',
      LuckCategory.risk:
          'Aceleci risklerden çok beklemenin kazandırdığı bir zamandasın.',
      LuckCategory.sosyal:
          'Barışmak, arabuluculuk yapmak ya da bir kırgınlığı onarmak kolaylaşıyor.',
    },
    3: <LuckCategory, String>{
      LuckCategory.ask:
          'Hislerini söze dökmek aşkta kolaylaşıyor; tek bir mesaj bile bağını ısıtabilir.',
      LuckCategory.para:
          'Kendini ya da işini tanıtmak, görünür olmak maddi tarafa da yansıyor.',
      LuckCategory.saglik:
          'Keyif aldığın bir hareket, zorunlu bir egzersizden daha çok enerji verir.',
      LuckCategory.risk:
          'Heyecan seni hevesle karar vermeye itebilir; bir gece beklemek zarar vermez.',
      LuckCategory.sosyal:
          'Paylaşma isteğin sosyal ortamlarda seni öne çıkarıyor.',
    },
    4: <LuckCategory, String>{
      LuckCategory.ask:
          'Aşkta güven veren, istikrarlı adımlar daha çok karşılık buluyor.',
      LuckCategory.para:
          'Bütçe, fatura ve birikim gibi somut işler için zihnin net.',
      LuckCategory.saglik:
          'Uyku ve beslenme rutinini oturtmak için iyi bir fırsat var.',
      LuckCategory.risk:
          'Plansız risklerden çok hesaplı adımlar ödüllendiriliyor.',
      LuckCategory.sosyal:
          'Sosyal planlarını netleştirmek ve verdiğin sözleri tutmak öne çıkıyor.',
    },
    5: <LuckCategory, String>{
      LuckCategory.ask: 'Aşkta sürprizler ve rutinden çıkmak gündemde.',
      LuckCategory.para:
          'Beklenmedik bir fırsat ya da harcama kapıyı çalabilir.',
      LuckCategory.saglik:
          'Yeni bir aktivite denemek bedenini de zihnini de canlandırır.',
      LuckCategory.risk:
          'Risk cazip görünebilir; sınırını baştan koymak önemli.',
      LuckCategory.sosyal: 'Yeni ortamlar ve tanışmalar için kapılar açık.',
    },
    6: <LuckCategory, String>{
      LuckCategory.ask: 'Özen, ilgi ve bağlılık aşkta her zamankinden değerli.',
      LuckCategory.para:
          'Aile ve ev giderleri gündemin üst sıralarına çıkabilir.',
      LuckCategory.saglik:
          'Kendine iyi bakmayı hatırlamak için güzel bir zaman.',
      LuckCategory.risk:
          'Sevdiklerini etkileyecek kararlarda temkinli olmak akıllıca.',
      LuckCategory.sosyal:
          'Yakınlarınla bağlarını güçlendirmek için doğal bir sıcaklık var.',
    },
    7: <LuckCategory, String>{
      LuckCategory.ask:
          'Aşkta önce kendi duygularını anlamaya vakit ayırmak işe yarar.',
      LuckCategory.para:
          'Araştırma ve dikkatli değerlendirme maddi kararlarında seni korur.',
      LuckCategory.saglik: 'Zihinsel dinlenme ve uyku önceliğin olmalı.',
      LuckCategory.risk:
          'Riskleri incelemek için doğru zaman; ani adımlar için değil.',
      LuckCategory.sosyal:
          'Kalabalık yerine az ve derin sohbetler öne çıkıyor.',
    },
    8: <LuckCategory, String>{
      LuckCategory.ask:
          'Net konuşmak ve ilişkinin yönünü belirlemek aşkta kolaylaşıyor.',
      LuckCategory.para: 'Kazanç, tahsilat ve pazarlık konularında elin güçlü.',
      LuckCategory.saglik:
          'Yoğun tempo seni çok çalışmaya itebilir; stresini boşaltmayı ihmal etme.',
      LuckCategory.risk: 'Hesaplı risklerde kararlılığın işine yarıyor.',
      LuckCategory.sosyal: 'Sosyal ortamlarda sözünün dinlenmesi kolaylaşıyor.',
    },
    9: <LuckCategory, String>{
      LuckCategory.ask:
          'Aşkta eski bir konuyu kapatmak ya da affetmek için zemin hazır.',
      LuckCategory.para:
          'Bir borcu kapatmak ya da yarım kalan bir ödemeyi bitirmek rahatlatıcı olabilir.',
      LuckCategory.saglik:
          'Seni yoran bir alışkanlığı bırakmak için içinden bir istek geliyor.',
      LuckCategory.risk:
          'Yeni risklerden çok eldeki işleri bitirmek daha çok kazandırıyor.',
      LuckCategory.sosyal:
          'Seni yoran bir ilişkiye mesafe koymak artık daha kolay.',
    },
  };

  /// Kişisel yıla göre yorumun sonundaki "bu dönem" cümlesi (sayı yok).
  static const Map<int, List<String>> donemCumleleri = <int, List<String>>{
    1: <String>[
      'Genel olarak yeni başlangıçların dönemindesin; attığın küçük adımlar önümüzdeki aylara yön veriyor.',
      'Bu yıl hayatında yeni bir sayfa açılıyor; cesur ama sabırlı olmak sana çok şey kazandırır.',
      'Önündeki aylar yeni başlangıçlara açık; şimdi ektiğin tohumlar yıl boyunca filizlenebilir.',
      'Bu yıl önceliğin kendi yolunu çizmek; başkalarının onayını beklemeden atılan adımlar daha çok kazandırıyor.',
    ],
    2: <String>[
      'Genel olarak ilişkilerin ve sabrın öne çıktığı bir dönemdesin; sonuçlar yavaş gelse de temeller sağlamlaşıyor.',
      'Bu yıl tek başına koşmak yerine birlikte ilerlemenin kazandırdığı bir dönemdesin.',
      'Yıl boyunca acele etmeyen, ilişkilerine emek veren taraf kazanıyor; senin için de öyle.',
      'İçinde bulunduğun yıl sabrı ödüllendiriyor; aceleye getirilmeyen işler daha sağlam sonuçlanıyor.',
    ],
    3: <String>[
      'Genel olarak kendini ifade etmenin ve çevreni genişletmenin dönemindesin; kurduğun bir bağlantı ileride işine yarayabilir.',
      'Bu yıl yaratıcılığın ve sosyal hayatın canlandığı bir dönemdesin; enerjini dağıtmadan kullanmak önemli.',
      'Bu dönemin anahtarı kendini ifade etmek; sesini ne kadar duyurursan kapılar o kadar açılıyor.',
      'Yıl boyunca çevrenin genişlemesi sürpriz fırsatlar getirebilir; yeni tanışmalara açık ol.',
    ],
    4: <String>[
      'Genel olarak emek verip sağlam temeller kurduğun bir dönemdesin; düzenli çaban uzun vadede karşılığını verecek.',
      'Bu yıl çalışmanın ve istikrarın ön planda olduğu bir dönemdesin; yorulduğunda kurduğun yapının değerini hatırla.',
      'İçinde bulunduğun yıl bir inşa yılı; yorucu ama kalıcı.',
      'Bu yıl attığın her düzenli adım, gelecek yıllar için bir temel taşı oluyor.',
    ],
    5: <String>[
      'Genel olarak değişimlerin ve yeni deneyimlerin dönemindesin; esnek kaldıkça fırsatlar çoğalıyor.',
      'Bu yıl hayatında hareketin arttığı bir dönemdesin; aceleci kararlar yerine bilinçli değişimler kazandırır.',
      'Bu yılın ritmi hızlı ve değişken; esnek kalmak en büyük gücün.',
      'Bu yıl kalıplarını esnetmek için bir fırsat; denediğin her yeni şey ufkunu biraz daha açıyor.',
    ],
    6: <String>[
      'Genel olarak aile, ev ve yakın ilişkilerin öne çıktığı bir dönemdesin; verdiğin emek sevdiklerinle bağında karşılık buluyor.',
      'Bu yıl sorumlulukların arttığı bir dönemdesin; başkalarına verirken kendini ihmal etmemek önemli.',
      'Bu dönemde evin, ailen ve yakın ilişkilerin hayatının merkezine yerleşiyor.',
      'Yıl boyunca sevgi ve sorumluluk dengesi gündeminde; ikisini birlikte taşımayı öğreniyorsun.',
    ],
    7: <String>[
      'Genel olarak içe dönmenin, öğrenmenin ve kendini tanımanın dönemindesin; sessiz geçen zamanlar sana yön kazandırıyor.',
      'Bu yıl düşünmenin ve derinleşmenin önemli olduğu bir dönemdesin; hızdan çok anlam arayışı kazandırıyor.',
      'Bu yıl kendinle yeniden tanıştığın bir dönem; sessizliğin içinde önemli cevaplar var.',
      'İçinde bulunduğun yıl hız değil derinlik istiyor; öğrendiklerin uzun süre işine yarayabilir.',
    ],
    8: <String>[
      'Genel olarak iş, para ve kariyer konularının öne çıktığı bir dönemdesin; kararlı adımların karşılık bulma ihtimali yüksek.',
      'Bu yıl emeğinin karşılığını alabileceğin bir dönemdesin; hedeflere odaklanırken dengeyi korumak önemli.',
      'İçinde bulunduğun yıl bir hasat yılı gibi; emek verdiğin konularda somut sonuçlar görmek mümkün.',
      'Bu yıl hedeflerin büyüyebilir; güçlü durmakla esnek kalmak arasındaki dengeyi korumak önemli.',
    ],
    9: <String>[
      'Genel olarak kapanışların ve ayıklamanın dönemindesin; bir şeyi tamamlamak ya da bırakmak içini rahatlatacak.',
      'Bu yıl artık sana iyi gelmeyenleri geride bıraktığın bir dönemdesin; hafifledikçe yeni başlangıçlara yer açılıyor.',
      'Bu yıl bir döngünün son halkası; kapanan her kapı yeni başlangıçlara yer açıyor.',
      'Yıl boyunca eski sayfalar kapanıyor; geride bıraktıkların yeni bir başlangıca hazırlık.',
    ],
  };

  /// Kişisel aya göre yorumun sonundaki "bu ay" cümlesi (sayı yok).
  ///
  /// Kapanış havuzu dönem ve ay cümlelerinin birleşimidir; kişisel ay her
  /// takvim ayında değiştiği için kapanış yıl boyunca aynı birkaç cümlede
  /// takılı kalmaz.
  static const Map<int, List<String>> ayCumleleri = <int, List<String>>{
    1: <String>[
      'Bu ay yeni bir şeye başlamak için içinde bir kıpırtı var; küçük de olsa ilk adım önemli.',
      'Bu ayın havası taze başlangıçlardan yana; ertelenen bir planı yeniden masaya koyabilirsin.',
      'Önündeki haftalar inisiyatif alanı ödüllendiriyor; beklemek yerine harekete geç.',
      'Bu ayın sonunda geriye baktığında başlattığın bir şeyle gurur duyabilirsin.',
    ],
    2: <String>[
      'Bu ay işler biraz yavaş ilerleyebilir; sabır ve iş birliği sana en çok kazandıracak şeyler.',
      'Bu ayın havası ilişkilerden yana; yakınlaşmalar ve uzlaşmalar ön planda.',
      'Önündeki haftalarda duyguların daha hassas olabilir; kendine ve sevdiklerine nazik davran.',
      'Bu ay tek başına hızlanmaktansa doğru kişiyle yan yana yürümek daha çok kazandırıyor.',
    ],
    3: <String>[
      'Bu ay sosyal hayatın canlanıyor; davetlere ve yeni bağlantılara açık ol.',
      'Bu ayın havası yaratıcılıktan yana; aklındaki fikri paylaşmak için iyi bir dönem.',
      'Önündeki haftalarda sözlerin her zamankinden etkili; ne söylediğin kadar nasıl söylediğin de önemli.',
      'Bu ay kendini göstermekten çekinme; görünür oldukça fırsatlar da seni buluyor.',
    ],
    4: <String>[
      'Bu ay emek ve düzen ayı; dağınık işleri toparlamak sana büyük rahatlık verebilir.',
      'Bu ayın havası sağlam adımlardan yana; kısa yollar yerine adım adım ilerlemek kazandırır.',
      'Önündeki haftalar yoğun geçebilir; dinlenmeyi de planının bir parçası yap.',
      'Bu ay sabırla sürdürdüğün çaba, ay sonunda somut bir ilerlemeye dönüşebilir.',
    ],
    5: <String>[
      'Bu ay hareketli geçebilir; plan değişikliklerine karşı esnek kalmak işini kolaylaştırır.',
      'Bu ayın havası değişimden yana; yeni bir deneyim ya da kısa bir kaçamak seni tazeleyebilir.',
      'Önündeki haftalarda beklenmedik fırsatlar çıkabilir; hızlı ama düşünerek karar ver.',
      'Bu ay rutin dışı bir karar sana yeni bir pencere açabilir.',
    ],
    6: <String>[
      'Bu ay ev, aile ve yakın ilişkiler gündeminde; verdiğin özen karşılık bulabilir.',
      'Bu ayın havası sorumluluklardan yana; yük paylaştıkça hafifler.',
      'Önündeki haftalarda birine destek olmak sana da anlam katabilir.',
      'Bu ay bir sevdiğinle aranızdaki bağ küçük ilgilerle güçlenebilir.',
    ],
    7: <String>[
      'Bu ay içe dönmek ve düşünmek için zaman ayırmak sana yön verebilir.',
      'Bu ayın havası öğrenmekten ve araştırmaktan yana; merak ettiğin bir konuyu derinleştir.',
      'Önündeki haftalarda kalabalıktan çok sessizlik seni besleyebilir.',
      'Bu ay cevap aradığın bir soruya beklemediğin bir anda netlik gelebilir.',
    ],
    8: <String>[
      'Bu ay iş ve para konuları öne çıkıyor; net hedefler koymak sonuç almanı kolaylaştırır.',
      'Bu ayın havası kararlılıktan yana; emeğinin karşılığını istemekten çekinme.',
      'Önündeki haftalarda sorumluluklar artabilir; önceliklerini netleştirmek seni rahatlatır.',
      'Bu ay maddi ve mesleki konularda attığın net adımlar karşılık bulabilir.',
    ],
    9: <String>[
      'Bu ay kapanışlar ayı; yarım kalan işleri bitirmek içini rahatlatabilir.',
      'Bu ayın havası bırakmaktan yana; artık işine yaramayan bir alışkanlığa veda edebilirsin.',
      'Önündeki haftalarda geçmişle ilgili konular gündeme gelebilir; onlara bir nokta koymak hafifletir.',
      'Bu ay bir şeyi bitirmenin verdiği hafiflik yeni aya enerjiyle girmeni sağlayabilir.',
    ],
  };

  /// Kişisel yıl ve aya göre kapanış cümlesi havuzu (dönem + ay).
  static List<String> kapanisHavuzu(int kisiselYil, int kisiselAy) => <String>[
    ...donemCumleleri[kisiselYil]!,
    ...ayCumleleri[kisiselAy]!,
  ];

  /// Okuyucunun durumuna göre [kategori] durum anahtarı.
  ///
  /// Aşk: ilişki durumu; para: uğraş; risk: karar tarzı; sosyal: enerji
  /// tarzı; sağlık: her zaman genel. Bilinmeyen durumda [genelAnahtar].
  static String durumAnahtari(LuckCategory kategori, OkuyucuTercihleri t) {
    final String? anahtar = switch (kategori) {
      LuckCategory.ask =>
        t.iliski == null
            ? null
            : (t.iliski!.partnerliMi ? 'partnerli' : 'bekar'),
      LuckCategory.para => t.ugras?.name,
      LuckCategory.risk => t.karar?.name,
      LuckCategory.sosyal => t.enerji?.name,
      LuckCategory.saglik => null,
    };
    final Map<String, Map<KategoriTonu, List<String>>> durumlar =
        kategoriDurumlari[kategori]!;
    return anahtar != null && durumlar.containsKey(anahtar)
        ? anahtar
        : genelAnahtar;
  }
}
