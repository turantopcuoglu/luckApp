/// Kategori × kişinin durumu × ton: o alanda bugün ne oluyor.
///
/// Öne çıkan kategori çoğu kişide ayda 10-15 kez aynı tonda gelir; bu
/// yüzden her (kategori, durum, ton) havuzu en az
/// [ContentConfig.enAzKategoriDurumVaryanti] varyant içerir.
///
/// Yazım kuralları (bkz. `sayi_metinleri.dart`) ek olarak:
/// - Cümle alan adıyla açılır ("Aşk tarafında", "İşinde", "Kararlarında"…)
///   ve "Bugün" ile BAŞLAMAZ; günü anan cümle okumanın açılışıdır.
/// - "uygun bir gün" / "elverişli bir gün" kalıpları kullanılmaz.
/// - Düşük tonda her cümle bir koruyucu öneri de taşır.
library;

import '../luck_engine/luck_engine.dart';
import 'content_config.dart';

/// Kategori durum havuzları.
abstract final class KategoriDurumlari {
  /// Kategori → durum anahtarı → ton → varyantlar.
  ///
  /// Durum anahtarları `YorumYonu.durumAnahtari` ile bulunur; her
  /// kategoride `genel` anahtarı her zaman vardır.
  static const Map<LuckCategory, Map<String, Map<KategoriTonu, List<String>>>>
  hepsi = <LuckCategory, Map<String, Map<KategoriTonu, List<String>>>>{
    LuckCategory.ask: <String, Map<KategoriTonu, List<String>>>{
      'bekar': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Aşk tarafında beklediğin ilgi gelmeyebilir; bunu kendi değerinle ilgili bir işaret olarak görme.',
          'Aşk tarafında yalnızlık hissi biraz daha belirgin olabilir; seni iyi hissettiren biriyle vakit geçirmek dengeni toparlar.',
          'Aşk tarafında birine fazla anlam yüklemeye yatkın olabilirsin; bir mesajın gecikmesi her zaman bir cevap değildir.',
          'Aşk tarafında geçmişten biri aklına gelebilir; o kapıyı yeniden açmadan önce neden kapandığını hatırla.',
        ],
        KategoriTonu.orta: <String>[
          'Aşk tarafında sakin bir akış var; tanıdık bir çevrede yeni bir yüzle sohbet başlayabilir.',
          'Aşk tarafında flört için zorlamak yerine doğal davranmak daha çekici.',
          'Aşk tarafında beklentisiz bir buluşma, planlanmış olandan daha keyifli geçebilir.',
          'Aşk tarafında ilgini çeken biriyle küçük bir sohbet zamanla daha fazlasına dönüşebilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Aşk tarafında tanışmalar ve ilgi için kapılar açık; bir davete ya da sohbete evet demek güzel sonuç verebilir.',
          'Aşk tarafında çekiciliğin yüksek; ilgini çeken biriyle ilk adımı atmak için cesaretin yerinde.',
          'Aşk tarafında gözler üzerinde olabilir; kendini gizlemek yerine olduğun gibi görünmek seni çekici kılar.',
          'Aşk tarafında bir mesaj, bir bakış ya da bir tesadüf heyecan verici bir başlangıca dönüşebilir.',
        ],
      },
      'partnerli': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'İlişkinde küçük bir konu kolayca büyüyebilir; önce dinlemek, sonra cevap vermek işleri yumuşatır.',
          'İlişkinde partnerinle aranızda bir yorgunluk hissedebilirsin; bu bir kopuş değil, biraz alana ihtiyaç.',
          'İlişkinde söylenmeyen bir beklenti gerginlik yaratabilir; tahmin ettirmek yerine açıkça söylemek rahatlatır.',
          'İlişkinde günlük stres aranıza girebilir; sorunu birbirinizde değil yorgunlukta aramak işleri kolaylaştırır.',
        ],
        KategoriTonu.orta: <String>[
          'İlişkinde sıradan ama sıcak bir akış var; küçük bir jest aranızdaki bağı güçlendirir.',
          'İlişkinde partnerinle birlikte yapacağınız basit bir iş, uzun bir konuşmadan daha çok yakınlaştırır.',
          'İlişkinde ortak bir plan yapmak ya da bir hayali konuşmak bağınızı tazeler.',
          'İlişkinde ufak bir teşekkür ya da takdir sandığından derin bir etki bırakır.',
        ],
        KategoriTonu.yuksek: <String>[
          'İlişkinde yakınlık kolay; birlikte plan yapmak ya da güzel bir akşam geçirmek için zaman tam yerinde.',
          'İlişkinde partnerine hissettiklerini söylemek için doğal bir akış var.',
          'İlişkinde birbirinizi yeniden keşfettiğiniz bir an yaşanabilir; küçük bir sürpriz bunu tetikleyebilir.',
          'İlişkinde uzun süredir konuşmak istediğin bir konu beklediğinden yumuşak karşılanabilir.',
        ],
      },
      'genel': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Aşk tarafında duygular hassas; yanlış anlaşılmaya açık konuşmaları ertelemek iyi olur.',
          'Aşk tarafında kalbini başkasının onayına bağlamak seni yorabilir.',
          'Aşk tarafında beklentilerin karşılık bulmayabilir; kendine şefkat göstermek ilk adım.',
          'Aşk tarafında kıskançlık ya da güvensizlik hissi büyüyebilir; hisleri gerçeklerden ayırmaya çalış.',
        ],
        KategoriTonu.orta: <String>[
          'Aşk tarafında dengeli bir akış var; küçük bir ilgi büyük yankı bulabilir.',
          'Aşk tarafında duygularını sakin bir dille ifade etmek ilişkilerini yumuşatır.',
          'Aşk tarafında sürpriz yok ama huzur var; bunun kıymetini bilmek yeterli.',
          'Aşk tarafında birine ayıracağın içten bir an seni de ısıtabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Aşk tarafında sıcak ve açık bir hava var; hissettiklerini göstermek karşılık bulur.',
          'Aşk tarafında duygusal yakınlık kurmak her zamankinden kolay.',
          'Aşk tarafında çekiciliğin ve sıcaklığın öne çıkıyor; insanlar sana daha kolay yaklaşıyor.',
          'Aşk tarafında kalbinin sesini dinlemek seni güzel bir yakınlığa götürebilir.',
        ],
      },
    },
    LuckCategory.para: <String, Map<KategoriTonu, List<String>>>{
      'calisiyor': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'İş ve para tarafında beklenmedik bir aksilik ya da ek iş çıkabilir; önemli kararları yarına bırakmak daha güvenli.',
          'İş tarafında emeğinin görünmediğini hissedebilirsin; şimdilik sabırlı olmak daha doğru.',
          'İş tarafında iletişim aksayabilir; önemli bir mesajı göndermeden önce bir kez daha oku.',
          'İş tarafında yetişmesi gereken işler üst üste binebilir; listeyi kısaltmak seni rahatlatır.',
        ],
        KategoriTonu.orta: <String>[
          'İş tarafında sakin ve yönetilebilir bir akış var; önceliklerini sıraya koymak yeterli.',
          'İş tarafında küçük ama düzenli bir ilerleme kaydedebilirsin.',
          'İş tarafında rutin işler ağır basabilir; onları hızla bitirmek sana nefes alanı açar.',
          'İş tarafında bir iş arkadaşınla kısa bir fikir alışverişi işini kolaylaştırabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'İş tarafında emeğin görünür oluyor; bir talebini dile getirmek için zaman yerinde.',
          'İş tarafında bir fırsat ya da takdir gelebilir; kendini geri çekme.',
          'İş tarafında fikirlerin her zamankinden çok dinleniyor; bir öneri sunmak için cesaretini kullan.',
          'İş tarafında uzun süredir uğraştığın bir konu olumlu bir noktaya gelebilir.',
        ],
      },
      'girisimci': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'İşinde bir gecikme ya da beklenmedik bir gider canını sıkabilir; büyük harcamaları ertele.',
          'İşinde yeni harcama kararları yerine eldekini korumaya odaklanmak daha güvenli.',
          'İşinde bir müşteri ya da iş ortağıyla iletişim zorlaşabilir; sakin kalmak pazarlık gücünü korur.',
          'İşinde planladığın bir adım beklemek zorunda kalabilir; bu süreyi hazırlığa çevir.',
        ],
        KategoriTonu.orta: <String>[
          'İşinde dengeli bir akış var; müşterilerinle ilişkini güçlendirmek için iyi bir fırsat.',
          'İşinde hesapları gözden geçirip küçük iyileştirmeler yapmak kazandırır.',
          'İşinde sürdürülebilir bir tempo büyük hamlelerden daha çok işe yarar.',
          'İşinde bir süreci sadeleştirmek ya da bir işi devretmek zaman kazandırabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'İşinde satış, anlaşma ya da yeni bir iş bağlantısı için kapılar açık.',
          'İşinde cesur bir teklif ya da fiyat kararı karşılık bulabilir.',
          'İşinde görünürlüğün artıyor; bir tanıtım ya da paylaşım beklediğinden geniş bir kitleye ulaşabilir.',
          'İşinde uzun süredir beklediğin bir dönüş olumlu gelebilir.',
        ],
      },
      'ogrenci': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Para tarafında bütçeni zorlayacak küçük harcamalara dikkat.',
          'Derslerde sorumluluklar üst üste gelebilir; önce en acil olanı bitir.',
          'Derslerde odaklanmak zor olabilir; kısa aralıklarla çalışmak daha verimli.',
          'Derslerde bir sonucun beklediğin gibi gelmemesi moralini bozabilir; bu tek bir an, bütün yol değil.',
        ],
        KategoriTonu.orta: <String>[
          'Dersler ve bütçe tarafında sakin bir akış var; küçük bir planlama işini kolaylaştırır.',
          'Derslerde bir sınava ya da projeye düzenli çalışmak karşılığını verir.',
          'Derslerde tekrar yapmak yeni bir konuya geçmekten daha çok kazandırabilir.',
          'Para tarafında küçük bir tasarruf ay sonunda seni rahatlatabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Dersler tarafında verimli bir akış var; zor bir konuyu çözmek ya da iyi bir sonuç almak mümkün.',
          'Okul tarafında bir burs, staj ya da proje fırsatını kaçırmamak için etrafına dikkat et.',
          'Derslerde kavrayışın hızlı; zor bulduğun konuya şimdi dönmek iyi bir fikir.',
          'Derslerde bir öğretmenden ya da hocadan olumlu bir geri dönüş gelebilir.',
        ],
      },
      'isArayan': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'İş arayışında beklediğin dönüş gelmeyebilir; bunu yeteneğinle ilgili bir işaret olarak görme.',
          'İş arayışında moralin biraz düşük olabilir; başvuru yapmak yerine kendini toparlamak daha iyi.',
          'İş arayışında aceleyle verilen bir karar sonradan ağır gelebilir; teklifleri tartarak değerlendir.',
          'İş arayışında süreç yavaş ilerleyebilir; bu sessizlik bir ret değil, bekleme.',
        ],
        KategoriTonu.orta: <String>[
          'İş arayışında düzenli bir akış var; birkaç başvuruyu dikkatle hazırlamak iyi sonuç verir.',
          'İş arayışında tanıdıklarına ne aradığını anlatmak beklenmedik bir kapı açabilir.',
          'İş arayışında yeni bir beceriye ya da kursa göz atmak seni bir adım öne taşıyabilir.',
          'İş arayışında özgeçmişini başvurduğun işe göre uyarlamak fark yaratabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'İş arayışında olumlu bir dönüş ya da görüşme daveti gelebilir.',
          'İş arayışında bir görüşmede kendini anlatman her zamankinden etkili olabilir.',
          'İş arayışında bir tanıdığın önerisi ya da bir ilan beklediğinden doğru çıkabilir.',
          'İş arayışında özgüvenin yüksek; cesur bir başvuru yapmak için zaman yerinde.',
        ],
      },
      'evde': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Para tarafında ev giderleri ya da beklenmedik bir masraf canını sıkabilir.',
          'Para tarafında alışverişte plansız harcamalara karşı dikkatli ol.',
          'Para tarafında bir ödeme ya da fatura unutulabilir; kısa bir kontrol seni rahatlatır.',
          'Para tarafında evdeki bir arıza ya da ihtiyaç bütçeni zorlayabilir; acele etmeden seçenekleri karşılaştır.',
        ],
        KategoriTonu.orta: <String>[
          'Para tarafında sakin bir akış var; ev bütçesini gözden geçirmek netlik verir.',
          'Para tarafında küçük bir tasarruf fikri ay sonunu rahatlatabilir.',
          'Para tarafında ihtiyaç ile istek arasındaki farkı netleştirmek kararlarını kolaylaştırır.',
          'Para tarafında aile içinde bütçe konuşmak herkesi aynı sayfaya getirir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Para tarafında ferah bir hava var; ev için uzun süredir düşündüğün bir ihtiyacı değerlendirebilirsin.',
          'Para tarafında bir indirim, hediye ya da beklenmedik küçük bir kazanç gelebilir.',
          'Para tarafında evle ilgili bir fikir küçük bir gelir kapısına dönüşebilir.',
          'Para tarafında uzun süredir biriktirdiğin bir hedefe yaklaştığını fark edebilirsin.',
        ],
      },
      'genel': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Para tarafında plansız harcamalar ve beklenmedik giderler öne çıkabilir.',
          'Para tarafında maddi bir kararı aceleyle vermek yerine bir gün beklemek daha güvenli.',
          'Para tarafında borç vermek ya da ödünç almak konusunda temkinli ol.',
          'Para tarafında küçük harcamalar birikip seni şaşırtabilir; bir göz atmak yeterli.',
        ],
        KategoriTonu.orta: <String>[
          'Para tarafında dengeli bir akış var; büyük adımlar yerine küçük düzenlemeler yeterli.',
          'Para tarafında harcamalarını gözden geçirmek sana netlik kazandırır.',
          'Para tarafında sürpriz yok; mevcut düzenini korumak en akıllıca yol.',
          'Para tarafında küçük bir hedef koymak motivasyonunu artırabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Para tarafında fırsatlara açık bir hava var; emeğinin karşılığını istemekten çekinme.',
          'Para tarafında maddi konularda olumlu bir gelişme olabilir.',
          'Para tarafında beklenmedik bir kazanç ya da tasarruf kapısı açılabilir.',
          'Para tarafında verdiğin bir karar beklediğinden iyi sonuç verebilir.',
        ],
      },
    },
    LuckCategory.saglik: <String, Map<KategoriTonu, List<String>>>{
      'genel': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Enerjin düşük olabilir; gün içinde kısa molalar vermek seni toparlar.',
          'Yorgunluk ve gerginlik bedeninde daha çok hissedilebilir; uykuna ve su içmeye özen göster.',
          'Kendini zorlamak yerine temponu düşürmek daha doğru.',
          'Bedenin sana yavaşlaman gerektiğini söylüyor olabilir; sinyalleri görmezden gelme.',
        ],
        KategoriTonu.orta: <String>[
          'Enerjin dengede; düzenli beslenme ve kısa bir yürüyüş gününü güzelleştirir.',
          'Bedenin sana ne istediğini söylüyor; dinlenmeyle hareket arasında denge kur.',
          'Hafif bir egzersiz ya da temiz hava moralini de yükseltir.',
          'Enerjin ne yüksek ne düşük; küçük ama düzenli alışkanlıklar fark yaratır.',
        ],
        KategoriTonu.yuksek: <String>[
          'Enerjin yüksek; ertelediğin bir spora ya da uzun bir yürüyüşe başlamak için güzel bir fırsat.',
          'Kendini canlı ve dayanıklı hissedebilirsin; bu enerjiyi hareketle değerlendir.',
          'Yeni ve sağlıklı bir alışkanlığa başlamak için motivasyonun yerinde.',
          'Bedenin hafif ve zinde; açık havada geçireceğin bir saat bu enerjiyi katlayabilir.',
        ],
      },
    },
    LuckCategory.risk: <String, Map<KategoriTonu, List<String>>>{
      'kalp': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Kararlarında duygularınla hızlı davranmak pişmanlık getirebilir; bir gece beklemek daha iyi.',
          "Kararlarında heyecanla verilen bir 'evet' yarın ağır gelebilir.",
          'Kararlarında kırgınlık ya da öfkeyle hareket etmek seni istemediğin bir yere götürebilir.',
          'Kararlarında içindeki ses biraz karışık; netleşene kadar beklemek en iyisi.',
        ],
        KategoriTonu.orta: <String>[
          'Kararlarında içinden geleni dinleyebilirsin ama rakamlara da bir göz at.',
          'Kararlarında küçük riskler alınabilir; büyük olanları birine danışarak ver.',
          'Kararlarında sezgin ile mantığın aynı yönü gösterdiğinde ilerlemek güvenli.',
          'Kararlarında güvendiğin birinin fikri kalbinin sesini netleştirebilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Kararlarında sezgilerin güçlü; içinden gelen cesur adım karşılık bulabilir.',
          'Kararlarında kalbinin evet dediği bir fırsatı değerlendirmek için cesaretin yerinde.',
          'Kararlarında ilk hissin isabetli olabilir; uzun uzun tartmadan da doğruyu bulabilirsin.',
          'Kararlarında tutkuyla bağlandığın bir fikir sana beklediğinden fazlasını getirebilir.',
        ],
      },
      'akil': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Kararlarında hesapların bile seni yanıltabilir; önemli bir riski ertelemek daha güvenli.',
          "Kararlarında 'mantıklı görünüyor' dediğin bir teklifin arkasını bir kez daha kontrol et.",
          'Kararlarında eksik bilgiyle ilerlemek risk taşıyor; önce sorularını tamamla.',
          'Kararlarında aşırı analiz seni kararsızlığa itebilir; büyük kararları bir süre beklet.',
        ],
        KategoriTonu.orta: <String>[
          'Kararlarında hesaplı riskler alınabilir; artıları ve eksileri yazmak işini kolaylaştırır.',
          'Kararlarında işin duygusal tarafını da hesaba katmak daha iyi sonuç verir.',
          'Kararlarında küçük bir deneme büyük bir taahhütten daha akıllıca.',
          'Kararlarında deneyimli birine danışmak seni güçlendirir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Kararlarında analizlerin isabetli; hesapladığın bir adımı atmak için zaman yerinde.',
          'Kararlarında planladığın bir riski almak için koşullar senden yana.',
          'Kararlarında zihnin berrak; karmaşık bir seçimi netleştirmek kolaylaşıyor.',
          'Kararlarında hazırlığının karşılığını alabilirsin; ertelediğin hesaplı adımı atmaktan çekinme.',
        ],
      },
      'genel': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Kararlarında şansı zorlamak yerine elindekini korumak daha güvenli.',
          'Kararlarında büyük riskler için zaman doğru değil; bekleyebiliyorsan bekle.',
          'Kararlarında başkalarının baskısıyla acele etme; zaman senin tarafında.',
          'Kararlarında ilk göründüğü kadar parlak olmayan bir teklif çıkabilir; ayrıntılara bak.',
        ],
        KategoriTonu.orta: <String>[
          'Kararlarında küçük ve hesaplı riskler alınabilir.',
          'Kararlarında yeni bir şey denerken sınırını önceden belirlemek yeterli.',
          'Kararlarında orta yolu bulmak hem cesaretini hem güvenliğini korur.',
          'Kararlarında acele etmeden ama ertelemeden ilerlemek doğru denge.',
        ],
        KategoriTonu.yuksek: <String>[
          'Kararlarında cesaret karşılık buluyor; ertelediğin bir adımı atmanın zamanı.',
          'Kararlarında şans cesur ama hazırlıklı olandan yana.',
          'Kararlarında yeni bir fırsatı değerlendirmek için koşullar senden yana.',
          'Kararlarında içindeki güven seni doğru zamanda doğru adıma götürebilir.',
        ],
      },
    },
    LuckCategory.sosyal: <String, Map<KategoriTonu, List<String>>>{
      'iceDonuk': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Sosyal tarafta kalabalık seni çabuk yorabilir; bir daveti ertelemekte sakınca yok.',
          'Sosyal tarafta uzun sohbetler yerine kendine ayırdığın sessiz bir zaman seni daha çok toparlar.',
          'Sosyal tarafta birinin sözü seni olduğundan fazla etkileyebilir; her şeyi kişisel algılama.',
          'Sosyal tarafta mesajlara hemen cevap vermek zorunda değilsin; kendi temponu koru.',
        ],
        KategoriTonu.orta: <String>[
          'Sosyal tarafta tek bir yakın dostla yapılacak sohbet sana enerji verir.',
          'Sosyal tarafta küçük ve samimi bir buluşma büyük bir kalabalıktan daha keyifli olur.',
          'Sosyal tarafta kısa bir mesajla bir bağı canlı tutmak yeterli.',
          'Sosyal tarafta dinlediğin kadar paylaşmak da seni rahatlatabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Sosyal tarafta normalden daha açıksın; yeni biriyle tanışmak sandığından kolay olabilir.',
          'Sosyal tarafta bir grupta fikrini söylemek için içinden gelen cesareti değerlendir.',
          'Sosyal tarafta sessiz gücün fark ediliyor; insanlar fikrini merak ediyor.',
          'Sosyal tarafta derin bir sohbet seni yeni bir dostluğa yaklaştırabilir.',
        ],
      },
      'disaDonuk': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Sosyal tarafta herkese yetişmeye çalışmak seni yorabilir; planlarını azaltmak enerjini korur.',
          'Sosyal tarafta sözlerin yanlış anlaşılmaya açık; esprilerine dikkat et.',
          'Sosyal tarafta bir planın iptal olması canını sıkabilir; kendine vakit ayırmak da fena değil.',
          'Sosyal tarafta ortamın gerginliğini üstlenme; herkesin modunu düzeltmek senin görevin değil.',
        ],
        KategoriTonu.orta: <String>[
          'Sosyal tarafta hareketli bir akış var; arkadaşlarla kısa bir buluşma enerjini yükseltir.',
          'Sosyal tarafta yeni insanlarla tanışmak için makul bir fırsat var.',
          'Sosyal tarafta bir grup sohbeti ya da ortak bir plan seni canlandırabilir.',
          'Sosyal tarafta uzun zamandır görmediğin biriyle yeniden bağ kurmak sevindirici olabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Sosyal tarafta ortamın merkezinde olabilirsin; davetlere evet demek güzel bağlantılar getirir.',
          'Sosyal tarafta bir etkinlik ya da buluşma beklediğinden daha keyifli geçebilir.',
          'Sosyal tarafta enerjin bulaşıcı; insanları bir araya getirmek için harika bir an.',
          'Sosyal tarafta yeni bir tanışma ileride işine yarayacak bir bağlantıya dönüşebilir.',
        ],
      },
      'genel': <KategoriTonu, List<String>>{
        KategoriTonu.dusuk: <String>[
          'Sosyal tarafta gerginliklere açık bir hava var; tartışmaya girmemek seni korur.',
          'Sosyal tarafta kalabalık ortamlarda çabuk yorulabilirsin; kısa tutmak sorun değil.',
          'Sosyal tarafta bir yanlış anlaşılma büyüyebilir; netleştirmek için sakin bir an bekle.',
          'Sosyal tarafta herkesi memnun etmeye çalışmak seni yorabilir; kendi sınırını koru.',
        ],
        KategoriTonu.orta: <String>[
          'Sosyal tarafta dengeli bir akış var; eski bir dosta haber vermek gününü ısıtabilir.',
          'Sosyal tarafta insanlarla sakin ve samimi bir iletişim kurabilirsin.',
          'Sosyal tarafta küçük bir nezaket büyük bir yakınlığa dönüşebilir.',
          'Sosyal tarafta yeni bir tanışma ya da eski bir bağ seni şaşırtabilir.',
        ],
        KategoriTonu.yuksek: <String>[
          'Sosyal tarafta insanlar sana karşı sıcak; yeni bağlantılar kurmak kolay.',
          'Sosyal tarafta bir buluşma ya da davet güzel bir fırsata dönüşebilir.',
          'Sosyal tarafta sözlerin ve enerjin insanları sana çekiyor.',
          'Sosyal tarafta birlikte geçirilen zaman sana yeni fikirler ve bağlar kazandırabilir.',
        ],
      },
    },
  };
}
