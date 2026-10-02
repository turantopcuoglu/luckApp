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
/// Yer tutucular: `{isim}`, `{doga}`, `{gunIstegi}`, `{saat}`.
library;

import '../luck_engine/luck_engine.dart';
import 'content_config.dart';
import 'dongu_metinleri.dart';
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
    required this.gucTavsiyesi,
    required this.golgeTavsiyesi,
    required this.dengeTavsiyesi,
    required this.kategoriTarzi,
  });

  /// Kişinin doğası, mastar öbeği ("harekete geçmek ve yön vermek").
  final String doga;

  /// Temasını doğal bulduğu kişisel gün sayıları (1-9).
  final Set<int> uyumluGunler;

  /// Temasında zorlandığı kişisel gün sayıları (1-9).
  final Set<int> zorlayiciGunler;

  /// Uyumlu günde: güçlü yanını kullanma önerisi.
  final String gucTavsiyesi;

  /// Zorlayıcı günde: gölge yanını yönetme önerisi.
  final String golgeTavsiyesi;

  /// Dengeli günde: iki yanı birleştirme önerisi.
  final String dengeTavsiyesi;

  /// Her kategoride kişinin tipik tarzı (tondan bağımsız).
  final Map<LuckCategory, String> kategoriTarzi;

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

  /// Buluşma türüne göre öneri.
  String tavsiye(BulusmaTuru tur) => switch (tur) {
        BulusmaTuru.uyumlu => gucTavsiyesi,
        BulusmaTuru.dengeli => dengeTavsiyesi,
        BulusmaTuru.zorlayici => golgeTavsiyesi,
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

/// v3 yorum içerikleri.
abstract final class YorumYonu {
  /// Kişisel gün temaları.
  static const Map<int, GunTemasi> gunTemalari = <int, GunTemasi>{
    1: GunTemasi(
      istek: 'yeni bir şeye cesaretle başlamak',
      durum: <GunTonu, List<String>>{
        GunTonu.dusuk: <String>[
          '{isim}, bugün yeni bir şeye başlama isteğin olabilir ama koşullar henüz tam hazır değil.',
          'Bugün içinde bir başlangıç kıpırtısı var; yine de büyük adımlar yerine küçük bir hazırlık daha doğru olur.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün yeni bir sayfa açmak için makul bir gün; küçük ve somut bir başlangıç iyi gelir.',
          'Bugün ertelediğin bir işe başlamak için yeterli enerjin var, yeter ki mükemmel anı bekleme.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün yeni bir şeye başlamak, bir teklifte bulunmak ya da ilk adımı atmak için elverişli bir gün.',
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
          '{isim}, bugün iş birliği, anlaşma ve yakınlaşma için elverişli bir gün; insanlar sana karşı daha açık.',
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
          '{isim}, bugün kendini ifade etmek ve insanlarla temas kurmak sana iyi gelecek.',
          'Bugün bir fikri paylaşmak ya da uzun zamandır görmediğin biriyle konuşmak için uygun bir gün.',
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
          '{isim}, bugün dağınık duran işleri toparlamak ve bir planı adım adım ilerletmek için uygun bir gün.',
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
          'Bugün içinde her şeyi bir anda değiştirme isteği olabilir; ani kararlar için uygun bir gün değil.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün rutini biraz esnetmek ve farklı bir şey denemek zihnini tazeler.',
          'Bugün beklenmedik küçük değişiklikler olabilir; esnek kaldıkça gün kolaylaşır.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün yeni bir deneyim, kısa bir yolculuk ya da beklenmedik bir teklif için açık bir gün.',
          'Bugün değişim senin lehine işliyor; farklı bir yol denemek için elverişli bir gün.',
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
          '{isim}, bugün sevdiklerinle ilgilenmek ve yaşadığın alanı düzenlemek sana iyi gelecek.',
          'Bugün yakınlarına göstereceğin küçük bir ilgi, beklediğinden daha çok karşılık bulur.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün yakın ilişkilerin güçlendiği, sevgi ve desteğin karşılıklı aktığı bir gün.',
          'Bugün aile, ev ve yakın ilişkiler konusunda güzel gelişmeler için uygun bir gün.',
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
          '{isim}, bugün biraz yavaşlamak, düşünmek ve kendine vakit ayırmak sana iyi gelecek.',
          'Bugün bir konuyu derinlemesine incelemek ya da bir şey öğrenmek için uygun bir gün.',
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
          '{isim}, bugün iş ve para konularında engeller öne çıkabilir; aceleyle karar vermek için uygun bir gün değil.',
          'Bugün kontrol edemediğin şeyler seni gerebilir; zorlamak yerine hesaplı hareket etmek daha doğru.',
        ],
        GunTonu.orta: <String>[
          '{isim}, bugün net bir hedef belirleyip ona odaklandığında sonuç almak mümkün.',
          'Bugün iş ve para konularını gözden geçirmek, önceliklerini netleştirmek için uygun bir gün.',
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
          '{isim}, bugün yarım kalan işleri bitirmek ve gereksiz yüklerden hafiflemek için uygun bir gün.',
          'Bugün yeni bir şeye başlamaktan çok, elindekileri tamamlamak sana iyi gelecek.',
        ],
        GunTonu.yuksek: <String>[
          '{isim}, bugün uzun süredir uğraştığın bir konunun güzelce sonuçlanabileceği bir gün.',
          'Bugün affetmek, rahatlamak ve bir sayfayı kapatmak her zamankinden kolay.',
        ],
      },
    ),
  };

  /// Buluşma türüne göre "bu gün seninle nasıl buluşuyor" cümleleri.
  static const Map<BulusmaTuru, List<String>> bulusmaCumleleri =
      <BulusmaTuru, List<String>>{
    BulusmaTuru.uyumlu: <String>[
      'Bugünün senden istediği şey, yani {gunIstegi}, zaten doğanda var; bu yüzden gün sana ağır değil, tanıdık gelecek.',
      'Doğanda {doga} olduğu için bugünün temposuna kolayca uyum sağlarsın; başkalarının zorlandığı yerde sen rahat olabilirsin.',
    ],
    BulusmaTuru.dengeli: <String>[
      'Bugün öne çıkan şey {gunIstegi}; bu senin ilk tercihin olmasa da doğandaki {doga} isteğini güzelce tamamlayabilir.',
      'Bugün senden {gunIstegi} bekleniyor; bunu kendi tarzınla, yani {doga} yoluyla yaparsan gün dengeli ve verimli geçer.',
    ],
    BulusmaTuru.zorlayici: <String>[
      'Senin doğanda {doga} var; bugün ise gün senden {gunIstegi} istiyor. Bu yüzden gün boyunca hafif bir sürtünme hissedersen şaşırma.',
      'Bugün senden {gunIstegi} bekleniyor, oysa senin rahat ettiğin alan {doga}. Ritmin bugün biraz zorlanabilir; bu bir kötü gün değil, farklı bir gün.',
    ],
  };

  /// Günün temasının kişinin gündelik hayatında nerede görüneceği
  /// (tema × uğraş). Anahtar: [Ugras.name] ya da [genelAnahtar].
  static const Map<int, Map<String, String>> gunSahneleri =
      <int, Map<String, String>>{
    1: <String, String>{
      'calisiyor': 'İş tarafında bu, yeni bir görev üstlenmek ya da bir öneri sunmak anlamına gelebilir.',
      'ogrenci': 'Derslerinde bu, yeni bir konuya ya da yeni bir çalışma düzenine başlamak anlamına gelebilir.',
      'isArayan': 'İş arayışında bu, yeni bir başvuru yapmak ya da daha önce denemediğin bir alana bakmak anlamına gelebilir.',
      'girisimci': 'İşinde bu, aklındaki yeni bir fikri denemek ya da ilk kez bir müşteriyle görüşmek anlamına gelebilir.',
      'evde': 'Evde bu, uzun süredir düşündüğün bir değişikliğe ya da kendine ait yeni bir alışkanlığa başlamak anlamına gelebilir.',
      'genel': 'Pratikte bu, uzun süredir ertelediğin bir işe ilk adımı atmak anlamına gelebilir.',
    },
    2: <String, String>{
      'calisiyor': 'İş tarafında bu, bir iş arkadaşınla birlikte çalışmak ya da gergin bir konuyu nazikçe konuşmak anlamına gelebilir.',
      'ogrenci': 'Derslerinde bu, bir arkadaşınla birlikte çalışmak ya da takıldığın bir konuyu birine sormak anlamına gelebilir.',
      'isArayan': 'İş arayışında bu, tanıdıklarından destek istemek ya da bir referans rica etmek anlamına gelebilir.',
      'girisimci': 'İşinde bu, bir ortak, tedarikçi ya da müşteriyle anlaşma zemini aramak anlamına gelebilir.',
      'evde': 'Evde bu, bir konuyu birlikte konuşup ortak karar almak anlamına gelebilir.',
      'genel': 'Pratikte bu, bir konuyu tek başına çözmeye çalışmak yerine birinden destek istemek anlamına gelebilir.',
    },
    3: <String, String>{
      'calisiyor': 'İş tarafında bu, bir fikrini paylaşmak, sunum yapmak ya da ekiple iletişimi güçlendirmek anlamına gelebilir.',
      'ogrenci': 'Derslerinde bu, bir sunum, grup çalışması ya da yaratıcı bir ödev anlamına gelebilir.',
      'isArayan': 'İş arayışında bu, özgeçmişini güncellemek ya da çevrene ne aradığını anlatmak anlamına gelebilir.',
      'girisimci': 'İşinde bu, işini tanıtmak, paylaşım yapmak ya da yeni insanlarla tanışmak anlamına gelebilir.',
      'evde': 'Evde bu, arkadaşlarla görüşmek ya da yaratıcı bir uğraşa vakit ayırmak anlamına gelebilir.',
      'genel': 'Pratikte bu, bir arkadaşınla görüşmek ya da seni ifade eden bir işe vakit ayırmak anlamına gelebilir.',
    },
    4: <String, String>{
      'calisiyor': 'İş tarafında bu, biriken e-postaları, dosyaları ya da yarım işleri toparlamak anlamına gelebilir.',
      'ogrenci': 'Derslerinde bu, notlarını düzenlemek, bir çalışma planı yapmak ya da ertelediğin ödevi bitirmek anlamına gelebilir.',
      'isArayan': 'İş arayışında bu, başvurularını bir listeye dökmek ve düzenli bir arama planı yapmak anlamına gelebilir.',
      'girisimci': 'İşinde bu, hesapları, süreçleri ve yapılacaklar listesini düzene koymak anlamına gelebilir.',
      'evde': 'Evde bu, bir köşeyi düzenlemek ya da haftanın planını çıkarmak anlamına gelebilir.',
      'genel': 'Pratikte bu, masandaki, telefonundaki ya da aklındaki birikmiş işleri toparlamak anlamına gelebilir.',
    },
    5: <String, String>{
      'calisiyor': 'İş tarafında bu, bir yöntemi değiştirmek ya da farklı bir görevde yer almak anlamına gelebilir.',
      'ogrenci': 'Derslerinde bu, çalışma yerini ya da yöntemini değiştirip dikkatini tazelemek anlamına gelebilir.',
      'isArayan': 'İş arayışında bu, daha önce düşünmediğin bir sektöre ya da pozisyona bakmak anlamına gelebilir.',
      'girisimci': 'İşinde bu, ürününde ya da yaklaşımında küçük bir değişiklik denemek anlamına gelebilir.',
      'evde': 'Evde bu, rutinin dışına çıkmak, kısa bir gezinti yapmak ya da yeni bir tarif denemek anlamına gelebilir.',
      'genel': 'Pratikte bu, rutinin dışına çıkmak, farklı bir yoldan gitmek ya da yeni bir şey denemek anlamına gelebilir.',
    },
    6: <String, String>{
      'calisiyor': 'İş tarafında bu, bir iş arkadaşına yardım etmek ya da ekipte sorumluluk almak anlamına gelebilir.',
      'ogrenci': 'Derslerinde bu, bir arkadaşına yardım etmek; günün geri kalanında da ailene vakit ayırmak anlamına gelebilir.',
      'isArayan': 'İş arayışında bu, seni bu süreçte destekleyen insanlarla vakit geçirip moral toplamak anlamına gelebilir.',
      'girisimci': 'İşinde bu, müşterilerinle ya da ekibinle ilgilenmek ve onların ihtiyaçlarını dinlemek anlamına gelebilir.',
      'evde': 'Evde bu, ev ve aile için yapacağın küçük bir güzellik anlamına gelebilir.',
      'genel': 'Pratikte bu, bir yakınını aramak ya da evde küçük bir düzenleme yapmak anlamına gelebilir.',
    },
    7: <String, String>{
      'calisiyor': 'İş tarafında bu, kalabalık toplantılardan çok odaklanarak tek başına yürüttüğün işlere ağırlık vermek anlamına gelebilir.',
      'ogrenci': 'Derslerinde bu, sessiz bir ortamda zor bir konuyu gerçekten anlamaya çalışmak anlamına gelebilir.',
      'isArayan': 'İş arayışında bu, hangi işi gerçekten istediğini düşünmek ve bir alanda kendini geliştirmek anlamına gelebilir.',
      'girisimci': 'İşinde bu, verileri incelemek, araştırma yapmak ve stratejini gözden geçirmek anlamına gelebilir.',
      'evde': 'Evde bu, kendine sessiz bir saat ayırmak, kitap okumak ya da yürüyüş yapmak anlamına gelebilir.',
      'genel': 'Pratikte bu, kendine sessiz bir zaman ayırmak ya da ilgini çeken bir konuyu araştırmak anlamına gelebilir.',
    },
    8: <String, String>{
      'calisiyor': 'İş tarafında bu, bir talebini dile getirmek, sorumluluk istemek ya da önemli bir görüşme yapmak anlamına gelebilir.',
      'ogrenci': 'Derslerinde bu, hedeflerini netleştirmek ve sınav ya da proje takvimine ciddi bir plan koymak anlamına gelebilir.',
      'isArayan': 'İş arayışında bu, görüşmelere hazırlanmak ve beklentini netleştirmek anlamına gelebilir.',
      'girisimci': 'İşinde bu, fiyatlandırma, tahsilat ya da büyüme kararlarını ele almak anlamına gelebilir.',
      'evde': 'Evde bu, ev bütçesini gözden geçirmek ve maddi bir kararı netleştirmek anlamına gelebilir.',
      'genel': 'Pratikte bu, maddi konularını gözden geçirmek ve bir hedefi netleştirmek anlamına gelebilir.',
    },
    9: <String, String>{
      'calisiyor': 'İş tarafında bu, yarım kalan bir işi teslim etmek ya da artık işine yaramayan bir yükü bırakmak anlamına gelebilir.',
      'ogrenci': 'Derslerinde bu, bir konuyu tamamlamak ya da eski notları ayıklamak anlamına gelebilir.',
      'isArayan': 'İş arayışında bu, olmayan bir başvuruyu geride bırakıp enerjini yeni seçeneklere çevirmek anlamına gelebilir.',
      'girisimci': 'İşinde bu, kazandırmayan bir işi ya da süreci sonlandırmayı düşünmek anlamına gelebilir.',
      'evde': 'Evde bu, kullanmadığın eşyaları ayıklamak ya da bir konuyu kapatmak anlamına gelebilir.',
      'genel': 'Pratikte bu, yarım kalan bir işi bitirmek ya da artık gerekmeyen bir şeyi bırakmak anlamına gelebilir.',
    },
  };

  /// Uğraşı bilinmeyen okuyucu için sahne anahtarı.
  static const String genelAnahtar = 'genel';

  /// Yaşam yolu karakterleri (1-9, 11, 22, 33).
  static const Map<int, KarakterYonu> karakterler = <int, KarakterYonu>{
    1: KarakterYonu(
      doga: 'harekete geçmek ve yön vermek',
      uyumluGunler: <int>{1, 5, 8},
      zorlayiciGunler: <int>{2, 4, 7},
      gucTavsiyesi: 'Bugün ilk adımı atan sen ol; beklemek yerine inisiyatif almak sana kazandırır.',
      golgeTavsiyesi: 'Herkesin senin hızında gitmesini beklemek bugün seni yorar; bir kez durup başkalarını dinlemek işleri hızlandırır.',
      dengeTavsiyesi: 'Bugün her şeyi tek başına üstlenmek yerine bir işi paylaşmayı dene; liderliğin azalmaz, güçlenir.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta ilgini belli etmekten çekinmezsin ama kendine ait alanına da düşkünsün.',
        LuckCategory.para: 'Parayla ilişkin cesur; fırsatı erken görürsün, bazen hesabı sonraya bırakırsın.',
        LuckCategory.saglik: 'Enerjin yüksektir ama kendini zorlamaya ve molaları atlamaya yatkınsın.',
        LuckCategory.risk: 'Risk almaktan korkmazsın; asıl dikkat etmen gereken şey sabırsızlık.',
        LuckCategory.sosyal: 'Sosyal ortamlarda yön veren taraf olursun; bazen dinlemek yerine yönlendirmeye geçersin.',
      },
    ),
    2: KarakterYonu(
      doga: 'insanları anlamak ve arabuluculuk yapmak',
      uyumluGunler: <int>{2, 6, 7},
      zorlayiciGunler: <int>{1, 5, 8},
      gucTavsiyesi: 'Bugün sezgilerine güven; bir konuşmada söylenmeyeni fark etmen işleri kolaylaştıracak.',
      golgeTavsiyesi: 'Bugün başkalarını memnun etmek için kendi isteğini geri planda bırakma; ne istediğini açıkça söyle.',
      dengeTavsiyesi: 'Bugün uyum arayışını korurken bir kararı ertelemeden vermeye çalış.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta özenli ve sadıksın; duygularının karşılık görmesine ihtiyaç duyarsın.',
        LuckCategory.para: 'Parada temkinli ve düzenlisin; ani kararlar yerine güvenli adımları seçersin.',
        LuckCategory.saglik: 'Duygusal yükler bedenine çabuk yansır; gerginlikten uzak kalmak sana iyi gelir.',
        LuckCategory.risk: 'Risk almadan önce herkesin fikrini tartmak istersin; bu seni korur ama bazen fırsatı kaçırtır.',
        LuckCategory.sosyal: 'İnsanlar yanında rahatlar; sen de kalabalıktan çok samimi sohbetlerde parlarsın.',
      },
    ),
    3: KarakterYonu(
      doga: 'kendini ifade etmek ve ortamı canlandırmak',
      uyumluGunler: <int>{1, 3, 5},
      zorlayiciGunler: <int>{4, 7, 8},
      gucTavsiyesi: 'Bugün bir fikrini ya da duygunu paylaş; ifade gücün kapıları açacak.',
      golgeTavsiyesi: 'Bugün enerjini on farklı işe dağıtmak yerine birini bitirmeye odaklan.',
      dengeTavsiyesi: 'Bugün neşeni korurken sözlerini biraz daha tartarak seç; yanlış anlaşılmanın önüne geçersin.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta eğlenceli ve sıcaksın; ilgi görmek ve takdir duymak senin için önemli.',
        LuckCategory.para: 'Parayı kazanmakta yaratıcı, harcamakta cömertsin; bütçe tutmak sana zor gelebilir.',
        LuckCategory.saglik: 'Ruh halin enerjini doğrudan etkiler; keyif aldığın bir hareket sana en iyi gelen şeydir.',
        LuckCategory.risk: 'Yeni fikirlere hızla heveslenirsin; heyecan geçtikten sonra da istiyorsan devam etmek iyi olur.',
        LuckCategory.sosyal: 'Sosyal ortamlarda doğal olarak dikkat çekersin; insanlar senin enerjinle canlanır.',
      },
    ),
    4: KarakterYonu(
      doga: 'düzen kurmak ve işi sağlam temele oturtmak',
      uyumluGunler: <int>{2, 4, 8},
      zorlayiciGunler: <int>{3, 5, 9},
      gucTavsiyesi: 'Bugün bir planı adım adım uygula; sabrın ve düzenin somut sonuç getirecek.',
      golgeTavsiyesi: 'Bugün plan dışı gelişmelere katılaşmak yerine esnek kalmayı dene; her şeyin kontrolünde olması gerekmiyor.',
      dengeTavsiyesi: 'Bugün düzenini korurken küçük bir yeniliğe de yer aç; hem güven hem tazelik kazanırsın.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta güvenilir ve sadıksın; sevgini sözden çok yaptıklarınla gösterirsin.',
        LuckCategory.para: 'Parayla ilişkin planlı ve sağlam; adım adım biriktirmek sana güven verir.',
        LuckCategory.saglik: 'Düzenli bir rutin sana iyi gelir ama işe dalıp dinlenmeyi unutabilirsin.',
        LuckCategory.risk: 'Bilmediğin bir şeye kolay girmezsin; bu temkin seni çoğu zaman korur.',
        LuckCategory.sosyal: 'Sosyal çevren az ama sağlamdır; insanlar zor anda sana güvenir.',
      },
    ),
    5: KarakterYonu(
      doga: 'yeni deneyimlere açılmak ve özgürce hareket etmek',
      uyumluGunler: <int>{1, 3, 5},
      zorlayiciGunler: <int>{2, 4, 6},
      gucTavsiyesi: 'Bugün farklı bir şey denemekten çekinme; merakın sana yeni bir kapı açacak.',
      golgeTavsiyesi: 'Bugün sıkıldığın bir işi yarıda bırakma dürtüsüne karşı dur; bitirmek sana özgürlük kadar iyi gelecek.',
      dengeTavsiyesi: 'Bugün yenilik isteğini sorumluluklarınla dengele; önce bir işi kapat, sonra yeni bir şeye yönel.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta heyecan ararsın; kısıtlandığını hissettiğinde geri çekilirsin.',
        LuckCategory.para: 'Kazancın dalgalı olabilir; iyi günlerde bir kenara ayırmak özgürlüğünü korur.',
        LuckCategory.saglik: 'Hareket etmek sana iyi gelir ama aşırılığa kaçmaya yatkınsın.',
        LuckCategory.risk: 'Risk ve yenilik seni çeker; sınırını önceden koyduğunda en iyi sonucu alırsın.',
        LuckCategory.sosyal: 'Farklı insanlarla kolay tanışırsın; geniş bir çevrede rahat edersin.',
      },
    ),
    6: KarakterYonu(
      doga: 'sevdiklerini korumak ve sorumluluk almak',
      uyumluGunler: <int>{2, 6, 9},
      zorlayiciGunler: <int>{1, 5, 7},
      gucTavsiyesi: 'Bugün sevdiklerine göstereceğin ilgi beklediğinden fazla karşılık bulacak.',
      golgeTavsiyesi: "Bugün herkesin yükünü taşımak zorunda değilsin; birine 'şimdi yapamam' demek de bir sevgi biçimi.",
      dengeTavsiyesi: 'Bugün başkalarına verdiğin özenin bir kısmını kendine ayır.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta şefkatli ve bağlısın; aynı özeni geri görmediğinde çabuk yorulursun.',
        LuckCategory.para: 'Parayı sevdiklerin için harcamaktan hoşlanırsın; kendine ayırmayı sık unutursun.',
        LuckCategory.saglik: 'Başkalarıyla ilgilenirken kendi bakımını ikinci plana atmaya yatkınsın.',
        LuckCategory.risk: 'Sevdiklerini etkileyecek risklerde çok temkinlisin; kendi isteklerinde ise daha cesur olabilirsin.',
        LuckCategory.sosyal: 'Çevrendeki insanlar sana dert anlatır; sen de yakın ve güvenilir ilişkilerde huzur bulursun.',
      },
    ),
    7: KarakterYonu(
      doga: 'derinlemesine düşünmek ve kendi başına anlam aramak',
      uyumluGunler: <int>{4, 7, 9},
      zorlayiciGunler: <int>{3, 5, 6},
      gucTavsiyesi: 'Bugün bir konuyu derinlemesine düşünmeye vakit ayır; bulduğun cevap işine yarayacak.',
      golgeTavsiyesi: 'Bugün her şeyi kafanda çözmeye çalışma; güvendiğin biriyle konuşmak işleri hızlandırır.',
      dengeTavsiyesi: 'Bugün analiz yeteneğini kullanırken sezgine de bir şans ver.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta yavaş açılır ama derin bağlanırsın; zihinsel yakınlık senin için şarttır.',
        LuckCategory.para: 'Parada dikkatli ve araştırmacısın; bilmediğin bir işe kolay para koymazsın.',
        LuckCategory.saglik: 'Zihinsel yorgunluk bedenine çabuk yansır; sessizlik ve uyku senin şarj kaynağın.',
        LuckCategory.risk: 'Risk almadan önce her ayrıntıyı incelemek istersin; bazen fazla düşünmek fırsatı geçirir.',
        LuckCategory.sosyal: 'Kalabalık yerine az ve derin ilişkileri tercih edersin; yalnız kalmaya da ihtiyaç duyarsın.',
      },
    ),
    8: KarakterYonu(
      doga: 'hedef koymak ve sonuç almak',
      uyumluGunler: <int>{1, 4, 8},
      zorlayiciGunler: <int>{2, 7, 9},
      gucTavsiyesi: 'Bugün hedefini netleştir ve kararlılıkla ilerle; sonuç almaya yakınsın.',
      golgeTavsiyesi: 'Bugün her şeyi kontrol etmeye çalışmak seni yorar; bazı işleri başkalarına bırakmayı dene.',
      dengeTavsiyesi: 'Bugün hedefe odaklanırken yanındaki insanların ne hissettiğini de hesaba kat.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta koruyucu ve cömertsin; duygularını çoğu zaman sözden çok eylemle gösterirsin.',
        LuckCategory.para: 'Parayla ilişkin güçlü ve hırslı; büyük düşünürsün, inişli çıkışlı dönemler de yaşayabilirsin.',
        LuckCategory.saglik: 'Çok çalışmaya ve stresi içine atmaya yatkınsın; dinlenmek senin için bir ihtiyaç.',
        LuckCategory.risk: 'Hesaplı risk almayı bilirsin; seni yönlendiren şey kaybetme korkusu değil, kazanma isteği.',
        LuckCategory.sosyal: 'Sosyal ortamlarda doğal bir otorite taşırsın; insanlar senden yön bekler.',
      },
    ),
    9: KarakterYonu(
      doga: 'başkalarına şefkat göstermek ve büyük resmi görmek',
      uyumluGunler: <int>{3, 6, 9},
      zorlayiciGunler: <int>{1, 4, 8},
      gucTavsiyesi: 'Bugün birine karşılıksız bir iyilik yap ya da destek ol; bu sana da anlam katacak.',
      golgeTavsiyesi: 'Bugün geçmişte kalmış bir konuyu tekrar tekrar düşünmek yerine ona bir nokta koymayı dene.',
      dengeTavsiyesi: 'Bugün başkalarına verdiğin desteği kendi ihtiyaçlarınla dengele.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta derin ve affedicisin; sevdiğin kişiyi olduğundan büyük görebilirsin.',
        LuckCategory.para: 'Parayı bir amaç için kazanmak seni motive eder; verirken kendine pay ayırmak önemli.',
        LuckCategory.saglik: 'Başkalarının derdini içine almak seni yorabilir; kendine sınır koymak iyi gelir.',
        LuckCategory.risk: 'İdealist kararlar verebilirsin; bir fikre gönül vermeden önce gerçekçi yanlarını da düşün.',
        LuckCategory.sosyal: 'Farklı insanları kolayca anlarsın; geniş ve çeşitli bir çevren olur.',
      },
    ),
    11: KarakterYonu(
      doga: 'sezgilerine güvenmek ve insanlara ilham vermek',
      uyumluGunler: <int>{2, 7, 9},
      zorlayiciGunler: <int>{4, 5, 8},
      gucTavsiyesi: 'Bugün içinden gelen ilk hisse güven; sezgilerin seni doğru yere götürecek.',
      golgeTavsiyesi: 'Bugün hassasiyetin kaygıya dönüşmesin; bir hissi gerçek sanmadan önce bir kez kontrol et.',
      dengeTavsiyesi: 'Bugün sezgine güvenirken ayağını yere basan somut bir adım da at.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta ruhsal bir bağ ararsın; yüzeysel ilişkiler seni çabuk yorar.',
        LuckCategory.para: 'Parayla ilişkin dalgalı olabilir; sezgin kadar sade bir bütçeye de güvenmek seni rahatlatır.',
        LuckCategory.saglik: 'Uyaranlara karşı hassassın; gürültü ve yoğunluk enerjini hızla düşürür.',
        LuckCategory.risk: 'Sezgilerin risk konusunda çoğu zaman haklı çıkar; yine de kaygıyla sezgiyi karıştırmamaya dikkat et.',
        LuckCategory.sosyal: 'İnsanlar yanında ilham alır; ama kalabalıktan sonra toparlanmak için yalnız zamana ihtiyaç duyarsın.',
      },
    ),
    22: KarakterYonu(
      doga: 'büyük bir fikri adım adım gerçeğe dönüştürmek',
      uyumluGunler: <int>{1, 4, 8},
      zorlayiciGunler: <int>{3, 5, 9},
      gucTavsiyesi: 'Bugün büyük hedefinin somut bir parçasını tamamla; küçük adım büyük yapıyı ilerletir.',
      golgeTavsiyesi: 'Bugün her şeyin mükemmel olmasını beklemek seni durdurmasın; iyi olan bir adım yeterli.',
      dengeTavsiyesi: 'Bugün büyük planlarını düşünürken günün küçük işlerini de ihmal etme.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta güvenilir ve ciddisin; birlikte bir gelecek kurabileceğin birini ararsın.',
        LuckCategory.para: 'Parayı uzun vadeli ve sağlam planlarla büyütmeyi tercih edersin.',
        LuckCategory.saglik: 'Sorumluluk yükünü bedeninde taşıyabilirsin; gerginliği biriktirmemeye dikkat et.',
        LuckCategory.risk: 'Büyük düşünürsün ama riski planlı alırsın; hazırlıksız atılmayı sevmezsin.',
        LuckCategory.sosyal: 'İnsanları ortak bir amaç etrafında toplamakta ustasın.',
      },
    ),
    33: KarakterYonu(
      doga: 'insanlara yol göstermek ve onları desteklemek',
      uyumluGunler: <int>{3, 6, 9},
      zorlayiciGunler: <int>{1, 5, 8},
      gucTavsiyesi: 'Bugün bilgini ya da deneyimini biriyle paylaş; yol göstermek sana da güç verecek.',
      golgeTavsiyesi: 'Bugün herkesin sorununu çözmek zorunda değilsin; bazen dinlemek yeterli.',
      dengeTavsiyesi: 'Bugün başkalarını desteklerken kendine de aynı şefkati göster.',
      kategoriTarzi: <LuckCategory, String>{
        LuckCategory.ask: 'Aşkta fedakâr ve besleyicisin; kendi ihtiyaçlarını söylemeyi unutmamalısın.',
        LuckCategory.para: 'Para senin için iyilik yapabilmenin aracıdır; kendine ayırdığın payı korumak önemli.',
        LuckCategory.saglik: 'Başkalarına enerji verirken tükenmeye yatkınsın; kendi bakımına zaman ayırmalısın.',
        LuckCategory.risk: 'Başkalarını etkileyecek kararlarda çok dikkatlisin; bu sorumluluk duygun seni korur.',
        LuckCategory.sosyal: 'İnsanlar yanında öğrenir ve rahatlar; çevrende doğal bir rehber gibi görülürsün.',
      },
    ),
  };

  /// Kategori × kişinin durumu × ton: o alanda bugün ne oluyor.
  ///
  /// Durum anahtarı [durumAnahtari] ile bulunur; her kategoride
  /// [genelAnahtar] her zaman vardır.
  static const Map<LuckCategory, Map<String, Map<KategoriTonu, List<String>>>>
      kategoriDurumlari =
      <LuckCategory, Map<String, Map<KategoriTonu, List<String>>>>{
    LuckCategory.ask: <String, Map<KategoriTonu, List<String>>>{
      'bekar': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Aşk tarafında bugün beklediğin ilgi gelmeyebilir; bunu kendi değerinle ilgili bir işaret olarak görme.',
          'Bugün yalnızlık hissi biraz daha belirgin olabilir; seni iyi hissettiren biriyle vakit geçirmek iyi gelir.',
        ],
        KategoriTonu.orta: <String>[
          'Aşk tarafında bugün sakin bir gün; tanıdık bir çevrede yeni bir yüzle sohbet başlayabilir.',
          'Aşk tarafında bugün flört için zorlamak yerine doğal davranmak daha çekici.',
        ],
        KategoriTonu.yuksek: <String>[
          'Aşk tarafında bugün tanışmalar ve ilgi için açık bir gün; bir davete ya da sohbete evet demek güzel sonuç verebilir.',
          'Aşk tarafında bugün çekiciliğin yüksek; ilgini çeken biriyle ilk adımı atmak için uygun bir gün.',
        ],
      },
      'partnerli': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'İlişkinde bugün küçük bir konu kolayca büyüyebilir; önce dinlemek, sonra cevap vermek işleri yumuşatır.',
          'Bugün partnerinle aranızda bir yorgunluk hissedebilirsin; bu bir kopuş değil, biraz alana ihtiyaç.',
        ],
        KategoriTonu.orta: <String>[
          'İlişkinde bugün sıradan ama sıcak bir gün; küçük bir jest aranızdaki bağı güçlendirir.',
          'İlişkinde bugün partnerinle birlikte yapacağınız basit bir iş, uzun bir konuşmadan daha çok yakınlaştırır.',
        ],
        KategoriTonu.yuksek: <String>[
          'İlişkinde bugün yakınlık kolay; birlikte plan yapmak ya da güzel bir akşam geçirmek için elverişli bir gün.',
          'İlişkinde bugün partnerine hissettiklerini söylemek için doğal bir akış var.',
        ],
      },
      'genel': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Aşk tarafında bugün duygular hassas; yanlış anlaşılmaya açık konuşmaları ertelemek iyi olur.',
          'Aşk tarafında bugün kalbini başkasının onayına bağlamak seni yorabilir.',
        ],
        KategoriTonu.orta: <String>[
          'Aşk tarafında bugün dengeli bir gün; küçük bir ilgi büyük yankı bulabilir.',
          'Aşk tarafında bugün duygularını sakin bir dille ifade etmek ilişkilerine iyi gelir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Aşk tarafında bugün sıcak ve açık bir gün; hissettiklerini göstermek karşılık bulur.',
          'Aşk tarafında bugün duygusal yakınlık kurmak her zamankinden kolay.',
        ],
      },
    },
    LuckCategory.para: <String, Map<KategoriTonu, List<String>>>{
      'calisiyor': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'İş ve para tarafında bugün beklenmedik bir aksilik ya da ek iş çıkabilir; önemli kararları yarına bırakmak daha güvenli.',
          'Bugün işte emeğinin görünmediğini hissedebilirsin; şimdilik sabırlı olmak daha doğru.',
        ],
        KategoriTonu.orta: <String>[
          'İş tarafında bugün sakin ve yönetilebilir bir gün; önceliklerini sıraya koymak yeterli.',
          'İş tarafında bugün küçük ama düzenli bir ilerleme kaydedebilirsin.',
        ],
        KategoriTonu.yuksek: <String>[
          'İş tarafında bugün emeğinin görünür olduğu bir gün; bir talebini dile getirmek için uygun bir zaman.',
          'İş tarafında bugün bir fırsat ya da takdir gelebilir; kendini geri çekme.',
        ],
      },
      'girisimci': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'İşinde bugün bir gecikme ya da beklenmedik bir gider canını sıkabilir; büyük harcamaları ertele.',
          'İşinde bugün yeni harcama kararları yerine eldekini korumaya odaklanmak daha güvenli.',
        ],
        KategoriTonu.orta: <String>[
          'İşinde bugün dengeli bir gün; müşterilerinle ilişkini güçlendirmek için uygun.',
          'İşinde bugün hesapları gözden geçirip küçük iyileştirmeler yapmak kazandırır.',
        ],
        KategoriTonu.yuksek: <String>[
          'İşinde bugün satış, anlaşma ya da yeni bir iş bağlantısı için elverişli bir gün.',
          'İşinde bugün cesur bir teklif ya da fiyat kararı karşılık bulabilir.',
        ],
      },
      'ogrenci': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Para tarafında bugün bütçeni zorlayacak küçük harcamalara dikkat.',
          'Bugün dersler ve sorumluluklar üst üste gelebilir; önce en acil olanı bitir.',
        ],
        KategoriTonu.orta: <String>[
          'Dersler ve bütçe tarafında bugün sakin bir gün; küçük bir planlama işini kolaylaştırır.',
          'Bugün bir sınava ya da projeye düzenli çalışmak karşılığını verir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Dersler tarafında bugün verimli bir gün; zor bir konuyu çözmek ya da iyi bir sonuç almak için elverişli.',
          'Bugün bir burs, staj ya da proje fırsatını kaçırmamak için etrafına dikkat et.',
        ],
      },
      'isArayan': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'İş arayışında bugün beklediğin dönüş gelmeyebilir; bunu yeteneğinle ilgili bir işaret olarak görme.',
          'Bugün moralin biraz düşük olabilir; başvuru yapmak yerine kendini toparlamak daha iyi.',
        ],
        KategoriTonu.orta: <String>[
          'İş arayışında bugün düzenli bir gün; birkaç başvuruyu dikkatle hazırlamak iyi sonuç verir.',
          'Bugün tanıdıklarına ne aradığını anlatmak beklenmedik bir kapı açabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'İş arayışında bugün olumlu bir dönüş ya da görüşme daveti için elverişli bir gün.',
          'Bugün bir görüşmede kendini anlatman her zamankinden etkili olabilir.',
        ],
      },
      'evde': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Para tarafında bugün ev giderleri ya da beklenmedik bir masraf canını sıkabilir.',
          'Para tarafında bugün alışverişte plansız harcamalara karşı dikkatli ol.',
        ],
        KategoriTonu.orta: <String>[
          'Para tarafında bugün sakin bir gün; ev bütçesini gözden geçirmek iyi gelir.',
          'Para tarafında bugün küçük bir tasarruf fikri ay sonunu rahatlatabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Para tarafında bugün ferah bir gün; ev için uzun süredir düşündüğün bir ihtiyacı değerlendirmek uygun olabilir.',
          'Para tarafında bugün bir indirim, hediye ya da beklenmedik küçük bir kazanç gelebilir.',
        ],
      },
      'genel': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Para tarafında bugün plansız harcamalar ve beklenmedik giderler öne çıkabilir.',
          'Para tarafında bugün maddi bir kararı aceleyle vermek yerine bir gün beklemek daha güvenli.',
        ],
        KategoriTonu.orta: <String>[
          'Para tarafında bugün dengeli bir gün; büyük adımlar yerine küçük düzenlemeler yeterli.',
          'Para tarafında bugün harcamalarını gözden geçirmek sana netlik kazandırır.',
        ],
        KategoriTonu.yuksek: <String>[
          'Para tarafında bugün fırsatlara açık bir gün; emeğinin karşılığını istemek için uygun.',
          'Para tarafında bugün maddi konularda olumlu bir gelişme olabilir.',
        ],
      },
    },
    LuckCategory.saglik: <String, Map<KategoriTonu, List<String>>>{
      'genel': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Enerjin bugün düşük olabilir; gün içinde kısa molalar vermek seni toparlar.',
          'Bugün yorgunluk ve gerginlik bedeninde daha çok hissedilebilir; uykuna ve su içmeye özen göster.',
          'Bugün kendini zorlamak yerine temponu düşürmek daha doğru.',
        ],
        KategoriTonu.orta: <String>[
          'Enerjin bugün dengede; düzenli beslenme ve kısa bir yürüyüş gününü güzelleştirir.',
          'Bugün bedenin sana ne istediğini söylüyor; dinlenmeyle hareket arasında denge kur.',
          'Bugün hafif bir egzersiz ya da temiz hava moralini de yükseltir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Enerjin bugün yüksek; ertelediğin bir spora ya da uzun bir yürüyüşe başlamak için iyi bir gün.',
          'Bugün kendini canlı ve dayanıklı hissedebilirsin; bu enerjiyi hareketle değerlendir.',
          'Bugün yeni ve sağlıklı bir alışkanlığa başlamak için elverişli bir gün.',
        ],
      },
    },
    LuckCategory.risk: <String, Map<KategoriTonu, List<String>>>{
      'kalp': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Kararlarında bugün duygularınla hızlı davranmak pişmanlık getirebilir; bir gece beklemek daha iyi.',
          "Kararlarında bugün heyecanla verilen bir 'evet' yarın ağır gelebilir.",
        ],
        KategoriTonu.orta: <String>[
          'Kararlarında bugün içinden geleni dinleyebilirsin ama rakamlara da bir göz at.',
          'Kararlarında bugün küçük riskler alınabilir; büyük olanları birine danışarak ver.',
        ],
        KategoriTonu.yuksek: <String>[
          'Kararlarında bugün sezgilerin güçlü; içinden gelen cesur adım karşılık bulabilir.',
          'Kararlarında bugün kalbinin evet dediği bir fırsatı değerlendirmek için elverişli bir gün.',
        ],
      },
      'akil': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Kararlarında bugün hesapların bile seni yanıltabilir; önemli bir riski ertelemek daha güvenli.',
          "Kararlarında bugün 'mantıklı görünüyor' dediğin bir teklifin arkasını bir kez daha kontrol et.",
        ],
        KategoriTonu.orta: <String>[
          'Kararlarında bugün hesaplı riskler alınabilir; artıları ve eksileri yazmak işini kolaylaştırır.',
          'Kararlarında bugün işin duygusal tarafını da hesaba katmak daha iyi sonuç verir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Kararlarında bugün analizlerin isabetli; hesapladığın bir adımı atmak için uygun bir gün.',
          'Kararlarında bugün planladığın bir riski almak için koşullar senden yana.',
        ],
      },
      'genel': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Kararlarında bugün şansı zorlamak yerine elindekini korumak daha güvenli.',
          'Kararlarında bugün büyük riskler için uygun bir gün değil; bekleyebiliyorsan bekle.',
        ],
        KategoriTonu.orta: <String>[
          'Kararlarında bugün küçük ve hesaplı riskler alınabilir.',
          'Kararlarında bugün yeni bir şey denerken sınırını önceden belirlemek yeterli.',
        ],
        KategoriTonu.yuksek: <String>[
          'Kararlarında bugün cesaret karşılık buluyor; ertelediğin bir adımı atmak için uygun.',
          'Kararlarında bugün şans cesur ama hazırlıklı olandan yana.',
        ],
      },
    },
    LuckCategory.sosyal: <String, Map<KategoriTonu, List<String>>>{
      'iceDonuk': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Sosyal tarafta bugün kalabalık seni çabuk yorabilir; bir daveti ertelemekte sakınca yok.',
          'Sosyal tarafta bugün uzun sohbetler yerine kendine ayırdığın sessiz bir zaman iyi gelir.',
        ],
        KategoriTonu.orta: <String>[
          'Sosyal tarafta bugün tek bir yakın dostla yapılacak sohbet sana iyi gelir.',
          'Sosyal tarafta bugün küçük ve samimi bir buluşma, büyük bir kalabalıktan daha keyifli olur.',
        ],
        KategoriTonu.yuksek: <String>[
          'Sosyal tarafta bugün normalden daha açıksın; yeni biriyle tanışmak sandığından kolay olabilir.',
          'Sosyal tarafta bugün bir grupta fikrini söylemek için içinden gelen cesareti değerlendir.',
        ],
      },
      'disaDonuk': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Sosyal tarafta bugün herkese yetişmeye çalışmak seni yorabilir; planlarını azaltmak iyi gelir.',
          'Sosyal tarafta bugün sözlerin yanlış anlaşılmaya açık; esprilerine dikkat et.',
        ],
        KategoriTonu.orta: <String>[
          'Sosyal tarafta bugün hareketli bir gün; arkadaşlarla kısa bir buluşma enerjini yükseltir.',
          'Sosyal tarafta bugün yeni insanlarla tanışmak için makul bir fırsat var.',
        ],
        KategoriTonu.yuksek: <String>[
          'Sosyal tarafta bugün ortamın merkezinde olabilirsin; davetlere evet demek güzel bağlantılar getirir.',
          'Sosyal tarafta bugün bir etkinlik ya da buluşma beklediğinden daha keyifli geçebilir.',
        ],
      },
      'genel': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Sosyal tarafta bugün gerginliklere açık bir gün; tartışmaya girmemek seni korur.',
          'Sosyal tarafta bugün kalabalık ortamlarda çabuk yorulabilirsin.',
        ],
        KategoriTonu.orta: <String>[
          'Sosyal tarafta bugün dengeli bir gün; eski bir dosta haber vermek iyi gelir.',
          'Sosyal tarafta bugün insanlarla sakin ve samimi bir iletişim kurabilirsin.',
        ],
        KategoriTonu.yuksek: <String>[
          'Sosyal tarafta bugün insanlar sana karşı sıcak; yeni bağlantılar kurmak kolay.',
          'Sosyal tarafta bugün bir buluşma ya da davet güzel bir fırsata dönüşebilir.',
        ],
      },
    },
  };

  /// Günün temasının her kategoriye etkisi (tema × kategori).
  static const Map<int, Map<LuckCategory, String>> temaKategori =
      <int, Map<LuckCategory, String>>{
    1: <LuckCategory, String>{
      LuckCategory.ask: 'Günün başlangıç havası aşkta yeni bir tanışmaya ya da ilişkinde yeni bir sayfaya işaret ediyor.',
      LuckCategory.para: 'Günün başlangıç havası yeni bir gelir fikrine ya da birikim alışkanlığına başlamak için uygun.',
      LuckCategory.saglik: 'Günün başlangıç havası yeni bir spora ya da sağlıklı bir alışkanlığa başlamayı destekliyor.',
      LuckCategory.risk: 'Günün başlangıç havası yeni bir adım atma cesaretini artırıyor.',
      LuckCategory.sosyal: 'Günün başlangıç havası yeni insanlarla tanışmayı kolaylaştırıyor.',
    },
    2: <LuckCategory, String>{
      LuckCategory.ask: 'Günün uyum arayan havası aşkta anlayış ve sabır gerektiren konuşmalar için elverişli.',
      LuckCategory.para: 'Günün uyum arayan havası ortaklık, anlaşma ve pazarlıklarda işine yarar.',
      LuckCategory.saglik: 'Günün sakin havası bedenine dinlenme ve denge fırsatı veriyor.',
      LuckCategory.risk: 'Günün sabır isteyen havası, aceleci risklerden çok beklemenin kazandırdığını hatırlatıyor.',
      LuckCategory.sosyal: 'Günün uyum arayan havası ilişkilerde barışmak ve arabuluculuk için uygun.',
    },
    3: <LuckCategory, String>{
      LuckCategory.ask: 'Günün paylaşım havası aşkta hislerini söze dökmeyi kolaylaştırıyor.',
      LuckCategory.para: 'Günün paylaşım havası kendini ya da işini tanıtmaya yarıyor.',
      LuckCategory.saglik: 'Günün neşeli havası, keyif aldığın bir hareketle sağlığına iyi gelir.',
      LuckCategory.risk: 'Günün heyecanlı havası seni hevesle karar vermeye itebilir.',
      LuckCategory.sosyal: 'Günün paylaşım havası sosyal ortamlarda seni öne çıkarıyor.',
    },
    4: <LuckCategory, String>{
      LuckCategory.ask: 'Günün düzen havası aşkta güven veren, istikrarlı adımları destekliyor.',
      LuckCategory.para: 'Günün düzen havası bütçe, fatura ve birikim gibi somut işlere yarıyor.',
      LuckCategory.saglik: 'Günün düzen havası uyku ve beslenme rutinini oturtmak için uygun.',
      LuckCategory.risk: 'Günün düzen havası plansız risklerden çok hesaplı adımları ödüllendiriyor.',
      LuckCategory.sosyal: 'Günün düzen havası sosyal planlarını netleştirmek ve sözlerini tutmak için uygun.',
    },
    5: <LuckCategory, String>{
      LuckCategory.ask: 'Günün hareketli havası aşkta sürprizlere ve rutinden çıkmaya işaret ediyor.',
      LuckCategory.para: 'Günün hareketli havası beklenmedik bir fırsat ya da harcama getirebilir.',
      LuckCategory.saglik: 'Günün hareketli havası yeni bir aktivite denemeyi destekliyor.',
      LuckCategory.risk: 'Günün hareketli havası riski cazip gösteriyor; sınırını baştan koymak önemli.',
      LuckCategory.sosyal: 'Günün hareketli havası yeni ortamlara ve tanışmalara kapı açıyor.',
    },
    6: <LuckCategory, String>{
      LuckCategory.ask: 'Günün şefkatli havası aşkta özeni, ilgiyi ve bağlılığı güçlendiriyor.',
      LuckCategory.para: 'Günün sorumluluk havası aile ve ev giderlerini öne çıkarıyor.',
      LuckCategory.saglik: 'Günün şefkatli havası kendine iyi bakmayı hatırlatıyor.',
      LuckCategory.risk: 'Günün sorumluluk havası sevdiklerini etkileyecek kararlarda temkinli olmayı öneriyor.',
      LuckCategory.sosyal: 'Günün şefkatli havası yakınlarınla bağlarını güçlendiriyor.',
    },
    7: <LuckCategory, String>{
      LuckCategory.ask: 'Günün içe dönük havası aşkta kendi duygularını anlamaya vakit ayırmayı öneriyor.',
      LuckCategory.para: 'Günün düşünceli havası araştırma ve dikkatli değerlendirme için uygun.',
      LuckCategory.saglik: 'Günün sakin havası zihinsel dinlenmeye ve uykuya öncelik vermeyi destekliyor.',
      LuckCategory.risk: 'Günün düşünceli havası riskleri incelemek için uygun, ani adımlar için değil.',
      LuckCategory.sosyal: 'Günün içe dönük havası kalabalık yerine az ve derin sohbetleri öne çıkarıyor.',
    },
    8: <LuckCategory, String>{
      LuckCategory.ask: 'Günün kararlı havası aşkta net konuşmayı ve ilişkinin yönünü belirlemeyi destekliyor.',
      LuckCategory.para: 'Günün sonuç odaklı havası kazanç, tahsilat ve pazarlık için güçlü.',
      LuckCategory.saglik: 'Günün yoğun havası seni çok çalışmaya itebilir; stresini boşaltmayı ihmal etme.',
      LuckCategory.risk: 'Günün kararlı havası hesaplı risklerde işine yarıyor.',
      LuckCategory.sosyal: 'Günün kararlı havası sosyal ortamlarda sözünün dinlenmesini kolaylaştırıyor.',
    },
    9: <LuckCategory, String>{
      LuckCategory.ask: 'Günün kapanış havası aşkta eski bir konuyu kapatmak ya da affetmek için uygun.',
      LuckCategory.para: 'Günün kapanış havası bir borcu kapatmak ya da yarım kalan bir ödemeyi bitirmek için uygun.',
      LuckCategory.saglik: 'Günün kapanış havası seni yoran bir alışkanlığı bırakmayı destekliyor.',
      LuckCategory.risk: 'Günün kapanış havası yeni risklerden çok eldeki işleri bitirmeyi öneriyor.',
      LuckCategory.sosyal: 'Günün kapanış havası seni yoran bir ilişkiye mesafe koymak için uygun.',
    },
  };

  /// Kişisel yıla göre yorumun sonundaki "bu dönem" cümlesi (sayı yok).
  static const Map<int, List<String>> donemCumleleri = <int, List<String>>{
    1: <String>[
      'Genel olarak yeni başlangıçların dönemindesin; bugün attığın küçük adımlar önümüzdeki aylara yön veriyor.',
      'Bu yıl hayatında yeni bir sayfa açılıyor; cesur ama sabırlı olmak sana çok şey kazandırır.',
    ],
    2: <String>[
      'Genel olarak ilişkilerin ve sabrın öne çıktığı bir dönemdesin; sonuçlar yavaş gelse de temeller sağlamlaşıyor.',
      'Bu yıl tek başına koşmak yerine birlikte ilerlemenin kazandırdığı bir dönemdesin.',
    ],
    3: <String>[
      'Genel olarak kendini ifade etmenin ve çevreni genişletmenin dönemindesin; bugün kurduğun bir bağlantı ileride işine yarayabilir.',
      'Bu yıl yaratıcılığın ve sosyal hayatın canlandığı bir dönemdesin; enerjini dağıtmadan kullanmak önemli.',
    ],
    4: <String>[
      'Genel olarak emek verip sağlam temeller kurduğun bir dönemdesin; bugünkü düzenli çaban uzun vadede karşılığını verecek.',
      'Bu yıl çalışmanın ve istikrarın ön planda olduğu bir dönemdesin; yorulduğunda kurduğun yapının değerini hatırla.',
    ],
    5: <String>[
      'Genel olarak değişimlerin ve yeni deneyimlerin dönemindesin; esnek kaldıkça fırsatlar çoğalıyor.',
      'Bu yıl hayatında hareketin arttığı bir dönemdesin; aceleci kararlar yerine bilinçli değişimler kazandırır.',
    ],
    6: <String>[
      'Genel olarak aile, ev ve yakın ilişkilerin öne çıktığı bir dönemdesin; verdiğin emek sevdiklerinle bağında karşılık buluyor.',
      'Bu yıl sorumlulukların arttığı bir dönemdesin; başkalarına verirken kendini ihmal etmemek önemli.',
    ],
    7: <String>[
      'Genel olarak içe dönmenin, öğrenmenin ve kendini tanımanın dönemindesin; sessiz geçen zamanlar sana yön kazandırıyor.',
      'Bu yıl düşünmenin ve derinleşmenin önemli olduğu bir dönemdesin; hızdan çok anlam arayışı kazandırıyor.',
    ],
    8: <String>[
      'Genel olarak iş, para ve kariyer konularının öne çıktığı bir dönemdesin; kararlı adımların karşılık bulma ihtimali yüksek.',
      'Bu yıl emeğinin karşılığını alabileceğin bir dönemdesin; hedeflere odaklanırken dengeyi korumak önemli.',
    ],
    9: <String>[
      'Genel olarak kapanışların ve ayıklamanın dönemindesin; bugün bir şeyi tamamlamak ya da bırakmak içini rahatlatacak.',
      'Bu yıl artık sana iyi gelmeyenleri geride bıraktığın bir dönemdesin; hafifledikçe yeni başlangıçlara yer açılıyor.',
    ],
  };

  /// Okuyucunun durumuna göre [kategori] durum anahtarı.
  ///
  /// Aşk: ilişki durumu; para: uğraş; risk: karar tarzı; sosyal: enerji
  /// tarzı; sağlık: her zaman genel. Bilinmeyen durumda [genelAnahtar].
  static String durumAnahtari(LuckCategory kategori, OkuyucuTercihleri t) {
    final String? anahtar = switch (kategori) {
      LuckCategory.ask => t.iliski == null
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
