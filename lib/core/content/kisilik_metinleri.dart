/// Güneş burcu × kategori kişilik cümleleri ve cevaplarla çelişki süzgeci.
///
/// Okumada her kategori paragrafının ortasında, kişinin kendini tanıyacağı
/// kalıcı bir eğilim cümlesi yer alır. Gün gün dönüşümlü olarak ya Güneş
/// burcundan ([burc]) ya da yaşam yolu karakterinden
/// (`KarakterYonu.kategoriTarzi`) gelir; böylece hem burç hem numeroloji
/// okuyucuya "bu benim" dedirtir.
///
/// Yazım kuralları (bkz. `sayi_metinleri.dart`) ek olarak:
/// - Cümleler kalıcı eğilim anlatır, "bugün" içermez.
/// - İki yönlüdür: bir güç ve onun bedeli ("… ama …").
/// - Onboarding cevaplarını geri söylemez ([ContentConfig.yankiIfadeleri]).
/// - Kişinin cevabıyla çelişen cümleler [uyumlular] ile ayıklanır
///   ([ContentConfig.celiskiIfadeleri]).
library;

import '../luck_engine/luck_engine.dart';
import 'content_config.dart';
import 'okuyucu.dart';

/// Kişilik cümleleri ve çelişki süzgeci.
abstract final class KisilikMetinleri {
  /// Güneş burcu × kategori → kalıcı eğilim cümleleri. Yer tutucu:
  /// `{burc}`.
  static const Map<Burc, Map<LuckCategory, List<String>>>
  burc = <Burc, Map<LuckCategory, List<String>>>{
    Burc.koc: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta ilk adımı atmaktan çekinmezsin; ilişkinin de seninle aynı hızda akmasını istersin.',
        'Sevdiğinde bunu tutkuyla gösterirsin; sabırsızlığın ise bazen karşındakine nefes alacak zaman bırakmaz.',
        'Kalbin bir kez ısındığında tereddüt etmezsin; seni en çok, enerjine ayak uyduran biri heyecanlandırır.',
      ],
      LuckCategory.para: <String>[
        'Parada hızlı karar verirsin; fırsatı herkesten önce görür, hesabı bazen sonraya bırakırsın.',
        '{burc} burcu olarak kendi işini kendin yönetmek istersin; kazancın da en çok inisiyatif aldığında büyür.',
        'Kazanmak için yarışmak seni motive eder; harcamadan önce bir nefes almak ise kazancını korur.',
      ],
      LuckCategory.saglik: <String>[
        'Enerjin bir anda yükselir, bir anda düşer; yoğun ama kısa hareketler seni en çok toparlar.',
        '{burc} burcu olarak kendini zorlamayı seversin; ısınmadan başlamak ve molayı atlamak en zayıf noktan.',
        'Hareket etmediğin günlerde sinirlerin gerilir; kısa bir koşu ya da tempolu bir yürüyüş seni hemen toparlar.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak cesaret senin doğanda var; asıl sınavın sabırla bekleyebilmek.',
        'Belirsizlik seni durdurmaz, harekete geçirir; ikinci bir bakış ise çoğu zaman seni gereksiz bir sürprizden korur.',
        'İlk adımı atmak sana kolay gelir; asıl ustalık, başladığın şeyi bitirmekte.',
      ],
      LuckCategory.sosyal: <String>[
        'Ortamda sözünü sakınmazsın; dürüstlüğün insanları sana çeker, sertliğin ise ara sıra uzaklaştırır.',
        '{burc} burcu olarak bir planı başlatan çoğu zaman sensin; sıkıldığın ortamdan ise çabuk uzaklaşırsın.',
        'Dostlarını savunmaktan çekinmezsin; sadakatin bazen sözlerinden de hızlı davranır.',
      ],
    },
    Burc.boga: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta yavaş ama emin adımlarla ilerlersin; güven bir kez oluştuğunda çok sadıksın.',
        'Sevgini dokunarak, ilgiyle ve küçük konforlarla gösterirsin; değişkenlik ise seni yorar.',
        'Güven duyduğun kişiye sıcaklığını cömertçe açarsın; tutarsız davranışlar ise seni hemen uzaklaştırır.',
      ],
      LuckCategory.para: <String>[
        'Parayla ilişkin sağlam; biriktirmek sana güven verir, kaliteli bir şeye harcamak da keyif.',
        '{burc} burcu olarak sabırla kazanmayı bilirsin; ani değişiklikler maddi dengeni sandığından çok etkiler.',
        'Kaliteli ve kalıcı olana para vermeyi seversin; ucuz ama dayanıksız şeyler seni rahatsız eder.',
      ],
      LuckCategory.saglik: <String>[
        'Bedenin rutini sever; düzenli uyku ve sofra senin en büyük dayanağın.',
        '{burc} burcu olarak keyfine düşkünsün; hareketi zevkli bir şeye dönüştürdüğünde devam etmen kolaylaşır.',
        'İyi bir uyku ve sakin bir sofra seni her şeyden çabuk toparlar; aceleye gelen günler bedenini yorar.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak bildiğin yoldan şaşmazsın; bu seni korur ama bazen güzel bir değişikliği de ertelersin.',
        'Bir karar verdiğinde arkasında durursun; inadın en büyük gücün, bazen de en büyük engelin.',
        'Değişimi sevmezsin ama bir kez ikna olduğunda sonuna kadar gidersin.',
      ],
      LuckCategory.sosyal: <String>[
        'Çevrende sakin ve güvenilir bir liman olarak bilinirsin; insanlar yanında rahatlar.',
        '{burc} burcu olarak keyifli bir sofrada uzayan sohbetleri, aceleye getirilmiş buluşmalardan çok seversin.',
        'Sözünün eri olarak bilinirsin; bir buluşmaya söz verdiysen orada olursun.',
      ],
    },
    Burc.ikizler: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta önce zihnin etkilenir; seni güldüren ve konuşmaya doyamadığın biri kalbini kolay kazanır.',
        'Sıkıldığında bunu saklayamazsın; ilişkide merak ve yenilik seni canlı tutar.',
        'Mesajlaşmak, uzun sohbetler ve ortak espriler senin için sevginin ta kendisi.',
      ],
      LuckCategory.para: <String>[
        'Aynı anda birden fazla gelir fikri aklına gelir; birine odaklandığında sonuç çok daha hızlı gelir.',
        '{burc} burcu olarak iletişim ve ikna gerektiren işlerde kazancın kendiliğinden artar.',
        'Fırsatları hızlı fark edersin; aynı anda çok işe girişmek ise kazancını dağıtabilir.',
      ],
      LuckCategory.saglik: <String>[
        'Zihnin hiç durmaz; bedeninin yorgunluğunu çoğu zaman en son sen fark edersin.',
        '{burc} burcu olarak çeşitlilik seni hareketli tutar; aynı egzersizi tekrarlamak seni çabuk sıkar.',
        'Sinirlerin yorulduğunda uykun hafifler; akşamları zihnini sakinleştiren bir alışkanlık uykunu derinleştirir.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak yeni fikirlere çabuk heveslenirsin; heyecan geçtikten sonra da istiyorsan doğru yoldasın.',
        'Seçeneklerin çokluğu seni kararsız bırakabilir; ikisini yan yana yazmak netlik getirir.',
        'Farklı seçenekleri denemek seni heyecanlandırır; bir kararı sonuna kadar götürmek ise en büyük sınavın.',
      ],
      LuckCategory.sosyal: <String>[
        'Sohbet senin doğal alanın; kalabalıkta da birebirde de doğru cümleyi bulursun.',
        '{burc} burcu olarak merakın seni insanlara yaklaştırır; yüzeysel sohbetlerden ise çabuk sıkılırsın.',
        'Her ortama uyum sağlarsın; ama gerçekten açıldığın insanları sen seçersin.',
      ],
    },
    Burc.yengec: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta koruyucu ve şefkatlisin; güvende hissettiğinde kalbini tamamen açarsın.',
        'Kırıldığında kabuğuna çekilebilirsin; oysa hissettiğini söylediğin an bağın derinleşir.',
        'Sevdiklerini korumak senin aşk dilin; aynı şefkati gördüğünde çiçek gibi açılırsın.',
      ],
      LuckCategory.para: <String>[
        'Parayı bir güvence olarak görürsün; sevdiklerin ve yuvan için harcamak içini ısıtır.',
        '{burc} burcu olarak belirsiz bir teklifte içindeki ses genellikle haklı çıkar.',
        'Birikim yapmak içini rahatlatır; duygusal anlarda yapılan harcamalar ise bütçeni zorlayabilir.',
      ],
      LuckCategory.saglik: <String>[
        'Duyguların bedenine hızla yansır; huzurlu bir ortam seni her şeyden hızlı toparlar.',
        '{burc} burcu olarak başkalarına bakarken kendi bakımını ertelemeye yatkınsın.',
        'Mideni ve uykunu etkileyen şey çoğu zaman yemek değil, kafandaki düşüncelerdir.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak sevdiklerini etkileyecek kararlarda çok temkinlisin; kendi isteklerinde daha cesur olabilirsin.',
        'Güvende hissetmeden adım atmazsın; bu temkin seni çoğu zaman doğru yere götürür.',
        'Geçmiş deneyimlerin kararlarında rehberindir; aynı hatayı iki kez yapmamak için dikkatlisin.',
      ],
      LuckCategory.sosyal: <String>[
        'Çevren az ama derindir; sevdiklerin için her zaman oradasın.',
        '{burc} burcu olarak insanların ruh halini hemen fark edersin; bu seni sıcak bir dost yapar.',
        'Evine insan davet etmek, sofra kurmak seni mutlu eder; ait hissettiğin yerde parlarsın.',
      ],
    },
    Burc.aslan: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta cömert ve tutkulusun; takdir görmek senin için sevginin en net işareti.',
        'Sevdiğini gururla sahiplenirsin; ilgisizlik ise seni en çok kıran şeydir.',
        'Romantik jestleri seversin; sevildiğini hissettiğinde dünyanın en sadık insanı olursun.',
      ],
      LuckCategory.para: <String>[
        'Parayı kazanmakta da harcamakta da cömertsin; kendine ve sevdiklerine güzel şeyler almak seni mutlu eder.',
        '{burc} burcu olarak görünür olduğun işlerde kazancın da artar; emeğinin takdir edilmesi seni motive eder.',
        'Kendine değer verdiğin kadar emeğine de değer biçersin; düşük teklifler seni kırar.',
      ],
      LuckCategory.saglik: <String>[
        'Enerjin güçlüdür ama moralin düştüğünde bedenin de hemen yavaşlar.',
        '{burc} burcu olarak seni heyecanlandıran bir hareket bulduğunda bırakmazsın: dans, takım sporu, sahne.',
        'Güneş, hareket ve iyi bir moral senin en büyük enerji kaynağın.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak büyük oynamayı seversin; gururun ise bazen geri adım atmanı zorlaştırır.',
        'Kendine güvenin kararlarına cesaret verir; bir dostun dürüst fikri bu cesareti daha da sağlam kılar.',
        'Cesaretin insanlara ilham verir; bir planı yüksek sesle paylaşmak onu daha da güçlendirir.',
      ],
      LuckCategory.sosyal: <String>[
        'Sessiz kaldığında bile varlığın hissedilir; sıcaklığın insanları etrafında toplar.',
        '{burc} burcu olarak arkadaşlarına sadık ve cömertsin; aynı özeni görmediğinde kırılırsın.',
        'Arkadaşlarının başarısını kendi başarın gibi kutlarsın; cömertliğin unutulmaz.',
      ],
    },
    Burc.basak: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak sevgini ayrıntılarla gösterirsin; karşındakinin ihtiyacını o söylemeden fark edersin.',
        'Aşkta seçicisin; mükemmeli beklemek bazen güzel bir başlangıcı geciktirebilir.',
        'Aşkta küçük ayrıntılar senin için büyük anlam taşır; hatırlanan bir alışkanlık kalbini fethedebilir.',
      ],
      LuckCategory.para: <String>[
        'Parayla ilişkin düzenli ve dikkatli; bütçeni bilmek seni rahatlatır.',
        '{burc} burcu olarak emeğin titizliğiyle değer kazanır; karşılığını istemekte ise bazen geç kalırsın.',
        'Gereksiz bir harcamayı hemen fark edersin; kendine iyi bir şey almayı ise bazen fazla ertelersin.',
      ],
      LuckCategory.saglik: <String>[
        '{burc} burcu olarak bedenine dikkat edersin; ama endişe de bedeninde gerginlik olarak birikebilir.',
        'Düzenli bir rutin seni ayakta tutar; işe dalıp molaları unutmaya yatkınsın.',
        'Bedeninin verdiği sinyalleri iyi okursun; kaygı ise bu sinyalleri olduğundan büyük gösterebilir.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak her ayrıntıyı incelemeden karar vermezsin; bu seni korur ama bazen fırsatı geciktirir.',
        'Küçük ve kontrollü denemeler sana büyük hamlelerden daha çok güven verir.',
        'Bir planın zayıf noktasını herkesten önce görürsün; bu yeteneğin seni pahalı hatalardan korur.',
      ],
      LuckCategory.sosyal: <String>[
        'Az konuşur, çok gözlemlersin; yardımın ise çevrende hep hatırlanır.',
        '{burc} burcu olarak arkadaşlarının işine koşan sensin; bazen sen de destek istemeyi unutma.',
        'Yardım isteyen herkese koşarsın; kendine zaman kalmadığında ise sessizce yorulursun.',
      ],
    },
    Burc.terazi: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta uyum ve incelik ararsın; kaba bir söz sende uzun süre iz bırakır.',
        'İlişkide dengeyi korumak için kendi isteğini geri plana atabilirsin; oysa ne istediğini söylemek bağını güçlendirir.',
        'Güzel bir akşam, özenli bir söz ve karşılıklı saygı senin için romantizmin temeli.',
      ],
      LuckCategory.para: <String>[
        'Güzel şeylere harcamayı seversin; estetik ve kalite senin için lüks değil, ihtiyaç.',
        '{burc} burcu olarak ortaklıklarda ve iş birliklerinde kazancın, tek başına yaptıklarından çoğu zaman yüksektir.',
        'Ortak kararlarla para harcamak sana daha kolay gelir; tek başına karar vermek ise bazen zorlar.',
      ],
      LuckCategory.saglik: <String>[
        'Dengen bozulduğunda bunu önce uykunda ve ruh halinde hissedersin.',
        '{burc} burcu olarak güzel bir ortamda hareket etmek seni motive eder: bir park, bir sahil, bir dans dersi.',
        'Dengesiz bir program bedenini hemen etkiler; düzenli öğünler ve hafif hareket seni ayarlar.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak karar vermeden önce her tarafı tartarsın; kararsızlık ise bazen fırsatı geçirir.',
        'Herkesi memnun edecek seçeneği ararsın; bazen yalnızca seni memnun edecek olanı seçmek de doğrudur.',
        'Adil olanı seçmek senin için kazançtan önemli; bu seni çoğu zaman doğru kararlara götürür.',
      ],
      LuckCategory.sosyal: <String>[
        'İnsanlar arasında köprü kurarsın; ortamdaki gerginliği yumuşatan çoğu zaman sensin.',
        '{burc} burcu olarak nezaketin insanları rahatlatır; hayır demek ise sana zor gelir.',
        'Herkesle iyi geçinmeyi bilirsin; çatışmadan kaçmak ise bazen söylemen gerekeni geciktirir.',
      ],
    },
    Burc.akrep: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta ya hep ya hiç dersin; yüzeysel bağlar seni hiç tatmin etmez.',
        'Güvenmen zaman alır; güvendiğin kişiye ise derin ve tutkulu bir sadakatle bağlanırsın.',
        'Sevdiğin kişiyi derinden tanımak istersin; sırlar ve yarım cevaplar güvenini sarsar.',
      ],
      LuckCategory.para: <String>[
        'Maddi konularda stratejiksin; planını kimseye anlatmadan sessizce büyütürsün.',
        '{burc} burcu olarak kontrolü elinde tutmak istersin; ortak paralarda netlik seni rahatlatır.',
        'Ortak bir parada ya da anlaşmada ayrıntıları bilmek istersin; belirsizlik seni rahatsız eder.',
      ],
      LuckCategory.saglik: <String>[
        'Duygularını içine atma eğilimin bedeninde gerginlik olarak birikebilir.',
        '{burc} burcu olarak yoğun bir hareket, stresini boşaltmanın en iyi yolu olabilir.',
        'Yoğun duygular bedenini yorar; derin bir nefes ve kısa bir yalnızlık seni hızla toplar.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak bir şeyin yolunda gitmediğini çoğu zaman herkesten önce sezersin.',
        'Bir karar verdiğinde sonuna kadar gidersin; geri adım atmak sana zor gelir.',
        'Kararlarında kimsenin göremediği bir ayrıntıyı yakalarsın; bu seni stratejik kılar.',
      ],
      LuckCategory.sosyal: <String>[
        'Az ama çok derin ilişkiler kurarsın; seni gerçekten tanıyanlar sana sonuna kadar güvenir.',
        '{burc} burcu olarak insanların niyetini çabuk okursun; bu seni hem güçlü hem temkinli kılar.',
        'Güvendiğin insanlara karşı son derece sadıksın; ihanete ise kolay kolay göz yummazsın.',
      ],
    },
    Burc.yay: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta özgürlüğüne düşkünsün; seninle birlikte keşfe çıkan biri kalbini kazanır.',
        'Dürüstlüğün ilişkinin temelidir; bazen fazla açık sözlülüğün yanlış anlaşılabilir.',
        'Seni güldüren ve ufkunu genişleten biri kalbine en hızlı yoldan ulaşır.',
      ],
      LuckCategory.para: <String>[
        'Para senin için deneyim demek; yolculuğa ve öğrenmeye harcamak seni mutlu eder.',
        '{burc} burcu olarak iyimserliğin maddi fırsatları görmeni sağlar; ayrıntıları ise bazen gözden kaçırırsın.',
        'Kazancını yeni deneyimlere dönüştürmeyi seversin; birikim yapmak ise bilinçli bir karar gerektirir.',
      ],
      LuckCategory.saglik: <String>[
        'Açık havada geçen bir saat seni kapalı bir yerde geçen bütün bir günden daha çok toparlar.',
        '{burc} burcu olarak hareketsiz kalmak sana iyi gelmez; aşırılığa kaçmak ise en zayıf noktan.',
        'Hareketsiz geçen bir gün ruh halini de düşürür; spor senin için bir özgürlük alanı.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak şansın genellikle yanında olduğuna inanırsın; bu iyimserlik kapı açar, sınır koymak ise korur.',
        'Yeni bir yol seni her zaman çeker; nereye vardığını görmek için arada durmak da gerekir.',
        'Bir fırsatın potansiyelini hemen görürsün; ayrıntıları bir dostunla birlikte kontrol etmek seni korur.',
      ],
      LuckCategory.sosyal: <String>[
        'Farklı fikirlerden insanlarla karşılaşmak seni canlandırır; sıkıcı ortamlardan ise çabuk uzaklaşırsın.',
        '{burc} burcu olarak neşen ve açık sözlülüğün insanları sana çeker.',
        'Sohbetlerinde dürüstlüğün ve espri anlayışın öne çıkar; insanlar yanında kendini özgür hisseder.',
      ],
    },
    Burc.oglak: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta ciddisin; sevgini sözden çok sorumluluk alarak gösterirsin.',
        'Duygularını açmakta temkinlisin; güvendiğinde ise uzun soluklu ve sağlam bir bağ kurarsın.',
        'Sevgini sözden çok emekle gösterirsin; birlikte bir gelecek kurmak seni derinden mutlu eder.',
      ],
      LuckCategory.para: <String>[
        'Uzun vadeli hedeflerin için kısa vadeli keyiflerden vazgeçebilirsin; sabrın en büyük sermayen.',
        '{burc} burcu olarak emeğinin karşılığını geç ama sağlam alırsın.',
        'Maddi güvence senin için önceliktir; kendine küçük ödüller vermeyi ise çoğu zaman unutursun.',
      ],
      LuckCategory.saglik: <String>[
        'Çok çalışmaya ve yorgunluğu görmezden gelmeye yatkınsın; dinlenmeyi de hedeflerinin parçası say.',
        '{burc} burcu olarak gerginliği omuzlarında ve sırtında taşırsın; düzenli esneme seni rahatlatır.',
        'Sorumluluk yükünü bedeninde taşırsın; molaları programına yazmak seni korur.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak riski ancak hesapladıktan sonra alırsın; hazırlıksız yakalanmaktan hoşlanmazsın.',
        'Bir adımı aşamalara bölmek seni hem cesur hem güvende tutar.',
        'Kararlarında sabırlı ve kararlısın; uzun vadeli bir hedef için kısa vadeli zahmeti göze alırsın.',
      ],
      LuckCategory.sosyal: <String>[
        'Çevreni özenle seçersin; güvendiğin insanlarla uzun yıllar yürürsün.',
        '{burc} burcu olarak ilk izlenimde mesafeli görünebilirsin; seni tanıyanlar ise sıcaklığını bilir.',
        'Arkadaşlıklarında güvenilir bir dayanaksın; insanlar zor anlarında sana başvurur.',
      ],
    },
    Burc.kova: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta önce arkadaşlık ararsın; özgürlüğüne saygı duyan biriyle bağın güçlenir.',
        'Duygularını mantığınla süzmeye yatkınsın; içten bir an seni beklediğinden çok yakınlaştırır.',
        'Aşkta kalıplara sığmazsın; seni olduğun gibi kabul eden biriyle bağın derinleşir.',
      ],
      LuckCategory.para: <String>[
        'Para kazanmak için alışılmadık yollar bulmakta ustasın; yenilikçi fikirlerin maddi karşılığı da olabilir.',
        '{burc} burcu olarak maddi bağımsızlık senin için özgürlük demek.',
        'Maddi kararlarında kendi mantığını izlersin; kalabalığın peşinden gitmek sana göre değil.',
      ],
      LuckCategory.saglik: <String>[
        'Rutin seni sıkar; yeni bir hareket türü denemek motivasyonunu tazeler.',
        '{burc} burcu olarak zihnin bedeninden hızlı çalışır; ekran ve uyku dengesi senin için önemli.',
        'Yeni bir egzersiz ya da sağlık fikri seni hemen meraklandırır; süreklilik ise asıl sınavın.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak başkalarının denemediği yolu denemekten çekinmezsin.',
        'Kararlarını kendi değerlendirmen belirler; kalabalığın coşkusu seni pek etkilemez.',
        'Deneysel fikirlere açıksın; küçük bir deneme seni büyük bir hayal kırıklığından korur.',
      ],
      LuckCategory.sosyal: <String>[
        'Geniş bir arkadaş çevren olabilir; yine de en yakınına bile kendine ait bir alan bırakırsın.',
        '{burc} burcu olarak bir topluluk ya da ortak bir amaç için bir araya gelmek seni canlandırır.',
        'İnsanları ortak bir fikir etrafında buluşturmayı seversin; bağımsızlığını ise her zaman korursun.',
      ],
    },
    Burc.balik: <LuckCategory, List<String>>{
      LuckCategory.ask: <String>[
        '{burc} burcu olarak aşkta romantik ve şefkatlisin; sevdiğin kişiyi olduğundan büyük görebilirsin.',
        'Sevdiğinin söylemediklerini hissedersin; bu hassasiyet hem güçlü yanın hem yükün.',
        'Aşkı bir masal gibi yaşamak istersin; gerçekçi bir bakış bu masalı daha da güzelleştirir.',
      ],
      LuckCategory.para: <String>[
        'Parada sezgilerin güçlüdür; sınırlarını netleştirdiğinde cömertliğin bütçeni zorlamaz.',
        '{burc} burcu olarak yaratıcı ve anlam taşıyan işlerde emeğin daha çok karşılık bulur.',
        'Para konusunda cömert ve esneksin; net bir bütçe bu cömertliği sürdürülebilir kılar.',
      ],
      LuckCategory.saglik: <String>[
        'Başkalarının duygularını üstlendiğinde yorgunluğu bedeninde hissedersin.',
        '{burc} burcu olarak su, müzik ve sessizlik seni en hızlı toparlayan şeyler.',
        'Yoğun duygusal günlerden sonra bedenin dinlenmeye ihtiyaç duyar; su ve uyku seni en hızlı toparlar.',
      ],
      LuckCategory.risk: <String>[
        '{burc} burcu olarak kalbinin sesiyle karar verirsin; önemli anlaşmalarda ayrıntıları yazıya dökmek seni korur.',
        'İnsanlara güvenmeye yatkınsın; bir teklifin arkasına bir kez daha bakmak seni korur.',
        'Hayal gücün sana başkalarının göremediği fırsatları gösterir; onları adım adım sınamak seni korur.',
      ],
      LuckCategory.sosyal: <String>[
        'İnsanlar yanında anlaşıldığını hisseder; sınır koymak ise enerjini korur.',
        '{burc} burcu olarak kalabalıkta kolay yorulabilirsin; sana iyi gelen birkaç kişiyle vakit geçirmek seni yeniler.',
        'Herkesin derdini dinlersin; kendi duygularını paylaşacak birkaç güvenli insana ihtiyacın var.',
      ],
    },
  };

  /// Okuyucunun cevaplarından çelişki anahtarları: enerji ve karar tarzı
  /// adı, ilişki durumu için `bekar` / `partnerli`.
  static Set<String> celiskiAnahtarlari(OkuyucuTercihleri t) => <String>{
    ?t.enerji?.name,
    ?t.karar?.name,
    if (t.iliski case final IliskiDurumu d)
      d.partnerliMi ? 'partnerli' : 'bekar',
  };

  /// [metin] okuyucunun cevaplarından biriyle çelişiyor mu?
  static bool celisir(String metin, OkuyucuTercihleri t) {
    final String kucuk = metin.toLowerCase();
    for (final String anahtar in celiskiAnahtarlari(t)) {
      for (final String ifade
          in ContentConfig.celiskiIfadeleri[anahtar] ?? const <String>[]) {
        if (kucuk.contains(ifade)) {
          return true;
        }
      }
    }
    return false;
  }

  /// [havuz]dan okuyucunun cevaplarıyla çelişmeyen cümleler.
  ///
  /// Hepsi çelişirse havuz olduğu gibi döner (okuma boş kalmasın); havuz
  /// bütünlük testleri bunun hiçbir kombinasyonda olmadığını doğrular.
  static List<String> uyumlular(List<String> havuz, OkuyucuTercihleri t) {
    final List<String> kalan = <String>[
      for (final String m in havuz)
        if (!celisir(m, t)) m,
    ];
    return kalan.isEmpty ? havuz : kalan;
  }

  /// Profil metinlerinde (yaşam yolu özü, güçlü yanlar, gölge yan, aşkta,
  /// iş ve para) okuyucunun cevabıyla çelişen cümlelerin uyarlamaları:
  /// orijinal cümle → çelişki anahtarı (bkz. [celiskiAnahtarlari]) → yerine
  /// geçen cümle.
  ///
  /// Uyarlama cümlenin anlamını korur, yalnızca kişinin kendini tanımladığı
  /// yöne çevirir: "asıl yenilenmen yalnız kaldığında olur" cümlesi
  /// insanlarla beslenen biri için "insanların arasında açılırsın; yine de
  /// zihnin derinlerde dolaşır" olur.
  static const Map<String, Map<String, String>>
  profilUyarlamalari = <String, Map<String, String>>{
    // Yaşam yolu 7 · öz
    'Kalabalıkta bulunabilirsin ama asıl yenilenmen yalnız kaldığında olur.':
        <String, String>{
          'disaDonuk':
              'İnsanların arasında açılır, sohbetle beslenirsin; yine de '
              'zihnin herkesin göremediği derinliklerde dolaşır.',
        },
    'Dışarıdan mesafeli görünebilirsin; güvendiğin birkaç kişi ise '
        'içindeki derin ve sıcak dünyayı bilir.': <String, String>{
      'disaDonuk':
          'Çevren seni sıcak ve meraklı biri olarak tanır; içindeki derin '
          'dünyayı ise yalnızca güvendiğin birkaç kişi bilir.',
    },
    // Yaşam yolu 7 · gölge yan
    'Yalnızlık isteğin, istemeden yalnızlaşmaya dönebilir.': <String, String>{
      'disaDonuk':
          'Herkesle konuşup kimseye tam açılmamak, kalabalığın içinde '
          'seni yalnız hissettirebilir.',
    },
    'Her şeyi anlamadan karar vermemek, bazen hiç karar vermemek '
        'anlamına gelir.': <String, String>{
      'kalp':
          'Kalbin bir şey söylerken aklının itirazlarını susturmaya '
          'çalışmak, seni bazen kararsız bırakır.',
    },
    // Yaşam yolu 11 · gölge yan
    'Uyaran fazlası seni hızla tüketir.': <String, String>{
      'disaDonuk':
          'İnsanlarla beslenirsin ama herkesin duygusunu üstlendiğinde '
          'hızla tükenirsin.',
    },
    // Yaşam yolu 3 · güçlü yanlar
    'İnsanlarla kolay bağ kurar, fikirleri çekici hale getirirsin.':
        <String, String>{
          'iceDonuk':
              'Kalabalığı sevmesen de güvendiğin insanlarla sıcak bağlar '
              'kurar, fikirleri çekici hale getirirsin.',
        },
    // Yaşam yolu 5 · güçlü yanlar
    'Meraklısın, çok yönlüsün, insanlarla kolay konuşursun.': <String, String>{
      'iceDonuk':
          'Meraklısın, çok yönlüsün; insanlara seçerek açılsan da '
          'açıldığında sohbetin akıcıdır.',
    },
  };

  /// [metin]in cümlelerinden okuyucunun cevabıyla çelişenleri
  /// [profilUyarlamalari]daki karşılığıyla değiştirir; diğer cümleler
  /// olduğu gibi kalır.
  static String profilMetniniUyarla(String metin, OkuyucuTercihleri t) {
    final Set<String> anahtarlar = celiskiAnahtarlari(t);
    if (anahtarlar.isEmpty) {
      return metin;
    }
    return metin
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((String cumle) {
          final Map<String, String>? uyarlama = profilUyarlamalari[cumle];
          if (uyarlama != null) {
            for (final String anahtar in anahtarlar) {
              final String? yeni = uyarlama[anahtar];
              if (yeni != null) {
                return yeni;
              }
            }
          }
          return cumle;
        })
        .join(' ');
  }
}
