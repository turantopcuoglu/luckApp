/// Gökyüzü tabanlı kategori okumaları: Aşk, Para, Sağlık, Risk ve Sosyal.
///
/// Bu kategorilerde günün gerekçesi numeroloji değil gerçek gökyüzüdür:
/// Ay'ın o gün bulunduğu burcun elementi, kişinin Güneş burcunun
/// elementiyle karşılaştırılır (aynı / tamamlayıcı / nötr / zıt) ve
/// kategori skorunun tonuyla birleşir. Ay her 2-3 günde burç
/// değiştirdiği ve kişi bunu başka kaynaklardan da doğrulayabildiği için
/// okuma "bugüne" bağlanır.
///
/// Bir okuma şu parçalardan kurulur ve her parça tek bir fikre hizmet eder:
/// 1. [basliklar]: kısa, çarpıcı başlık.
/// 2. [gokyuzu]: Ay burcu + kişinin burcu + tonun iç hissi.
/// 3. Kişilik cümlesi: Güneş burcundan ya da yaşam yolundan, kişinin
///    cevaplarıyla çelişmeyenler arasından (bkz. `kisilik_metinleri.dart`).
/// 4. [sahneler]: kişinin gündelik hayatından somut bir an (Aşk'ta ilişki
///    durumuna, diğerlerinde uğraşa göre).
/// 5. [yap] / [yapma] ve [kisiselYap]: kısa, uygulanabilir öneriler.
///
/// Yazım kuralları (bkz. `sayi_metinleri.dart`) ek olarak:
/// - Onboarding cevapları metinde geri söylenmez: "şarj olmak", "kalbini
///   dinlemek", "öğrencisin", "ilişkin var" gibi seçenek ifadeleri yasak
///   (bkz. [ContentConfig.yankiIfadeleri]). Cevap yalnızca hangi sahnenin
///   ve önerinin seçileceğini belirler.
/// - Aşk metinleri ilişki durumunu varsaymaz; ortak havuzlar hem bekar hem
///   ilişkisi olan okura uyar.
/// - Yer tutucular: `{ayBurcu}` (günün Ay burcu), `{burc}` (kişinin
///   Güneş burcu). Ekleme sorunu olmasın diye burç adları "… burcunda",
///   "… burcunun" kalıbıyla kullanılır.
library;

import '../luck_engine/luck_engine.dart';
import 'content_config.dart';
import 'dongu_metinleri.dart';
import 'okuyucu.dart';

/// Sahne cümlesinin yönü: günün tonuna göre koruyucu ya da fırsat odaklı.
enum SahneYonu {
  /// Düşük tonlu günler: koruyucu, yavaşlatıcı sahneler.
  temkin,

  /// Orta ve yüksek tonlu günler: akışta, fırsat gösteren sahneler.
  akis;

  /// [ton] için sahne yönü.
  static SahneYonu tondan(KategoriTonu ton) =>
      ton == KategoriTonu.dusuk ? SahneYonu.temkin : SahneYonu.akis;
}

/// Gökyüzü tabanlı kategori metin havuzları.
abstract final class GokyuzuMetinleri {
  /// Cevap bilinmediğinde kullanılan sahne anahtarı.
  static const String genelAnahtar = 'genel';

  /// İlişkisi olmayan okuyucunun Aşk anahtarı.
  static const String bekarAnahtari = 'bekar';

  /// İlişkisi olan (sevgili ya da evli) okuyucunun Aşk anahtarı.
  static const String partnerliAnahtari = 'partnerli';

  /// İlişki durumunun Aşk anahtarı (bilinmiyorsa null).
  static String? _iliskiAnahtari(OkuyucuTercihleri t) => switch (t.iliski) {
    null => null,
    final IliskiDurumu d => d.partnerliMi ? partnerliAnahtari : bekarAnahtari,
  };

  /// Okuyucunun [kategori]deki sahne anahtarı: Aşk'ta ilişki durumu,
  /// diğerlerinde uğraş; bilinmiyorsa [genelAnahtar].
  static String sahneAnahtari(LuckCategory kategori, OkuyucuTercihleri t) =>
      (kategori == LuckCategory.ask ? _iliskiAnahtari(t) : t.ugras?.name) ??
      genelAnahtar;

  /// Okuyucunun [kategori]deki kişisel öneri anahtarı (yoksa null).
  ///
  /// Aşk: ilişki durumu; Para ve Risk: karar tarzı; Sağlık ve Sosyal:
  /// enerji tarzı.
  static String? kisiselAnahtar(LuckCategory kategori, OkuyucuTercihleri t) =>
      switch (kategori) {
        LuckCategory.ask => _iliskiAnahtari(t),
        LuckCategory.para || LuckCategory.risk => t.karar?.name,
        LuckCategory.saglik || LuckCategory.sosyal => t.enerji?.name,
      };

  /// Element ilişkisi (Ay ↔ kişinin Güneşi) × günün tonu → günlük kartın
  /// açılış paragrafındaki gökyüzü cümlesi (kategoriden bağımsız, günün
  /// genel havası). Açılış cümlesinden sonra gelir; "Bugün" ile başlamaz.
  static const Map<ElementIliskisi, Map<GunTonu, List<String>>>
  gunler = <ElementIliskisi, Map<GunTonu, List<String>>>{
    ElementIliskisi.ayni: <GunTonu, List<String>>{
      GunTonu.dusuk: <String>[
        'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; duyguların tanıdık ama yoğun, en iyi bildiğin şeyleri yapmak seni korur.',
        '{ayBurcu} burcundaki Ay senin elementinden geçiyor; alışkanlıkların güçleniyor, yorucu olanlara karşı biraz daha dikkatli ol.',
        'Ay senin elementinde ({ayBurcu}); kendi temponda kaldığın sürece günün zorlukları sana daha az dokunur.',
      ],
      GunTonu.orta: <String>[
        'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; kendini evinde hissettiğin, sakin ve tanıdık bir akış var.',
        '{ayBurcu} burcundaki Ay sana tanıdık geliyor; neyin sana iyi geldiğini bugün her zamankinden net görüyorsun.',
        'Ay senin elementinde dolaşıyor ({ayBurcu}); olduğun gibi davrandığında işler kendiliğinden yerine oturur.',
      ],
      GunTonu.yuksek: <String>[
        'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; doğallığın parlıyor ve günün enerjisi seninle aynı dili konuşuyor.',
        '{ayBurcu} burcundaki Ay güçlü yanlarını büyütüyor; kendine güvenmek için daha iyi bir an zor bulunur.',
        'Ay senin elementinde ({ayBurcu}) ve rüzgâr arkanda; içinden gelen adımı atmaktan çekinme.',
      ],
    },
    ElementIliskisi.tamamlayici: <GunTonu, List<String>>{
      GunTonu.dusuk: <String>[
        'Ay {ayBurcu} burcunda ve {burc} burcunun elementini destekliyor; zorlandığın anlarda bu destek seni beklediğinden çabuk toparlar.',
        '{ayBurcu} burcundaki Ay arkanda duruyor; gün ağır gelse de yanında birinin olması işini kolaylaştırır.',
        'Ay destekleyici bir elementte ({ayBurcu}); yavaş ilerlesen de doğru yönde ilerliyorsun.',
      ],
      GunTonu.orta: <String>[
        'Ay {ayBurcu} burcunda ve {burc} burcunun elementini besliyor; gün sana hafif bir rüzgâr gibi eşlik ediyor.',
        '{ayBurcu} burcundaki Ay seni destekleyen bir konumda; küçük adımlar beklediğinden çabuk karşılık bulur.',
        'Ay destekleyici bir elementte ({ayBurcu}); çevrendekilerle iş birliği yaptığında gün daha da kolaylaşır.',
      ],
      GunTonu.yuksek: <String>[
        'Ay {ayBurcu} burcunda ve {burc} burcunun elementine güç veriyor; enerjin yüksek, kapılar kolay aralanıyor.',
        '{ayBurcu} burcundaki Ay seni öne çıkarıyor; fikirlerini paylaşmak ve harekete geçmek için an yerinde.',
        'Ay destekleyici bir elementte ({ayBurcu}) ve şans senden yana esiyor; ertelediğin bir şeye başla.',
      ],
    },
    ElementIliskisi.notr: <GunTonu, List<String>>{
      GunTonu.dusuk: <String>[
        'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; ritmini bulmak biraz zaman alabilir, kendine sabırlı davran.',
        '{ayBurcu} burcundaki Ay sana alışık olmadığın bir dilden sesleniyor; yanlış anlaşılmalara karşı sözlerini netleştir.',
        'Ay farklı bir elementte ({ayBurcu}); planlarını esnek tutmak günün sürprizlerine karşı en iyi korumandır.',
      ],
      GunTonu.orta: <String>[
        'Ay {ayBurcu} burcunda, {burc} burcuna farklı bir açıdan bakıyor; alışkanlıklarının dışındaki küçük bir değişiklik günü tazeler.',
        '{ayBurcu} burcundaki Ay sana yeni bir bakış öneriyor; bildiğin bir şeye başka bir yerden bakmak ufkunu açar.',
        'Ay farklı bir elementte ({ayBurcu}); merakını açık tuttuğunda gün sana beklemediğin bir şey öğretebilir.',
      ],
      GunTonu.yuksek: <String>[
        'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; bu fark sana tazelik ve yeni bir cesaret getiriyor.',
        '{ayBurcu} burcundaki Ay seni rutinin dışına çağırıyor; denemediğin bir yol beklediğinden şanslı çıkabilir.',
        'Ay farklı bir elementte ({ayBurcu}) ve bu değişiklik seni canlandırıyor; yeni bir şeye evet de.',
      ],
    },
    ElementIliskisi.zit: <GunTonu, List<String>>{
      GunTonu.dusuk: <String>[
        'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; küçük sürtünmeler olabilir, tepki vermeden önce bir nefes al.',
        '{ayBurcu} burcundaki Ay seninle çekişiyor; yorgun hissedersen bu senden değil, günün havasından.',
        'Ay zıt bir elementte ({ayBurcu}); zorlamak yerine akışı beklemek seni korur.',
      ],
      GunTonu.orta: <String>[
        'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters düşüyor; hafif bir gerilim var ama yönetilebilir, acele etmemek yeter.',
        '{ayBurcu} burcundaki Ay seni alışık olmadığın bir yöne çekiyor; bu hafif zorlanma aynı zamanda seni büyütüyor.',
        'Ay zıt bir elementte ({ayBurcu}); farklı düşünen biriyle konuşmak sana yeni bir pencere açabilir.',
      ],
      GunTonu.yuksek: <String>[
        'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; bu gerilim seni yormuyor, kıvılcım veriyor.',
        '{ayBurcu} burcundaki Ay seni meydan okumaya çağırıyor; zor görünen işi bugün halledebilirsin.',
        'Ay zıt bir elementte ({ayBurcu}) ama enerjin güçlü; cesur bir adım beklediğinden iyi karşılanır.',
      ],
    },
  };

