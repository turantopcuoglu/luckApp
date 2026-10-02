/// Yaşam yolu karakterlerinin günlük yoruma yön veren metinleri.
///
/// Her öneri türünde en az [ContentConfig.enAzOneriVaryanti], her
/// kategori tarzında en az [ContentConfig.enAzTarzVaryanti] varyant
/// bulunur: aynı kategori bir ayda 15-20 kez öne çıkabildiği için tek
/// cümlelik tarz metinleri okura kısa sürede ezber gibi gelir.
///
/// Yazım kuralları (bkz. `sayi_metinleri.dart`) ek olarak:
/// - Öneriler "Bugün" ile BAŞLAMAZ; günü anan cümle okumanın açılışıdır.
/// - Tarz cümleleri günden bağımsızdır: kişinin o alandaki kalıcı
///   eğilimini anlatır, "bugün" kelimesini içermez.
library;

import '../luck_engine/luck_engine.dart';
import 'yorum_yonu.dart';

/// Tüm yaşam yolu karakterleri (1-9, 11, 22, 33).
abstract final class KarakterYonleri {
  /// Yaşam yolu sayısı → karakter yönü.
  static const Map<int, KarakterYonu> hepsi = <int, KarakterYonu>{
    1: KarakterYonu(
      doga: 'harekete geçmek ve yön vermek',
      uyumluGunler: <int>{1, 5, 8},
      zorlayiciGunler: <int>{2, 4, 7},
      gucTavsiyeleri: <String>[
        'İlk adımı atan sen ol; beklemek yerine inisiyatif almak sana kazandırır.',
        'Kafanda dönen o başlangıcı küçük de olsa somut bir harekete çevir; gerisi kendiliğinden gelir.',
        'Kimse yönü göstermiyorsa yönü sen çiz; insanlar senin netliğini bekliyor olabilir.',
        'Ertelenmiş bir kararı sen ver; netliğin etrafındakileri de rahatlatabilir.',
      ],
      golgeTavsiyeleri: <String>[
        'Herkesin senin hızında gitmesini beklemek seni yorar; bir kez durup başkalarını dinlemek işleri hızlandırır.',
        "Bir işi 'ben hallederim' diye tek başına sırtlanmadan önce kimden destek alabileceğini düşün.",
        'Sabrının daraldığını hissettiğin anda cevap vermeden önce bir nefes al; haklı olsan bile tonun sonucu belirler.',
        'Bir tartışmayı kazanmak yerine anlaşmayı kazanmayı hedefle; sonuç senin için daha değerli.',
      ],
      dengeTavsiyeleri: <String>[
        'Her şeyi tek başına üstlenmek yerine bir işi paylaşmayı dene; liderliğin azalmaz, güçlenir.',
        'Hızını korurken planını yüksek sesle paylaş; başkalarının fikri yolunu kısaltabilir.',
        'Kararı sen ver ama son sözü söylemeden önce bir kişiye danış; hem hızlı hem sağlam olursun.',
        'Önden giderken arkana bir bak; seninle yürüyenlerin hızını gözetmek seni daha uzağa taşır.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta ilgini belli etmekten çekinmezsin ama kendine ait alanına da düşkünsün.',
          'Sevdiğinde bunu saklamazsın; ilk mesajı atan, ilk planı yapan çoğu zaman sensin.',
          'Seni en çok etkileyen, hem hayranlık duyduğun hem de sana nefes aldıran biridir.',
          'Kırıldığında bunu göstermek yerine susmayı seçebilirsin; içindeki tutku ise kolay sönmez.',
        ],
        LuckCategory.para: <String>[
          'Parayla ilişkin cesur; fırsatı erken görürsün, bazen hesabı sonraya bırakırsın.',
          'Talimat beklemek yerine kendi yolunu açtığında kazancın da büyür.',
          'Para senin için bağımsızlık demek; kimseye hesap vermeden karar verebilmek seni rahatlatır.',
          'Hızlı karar vermek sana çoğu zaman kazandırır; tek tuzak, heyecanın rakamların önüne geçtiği anlar.',
        ],
        LuckCategory.saglik: <String>[
          'Enerjin yüksektir ama kendini zorlamaya ve molaları atlamaya yatkınsın.',
          'Bedenin, sen yavaşlamayı unuttuğunda bunu sana küçük gerginliklerle hatırlatır.',
          'Rekabet içeren bir hareket sana sıradan bir egzersizden daha çok keyif verir.',
          'Yorgunluğu kabul etmek sana zor gelir; oysa erken verilen mola, geç kalan moladan daha az kayıp demek.',
        ],
        LuckCategory.risk: <String>[
          'Risk almaktan korkmazsın; asıl dikkat etmen gereken şey sabırsızlık.',
          'Belirsizlik seni dondurmaz, aksine harekete geçirir; bu cesaret doğru zamanda büyük kapılar açar.',
          "Başkalarının 'şimdi olmaz' dediği yerde sen 'neden olmasın' dersin.",
          'Kararlarını hızla verirsin; ikinci bir bakış seni çoğu zaman gereksiz bir sürprizden korur.',
        ],
        LuckCategory.sosyal: <String>[
          'Sosyal ortamlarda yön veren taraf olursun; bazen dinlemek yerine yönlendirmeye geçersin.',
          'Kalabalık bir masada kararın nereye gideceğini ilk sezen sensin.',
          'İnsanlar seninle bir plana dahil olmayı sever; çünkü sen işi lafta bırakmazsın.',
          'Arkadaşlıklarında sadık ama talepkârsın; aynı enerjiyi görmediğinde mesafe koyarsın.',
        ],
      },
    ),
    2: KarakterYonu(
      doga: 'insanları anlamak ve arabuluculuk yapmak',
      uyumluGunler: <int>{2, 6, 7},
      zorlayiciGunler: <int>{1, 5, 8},
      gucTavsiyeleri: <String>[
        'Sezgilerine güven; bir konuşmada söylenmeyeni fark etmen işleri kolaylaştıracak.',
        'Gergin bir ortamı yumuşatabilecek kişi sensin; tek bir cümlen bir anlaşmazlığı çözebilir.',
        'Birinin derdini dinlemek için ayıracağın on dakika, sandığından büyük bir kapı açar.',
        'İki taraf arasında köprü kurman gereken bir an gelebilir; sakinliğin en güçlü aracın.',
      ],
      golgeTavsiyeleri: <String>[
        'Başkalarını memnun etmek için kendi isteğini geri planda bırakma; ne istediğini açıkça söyle.',
        'Küçük bir eleştiriyi gün boyu içinde taşımak yerine, gerekiyorsa sakince sor.',
        'Bir karar için herkesin onayını beklersen fırsat geçebilir; kendi sesine de bir oy ver.',
        'Birinin ruh halini düzeltmek senin sorumluluğun değil; kendi dengenle ilgilen.',
      ],
      dengeTavsiyeleri: <String>[
        'Uyum arayışını korurken bir kararı ertelemeden vermeye çalış.',
        "Nazikliğini koru ama bir 'hayır'ı da kibarca söylemeyi dene; ilişkilerin bundan güçlenir.",
        'Dinlediğin kadar konuşmaya da alan aç; fikrin sandığından değerli.',
        'Uzlaşmayı ararken kendi sınırını da masaya koy; adil bir anlaşma iki tarafı da korur.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta özenli ve sadıksın; duygularının karşılık görmesine ihtiyaç duyarsın.',
          'Küçük jestleri hatırlarsın; sevdiğinin ruh halini çoğu zaman ondan önce fark edersin.',
          'Tartışmadan kaçmak için susabilirsin; oysa istediğini nazikçe söylemek bağını derinleştirir.',
          'Seni en çok, duygularını ciddiye alan ve seni acele ettirmeyen biri mutlu eder.',
        ],
        LuckCategory.para: <String>[
          'Parada temkinli ve düzenlisin; ani kararlar yerine güvenli adımları seçersin.',
          'Ortaklıklarda ve iş birliklerinde kazancın, tek başına yaptıklarından çoğu zaman daha yüksektir.',
          'Pazarlık etmek sana zor gelebilir; emeğinin değerini söylemek kaba olmak demek değil.',
          'Para konusunda güven duymak istersin; belirsiz tekliflerde içindeki ses genellikle haklı çıkar.',
        ],
        LuckCategory.saglik: <String>[
          'Duygusal yükler bedenine çabuk yansır; gerginlikten uzak kalmak seni korur.',
          'Huzursuz bir ortam uykunu ve iştahını hemen etkiler; sakin bir köşe seni en hızlı toparlayan şeydir.',
          'Başkalarının derdini dinlerken kendi yorgunluğunu fark etmeyebilirsin.',
          'Yumuşak ve düzenli hareketler, yoğun egzersizlerden daha çok dengeni korur.',
        ],
        LuckCategory.risk: <String>[
          'Risk almadan önce herkesin fikrini tartmak istersin; bu seni korur ama bazen fırsatı kaçırtır.',
          'Bir şeyin yanlış gittiğini çoğu zaman rakamlardan önce hissedersin.',
          'Tek başına atılmak yerine güvendiğin biriyle birlikte adım attığında daha cesursun.',
          'Uzun uzun tartmak senin güvencen; sadece kararı sonsuza kadar ertelememeye dikkat et.',
        ],
        LuckCategory.sosyal: <String>[
          'İnsanlar yanında rahatlar; sen de kalabalıktan çok samimi sohbetlerde parlarsın.',
          'Bir grupta görünmeyen yapıştırıcı çoğu zaman sensin.',
          'İnsanlar dertlerini sana anlatır; dinlerken kendi duygularını da tartarsın.',
          'Küs iki arkadaşı barıştıran, ortamdaki gerginliği ilk fark eden kişi olursun.',
        ],
      },
    ),
    3: KarakterYonu(
      doga: 'kendini ifade etmek ve ortamı canlandırmak',
      uyumluGunler: <int>{1, 3, 5},
      zorlayiciGunler: <int>{4, 7, 8},
      gucTavsiyeleri: <String>[
        'Bir fikrini ya da duygunu paylaş; ifade gücün kapıları açacak.',
        'Aklındaki fikri bir mesaja, bir taslağa ya da bir sohbete dök; söze döndüğünde büyüyor.',
        'Ortamı canlandırmak sende doğal; bir şakan ya da bir davetin birinin gününü değiştirebilir.',
        'Seni heyecanlandıran bir konuyu biriyle paylaş; coşkun bulaşıcı ve kapı açıcı.',
      ],
      golgeTavsiyeleri: <String>[
        'Enerjini on farklı işe dağıtmak yerine birini bitirmeye odaklan.',
        'Heyecanla söz vermeden önce takvimine bir bak; yetişemeyeceğin bir sözü vermemek seni rahatlatır.',
        'Ruh halin dalgalanırsa onu herkesle paylaşmak zorunda değilsin; birkaç satır yazmak da rahatlatır.',
        'Bir konuyu şakaya vurup geçiştirmek yerine bir kez ciddiyetle konuş; karşındaki bunu fark eder.',
      ],
      dengeTavsiyeleri: <String>[
        'Neşeni korurken sözlerini biraz daha tartarak seç; yanlış anlaşılmanın önüne geçersin.',
        'Yaratıcılığına bir çerçeve çiz: bir saat, bir konu, bir sonuç.',
        'Konuşmaktan keyif aldığın kadar dinlemeye de yer aç; en iyi fikirlerin bazen karşındakinden gelir.',
        'Fikirlerinden birini seç ve onu bir adım ileri taşı; gerisi sırasını bekleyebilir.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta eğlenceli ve sıcaksın; ilgi görmek ve takdir duymak senin için önemli.',
          'Flört senin için bir oyun gibi; ama ciddileştiğinde sandığından derin bağlanırsın.',
          'Seni güldüren ve sözlerine değer veren biri kalbine en kısa yoldan ulaşır.',
          'Sıkıldığında bunu saklayamazsın; ilişkide sürpriz ve yenilik seni canlı tutar.',
        ],
        LuckCategory.para: <String>[
          'Parayı kazanmakta yaratıcı, harcamakta cömertsin; bütçe tutmak sana zor gelebilir.',
          'Anlatma, tanıtma ve ikna gerektiren işlerde kazancın kendiliğinden artar.',
          'Keyif aldığın bir şeye para harcamak seni mutlu eder; asıl sınav, ay sonuna pay bırakmak.',
          'Birden fazla gelir fikri aynı anda aklına gelir; birine odaklandığında sonuç çok daha hızlı gelir.',
        ],
        LuckCategory.saglik: <String>[
          'Ruh halin enerjini doğrudan etkiler; keyif aldığın bir hareket seni en çok toparlayan şeydir.',
          'Dans, müzik ya da bir arkadaşla yürüyüş sana spor salonundan daha çok enerji verir.',
          'Gece geç saatlere kayan sohbetler enerjini ertesi gün düşürebilir.',
          'Moralin yüksekken bedenin de toparlanır; neşeni koruyan şeyler aynı zamanda seni dinlendirir.',
        ],
        LuckCategory.risk: <String>[
          'Yeni fikirlere hızla heveslenirsin; heyecan geçtikten sonra da istiyorsan devam etmek iyi olur.',
          'Bir fırsatın anlatılış biçimi seni kolay etkileyebilir; parlak sunumun arkasına bir kez bak.',
          'Anlık kararların çoğu zaman eğlenceli sonuçlanır; büyük olanlarda bir gece beklemek yeter.',
          'Merakın seni yeni kapılara götürür; hangisinden gireceğini seçmek ise asıl ustalık.',
        ],
        LuckCategory.sosyal: <String>[
          'Sosyal ortamlarda doğal olarak dikkat çekersin; insanlar senin enerjinle canlanır.',
          'Bir masaya oturduğunda sohbetin havası değişir; hikâye anlatmak senin işin.',
          'Geniş bir çevren olur ama kendini gerçekten açtığın kişi sayısı azdır.',
          'Bir buluşmayı organize eden, grubu bir araya getiren çoğu zaman sensin.',
        ],
      },
    ),
    4: KarakterYonu(
      doga: 'düzen kurmak ve işi sağlam temele oturtmak',
      uyumluGunler: <int>{2, 4, 8},
      zorlayiciGunler: <int>{3, 5, 9},
      gucTavsiyeleri: <String>[
        'Bir planı adım adım uygula; sabrın ve düzenin somut sonuç getirecek.',
        'Listendeki en sıkıcı ama en önemli işi ilk sıraya koy; bitirdiğinde gün hafifleyecek.',
        'Emek isteyen bir işe oturmak için enerjin yerinde; acele etmeden ama ara vermeden ilerle.',
        'Uzun süredir bekleyen bir işi sona taşı; bitirmenin verdiği rahatlık sana enerji olarak döner.',
      ],
      golgeTavsiyeleri: <String>[
        'Plan dışı gelişmelere katılaşmak yerine esnek kalmayı dene; her şeyin kontrolünde olması gerekmiyor.',
        "Mükemmel olmasını beklediğin bir işi 'yeterince iyi' noktasında teslim etmek de bir beceri.",
        'Başkalarının dağınıklığına sinirlenmeden önce, herkesin senin düzenine ihtiyaç duymadığını hatırla.',
        'Bir planın aksaması felaket değil; yeni duruma göre küçük bir düzeltme yeterli.',
      ],
      dengeTavsiyeleri: <String>[
        'Düzenini korurken küçük bir yeniliğe de yer aç; hem güven hem tazelik kazanırsın.',
        'Çalışma temponu korurken arada bir mola koy; sağlam yapılar dinlenen ellerden çıkar.',
        'Planına sadık kal ama bir saatlik boşluk bırak; sürprizler o boşluğa sığsın.',
        'Sağlam adımlarına küçük bir esneklik ekle; beklenmedik bir fırsatı kaçırmamış olursun.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta güvenilir ve sadıksın; sevgini sözden çok yaptıklarınla gösterirsin.',
          'Hızlı başlayan ilişkilerden çok, yavaş ama sağlam kurulanlara güvenirsin.',
          'Romantik sözler yerine sözünü tutmak senin için sevginin en net dilidir.',
          'Değişkenlik seni yorar; seni en çok huzurlu ve öngörülebilir bir bağ mutlu eder.',
        ],
        LuckCategory.para: <String>[
          'Parayla ilişkin planlı ve sağlam; adım adım biriktirmek sana güven verir.',
          'Hızlı kazanç vaatlerine şüpheyle bakarsın; bu temkin seni çoğu zaman korur.',
          'Bütçeni bilmek seni rahatlatır; hesabını yapmadığın bir harcama içini kemirir.',
          'Emeğinin karşılığını geç ama sağlam alırsın; sabrın uzun vadede en büyük sermayen.',
        ],
        LuckCategory.saglik: <String>[
          'Düzenli bir rutin seni ayakta tutar ama işe dalıp dinlenmeyi unutabilirsin.',
          'Aynı saatte uyuyup uyanmak senin için sıradan bir alışkanlık değil, bir denge kaynağı.',
          'Gerginliği omuzlarında ve sırtında taşımaya yatkınsın; esnemek seni rahatlatır.',
          'Planlı bir yürüyüş ya da düzenli bir egzersiz, ani ve yoğun çıkışlardan daha çok işine yarar.',
        ],
        LuckCategory.risk: <String>[
          'Bilmediğin bir şeye kolay girmezsin; bu temkin seni çoğu zaman korur.',
          'Bir adım atmadan önce B planını hazırlarsın; bu seni sürprizlere karşı sağlam kılar.',
          'Risk senin için hesaplanması gereken bir şeydir, heyecan kaynağı değil.',
          'Fazla temkin bazen fırsatı geciktirir; küçük ve kontrollü bir deneme seni rahatlatır.',
        ],
        LuckCategory.sosyal: <String>[
          'Sosyal çevren az ama sağlamdır; insanlar zor anda sana güvenir.',
          'Söz verdiğin bir buluşmayı iptal etmek sana zor gelir; güvenilirliğin çevrende bilinir.',
          'Yeni insanlara açılman zaman alır ama bir kez güvendiğinde yıllarca yanında kalırsın.',
          'Plansız davetlerden çok, önceden konuşulmuş buluşmalar seni rahatlatır.',
        ],
      },
    ),
    5: KarakterYonu(
      doga: 'yeni deneyimlere açılmak ve özgürce hareket etmek',
      uyumluGunler: <int>{1, 3, 5},
      zorlayiciGunler: <int>{2, 4, 6},
      gucTavsiyeleri: <String>[
        'Farklı bir şey denemekten çekinme; merakın sana yeni bir kapı açacak.',
        'Rutinini bir yerinden kır: başka bir yol, başka bir mekân, başka bir yöntem.',
        'Beklenmedik bir teklife hemen hayır deme; esnekliğin bu sefer işine yarayabilir.',
        'Merak ettiğin bir şeyi öğrenmek için kısa bir keşfe çık; yeni bir bilgi yeni bir yol açabilir.',
      ],
      golgeTavsiyeleri: <String>[
        'Sıkıldığın bir işi yarıda bırakma dürtüsüne karşı dur; bitirmek sana özgürlük kadar iyi gelecek.',
        'Aynı anda her şeye evet demek seni dağıtır; iki seçenekten birini bilerek bırak.',
        'Bir sorumluluktan kaçmak geçici rahatlık verir; üstesinden gelmek ise kalıcı rahatlık.',
        'Sabırsızlığını fark ettiğinde kısa bir mola ver; acele kararlar özgürlüğünü kısıtlayabilir.',
      ],
      dengeTavsiyeleri: <String>[
        'Yenilik isteğini sorumluluklarınla dengele; önce bir işi kapat, sonra yeni bir şeye yönel.',
        'Merakını bir plana bağla: denemek istediğin şeye bir zaman ve bir sınır koy.',
        'Hareketli temponu korurken bir noktada dur ve neyin gerçekten işe yaradığına bak.',
        'Esnekliğini korurken bir söz ver ve onu tut; güvenilirlik özgürlüğünü daha da genişletir.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta heyecan ararsın; kısıtlandığını hissettiğinde geri çekilirsin.',
          'Seni en çok, hayatına renk katan ve özgürlüğüne saygı duyan biri etkiler.',
          'İlişkide rutin seni boğabilir; birlikte yeni bir şey denemek bağını tazeler.',
          'Çabuk ilgilenirsin; kalıcı olanı ise seninle birlikte büyümeye açık biri belirler.',
        ],
        LuckCategory.para: <String>[
          'Kazancın dalgalı olabilir; iyi günlerde bir kenara ayırmak özgürlüğünü korur.',
          'Tek bir gelire sıkışmak yerine farklı kazanç yolları denemek sana daha çok yakışır.',
          'Para senin için deneyim demek; seyahate ve yeniliğe harcamak seni mutlu eder.',
          'Ani alışveriş kararları en zayıf noktan; bir gün beklemek çoğu zaman fikrini değiştirir.',
        ],
        LuckCategory.saglik: <String>[
          'Hareket etmek seni canlandırır ama aşırılığa kaçmaya yatkınsın.',
          'Aynı egzersizi tekrarlamak seni çabuk sıkar; çeşitlilik seni hareketli tutar.',
          'Düzensiz uyku ve öğün saatleri enerjini sandığından çok etkiler.',
          'Açık havada geçen bir saat seni kapalı bir yerde geçen bütün bir günden daha çok toparlar.',
        ],
        LuckCategory.risk: <String>[
          'Risk ve yenilik seni çeker; sınırını önceden koyduğunda en iyi sonucu alırsın.',
          'Belirsizlik başkalarını korkuturken sana heyecan verir.',
          'Fırsatları hızlı yakalarsın; acele ettiğinde ayrıntıları gözden kaçırabilirsin.',
          'Denemekten korkmaman büyük avantaj; kaybetmeyi göze alabileceğin miktarı bilmek ise güvencen.',
        ],
        LuckCategory.sosyal: <String>[
          'Farklı insanlarla kolay tanışırsın; geniş bir çevrede rahat edersin.',
          'Yeni bir ortama girdiğinde kısa sürede herkesle konuşur hâle gelirsin.',
          'Plansız buluşmalar ve son dakika davetleri senin için günün en güzel kısmı olabilir.',
          'Arkadaşlıklarında alan istersin; seni sıkmayan insanlarla bağın uzun sürer.',
        ],
      },
    ),
    6: KarakterYonu(
      doga: 'sevdiklerini korumak ve sorumluluk almak',
      uyumluGunler: <int>{2, 6, 9},
      zorlayiciGunler: <int>{1, 5, 7},
      gucTavsiyeleri: <String>[
        'Sevdiklerine göstereceğin ilgi beklediğinden fazla karşılık bulacak.',
        'Evine ya da yakın çevrene yapacağın küçük bir dokunuş, herkesin gününü güzelleştirir.',
        'Birine destek olmak için atacağın adım sana da aidiyet hissi verecek.',
        'Çevrendeki birine ihtiyaç duyduğu sıcaklığı ver; senin özen gösterme biçimin kolay bulunmaz.',
      ],
      golgeTavsiyeleri: <String>[
        "Herkesin yükünü taşımak zorunda değilsin; birine 'şimdi yapamam' demek de bir sevgi biçimi.",
        'Başkalarının sorununu çözmeye koşmadan önce, senden gerçekten bunu isteyip istemediklerine bak.',
        'Her şeyin kusursuz olması için uğraşırken kendini yıpratma; sevgi kusursuzluk istemez.',
        'Kendini ihmal ederek başkasına iyi bakamazsın; önce kendi bardağını doldur.',
      ],
      dengeTavsiyeleri: <String>[
        'Başkalarına verdiğin özenin bir kısmını kendine ayır.',
        'Sorumluluklarını paylaştır; yardım istemek seni daha az sevgi dolu yapmaz.',
        'Sevdiklerinle ilgilenirken kendi ihtiyacını da bir kez sesli söyle.',
        'Bir sorumluluğu bir süreliğine bırakıp yerine kendin için küçük bir keyif koy.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta şefkatli ve bağlısın; aynı özeni geri görmediğinde çabuk yorulursun.',
          'Sevgini bakım vererek gösterirsin: bir yemek, bir hatırlatma, sıcak bir mesaj.',
          'İlişkide yuva kurma isteğin güçlüdür; geçici bağlar seni pek tatmin etmez.',
          'Partnerinin mutluluğunu kendi mutluluğunun önüne koymaya yatkınsın.',
        ],
        LuckCategory.para: <String>[
          'Parayı sevdiklerin için harcamaktan hoşlanırsın; kendine ayırmayı sık unutursun.',
          'Ev ve aile giderleri senin bütçende her zaman ilk sırada yer alır.',
          'İnsanlara dokunan, bakım ve hizmet içeren işlerde emeğin daha görünür olur.',
          'Birine borç vermeye ya da yardım etmeye hızlı karar verirsin; sınır koymak seni korur.',
        ],
        LuckCategory.saglik: <String>[
          'Başkalarıyla ilgilenirken kendi bakımını ikinci plana atmaya yatkınsın.',
          'Huzurlu bir ev ortamı senin için en iyi dinlenme biçimidir.',
          'Sevdiklerin için endişelendiğinde bunu önce uykunda hissedersin.',
          'Kendine ayırdığın küçük bir bakım anı, başkalarına verdiğin enerjiyi de yeniler.',
        ],
        LuckCategory.risk: <String>[
          'Sevdiklerini etkileyecek risklerde çok temkinlisin; kendi isteklerinde ise daha cesur olabilirsin.',
          'Bir karar verirken önce ailen ve yakınların üzerindeki etkisini düşünürsün.',
          'Güvenlik hissi senin için heyecandan önemlidir; bu seni çoğu zaman doğru yere götürür.',
          'Başkası için risk almaya, kendin için almaktan daha hazırsın.',
        ],
        LuckCategory.sosyal: <String>[
          'Çevrendeki insanlar sana dert anlatır; sen de yakın ve güvenilir ilişkilerde huzur bulursun.',
          'Bir buluşmada herkesin rahat olup olmadığını kontrol eden kişi sensin.',
          'Misafir ağırlamak, insanları bir sofrada toplamak seni mutlu eder.',
          'Arkadaşlarına sadakatin güçlüdür; kırıldığında ise bunu uzun süre içinde taşırsın.',
        ],
      },
    ),
    7: KarakterYonu(
      doga: 'derinlemesine düşünmek ve kendi başına anlam aramak',
      uyumluGunler: <int>{4, 7, 9},
      zorlayiciGunler: <int>{3, 5, 6},
      gucTavsiyeleri: <String>[
        'Bir konuyu derinlemesine düşünmeye vakit ayır; bulduğun cevap işine yarayacak.',
        'Merak ettiğin bir soruyu araştırmaya bir saat ayır; zihnin bunu bir ödül gibi karşılar.',
        'Sezgin ve analizin aynı yönü gösteriyorsa kararını vermekten çekinme.',
        'İç sesin bir şey söylüyorsa dinle; sessizlikte bulduğun fikir seni şaşırtabilir.',
      ],
      golgeTavsiyeleri: <String>[
        'Her şeyi kafanda çözmeye çalışma; güvendiğin biriyle konuşmak işleri hızlandırır.',
        'Kurduğun senaryolar gerçekte olduğundan büyük görünebilir; bir şeyi sormak saatlerce düşünmekten kısa sürer.',
        'Kendini geri çekmek istediğinde bunu kibarca söyle; sessizliğin yanlış anlaşılmasın.',
        'Mesafeli görünmek istemiyorsan küçük bir sıcaklık göster; bir gülümseme yeterli.',
      ],
      dengeTavsiyeleri: <String>[
        'Analiz yeteneğini kullanırken sezgine de bir şans ver.',
        'Yalnız kalma ihtiyacını koru ama bir kişiyle de bağını sürdür; ikisi birbirini besler.',
        'Düşündüklerinin bir kısmını yazıya dök; düşünce somutlaştığında karar kolaylaşır.',
        'Araştırmayı bir noktada bırak ve karar ver; bilgi ancak kullanıldığında değer kazanır.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta yavaş açılır ama derin bağlanırsın; zihinsel yakınlık senin için şarttır.',
          'Seni gerçekten anlayan biriyle sessizlik bile konuşmaya dönüşür.',
          'Duygularını göstermekte temkinlisin; güven oluştuğunda ise çok sadık birisin.',
          'Yüzeysel flörtler seni çabuk sıkar; anlamlı bir sohbet seni çok daha fazla etkiler.',
        ],
        LuckCategory.para: <String>[
          'Parada dikkatli ve araştırmacısın; bilmediğin bir işe kolay para koymazsın.',
          'Uzmanlık ve derin bilgi isteyen işlerde değerin zamanla daha çok anlaşılır.',
          'Para seni tek başına motive etmez; yaptığın işin anlamı da senin için önemli.',
          'Bir harcama yapmadan önce karşılaştırır, yorumları okur, ancak sonra karar verirsin.',
        ],
        LuckCategory.saglik: <String>[
          'Zihinsel yorgunluk bedenine çabuk yansır; sessizlik ve uyku senin şarj kaynağın.',
          'Doğada, kalabalıktan uzak geçirilen bir saat seni hızla toparlar.',
          'Zihnin durmadığında uykun da bölünebilir; akşamları ekranı erken bırakmak seni rahatlatır.',
          'Tek başına yapılan yürüyüş ya da yüzme gibi sakin hareketler sana daha çok yakışır.',
        ],
        LuckCategory.risk: <String>[
          'Risk almadan önce her ayrıntıyı incelemek istersin; bazen fazla düşünmek fırsatı geçirir.',
          'Araştırmadan bir şeye girmezsin; bu temkin seni çoğu zaman pişmanlıktan korur.',
          'Sezgilerin genellikle doğru yeri gösterir; onları kuşkuyla bastırmamaya dikkat et.',
          'Başkalarının coşkusuna kapılmazsın; kararlarını kendi değerlendirmen belirler.',
        ],
        LuckCategory.sosyal: <String>[
          'Kalabalık yerine az ve derin ilişkileri tercih edersin; yalnız kalmaya da ihtiyaç duyarsın.',
          'Küçük sohbetlerden çok, anlamlı konuşmalar seni insanlara yaklaştırır.',
          'Bir grupta az konuşursun ama söylediğin şey genellikle akılda kalır.',
          'Arkadaşlarınla uzun süre görüşmesen bile bağın kopmaz; seni tanıyanlar bunu bilir.',
        ],
      },
    ),
    8: KarakterYonu(
      doga: 'hedef koymak ve sonuç almak',
      uyumluGunler: <int>{1, 4, 8},
      zorlayiciGunler: <int>{2, 7, 9},
      gucTavsiyeleri: <String>[
        'Hedefini netleştir ve kararlılıkla ilerle; sonuç almaya yakınsın.',
        'Ertelenen bir görüşmeyi ya da talebi gündeme getir; netliğin karşılık bulacak.',
        'Bir işin sorumluluğunu üstlen; yönetme becerin görünür olduğunda kapılar açılır.',
        'Bir pazarlıkta ya da görüşmede değerini net söyle; kararlılığın saygı uyandırır.',
      ],
      golgeTavsiyeleri: <String>[
        'Her şeyi kontrol etmeye çalışmak seni yorar; bazı işleri başkalarına bırakmayı dene.',
        'Sonuca odaklanırken insanların emeğini görmeyi unutma; bir teşekkür ekibini güçlendirir.',
        'Gerginliği içine atmak yerine bir yere boşalt: hareket, konuşma ya da kısa bir mola.',
        'Sonucu zorlamak yerine süreci izle; bazı kapılar zorlandıkça daha sıkı kapanır.',
      ],
      dengeTavsiyeleri: <String>[
        'Hedefe odaklanırken yanındaki insanların ne hissettiğini de hesaba kat.',
        'İddialı ol ama bir kapıyı açık bırak; esnek bir plan seni daha uzağa götürür.',
        'Çalışmaya ayırdığın kararlılığın bir kısmını dinlenmeye de ayır.',
        'Güçlü durmayı bırakmadan birine nasıl hissettiğini anlat; bu seni daha da güçlü kılar.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta koruyucu ve cömertsin; duygularını çoğu zaman sözden çok eylemle gösterirsin.',
          'Güçlü ve kendinden emin insanlar seni etkiler; zayıflığını göstermek ise sana zor gelir.',
          'İlişkide sorumluluk almaktan çekinmezsin; birlikte bir gelecek kurmak seni heyecanlandırır.',
          'İşin yoğunluğu ilişkine az zaman bırakabilir; küçük ama düzenli bir ilgi bunu dengeler.',
        ],
        LuckCategory.para: <String>[
          'Parayla ilişkin güçlü ve hırslı; büyük düşünürsün, inişli çıkışlı dönemler de yaşayabilirsin.',
          'Pazarlık masasında güçlüsün; değerini bilir ve bunu söylemekten çekinmezsin.',
          'Para senin için güç ve güvenlik demek; kontrolü elinde tutmak seni rahatlatır.',
          'Uzun vadeli hedeflerin için kısa vadeli keyiflerden vazgeçebilirsin.',
        ],
        LuckCategory.saglik: <String>[
          'Çok çalışmaya ve stresi içine atmaya yatkınsın; dinlenmek senin için bir ihtiyaç.',
          'Bedenini bir makine gibi zorlayabilirsin; molaları da hedeflerinin bir parçası say.',
          'Güç ve dayanıklılık gerektiren hareketler stresini boşaltmanın en iyi yolu olabilir.',
          'Gerginlik çenene, boynuna ya da uykuna yerleşebilir; bu işaretleri görmezden gelme.',
        ],
        LuckCategory.risk: <String>[
          'Hesaplı risk almayı bilirsin; seni yönlendiren şey kaybetme korkusu değil, kazanma isteği.',
          'Büyük oynamayı seversin; bir adımın hem kazancını hem bedelini önceden hesaplarsın.',
          'Kontrol edemediğin risklerden hoşlanmazsın; kendi yönettiğin işte daha cesursun.',
          'Kararlılığın güçlü bir avantaj; bazen geri adım atmak da stratejinin parçasıdır.',
        ],
        LuckCategory.sosyal: <String>[
          'Sosyal ortamlarda doğal bir otorite taşırsın; insanlar senden yön bekler.',
          'Çevreni özenle seçersin; seni ileri taşıyan insanlarla vakit geçirmek istersin.',
          'Bir organizasyonu toparlamak, kimin ne yapacağını belirlemek sana kolay gelir.',
          'Güvendiğin insanlara cömertsin; sözünü tutmayanlara karşı ise sabrın kısadır.',
        ],
      },
    ),
    9: KarakterYonu(
      doga: 'başkalarına şefkat göstermek ve büyük resmi görmek',
      uyumluGunler: <int>{3, 6, 9},
      zorlayiciGunler: <int>{1, 4, 8},
      gucTavsiyeleri: <String>[
        'Birine karşılıksız bir iyilik yap ya da destek ol; bu sana da anlam katacak.',
        'Büyük resme bak; küçük bir aksilik, uzun yolun yalnızca bir parçası.',
        'Deneyimini biriyle paylaş; anlattığın şey onun için bir yol haritası olabilir.',
        'Uzun süredir aklında olan bir iyiliği gerçekleştir; vermenin keyfi sana geri döner.',
      ],
      golgeTavsiyeleri: <String>[
        'Geçmişte kalmış bir konuyu tekrar tekrar düşünmek yerine ona bir nokta koymayı dene.',
        'Herkesi kurtarmaya çalışmak seni tüketir; bazı insanlar kendi yolunu kendisi bulmalı.',
        'Kırgınlığını içinde biriktirme; sakin bir cümleyle söylemek seni hafifletir.',
        'Hayal kırıklığını büyütmek yerine ondan öğrendiğin tek bir şeyi yaz ve sayfayı çevir.',
      ],
      dengeTavsiyeleri: <String>[
        'Başkalarına verdiğin desteği kendi ihtiyaçlarınla dengele.',
        'İdealini koru ama ona giden ilk küçük adımı da somut olarak belirle.',
        'Bırakman gerekeni bırakırken kalanı da değerini bilerek koru.',
        'Herkese yetişmeye çalışmadan, en çok önemsediğin bir kişiye zaman ayır.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta derin ve affedicisin; sevdiğin kişiyi olduğundan büyük görebilirsin.',
          'Romantik ve idealistsin; kalbini verdiğinde koşulsuz verirsin.',
          'Geçmiş ilişkilerin izlerini uzun süre taşıyabilirsin; kapanış senin için önemli.',
          'Seni en çok, dünyaya senin gibi geniş bakan ve şefkatini paylaşan biri etkiler.',
        ],
        LuckCategory.para: <String>[
          'Parayı bir amaç için kazanmak seni motive eder; verirken kendine pay ayırmak önemli.',
          'İnsanlara dokunan, anlam taşıyan işlerde emeğin daha çok karşılık bulur.',
          'Cömertliğin bazen bütçeni zorlar; vermeden önce kendi ihtiyacını hesaplamak seni korur.',
          'Maddi konularda büyük döngüler yaşarsın; bir dönemin kapanışı yenisine yer açar.',
        ],
        LuckCategory.saglik: <String>[
          'Başkalarının derdini içine almak seni yorabilir; kendine sınır koymak seni korur.',
          'Duygusal yorgunluğun bedeninde hissedilir; ağlamak da gülmek de seni hafifletir.',
          'Sanat, müzik ya da doğa sana en derin dinlenmeyi verir.',
          'Başkasına ayırdığın şefkatin küçük bir kısmını kendi bedenine ayırmak dengeni korur.',
        ],
        LuckCategory.risk: <String>[
          'İdealist kararlar verebilirsin; bir fikre gönül vermeden önce gerçekçi yanlarını da düşün.',
          'İnsanlara güvenmeye yatkınsın; önemli bir anlaşmada ayrıntıları yazıya dökmek seni korur.',
          'Bir dönemi kapatma cesaretin güçlüdür; yeni bir başlangıca ise acele etmeden geçmek daha iyi.',
          'Kalbinin sesi seni anlamlı yerlere götürür; bütçenin sesi ise oraya güvenle varmanı sağlar.',
        ],
        LuckCategory.sosyal: <String>[
          'Farklı insanları kolayca anlarsın; geniş ve çeşitli bir çevren olur.',
          'Yabancılarla bile kısa sürede samimi olursun; insanlar yanında anlaşıldığını hisseder.',
          'Bir topluluk ya da bir amaç için bir araya gelmek seni canlandırır.',
          'Eski arkadaşlıkları bırakmakta zorlanırsın; bazı bağların doğal sonu da bir saygıdır.',
        ],
      },
    ),
    11: KarakterYonu(
      doga: 'sezgilerine güvenmek ve insanlara ilham vermek',
      uyumluGunler: <int>{2, 7, 9},
      zorlayiciGunler: <int>{4, 5, 8},
      gucTavsiyeleri: <String>[
        'İçinden gelen ilk hisse güven; sezgilerin seni doğru yere götürecek.',
        'Birine ilham verecek bir şey paylaş; sözlerin beklediğinden uzağa ulaşır.',
        'Fark ettiğin ince ayrıntıyı dile getir; başkalarının kaçırdığını sen görebilirsin.',
        'Bir önsezin varsa onu küçük bir adımla sına; sonuç seni şaşırtmayabilir.',
      ],
      golgeTavsiyeleri: <String>[
        'Hassasiyetin kaygıya dönüşmesin; bir hissi gerçek sanmadan önce bir kez kontrol et.',
        'Kendinden çok şey beklemek seni gerer; yaptığın şeyin yeterli olduğunu kabul et.',
        'Yoğun uyaranlardan uzaklaşmak için kendine sessiz bir an yarat.',
        'Başkalarının beklentilerini omzuna almadan önce kendi beklentini netleştir.',
      ],
      dengeTavsiyeleri: <String>[
        'Sezgine güvenirken ayağını yere basan somut bir adım da at.',
        'İlhamını bir plana dönüştür: bir fikir, bir tarih, bir ilk adım.',
        'Başkalarına ışık tutarken kendi yorgunluğunu da fark et.',
        'Hayal ettiğin şeyi birine anlat; söze döktüğünde gerçeğe bir adım yaklaşır.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta ruhsal bir bağ ararsın; yüzeysel ilişkiler seni çabuk yorar.',
          'Partnerinin söylemediklerini hissedersin; bu hassasiyet hem güçlü yanın hem yükün.',
          'Seni gerçekten gören biriyle bağın, sıradan ilişkilerden çok daha yoğun yaşanır.',
          'Kırılganlığını göstermekten çekinebilirsin; oysa açıldığında bağın derinleşir.',
        ],
        LuckCategory.para: <String>[
          'Parayla ilişkin dalgalı olabilir; sezgin kadar sade bir bütçeye de güvenmek seni rahatlatır.',
          'İlham verdiğin, insanlara dokunduğun işlerde kazancın da anlamın da artar.',
          'Maddi kararlarda ilk hissin çoğu zaman doğrudur; rakamlarla desteklediğinde daha da güçlenir.',
          'Para senin için tek başına hedef değil; bir vizyona hizmet ettiğinde motive edicidir.',
        ],
        LuckCategory.saglik: <String>[
          'Uyaranlara karşı hassassın; gürültü ve yoğunluk enerjini hızla düşürür.',
          'Hassas bir zihnin var; sakin bir akşam rutini seni hızla dengeler.',
          'Nefes egzersizi gibi sakin uygulamalar sana yoğun tempodan daha çok enerji verir.',
          'Başkalarının duygularını üstlendiğinde yorgunluğu bedeninde hissedersin.',
        ],
        LuckCategory.risk: <String>[
          'Sezgilerin risk konusunda çoğu zaman haklı çıkar; yine de kaygıyla sezgiyi karıştırmamaya dikkat et.',
          'Büyük vizyonlar kurarsın; onları küçük ve güvenli adımlarla sınamak seni korur.',
          'Bir fırsatın ruhunu hissedersin; ayrıntılarını ise güvendiğin birine danışmak iyi olur.',
          'Belirsizlik zihnini yorabilir; net bir sınır koyduğunda daha cesur karar verirsin.',
        ],
        LuckCategory.sosyal: <String>[
          'İnsanlar yanında ilham alır; ama kalabalıktan sonra toparlanmak için yalnız zamana ihtiyaç duyarsın.',
          'Bir ortama girdiğinde havayı hemen hissedersin; bu seni iyi bir dinleyici yapar.',
          'Az ama ruhen yakın arkadaşlıklar seni besler.',
          'İnsanlar sana içlerini açar; sınır koymak enerjini korur.',
        ],
      },
    ),
    22: KarakterYonu(
      doga: 'büyük bir fikri adım adım gerçeğe dönüştürmek',
      uyumluGunler: <int>{1, 4, 8},
      zorlayiciGunler: <int>{3, 5, 9},
      gucTavsiyeleri: <String>[
        'Büyük hedefinin somut bir parçasını tamamla; küçük adım büyük yapıyı ilerletir.',
        'Bir planı kâğıda dök ve ilk aşamasını başlat; vizyonun ancak böyle görünür olur.',
        'Yönetme ve organize etme becerini kullan; dağınık bir işi toparlayan sen olabilirsin.',
        'Uzun vadeli planının bir parçasını birine emanet et; doğru ekip yükü hafifletir.',
      ],
      golgeTavsiyeleri: <String>[
        'Her şeyin mükemmel olmasını beklemek seni durdurmasın; iyi olan bir adım yeterli.',
        'Tüm yükü kendi omzunda taşıma; büyük yapılar birçok elle kurulur.',
        'Hedefin büyüklüğü seni bunaltırsa yalnızca sıradaki adıma bak.',
        'Kontrolü bırakmak zor geldiğinde kendine sor: bu ayrıntı gerçekten şimdi mi önemli?',
      ],
      dengeTavsiyeleri: <String>[
        'Büyük planlarını düşünürken günün küçük işlerini de ihmal etme.',
        'Uzun vadeli hedefini korurken kısa bir dinlenmeye de izin ver.',
        'Vizyonunu paylaş ama ayrıntıları birlikte çalıştığın insanlara da bırak.',
        'Hedeflerinle ilişkilerin arasında bir köprü kur; başarını paylaşacağın insanlar da yapının parçası.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta güvenilir ve ciddisin; birlikte bir gelecek kurabileceğin birini ararsın.',
          'Sevgini planlarına dahil ederek gösterirsin; partnerin hayatının yapı taşlarından biridir.',
          'İşine olan bağlılığın ilişkine az alan bırakabilir; ortak zaman planlamak bunu dengeler.',
          'Hayallerini paylaşabileceğin, seninle aynı yöne bakan biri sana güç verir.',
        ],
        LuckCategory.para: <String>[
          'Parayı uzun vadeli ve sağlam planlarla büyütmeyi tercih edersin.',
          'Büyük ölçekli düşünürsün; küçük kazançlardan çok kalıcı yapılar seni motive eder.',
          'Kaynakları organize etme becerin maddi konularda en büyük avantajın.',
          'Hızlı kazançtan çok kalıcı değer üretmek sana daha çok yakışır.',
        ],
        LuckCategory.saglik: <String>[
          'Sorumluluk yükünü bedeninde taşıyabilirsin; gerginliği biriktirmemeye dikkat et.',
          'Uzun çalışma saatleri seni farkında olmadan yıpratır; düzenli molalar sistemin parçası olmalı.',
          'Güçlü bir rutin seni ayakta tutar; dinlenmeyi de o rutine yazmak işini kolaylaştırır.',
          'Zihnin sürekli plan yaptığında uykun hafifleyebilir; günü yazıya dökerek kapatmak seni rahatlatır.',
        ],
        LuckCategory.risk: <String>[
          'Büyük düşünürsün ama riski planlı alırsın; hazırlıksız atılmayı sevmezsin.',
          'Uzun vadeli bir hedef için kısa vadeli fedakârlıkları göze alabilirsin.',
          'Büyük bir adımı aşamalara bölmek seni hem cesur hem güvende tutar.',
          'Riskin kendisinden çok, hazırlıksız yakalanmaktan hoşlanmazsın.',
        ],
        LuckCategory.sosyal: <String>[
          'İnsanları ortak bir amaç etrafında toplamakta ustasın.',
          'Çevrende güvenilir bir lider olarak görülürsün; insanlar planlarına katılmak ister.',
          'Sohbetlerin bile çoğu zaman bir projeye ya da fikre dönüşür.',
          'Sana güvenen küçük ama güçlü bir çevre, kalabalık bir topluluktan daha değerlidir.',
        ],
      },
    ),
    33: KarakterYonu(
      doga: 'insanlara yol göstermek ve onları desteklemek',
      uyumluGunler: <int>{3, 6, 9},
      zorlayiciGunler: <int>{1, 5, 8},
      gucTavsiyeleri: <String>[
        'Bilgini ya da deneyimini biriyle paylaş; yol göstermek sana da güç verecek.',
        'Zor bir dönemden geçen birine ayıracağın zaman ikiniz için de anlamlı olacak.',
        'Şefkatini bir eyleme dönüştür: bir telefon, bir yardım, cesaret veren bir söz.',
        'Birinin içindeki potansiyeli gör ve ona söyle; cesaret veren sözün uzun süre hatırlanabilir.',
      ],
      golgeTavsiyeleri: <String>[
        'Herkesin sorununu çözmek zorunda değilsin; bazen dinlemek yeterli.',
        'Kendini feda etmek ile destek olmak arasındaki çizgiyi koru.',
        'Başkalarından beklediğin özeni sessizce bekleme; ihtiyacını dile getir.',
        'Yardım teklifine hayır diyen birine ısrar etme; saygı da bir şefkat biçimi.',
      ],
      dengeTavsiyeleri: <String>[
        'Başkalarını desteklerken kendine de aynı şefkati göster.',
        'Yardım ederken bir sınır belirle; böylece verdiğin destek daha uzun sürer.',
        'Yol göstermek ile yolu onların yerine yürümek arasındaki farkı gözet.',
        'Verdiğin kadar almaya da izin ver; birinin sana destek olmasına alan aç.',
      ],
      kategoriTarzi: <LuckCategory, List<String>>{
        LuckCategory.ask: <String>[
          'Aşkta fedakâr ve besleyicisin; kendi ihtiyaçlarını söylemeyi unutmamalısın.',
          'Sevdiğin kişiyi büyütmek, desteklemek ve korumak senin sevgi dilin.',
          'İlişkide karşılıklılık önemlidir; yalnızca veren taraf olmak seni yorabilir.',
          'Şefkatine değer veren ve sana da alan açan biriyle bağın derinleşir.',
        ],
        LuckCategory.para: <String>[
          'Para senin için iyilik yapabilmenin aracıdır; kendine ayırdığın payı korumak önemli.',
          'Öğretmek, iyileştirmek ya da rehberlik etmek gibi işlerde emeğin daha çok karşılık bulur.',
          'Yardım etme isteğin bütçeni zorlayabilir; önce kendi güvenceni kurmak herkes için iyi.',
          'Maddi başarı seni tek başına mutlu etmez; bir işe yaradığını görmek istersin.',
        ],
        LuckCategory.saglik: <String>[
          'Başkalarına enerji verirken tükenmeye yatkınsın; kendi bakımına zaman ayırmalısın.',
          'Herkesin derdini dinledikten sonra sessiz bir akşam seni yeniden doldurur.',
          'Bedenin, verdiğin desteğin yükünü sessizce taşır; ona da şefkat göstermelisin.',
          'Yaratıcı ve sakin uğraşlar zihnini ve bedenini birlikte dinlendirir.',
        ],
        LuckCategory.risk: <String>[
          'Başkalarını etkileyecek kararlarda çok dikkatlisin; bu sorumluluk duygun seni korur.',
          'Kendi çıkarın için risk almakta isteksiz, başkası için cesursun.',
          'Kararlarında vicdanın pusulandır; bu seni çoğu zaman doğru yere götürür.',
          'Yardım etmek için girdiğin işlerde de sınırını önceden belirlemek seni korur.',
        ],
        LuckCategory.sosyal: <String>[
          'İnsanlar yanında öğrenir ve rahatlar; çevrende doğal bir rehber gibi görülürsün.',
          'Bir grupta herkesin sesinin duyulmasını sağlayan sensin.',
          'İnsanlar zor anlarında ilk seni arar; bu güven en büyük sosyal sermayen.',
          'Seni de dinleyen, senin için de orada olan arkadaşlar senin için en kıymetlileri.',
        ],
      },
    ),
  };
}