  /// Kategori × ton → başlık.
  static const Map<LuckCategory, Map<KategoriTonu, List<String>>> basliklar =
      <LuckCategory, Map<KategoriTonu, List<String>>>{
        LuckCategory.ask: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Kalbini acele ettirme.',
            'Önce kendine iyi davran.',
            'Söz değil, davranış.',
          ],
          KategoriTonu.orta: <String>[
            'Küçük jest, büyük yankı.',
            'Kalbin sakin, bağın sıcak.',
            'Olduğun gibi ol.',
          ],
          KategoriTonu.yuksek: <String>[
            'Kalbin açık, kapılar da.',
            'İçinden geçeni söyle.',
            'Çekiciliğin zirvede.',
          ],
        },
        LuckCategory.para: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Eldekini koru.',
            'Sepeti bir gün beklet.',
            'Önce hesap, sonra harcama.',
          ],
          KategoriTonu.orta: <String>[
            'Düzen bereket getirir.',
            'Küçük adım, sağlam kazanç.',
            'Bütçene bir göz at.',
          ],
          KategoriTonu.yuksek: <String>[
            'Emeğinin karşılığını iste.',
            'Kazanç tarafında elin güçlü.',
            'Fırsatı erken gör.',
          ],
        },
        LuckCategory.saglik: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Bedenin bugün yavaşlamanı istiyor.',
            'Hız değil, toparlanma günü.',
            'Yorgunluğu görmezden gelme.',
          ],
          KategoriTonu.orta: <String>[
            'Dengedesin, ama ihmale gelmez.',
            'Küçük molalar, büyük fark.',
            'Bedeninin ritmini dinle.',
          ],
          KategoriTonu.yuksek: <String>[
            'Enerjin yüksek, harekete geç.',
            'Bedenin bugün senden yana.',
            'Zindeliğini iyi bir şeye harca.',
          ],
        },
        LuckCategory.risk: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Bugün şansı zorlama.',
            'Önce bilgi, sonra karar.',
            'Acele eden kaybeder.',
          ],
          KategoriTonu.orta: <String>[
            'Hesaplı bir adım yeterli.',
            'Küçük dene, büyük öğren.',
            'Orta yol bugün en güvenlisi.',
          ],
          KategoriTonu.yuksek: <String>[
            'Cesaret bugün karşılık buluyor.',
            'Beklediğin adımın zamanı.',
            'Şans hazırlıklı olandan yana.',
          ],
        },
        LuckCategory.sosyal: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Az ama iyi insan.',
            'Sözlerini yumuşak seç.',
            'Kendine alan açmak da sosyalliktir.',
          ],
          KategoriTonu.orta: <String>[
            'Bir mesaj, bir bağ.',
            'Sohbetler kolay akıyor.',
            'Tanıdık yüzler seni toparlar.',
          ],
          KategoriTonu.yuksek: <String>[
            'Kapılar insanlara açık.',
            'Ortamın ışığı sensin.',
            'İlk adımı sen at.',
          ],
        },
      };

  /// Kategori × element ilişkisi (Ay ↔ kişinin Güneşi) × ton → gökyüzü
  /// cümlesi. Her hücrenin üç varyantı farklı cümle kalıbıyla açılır.
  static const Map<
    LuckCategory,
    Map<ElementIliskisi, Map<KategoriTonu, List<String>>>
  >
  gokyuzu = <LuckCategory, Map<ElementIliskisi, Map<KategoriTonu, List<String>>>>{
    LuckCategory.ask: <ElementIliskisi, Map<KategoriTonu, List<String>>>{
      ElementIliskisi.ayni: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; duyguların yoğun ve tanıdık ama bu yoğunluk küçük bir sözü büyütebilir, kalbini acele ettirme.',
          '{ayBurcu} burcundaki Ay hislerini ikiye katlıyor; bir mesajın gecikmesini olduğundan fazla anlamlandırmaya yatkınsın.',
          'Ay senin elementinde ({ayBurcu}); kalbin kendi bildiğini istiyor, karşındakinin ritmini de hesaba katmak gerginliği önler.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; kalbin rahat, olduğun gibi davrandığında ilgi kendiliğinden geliyor.',
          '{ayBurcu} burcundaki Ay sana tanıdık bir sıcaklık veriyor; küçük bir jest sandığından uzun süre hatırlanır.',
          'Ay senin elementinde dolaşıyor ({ayBurcu}); duygularını kendi dilinle söylemek için an yerinde.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; çekiciliğin doğal hâlinde, kalbin de ne istediğini çok net biliyor.',
          '{ayBurcu} burcundaki Ay duygularını parlatıyor; içinden geçeni söylemek için daha iyi bir an zor bulunur.',
          'Ay senin elementinde ({ayBurcu}) ve yakınlık kolay kuruluyor; bir bakış, bir mesaj beklediğinden çok şey başlatabilir.',
        ],
      },
      ElementIliskisi.tamamlayici: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementini destekliyor ama kalbin biraz yorgun; yakınlık için zorlamak yerine dinlenmeyi seç.',
          '{ayBurcu} burcundaki Ay arkanda, yine de beklentiler kolay kırılabilir; söze değil davranışa bak.',
          'Ay destekleyici bir elementte ({ayBurcu}); bu desteği yeni bir başlangıç için değil, kendini toparlamak için kullan.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementini besliyor; duygular yumuşak akıyor, küçük bir ilgi büyük yankı bulabilir.',
          '{ayBurcu} burcundaki Ay seni sevdiğin insanlara yakınlaştırıyor; birlikte geçen sakin bir an en değerli hediye.',
          'Ay destekleyici bir elementte ({ayBurcu}); içten bir teşekkür ya da küçük bir hatırlatma bağını güçlendirir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda ve {burc} burcunun elementine güç veriyor; kalbin açık, ilgi de karşılık da kolay geliyor.',
          '{ayBurcu} burcundaki Ay aşk tarafında kapıları aralıyor; ilk adımı atmak için cesaretin yerinde.',
          'Ay destekleyici bir elementte ({ayBurcu}); hissettiklerini göstermek bağını beklediğinden hızlı derinleştirir.',
        ],
      },
      ElementIliskisi.notr: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; karşındakinin niyetini yanlış okuyabilirsin, varsaymak yerine sor.',
          '{ayBurcu} burcundaki Ay duygularını bulanıklaştırıyor; önemli bir konuşmayı netleşene kadar ertelemek iyi olur.',
          'Ay alışık olmadığın bir elementte ({ayBurcu}); kalbin bir şey, aklın başka bir şey söyleyebilir, karar için acele etme.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna farklı bir dilden sesleniyor; sevginin alışık olmadığın bir ifadesi seni şaşırtabilir.',
          '{ayBurcu} burcundaki Ay aşka yeni bir renk katıyor; rutinin dışında küçük bir plan heyecan katar.',
          'Ay farklı bir elementte ({ayBurcu}); karşındakinin sevgiyi nasıl gösterdiğini merak etmek aranızı yakınlaştırır.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; bu fark seni gizemli ve çekici kılıyor.',
          '{ayBurcu} burcundaki Ay seni beklenmedik bir yakınlığa taşıyabilir; tanıdık kalıplarının dışına çıkmaktan çekinme.',
          'Ay farklı bir elementte ({ayBurcu}) ve kalbin meraklı; yeni bir şey denemek aşkta heyecanı tazeler.',
        ],
      },
      ElementIliskisi.zit: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; duygular kolay alevlenebilir, kırıcı bir sözü söylemeden önce bekle.',
          '{ayBurcu} burcundaki Ay kalbinle çekişiyor; kıskançlık ya da alınganlık hissedersen bunu bir gece beklet.',
          'Ay zıt bir elementte ({ayBurcu}); aşk tarafında beklentini küçük tutmak seni hayal kırıklığından korur.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters düşüyor; farklılıklar görünür olabilir, onları tartışmak yerine merak et.',
          '{ayBurcu} burcundaki Ay ile aranda hafif bir gerilim var; duygusal konuşmalarda tonun sözünden önemli.',
          'Ay zıt bir elementte ({ayBurcu}); kalbinin istediğiyle ihtiyacı arasındaki farkı görebilirsin.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; bu gerilim aşkta kıvılcım yaratıyor, çekim güçlü.',
          '{ayBurcu} burcundaki Ay seni alışık olmadığın türden birine çekebilir; zıtlıklar heyecan verici.',
          'Ay zıt bir elementte ({ayBurcu}) ama kalbin cesur; içinden geçeni söylemek beklenmedik bir kapı açar.',
        ],
      },
    },
    LuckCategory.para: <ElementIliskisi, Map<KategoriTonu, List<String>>>{
      ElementIliskisi.ayni: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; para konusundaki alışkanlıkların güçleniyor, harcama dürtüne dikkat et.',
          '{ayBurcu} burcundaki Ay kendinden emin hissettiriyor ama maddi kararlarda bu güven aceleye dönüşebilir; büyük ödemeleri ertele.',
          'Ay senin elementinde ({ayBurcu}); bildiğin yoldan şaşma, yeni bir maddi deneme için zaman değil.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; maddi konularda kendi yöntemin işe yarıyor, düzenini koru.',
          '{ayBurcu} burcundaki Ay sana tanıdık bir netlik veriyor; küçük bir bütçe kararını rahatça verebilirsin.',
          'Ay senin elementinden geçiyor ({ayBurcu}); emeğinin karşılığını sakin ama net bir dille istemek için an yerinde.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; maddi sezgilerin keskin, fırsatı erken görüyorsun.',
          '{ayBurcu} burcundaki Ay kazanç tarafında elini güçlendiriyor; ertelediğin bir teklif ya da tahsilat için zaman yerinde.',
          'Ay senin elementinde ({ayBurcu}) ve emeğin görünür oluyor; değerini söylemekten çekinme.',
        ],
      },
      ElementIliskisi.tamamlayici: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementini destekliyor; yine de para tarafında temkin kazandırır, eldekini koru.',
          '{ayBurcu} burcundaki Ay arkanda ama küçük harcamalar birikebilir; günün sonunda hesabına bir bak.',
          'Ay destekleyici bir elementte ({ayBurcu}); bu desteği yeni bir harcamaya değil, açığını kapatmaya kullan.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementini besliyor; düzenli küçük adımlar maddi tarafta karşılık bulur.',
          '{ayBurcu} burcundaki Ay hesaplarını netleştiriyor; bütçeni gözden geçirmek için iyi bir an.',
          'Ay destekleyici bir elementte ({ayBurcu}); bir iş birliği ya da ortak plan maddi tarafta kazandırabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda ve {burc} burcunun elementine güç veriyor; kazanç, tahsilat ve pazarlıkta elin güçlü.',
          '{ayBurcu} burcundaki Ay maddi kapıları aralıyor; beklenen bir dönüş ya da yeni bir gelir fikri gündeme gelebilir.',
          'Ay destekleyici bir elementte ({ayBurcu}); emeğinin karşılığını istemek için cesaretin yerinde.',
        ],
      },
      ElementIliskisi.notr: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; maddi tabloyu tam göremeyebilirsin, imza ve ödemeleri netleşene kadar beklet.',
          '{ayBurcu} burcundaki Ay rakamları bulanıklaştırıyor; parlak görünen bir teklifin ayrıntısına in.',
          'Ay alışık olmadığın bir elementte ({ayBurcu}); harcamak yerine bilgi topla.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna farklı bir açıdan bakıyor; alışık olmadığın bir tasarruf yolu işine yarayabilir.',
          '{ayBurcu} burcundaki Ay sana farklı bir bakış öneriyor; bir harcamayı başka biriyle konuşmak netlik verir.',
          'Ay farklı bir elementte ({ayBurcu}); maddi kararlarda orta yolu seçmek seni korur.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; bu fark sana yeni bir kazanç fikri getirebilir.',
          '{ayBurcu} burcundaki Ay rutinin dışındaki fırsatları gösteriyor; farklı bir gelir yolunu düşünmek için an yerinde.',
          'Ay farklı bir elementte ({ayBurcu}) ve maddi merakın yüksek; öğrenmek istediğin bir konuya küçük bir bütçe ayırmak kazandırır.',
        ],
      },
      ElementIliskisi.zit: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; ani harcama isteği güçlenebilir, sepeti bir gün beklet.',
          '{ayBurcu} burcundaki Ay seni maddi tarafta zıt yöne çekiyor; bugün verilen bir parasal söz yarın ağır gelebilir.',
          'Ay zıt bir elementte ({ayBurcu}); şansı zorlamak yerine bütçeni korumak kazandırır.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters düşüyor; bir maddi karar seni iki yana çekebilir, ikisini de yazıya dök.',
          '{ayBurcu} burcundaki Ay ile aranda hafif bir gerilim var; para konuşmalarında sakin kalmak pazarlık gücünü korur.',
          'Ay zıt bir elementte ({ayBurcu}); güvendiğin birinin maddi konudaki itirazı işine yarayabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; bu gerilim sana pazarlıkta cesaret veriyor.',
          '{ayBurcu} burcundaki Ay seni konfor alanının dışına itiyor; maddi tarafta beklemediğin bir fırsat orada olabilir.',
          'Ay zıt bir elementte ({ayBurcu}) ama maddi kararların keskin; ertelediğin bir adımı atabilirsin.',
        ],
      },
    },
    LuckCategory.saglik: <ElementIliskisi, Map<KategoriTonu, List<String>>>{
      ElementIliskisi.ayni: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; tanıdık bir enerji ama fazlası bedenini çabuk yorabilir, temponu yarıya indirmek seni korur.',
          '{ayBurcu} burcundaki Ay alışkanlıklarını büyütüyor, iyileri de yorucu olanları da; bedenin en çok düzenli bir mola istiyor.',
          'Ay senin elementinden geçiyor ({ayBurcu}) ve {burc} enerjini ikiye katlıyor; bu fazlalık bedende gerginlik olarak birikebilir, akşamı sakin tut.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; bedenin kendi ritmini kolayca buluyor, onu zorlamadan takip etmen yeterli.',
          '{ayBurcu} burcundaki Ay sana tanıdık geliyor: enerjin dengeli, yalnızca saatlerce aynı yerde oturup kalmamaya dikkat et.',
          'Ay senin elementinde dolaşıyor ({ayBurcu}); beden de zihin de alışık olduğu tempoda, küçük bir hareket günü canlandırır.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; bedenin kendini evinde hissediyor ve enerjin kolayca yükseliyor.',
          '{ayBurcu} burcundaki Ay {burc} enerjini besliyor; uzun zamandır ertelediğin bir hareketi denemek için bedenin hazır.',
          'Ay senin elementinden geçerken ({ayBurcu}) dayanıklılığın artıyor; yorgunluk sana her zamankinden az dokunuyor.',
        ],
      },
      ElementIliskisi.tamamlayici: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementini besleyen bir yerde; yine de enerjin düşük seyredebilir, bu desteği dinlenerek kullan.',
          '{ayBurcu} burcundaki Ay sana destek veriyor ama bedenin yavaşlamak istiyor; ona kulak vermek yarını daha güçlü başlatır.',
          'Ay elementini destekleyen bir burçta ({ayBurcu}); bu destek hızdan çok toparlanmaya yarıyor, uykunu öne al.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementini besliyor; enerjin akışta, gündeki ufak bir düzen değişikliği bile fark yaratır.',
          '{ayBurcu} burcundaki Ay bedenine hafif bir rüzgâr gibi geliyor: ne çok hızlı ne çok yavaş, dengeyi bulmak kolay.',
          'Ay elementini destekleyen bir burçta ({ayBurcu}); gün içindeki küçük molalar sandığından çok şey değiştirir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda ve {burc} burcunun elementine güç veriyor; bedenin hafif, zihnin açık, enerjini harekete çevirmek için an yerinde.',
          '{ayBurcu} burcundaki Ay enerjine yakıt ekliyor; kendini her zamankinden zinde hissedebilirsin.',
          'Ay elementini destekleyen bir burçtan geçiyor ({ayBurcu}); yeni bir alışkanlığa başlamak sana zor gelmez.',
        ],
      },
      ElementIliskisi.notr: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; bedenin ritmini bulmakta biraz zorlanabilir, kendine ek zaman tanı.',
          '{ayBurcu} burcundaki Ay alışık olduğun tempodan farklı çalışıyor; yorgunluk hissi bundan, zorlamak yerine yavaşla.',
          'Ay sana uzak bir elementte ({ayBurcu}); bedenin bildik şeylerle daha iyi toparlanır: su, uyku, sessizlik.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna farklı bir dilden sesleniyor; bedenin uyum sağlıyor ama alışkanlıklarını esnetmek seni rahatlatır.',
          '{ayBurcu} burcundaki Ay sana yeni bir ritim öneriyor; rutininde ufak bir değişiklik günü tazeleyebilir.',
          'Ay farklı bir elementten geçiyor ({ayBurcu}); enerjin dalgalı değil, sadece farklı, günü küçük parçalara bölmek rahatlatır.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; bu fark bedenine tazelik katıyor.',
          '{ayBurcu} burcundaki Ay alışık olmadığın bir canlılık getiriyor; farklı bir hareket türü sana çok iyi gelebilir.',
          'Ay farklı bir elementte ({ayBurcu}) ve bu değişiklik enerjini açıyor; bedenin yeniliğe hazır.',
        ],
      },
      ElementIliskisi.zit: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; bedenin bu sürtünmeyi gerginlik olarak taşıyabilir, omuzlarını ve nefesini kontrol et.',
          '{ayBurcu} burcundaki Ay enerjinle çekişiyor; yorgunluğun sebebi iş yükünden çok bu uyumsuzluk, kendine yumuşak davran.',
          'Ay zıt bir elementte ({ayBurcu}); bedenini zorlayacak planları erteleyip dinlenmeye alan aç.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters düşüyor; enerjin yerinde ama çabuk dağılabilir, tek bir işe odaklanmak seni korur.',
          '{ayBurcu} burcundaki Ay ile elementin arasında hafif bir gerilim var; ara ara ayağa kalkıp esnemek bu gerilimi boşaltır.',
          'Ay zıt bir elementte ({ayBurcu}); bedenin dengede ama sınırda, akşamı hafif tutmak iyi olur.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; bu sürtünme seni yormuyor, aksine kıvılcım veriyor.',
          '{ayBurcu} burcundaki Ay enerjinle çekişiyor ama kazanan sen oluyorsun; bedenin meydan okumaya hazır.',
          'Ay zıt bir elementte ({ayBurcu}) ve bu gerilim sana hareket isteği veriyor; onu bastırma, harekete dök.',
        ],
      },
    },
    LuckCategory.risk: <ElementIliskisi, Map<KategoriTonu, List<String>>>{
      ElementIliskisi.ayni: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; içgüdülerin güçlü ama bu güç aceleye dönüşebilir, büyük bir kararı yarına bırak.',
          '{ayBurcu} burcundaki Ay alışkanlıklarını büyütüyor; kararlarında hep düştüğün tuzağa düşmemek için bir kez dur.',
          'Ay senin elementinde ({ayBurcu}); kendinden emin hissetsen de riskleri küçük tutmak daha akıllıca.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; kararlarında kendi sesini net duyuyorsun, küçük adımlar için bu yeterli.',
          '{ayBurcu} burcundaki Ay sana tanıdık bir netlik veriyor; bildiğin alanda karar vermek kolay, yabancı alanda acele etme.',
          'Ay senin elementinden geçiyor ({ayBurcu}); seçimlerin kendine benziyor ve bu işine yarıyor.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; sezgilerin keskin, uzun süredir tarttığın bir adım için zemin sağlam.',
          '{ayBurcu} burcundaki Ay cesaretini ikiye katlıyor; fırsat gördüğün yerde tereddüt etme.',
          'Ay senin elementinde ({ayBurcu}) ve kararlarına güven veriyor; ilk hissin isabetli olabilir.',
        ],
      },
      ElementIliskisi.tamamlayici: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementini destekliyor; yine de şans temkinli olandan yana, riskleri bölerek al.',
          '{ayBurcu} burcundaki Ay arkanda ama zemin biraz kaygan; kararını vermeden önce bir kişiye daha danış.',
          'Ay destekleyici bir elementte ({ayBurcu}); bu desteği yeni risk için değil, eldekini korumak için kullan.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementini besliyor; hesaplı bir risk karşılık bulabilir.',
          '{ayBurcu} burcundaki Ay seçeneklerini netleştiriyor; artıları ve eksileri yazınca doğru yol kendini gösterir.',
          'Ay destekleyici bir elementte ({ayBurcu}); küçük bir deneme, büyük bir taahhütten daha çok şey öğretir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda ve {burc} burcunun elementine rüzgâr veriyor; şans cesur ama hazırlıklı olandan yana.',
          '{ayBurcu} burcundaki Ay kapıları aralıyor; ertelediğin bir başvuru, teklif ya da soru için zaman yerinde.',
          'Ay destekleyici bir elementte ({ayBurcu}); kararlarında akış senden yana, tereddüdü kısa tut.',
        ],
      },
      ElementIliskisi.notr: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; durumu tam okuyamayabilirsin, kesin bir karar için bir gün daha bekle.',
          '{ayBurcu} burcundaki Ay işleri bulanıklaştırıyor; ilk bakışta parlak görünen bir teklifin ayrıntısına in.',
          'Ay alışık olmadığın bir elementte ({ayBurcu}); riski değil, bilgiyi büyüt.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna farklı bir açıdan bakıyor; alışık olmadığın bir seçenek düşündüğünden mantıklı çıkabilir.',
          '{ayBurcu} burcundaki Ay sana başka bir bakış açısı öneriyor; kararını birine anlatmak onu netleştirir.',
          'Ay farklı bir elementte ({ayBurcu}); orta yolu bulmak hem cesaretini hem güvenliğini korur.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; bu yabancılık seni yeni bir fırsata itiyor.',
          '{ayBurcu} burcundaki Ay rutinin dışına çıkmayı ödüllendiriyor; denemediğin bir yol şanslı çıkabilir.',
          'Ay farklı bir elementte ({ayBurcu}) ve bu fark sezgini açıyor; beklenmedik bir teklife açık ol.',
        ],
      },
      ElementIliskisi.zit: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir konumda; içinle dışın aynı şeyi söylemeyebilir, büyük adımları ertele.',
          '{ayBurcu} burcundaki Ay seni zıt yöne çekiyor; bugün verdiğin bir "evet" yarın ağır gelebilir.',
          'Ay zıt bir elementte ({ayBurcu}); şansı zorlamak yerine elindekini korumak kazandırır.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters düşüyor; bir karar seni iki yana çekebilir, ikisini de yazıya dökmek dengeler.',
          '{ayBurcu} burcundaki Ay ile aranda hafif bir gerilim var; acele etmeden ama ertelemeden ilerlemek doğru denge.',
          'Ay zıt bir elementte ({ayBurcu}); güvendiğin birinin itirazı işine yarayabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; bu gerilim sana cesaret veriyor, beklediğin adımı atabilirsin.',
          '{ayBurcu} burcundaki Ay seni konfor alanının dışına itiyor ve şans tam orada bekliyor.',
          'Ay zıt bir elementte ({ayBurcu}) ama kararların keskin; zorlayıcı görünen seçenek en kazançlısı olabilir.',
        ],
      },
    },
    LuckCategory.sosyal: <ElementIliskisi, Map<KategoriTonu, List<String>>>{
      ElementIliskisi.ayni: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; kendi dünyanda rahatsın ama başkalarının ritmine sabrın azalabilir, sözlerini yumuşak seç.',
          '{ayBurcu} burcundaki Ay seni kendine çekiyor; kalabalık yorabilir, bir planı kısaltmak sorun değil.',
          'Ay senin elementinde ({ayBurcu}); sana benzeyenlerle rahat, farklı olanlarla çabuk gerilebilirsin.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; seni tanıyan insanlarla vakit geçirmek en iyi gelen şey.',
          '{ayBurcu} burcundaki Ay ilişkilerine tanıdık bir sıcaklık katıyor; eski bir dosta yazmak için an yerinde.',
          'Ay senin elementinde ({ayBurcu}); kendin gibi davrandığında insanlar sana daha kolay yaklaşıyor.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunla aynı elementte; doğallığın parlıyor, girdiğin ortam seninle ısınıyor.',
          '{ayBurcu} burcundaki Ay çekiciliğini artırıyor; bir davet ya da tanışma beklediğinden güzel geçebilir.',
          'Ay senin elementinde ({ayBurcu}); sözlerin karşılık buluyor, fikrini paylaşmaktan çekinme.',
        ],
      },
      ElementIliskisi.tamamlayici: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementini destekliyor ama sosyal enerjin düşük; çok kişiyle değil, iyi gelen bir kişiyle görüş.',
          '{ayBurcu} burcundaki Ay arkanda, yine de bir yanlış anlaşılma kolay büyüyebilir; mesajlarını göndermeden önce bir kez oku.',
          'Ay destekleyici bir elementte ({ayBurcu}); sosyal yükünü azaltmak ilişkilerini korur.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementini besliyor; sohbetler kolay akıyor, kısa bir buluşma enerjini tazeler.',
          '{ayBurcu} burcundaki Ay seni insanlara yakınlaştırıyor; bir teşekkür ya da takdir güçlü bir bağ kurar.',
          'Ay destekleyici bir elementte ({ayBurcu}); ortak bir plan ya da küçük bir yardımlaşma günü güzelleştirir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda ve {burc} burcunun elementine rüzgâr veriyor; yeni insanlarla tanışmak ve bağ kurmak çok kolay.',
          '{ayBurcu} burcundaki Ay sosyal şansını açıyor; bir grupta sesin her zamankinden çok duyulur.',
          'Ay destekleyici bir elementte ({ayBurcu}); insanları bir araya getiren sen olabilirsin.',
        ],
      },
      ElementIliskisi.notr: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; insanların ne demek istediğini yanlış okuyabilirsin, her şeyi kişisel alma.',
          '{ayBurcu} burcundaki Ay iletişimi biraz bulandırıyor; önemli bir konuşmayı yüz yüze yapmak daha güvenli.',
          'Ay alışık olmadığın bir elementte ({ayBurcu}); sosyal planlarını azaltıp kendine alan açmak seni korur.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna farklı bir dilden sesleniyor; senden farklı biriyle yapacağın sohbet ufkunu açabilir.',
          '{ayBurcu} burcundaki Ay sosyal çevrene yeni bir renk katıyor; alışık olmadığın bir ortama kısa bir uğrama seni tazeler.',
          'Ay farklı bir elementte ({ayBurcu}); dinlediğin kadar konuşmak dengeyi kurar.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcuna yabancı bir elementte; bu fark seni ilginç kılıyor, insanlar seni merak ediyor.',
          '{ayBurcu} burcundaki Ay seni yeni çevrelere taşıyor; bir tanışma beklenmedik bir kapı açabilir.',
          'Ay farklı bir elementte ({ayBurcu}) ve sosyal merakın yüksek; yeni bir gruba katılmak için an yerinde.',
        ],
      },
      ElementIliskisi.zit: <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; sürtüşme ihtimali yüksek, tartışmaya girmeden önce bir nefes al.',
          '{ayBurcu} burcundaki Ay sabrını zorluyor; birinin sözü sana olduğundan ağır gelebilir, cevabı yarına bırak.',
          'Ay zıt bir elementte ({ayBurcu}); kalabalık ortamlar seni yorabilir, bir daveti ertelemek sorun değil.',
        ],
        KategoriTonu.orta: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters düşüyor; farklı fikirler çatışabilir, haklı çıkmak yerine anlaşmayı seç.',
          '{ayBurcu} burcundaki Ay ile aranda hafif bir gerilim var; esprilerinin yanlış anlaşılmaması için tonuna dikkat et.',
          'Ay zıt bir elementte ({ayBurcu}); senden çok farklı biri sana önemli bir şey öğretebilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Ay {ayBurcu} burcunda, {burc} burcunun elementine ters bir yerde; bu kontrast seni dikkat çekici yapıyor, bir ortamda öne çıkabilirsin.',
          '{ayBurcu} burcundaki Ay seni alışık olmadığın insanlara yaklaştırıyor; beklemediğin bir dostluk filizlenebilir.',
          'Ay zıt bir elementte ({ayBurcu}) ama sosyal cesaretin yüksek; ilk adımı atan sen ol.',
        ],
      },
    },
  };

  /// Kategori × sahne anahtarı (uğraş adı ya da [genelAnahtar]) × sahne
  /// yönü → günün kişinin hayatında nerede hissedileceği.
  ///
  /// Düşük tonlu günlerde [SahneYonu.temkin] (koruyucu), orta ve yüksek
  /// tonlu günlerde [SahneYonu.akis] (fırsat) sahneleri seçilir; böylece
  /// "enerjin yüksek" diyen bir cümlenin ardından uyarı gelmez.
  static const Map<LuckCategory, Map<String, Map<SahneYonu, List<String>>>>
  sahneler = <LuckCategory, Map<String, Map<SahneYonu, List<String>>>>{
    LuckCategory.ask: <String, Map<SahneYonu, List<String>>>{
      'bekar': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Eski bir tanıdıktan gelen bir mesaj aklını karıştırabilir; o kapıyı neden kapattığını hatırla.',
          'Birinin paylaşımını fazla yorumlamak gününü gereksiz yere ağırlaştırabilir.',
          'Biriyle ilgili beklentini büyütmeden önce onu biraz daha tanımaya zaman ver.',
        ],
        SahneYonu.akis: <String>[
          'Bir arkadaş ortamında, bir kahve sırasında ya da beklenmedik bir mesajda yeni bir ilgi doğabilir.',
          'Tanıdık bir çevrede pek dikkat etmediğin biri seni şaşırtabilir.',
          'Bir davete evet demek ya da bir sohbeti uzatmak yeni bir hikâyenin ilk sayfası olabilir.',
        ],
      },
      'partnerli': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Günün yorgunluğu eve taşınırsa küçük bir konu kolay büyüyebilir; önce dinle, sonra cevap ver.',
          'Söylenmeyen bir beklenti aranızda gerginlik yaratabilir; tahmin ettirmek yerine açıkça söyle.',
          'Telefonun ya da işin aranıza girdiği bir akşam olabilir; birlikte geçirdiğiniz zamanı korumaya çalış.',
        ],
        SahneYonu.akis: <String>[
          'Birlikte yapacağınız basit bir iş, uzun bir konuşmadan daha çok yakınlaştırır.',
          'Sevdiğinle küçük bir sürpriz ya da ortak bir plan günü güzelleştirir.',
          'Uzun süredir konuşmak istediğin bir konu beklediğinden yumuşak karşılanabilir.',
        ],
      },
      genelAnahtar: <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Kalbini başkasının onayına bağlamak seni yorabilir; önce kendine iyi davran.',
          'Bir sözü olduğundan ağır algılamaya yatkın olabilirsin; netleştirmek için sormaktan çekinme.',
          'Geçmişten bir duygu yeniden gündeme gelebilir; onu bugünün kararlarına karıştırma.',
        ],
        SahneYonu.akis: <String>[
          'Sevdiğin birine ayıracağın içten bir an seni de ısıtır.',
          'Bir mesaj, bir bakış ya da küçük bir tesadüf günün en güzel anı olabilir.',
          'Duygularını sakin bir dille ifade etmek ilişkilerini yumuşatır.',
        ],
      },
    },
    LuckCategory.para: <String, Map<SahneYonu, List<String>>>{
      'calisiyor': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Ay sonu yaklaşırken küçük harcamalar bütçende beklediğinden büyük yer kaplayabilir.',
          'İşte karşılığı konuşulmadan üstlenilen ek bir görev yorgunluk getirir; önce koşulları netleştir.',
          'Bir maaş, prim ya da ödeme gecikmesi canını sıkabilir; takibini yazılı yap.',
        ],
        SahneYonu.akis: <String>[
          'İşte emeğinin görünür olduğu bir an gelebilir; bir talebini dile getirmek için zaman yerinde.',
          'Bir yöneticiyle ya da ekiple yapacağın kısa bir konuşma maddi tarafa da dokunabilir.',
          'Uzun süredir uğraştığın bir iş olumlu bir sonuca yaklaşabilir.',
        ],
      },
      'ogrenci': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Harçlık ya da burs bütçesini zorlayacak küçük harcamalara dikkat: kafe, yemek, abonelik.',
          'Arkadaş ortamında yapılan plansız harcamalar ay sonunu zorlayabilir.',
          'İndirim görünce hemen almak yerine bir gün beklemek bütçeni korur.',
        ],
        SahneYonu.akis: <String>[
          'Bir burs, staj ya da yarı zamanlı iş fırsatına başvurmak için an yerinde.',
          'Bir becerini küçük bir kazanca çevirmek düşündüğünden kolay olabilir: ders vermek, tasarım, çeviri.',
          'Arkadaşlarınla ortak alım ya da paylaşım birlikte tasarruf etmenizi sağlayabilir.',
        ],
      },
      'isArayan': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Bekleme döneminde bütçeyi sıkı tutmak içini rahatlatır; zorunlu olmayan harcamaları ertele.',
          'Hızlı kazanç vaat eden tekliflerin ayrıntısına iki kez bak.',
          'Bir ücret teklifini kabul etmeden önce benzer işlerin koşullarını araştır.',
        ],
        SahneYonu.akis: <String>[
          'Bir görüşmede ücret konusunu açmak için cesaretin yerinde.',
          'Geçici ya da serbest bir iş beklediğinden iyi bir kapı açabilir.',
          'Çevrenden gelecek bir yönlendirme maddi tarafta da karşılık bulabilir.',
        ],
      },
      'girisimci': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Nakit akışını zorlayacak bir gider ya da gecikmiş bir tahsilat canını sıkabilir; önceliklerini sırala.',
          'Bir müşteriye indirim yapmadan önce maliyetini yeniden hesapla.',
          'Yeni bir harcama yerine eldeki kaynakları verimli kullanmak kazandırır.',
        ],
        SahneYonu.akis: <String>[
          'Satış, anlaşma ya da yeni bir iş bağlantısı için kapılar açık.',
          'Bir fiyat güncellemesi ya da yeni bir paket fikri karşılık bulabilir.',
          'Beklediğin bir ödeme ya da olumlu bir dönüş gelebilir.',
        ],
      },
      'evde': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Ev giderleri arasında gözden kaçan bir fatura ya da abonelik olabilir; kısa bir kontrol yap.',
          'Ev için yapılacak büyük bir alışverişi bir süre daha beklet.',
          'Başkalarına harcarken kendi ihtiyacını unutmamaya dikkat et.',
        ],
        SahneYonu.akis: <String>[
          'Ev bütçesinde küçük bir düzenleme beklediğinden fazla tasarruf sağlayabilir.',
          'Evde değerlendirilebilecek bir beceri ya da eşya küçük bir kazanca dönüşebilir.',
          'Evdekilerle yapılacak ortak bir bütçe konuşması herkesi rahatlatır.',
        ],
      },
      genelAnahtar: <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Küçük harcamalar gün içinde fark edilmeden birikebilir.',
          'Bir ödeme ya da fatura tarihini kaçırmamak için takvimine bir not düş.',
          'İlk bakışta cazip görünen bir alışveriş seni ay sonunda zorlayabilir.',
        ],
        SahneYonu.akis: <String>[
          'Beklenen bir ödeme ya da küçük bir kazanç gündeme gelebilir.',
          'Bütçeni gözden geçirmek sana sürpriz bir tasarruf alanı gösterebilir.',
          'Bir hizmet ya da ürün için daha iyi bir fiyat bulmak kolay.',
        ],
      },
    },
    LuckCategory.saglik: <String, Map<SahneYonu, List<String>>>{
      'calisiyor': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Uzun bir toplantı ya da ekran başında geçen saatler bunu en çok boynunda ve omuzlarında hissettirebilir.',
          'İş yoğunluğu öğle yemeğini ayakta geçiştirmene yol açabilir; oturup yemek enerjini korur.',
          'İşten çıktıktan sonraki ilk yarım saat enerjinin nasıl kapanacağını belirliyor; o saati kendine ayır.',
        ],
        SahneYonu.akis: <String>[
          'İş arasında masadan kalkıp birkaç dakika yürümek öğleden sonrayı da canlı tutar.',
          'Merdiveni seçmek ya da bir görüşmeyi yürüyerek yapmak bu enerjiyi gününe yayar.',
          'İş çıkışı kısa bir spor ya da yürüyüş günün yorgunluğunu tazeliğe çevirir.',
        ],
      },
      'ogrenci': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Uzun süre aynı sandalyede oturduğun bir ders ya da çalışma saati bunu en çok sırtına yansıtabilir.',
          'Gece geç saatlere kalan bir çalışma ertesi güne pahalıya patlayabilir; uykunu koru.',
          'Sınav ya da ödev telaşında öğün atlamak dikkatini dağıtır; yanında küçük bir atıştırmalık olsun.',
        ],
        SahneYonu.akis: <String>[
          'İki ders arasında açık havada geçireceğin birkaç dakika zihnini de bedenini de tazeler.',
          'Okul yolunu yürüyerek ya da bisikletle gitmek bu enerjiyi iyi kullanır.',
          'Çalışma aralarına koyacağın kısa hareket molaları öğrendiklerini de daha kalıcı yapar.',
        ],
      },
      'isArayan': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Belirsiz bir bekleyiş bedende fark etmeden gerginlik biriktirir; gününe sabit bir yürüyüş saati koymak sana zemin verir.',
          'Bir cevap beklerken uykun bölünebilir; akşamları ekranı erken bırakmak zihnini sakinleştirir.',
          'İlan taramak ya da başvuru yazmak saatlerini yutabilir; araya sık sık kısa bir hareket koy.',
        ],
        SahneYonu.akis: <String>[
          'Güne hareketle başlamak başvurulara da daha net bir kafayla oturmanı sağlar.',
          'Bir görüşmeye yürüyerek gitmek ya da öncesinde kısa bir yürüyüş yapmak seni daha rahat gösterir.',
          'Kendine bir spor rutini kurmak bu dönemde günlerine sağlam bir omurga verir.',
        ],
      },
      'girisimci': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Durmadan çalıştığın günlerde beden en son şikâyet eder; bu sinyali erkenden dinle.',
          'Bir görüşmeden diğerine koşarken öğün atlamak öğleden sonra enerjini düşürebilir.',
          'İşi eve taşıdığın akşamlarda uykun bölünüyor; işi bir saat erken kapatmayı dene.',
        ],
        SahneYonu.akis: <String>[
          'Bir toplantıyı yürüyüşe çevirmek hem fikirlerini hem bedenini açar.',
          'Gününe koyacağın kısa bir spor arası öğleden sonraki kararlarını da keskinleştirir.',
          'İşin hızına bedenin de eşlik ediyor; bu tempoyu düzenli öğünlerle destekle.',
        ],
      },
      'evde': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Başkaları için koşturduğun bir günde kendi molanı en sona bırakmak bedenini yorabilir.',
          'Ev içinde sürekli ayakta olmak da bir yorgunluktur; oturup yalnızca nefes aldığın on dakika ayır.',
          'Ev işleri bitmek bilmeyebilir; bazılarını yarına bırakmak bedenini korur.',
        ],
        SahneYonu.akis: <String>[
          'Evin düzeniyle uğraşırken bir pencereyi açıp temiz hava almak sandığından çok tazeler.',
          'Ev içindeki koşturmayı kısa bir yürüyüşle dışarı taşımak enerjini tazeler.',
          'Evde yapabileceğin küçük bir esneme rutini bu enerjiyi bedenine yayar.',
        ],
      },
      genelAnahtar: <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Günün yoğun saatlerinde bedenin sana küçük sinyaller gönderebilir: susuzluk, gerginlik, dalgınlık.',
          'Akşam saatleri dinlenmenin kalitesini belirliyor; ekranı erken bırakmak uykunu derinleştirir.',
          'Gün içinde biriken yorgunluk akşama doğru kendini gösterebilir; programını hafif tut.',
        ],
        SahneYonu.akis: <String>[
          'Gün içinde bir kez telefonu bırakıp yalnızca yürüdüğün bir zaman enerjini yeniden toplar.',
          'Sabahın ilk saatleri bedenin için en verimli zaman; hareketi oraya koy.',
          'Açık havada geçireceğin her dakika bu enerjiyi biraz daha yükseltir.',
        ],
      },
    },
    LuckCategory.risk: <String, Map<SahneYonu, List<String>>>{
      'calisiyor': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'İşte önüne gelen bir öneri ya da yeni bir görev hızlı bir "evet" isteyebilir; önce iş yükünü hesapla.',
          'Bir e-postaya ya da talebe aceleyle verilecek cevap sonradan geri alınması zor bir söz olabilir.',
          'İş yerindeki bir tartışmada taraf tutmak için acele etme; tablo yarın daha net görünür.',
        ],
        SahneYonu.akis: <String>[
          'Bir yöneticiyle ya da ekiple konuşurken kendi fikrini savunmak risk değil, fırsat olabilir.',
          'Masada bekleyen bir karar var; onu en azından bir adım ileri taşıyabilirsin.',
          'Yeni bir sorumluluğa talip olmak beklediğinden iyi karşılanabilir.',
        ],
      },
      'ogrenci': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Bir ders seçimi ya da proje konusu için son karara varmadan önce bir hocaya danış.',
          'Arkadaşlarının yaptığını yapmak kolay; kendi planına sadık kalmak daha çok kazandırır.',
          'Sınav öncesi çalışma yöntemini son anda değiştirmek risk taşır; bildiğin düzende kal.',
        ],
        SahneYonu.akis: <String>[
          'Bir ders seçimi, proje konusu ya da sınav stratejisi karar istiyor olabilir.',
          'Bir hocaya soru sormak ya da farklı bir çalışma yöntemi denemek göze alınmaya değer küçük bir risk.',
          'Bir yarışmaya, kulübe ya da projeye başvurmak için cesaretin yerinde.',
        ],
      },
      'isArayan': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Gelen bir teklifi kabul etmeden önce koşullarını bir kez daha oku.',
          'Her ilana başvurmak yerine sana gerçekten uyan birkaçına odaklan.',
          'Bir görüşmede verilen sözleri yazılı teyit almadan kesin sayma.',
        ],
        SahneYonu.akis: <String>[
          'Bir başvuru, bir görüşme davetine cevap ya da beklenmedik bir ilan karar anı olabilir.',
          'Daha önce düşünmediğin bir alana başvurmak göze alınabilecek en iyi risk olabilir.',
          'Bir maaş ya da koşul konuşmasında sesini yükseltmek sana sandığından az şey kaybettirir.',
        ],
      },
      'girisimci': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Büyük bir harcama ya da yeni bir taahhüt için imza atmadan önce nakit durumuna bak.',
          'Bir müşterinin ya da ortağın aceleci teklifine hemen evet deme; şartları netleştir.',
          'Yeni bir işe girişmek yerine yarım kalanı bitirmek daha güvenli.',
        ],
        SahneYonu.akis: <String>[
          'Bir fiyat kararı, yeni bir iş birliği ya da bir müşteriye verilecek cevap masada olabilir.',
          'Küçük bir deneme ya da bir teklif büyük bir hamleden daha çok bilgi getirir.',
          'Bir ortak ya da müşteriyle yapacağın konuşmada net olmak en kazançlı risk.',
        ],
      },
      'evde': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Ev için düşündüğün büyük bir harcamayı bir süre daha beklet.',
          'Aileyle ilgili bir planda herkesin fikrini almadan karar vermek sonradan yük olabilir.',
          'Uzun süredir ertelediğin bir düzenleme için önce artıları ve eksileri tart.',
        ],
        SahneYonu.akis: <String>[
          'Ev için düşündüğün bir değişiklik ya da aileyle ilgili bir plan karar istiyor olabilir.',
          'Kendine ait yeni bir uğraşa adım atmak göze almaya değer bir risk olabilir.',
          'Evde uzun süredir konuşulan bir plan için ilk adımı sen atabilirsin.',
        ],
      },
      genelAnahtar: <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'İlk bakışta cazip görünen bir teklif önüne çıkabilir; ayrıntısına bakmadan karar verme.',
          'Birinin baskısıyla hızlı bir karar vermen istenebilir; zaman istemek hakkın.',
          'Kaybettiğin bir şeyi hemen telafi etme isteği seni aceleye itebilir.',
        ],
        SahneYonu.akis: <String>[
          'Bir teklif, bir davet ya da beklenmedik bir seçenek önüne çıkabilir.',
          'Uzun süredir aklında olan bir adım yeniden gündeme gelebilir.',
          'Küçük bir "neden olmasın" anı günün en şanslı kararı olabilir.',
        ],
      },
    },
    LuckCategory.sosyal: <String, Map<SahneYonu, List<String>>>{
      'calisiyor': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Gergin bir toplantıda sözlerin olduğundan sert anlaşılabilir; yazılı iletişimde tonuna dikkat et.',
          'Bir iş arkadaşının yorumu sana ağır gelebilir; cevap vermeden önce bir mola ver.',
          'Ekip içindeki bir dedikodudan uzak durmak seni korur.',
        ],
        SahneYonu.akis: <String>[
          'İş yerinde bir kahve arası ya da kısa bir koridor sohbeti beklenmedik bir yakınlık başlatabilir.',
          'Ekipte birine destek olmak ilişkilerini güçlendirmenin en kısa yolu.',
          'Bir iş arkadaşınla aranda kalan küçük bir kırgınlığı kapatmak için an yerinde.',
        ],
      },
      'ogrenci': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Bir grup çalışmasında görev paylaşımı gerginlik yaratabilir; beklentini baştan açıkça söyle.',
          'Sınıfta söylenen bir söz sana olduğundan ağır gelebilir; hemen cevap vermek zorunda değilsin.',
          'Kalabalık bir okul ortamı seni yorabilir; teneffüste kısa bir sessizlik seni toparlar.',
        ],
        SahneYonu.akis: <String>[
          'Bir grup çalışması ya da kantindeki bir sohbet yeni bir arkadaşlığa kapı açabilir.',
          'Okulda pek konuşmadığın biriyle bir ortak noktan çıkabilir.',
          'Ders notlarını ya da bir kaynağı paylaşmak çevrendekilerle bağını güçlendirir.',
        ],
      },
      'isArayan': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Çevrenden gelen iyi niyetli ama yorucu sorular canını sıkabilir; sınır koymak sorun değil.',
          'Kendini başkalarıyla kıyaslamak moralini düşürebilir; seni destekleyen birkaç kişiye yönel.',
          'Bir tanıdıktan beklediğin dönüş gecikebilir; bunu kişisel algılama.',
        ],
        SahneYonu.akis: <String>[
          'Eski bir iş arkadaşına ya da tanıdığa atacağın bir mesaj sandığından değerli olabilir.',
          'Çevrene ne aradığını anlatmak beklenmedik bir yönlendirme getirebilir.',
          'Bir etkinlik ya da buluşma hem moral hem bağlantı kazandırabilir.',
        ],
      },
      'girisimci': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Bir müşteri ya da iş ortağıyla yanlış anlaşılma çıkabilir; önemli şeyleri yazılı teyit et.',
          'Herkese aynı anda yetişmeye çalışmak ilişkilerini yıpratabilir; önceliklerini sırala.',
          'Sosyal medyada ya da bir grupta tartışmaya girmek enerjini boşa harcar.',
        ],
        SahneYonu.akis: <String>[
          'Bir müşteri, iş ortağı ya da takipçiyle yapacağın samimi bir sohbet işine de dokunabilir.',
          'Çevreni genişletmek için atacağın küçük bir mesaj karşılık bulabilir.',
          'Bir iş yemeği ya da kahve resmî bir toplantıdan daha çok kapı açar.',
        ],
      },
      'evde': <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Evde biriken küçük bir gerginlik kolay büyüyebilir; önce dinleyip sonra konuşmak işleri yumuşatır.',
          'Aile içinde herkesin isteğine yetişmeye çalışmak seni yorabilir; kendine de söz hakkı ver.',
          'Evdeki biriyle hassas bir konuyu açmak için yorgun bir anı değil, sakin bir anı seç.',
        ],
        SahneYonu.akis: <String>[
          'Ailenle ya da komşularınla kısa bir sohbet günün havasını değiştirebilir.',
          'Ev dışından, uzun süredir görmediğin bir dostla bağ kurmak seni yeniler.',
          'Evdekilerle ortak bir plan yapmak herkesi biraz daha yakınlaştırır.',
        ],
      },
      genelAnahtar: <SahneYonu, List<String>>{
        SahneYonu.temkin: <String>[
          'Bir mesajın gecikmesi ya da kısa bir cevap seni gereğinden fazla düşündürebilir.',
          'Kalabalık bir ortamda enerjin çabuk düşebilir; erken ayrılmak sorun değil.',
          'Eski bir kırgınlık gündeme gelebilir; hemen çözmek zorunda değilsin.',
        ],
        SahneYonu.akis: <String>[
          'Uzun süredir görüşmediğin birinden gelen bir mesaj gününü renklendirebilir.',
          'Bir arkadaş buluşması ya da kısa bir telefon konuşması beklediğinden derin geçebilir.',
          'Kalabalık bir ortamda bile bir kişiyle kuracağın gerçek bağ en değerli şey.',
        ],
      },
    },
  };

  /// Kategori × ton → genel "Yap" önerileri (kısa, emir kipinde).
  static const Map<LuckCategory, Map<KategoriTonu, List<String>>> yap =
      <LuckCategory, Map<KategoriTonu, List<String>>>{
        LuckCategory.ask: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Duygularını önce kendine yaz.',
            'Seni iyi hissettiren biriyle vakit geçir.',
            'Varsaymak yerine soru sor.',
          ],
          KategoriTonu.orta: <String>[
            'Sevdiğin birine içten bir iltifat et.',
            'Küçük bir jest yap: bir not, bir şarkı, bir kahve.',
            'Dinlerken telefonu bırak.',
          ],
          KategoriTonu.yuksek: <String>[
            'İçinden geçeni söyle.',
            'Bir buluşma ya da plan için ilk adımı at.',
            'Olduğun gibi görün.',
          ],
        },
        LuckCategory.para: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Harcamadan önce bir gün bekle.',
            'Hesap hareketlerini kontrol et.',
            'Zorunlu olmayan alımları ertele.',
          ],
          KategoriTonu.orta: <String>[
            'Küçük bir bütçe kontrolü yap.',
            'Bekleyen bir ödemeyi takip et.',
            'Aboneliklerini gözden geçir.',
          ],
          KategoriTonu.yuksek: <String>[
            'Emeğinin karşılığını iste.',
            'Bir teklif ya da fiyat konuşmasını başlat.',
            'Yeni bir gelir fikrini not al.',
          ],
        },
        LuckCategory.saglik: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Gün içinde en az iki kez kısa bir mola ver.',
            'Akşam ekranı erken bırak.',
            'Su şişeni yanında taşı.',
          ],
          KategoriTonu.orta: <String>[
            'Öğle arasında on dakika yürü.',
            'Gün içinde omuzlarını ve boynunu esnet.',
            'Uyku saatini biraz öne çek.',
          ],
          KategoriTonu.yuksek: <String>[
            'Enerjini seni terletecek bir harekete harca.',
            'Yeni bir spora ya da yürüyüş rotasına şans ver.',
            'Sabahı hareketle başlat.',
          ],
        },
        LuckCategory.risk: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Büyük kararları bir gece beklet.',
            'Bir teklifin ayrıntılarını iki kez oku.',
            'Güvendiğin birine danış.',
          ],
          KategoriTonu.orta: <String>[
            'Artıları ve eksileri yazıya dök.',
            'Küçük bir denemeyle başla.',
            'Sınırını önceden belirle.',
          ],
          KategoriTonu.yuksek: <String>[
            'Ertelediğin adımı at.',
            'Bir fırsata ilk sen başvur.',
            'Kararını tek cümleyle yaz ve arkasında dur.',
          ],
        },
        LuckCategory.sosyal: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Yakın bir kişiyle kısa ve sakin bir görüşme yap.',
            'Mesajlarını göndermeden önce bir kez oku.',
            'Kendine sessiz bir saat ayır.',
          ],
          KategoriTonu.orta: <String>[
            'Uzun zamandır yazmadığın birine selam gönder.',
            'Birine içten bir teşekkür et.',
            'Kısa bir kahve buluşması planla.',
          ],
          KategoriTonu.yuksek: <String>[
            'Bir davete evet de.',
            'Yeni biriyle tanışmak için ilk adımı at.',
            'İnsanları bir araya getiren planı sen kur.',
          ],
        },
      };

  /// Kategori × ton → "Yapma" önerileri (kısa, olumsuz emir kipinde).
  static const Map<LuckCategory, Map<KategoriTonu, List<String>>> yapma =
      <LuckCategory, Map<KategoriTonu, List<String>>>{
        LuckCategory.ask: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Gece geç saatte duygusal mesaj atma.',
            'Eski bir kapıyı aceleyle yeniden açma.',
            'Bir sessizliği cevap sanma.',
          ],
          KategoriTonu.orta: <String>[
            'Kendini başkalarıyla kıyaslama.',
            'Küçük bir kırgınlığı biriktirme.',
            'İlgini yalnızca mesajla gösterme.',
          ],
          KategoriTonu.yuksek: <String>[
            'Hislerini saklama.',
            'Mükemmel anı bekleme.',
            'Gururunu araya sokma.',
          ],
        },
        LuckCategory.para: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Ani bir alışverişe kapılma.',
            'Borç verme ya da alma kararını aceleye getirme.',
            'Eksik bilgiyle ödeme yapma.',
          ],
          KategoriTonu.orta: <String>[
            'Bütçeni tahminle yönetme.',
            'Faturaları son güne bırakma.',
            'Başkasının harcama hızına uyma.',
          ],
          KategoriTonu.yuksek: <String>[
            'Değerini düşük söyleme.',
            'Fırsatı kararsızlıkla kaçırma.',
            'Kazancı hemen harcama.',
          ],
        },
        LuckCategory.saglik: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Yorgunken yeni bir antrenmana başlama.',
            'Uykunu bir dizi bölümüne feda etme.',
            'Öğün atlayarak günü geçirme.',
          ],
          KategoriTonu.orta: <String>[
            'Saatlerce aynı pozisyonda oturma.',
            'Enerjini yalnızca kahveyle toplamaya çalışma.',
            'Akşamı ağır bir yemekle kapatma.',
          ],
          KategoriTonu.yuksek: <String>[
            'Bu enerjiyi yalnızca ekran başında tüketme.',
            'Kendini aşırı zorlayıp yarını yorma.',
            'Isınmadan hızlı başlama.',
          ],
        },
        LuckCategory.risk: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Baskı altında "evet" deme.',
            'Bir kaybı telafi etmek için yeni risk alma.',
            'Eksik bilgiyle imza atma.',
          ],
          KategoriTonu.orta: <String>[
            'Her şeyi tek karta bağlama.',
            'Kararı sonsuza kadar erteleme.',
            'Başkasının heyecanıyla karar verme.',
          ],
          KategoriTonu.yuksek: <String>[
            'Mükemmel anı bekleme.',
            'Fırsatı başkasına bırakma.',
            'Küçük bir aksilikte geri adım atma.',
          ],
        },
        LuckCategory.sosyal: <KategoriTonu, List<String>>{
          KategoriTonu.dusuk: <String>[
            'Gergin bir konuyu mesajla açma.',
            'Her daveti kabul etmek zorunda hissetme.',
            'Birinin sözünü kişisel alma.',
          ],
          KategoriTonu.orta: <String>[
            'Sohbeti tek başına yönetmeye çalışma.',
            'Dedikoduya ortak olma.',
            'Planları son dakika iptal etme.',
          ],
          KategoriTonu.yuksek: <String>[
            'Evde kalıp bu enerjiyi harcama.',
            'Çekinip sessiz kalma.',
            'Yalnızca bildik yüzlerle yetinme.',
          ],
        },
      };

  /// Kategori × kişisel anahtar ([kisiselAnahtar]) × ton → kişiye göre
  /// seçilen "Yap" önerisi. Cevabı geri söylemez; yalnızca öneriyi
  /// kişinin doğasına uygun seçer.
  static const Map<LuckCategory, Map<String, Map<KategoriTonu, List<String>>>>
  kisiselYap = <LuckCategory, Map<String, Map<KategoriTonu, List<String>>>>{
    LuckCategory.ask: <String, Map<KategoriTonu, List<String>>>{
      'bekar': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Kendine iyi bakmaya vakit ayır.',
          'Seni değerli hissettiren arkadaşlarınla buluş.',
        ],
        KategoriTonu.orta: <String>[
          'Bir davete evet de.',
          'İlgini çeken biriyle sohbeti uzat.',
        ],
        KategoriTonu.yuksek: <String>[
          'Beğendiğin birine ilk mesajı sen at.',
          'Yeni insanlarla tanışabileceğin bir ortama gir.',
        ],
      },
      'partnerli': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Akşamı sakin ve baş başa geçir.',
          'Bir gerginliği konuşmadan önce birlikte kısa bir yürüyüşe çıkın.',
        ],
        KategoriTonu.orta: <String>[
          'Birlikte küçük bir plan yap.',
          'Sevdiğine onu neden önemsediğini söyle.',
        ],
        KategoriTonu.yuksek: <String>[
          'Küçük bir sürpriz hazırla.',
          'Uzun süredir konuşmak istediğin konuyu aç.',
        ],
      },
    },
    LuckCategory.para: <String, Map<KategoriTonu, List<String>>>{
      'kalp': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Bir harcamaya heyecanla karar vermeden önce bir gece uyu.',
          'Moralini düzeltmek için alışveriş yapma isteğini ertele.',
        ],
        KategoriTonu.orta: <String>[
          'Sevdiğin bir şeye küçük ve planlı bir bütçe ayır.',
          'Hissini bir kez de rakamlarla kontrol et.',
        ],
        KategoriTonu.yuksek: <String>[
          'İçinin güvendiği fırsatı rakamlarla destekleyip değerlendir.',
          'Değer verdiğin bir işe emek ve zaman ayır.',
        ],
      },
      'akil': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Hesabın tutsa bile büyük ödemeyi bir gün beklet.',
          'Maddi planını bir kez de dışarıdan birine göster.',
        ],
        KategoriTonu.orta: <String>[
          'Bütçe tablona keyif payı da ekle.',
          'Hesaplı, küçük bir tasarruf hedefi koy.',
        ],
        KategoriTonu.yuksek: <String>[
          'Hazırladığın maddi planı uygulamaya koy.',
          'Hesapladığın pazarlığı ertelemeden yap.',
        ],
      },
    },
    LuckCategory.saglik: <String, Map<KategoriTonu, List<String>>>{
      'iceDonuk': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Sessiz bir odada on dakika gözlerini kapat.',
          'Akşamı kalabalıktan uzak, kendi temponda geçir.',
        ],
        KategoriTonu.orta: <String>[
          'Kulaklıksız, sakin bir yürüyüşe çık.',
          'Gün içinde kısa bir sessizlik molası ver.',
        ],
        KategoriTonu.yuksek: <String>[
          'Kendi rotanda uzun bir yürüyüş ya da koşu planla.',
          'Tek başına yapabileceğin bir sporu dene: yüzme, bisiklet, yoga.',
        ],
      },
      'disaDonuk': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Seni güldüren biriyle kısa bir telefon konuşması yap.',
          'Akşamı yorucu bir kalabalık yerine bir dostla geçir.',
        ],
        KategoriTonu.orta: <String>[
          'Bir arkadaşınla birlikte yürüyüşe çık.',
          'Öğle arasını biriyle sohbet ederek değerlendir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Bir grup sporuna ya da dans dersine katıl.',
          'Bir arkadaşını ortak bir aktiviteye davet et.',
        ],
      },
    },
    LuckCategory.risk: <String, Map<KategoriTonu, List<String>>>{
      'kalp': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Bir duyguyla karar vermeden önce bir gece uyu.',
          'Kırgınken verilecek kararları ertele.',
        ],
        KategoriTonu.orta: <String>[
          'İçinden geçeni bir kez de rakamlarla kontrol et.',
          'Hissini güvendiğin birinin fikriyle tart.',
        ],
        KategoriTonu.yuksek: <String>[
          'İçinin evet dediği fırsata adım at.',
          'İlk hissine güvenip harekete geç.',
        ],
      },
      'akil': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Hesabın tutsa bile bir gün beklemekten çekinme.',
          'Planını bir kez de dışarıdan birine göster.',
        ],
        KategoriTonu.orta: <String>[
          'Hesabına şunu da ekle: bu seçim seni mutlu eder mi?',
          'Hesaplı riskini küçük bir denemeyle başlat.',
        ],
        KategoriTonu.yuksek: <String>[
          'Hazırladığın planı uygulamaya koy.',
          'Hesapladığın adımı ertelemeden at.',
        ],
      },
    },
    LuckCategory.sosyal: <String, Map<KategoriTonu, List<String>>>{
      'iceDonuk': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Tek bir yakın dostla yetin.',
          'Mesajlara kendi temponda cevap ver.',
        ],
        KategoriTonu.orta: <String>[
          'Bir kişiyle uzun, derin bir sohbet planla.',
          'Küçük ve samimi bir buluşmayı tercih et.',
        ],
        KategoriTonu.yuksek: <String>[
          'Bir grupta fikrini söylemek için sesini yükselt.',
          'Tanımadığın biriyle bire bir sohbet başlat.',
        ],
      },
      'disaDonuk': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Planlarını azalt, en sevdiğin bir kişiye odaklan.',
          'Herkese yetişmek yerine tek bir buluşma seç.',
        ],
        KategoriTonu.orta: <String>[
          'Bir grup sohbetini canlandır ya da küçük bir buluşma kur.',
          'Yeni biriyle tanışmak için bir ortama uğra.',
        ],
        KategoriTonu.yuksek: <String>[
          'Bir etkinlik ya da toplanma organize et.',
          'Tanıştığın biriyle iletişimi sürdürmek için ilk mesajı sen at.',
        ],
      },
    },
  };
}
