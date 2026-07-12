import '../localization/app_dil.dart';
import '../luck_engine/luck_category.dart';
import 'content_config.dart';
import 'sans_rengi.dart';

/// Günlük yorumun kombinatoryal metin havuzları (TR + EN).
///
/// Yorum üç bağımsız cümleden birleşir: açılış (genel skor bandı) +
/// orta (baskın kategori × ton) + kapanış (banttan bağımsız). Her
/// cümle kendi başına tamdır; cümleler arası zamir gönderimi YASAK ki
/// her kombinasyon doğal okunsun. Ton: falcı sesi — mistik ama sıcak,
/// ikinci tekil şahıs, somut imgeler; sayı/yüzde/mekanik ifade yok.
///
/// **Determinizm (kural 8):** TR ve EN havuzları BİREBİR aynı uzunlukta
/// ve aynı enum anahtarlarla tutulur; seçim indeksi tohumdan gelir
/// (dilden bağımsız), yalnız render edilen dize dile göre değişir.
abstract final class FortunePools {
  /// Genel skor bandına göre açılış cümleleri ([dil]'e göre).
  static Map<SkorBandi, List<String>> acilisCumleleri(AppDil dil) =>
      dil.sec(_acilisTr, _acilisEn);

  /// Baskın kategori ve tonuna göre orta cümleler ([dil]'e göre).
  static Map<LuckCategory, Map<KategoriTonu, List<String>>> ortaCumleleri(
    AppDil dil,
  ) => dil.sec(_ortaTr, _ortaEn);

  /// Banttan bağımsız kapanış cümleleri ([dil]'e göre).
  static List<String> kapanisCumleleri(AppDil dil) =>
      dil.sec(_kapanisTr, _kapanisEn);

  /// Yorumdan bağımsız günün tavsiyeleri ([dil]'e göre).
  static List<String> gununTavsiyeleri(AppDil dil) =>
      dil.sec(_tavsiyeTr, _tavsiyeEn);

  /// Günün şans renkleri (ad TR+EN + tam opak ARGB). Tek liste; ad
  /// görüntüde `SansRengi.ad(dil)` ile seçilir.
  static const List<SansRengi> sansRenkleri = <SansRengi>[
    SansRengi(adTr: 'Gece Mavisi', adEn: 'Midnight Blue', hexArgb: 0xFF1B2A4A),
    SansRengi(adTr: 'Altın Sarısı', adEn: 'Golden Yellow', hexArgb: 0xFFF4C95D),
    SansRengi(
      adTr: 'Nar Kırmızısı',
      adEn: 'Pomegranate Red',
      hexArgb: 0xFFB23A48,
    ),
    SansRengi(
      adTr: 'Zümrüt Yeşili',
      adEn: 'Emerald Green',
      hexArgb: 0xFF2E8B57,
    ),
    SansRengi(
      adTr: 'Lavanta Moru',
      adEn: 'Lavender Purple',
      hexArgb: 0xFF8B7EC8,
    ),
    SansRengi(adTr: 'Gül Kurusu', adEn: 'Dusty Rose', hexArgb: 0xFFC08081),
    SansRengi(adTr: 'Turkuaz', adEn: 'Turquoise', hexArgb: 0xFF30B8B2),
    SansRengi(adTr: 'Kehribar', adEn: 'Amber', hexArgb: 0xFFDC9A3E),
    SansRengi(adTr: 'Fildişi', adEn: 'Ivory', hexArgb: 0xFFF5EFE0),
    SansRengi(adTr: 'Bakır', adEn: 'Copper', hexArgb: 0xFFB0653A),
    SansRengi(adTr: 'Orman Yeşili', adEn: 'Forest Green', hexArgb: 0xFF1F5C40),
    SansRengi(adTr: 'Lila', adEn: 'Lilac', hexArgb: 0xFFB79FD4),
    SansRengi(adTr: 'Mercan', adEn: 'Coral', hexArgb: 0xFFE9705F),
    SansRengi(adTr: 'Duman Grisi', adEn: 'Smoke Grey', hexArgb: 0xFF8C93A0),
    SansRengi(adTr: 'Safir', adEn: 'Sapphire', hexArgb: 0xFF2456A6),
    SansRengi(adTr: 'Ay Işığı', adEn: 'Moonlight', hexArgb: 0xFFE8E3D3),
  ];

  // ---------------------------------------------------------------------------
  // TÜRKÇE havuzlar
  // ---------------------------------------------------------------------------

  static const Map<SkorBandi, List<String>>
  _acilisTr = <SkorBandi, List<String>>{
    SkorBandi.cokDusuk: <String>[
      'Bugün gökyüzü perdesini kapatmış; evren senden sessizlik istiyor.',
      'Yıldızlar bu gece başka bir kıyıya bakıyor; bugün kendi limanında kal.',
      'Kader bugün düğümlerini sıkı bağlamış; çözmeye çalışma, bekle.',
      'Rüzgâr bugün karşıdan esiyor; yelkenleri indirip demir atma günü.',
      'Bugün falın sisli bir sabaha benziyor; yol görünene kadar acele etme.',
      'Evren bugün kapıları aralamıyor; anahtarı zorlamak kilidi bozar.',
      'Ay bugün yüzünü senden çevirmiş; ışığın dönmesini beklemek en akıllıcası.',
      'Kader bugün elini geri çekmiş; sen de hamleni yarına ertele.',
      'Sabır bugün en sadık yoldaşın; acele eden yolda taşa takılır.',
    ],
    SkorBandi.dusuk: <String>[
      'Bugün temkinli bir gün; adımlarını küçük tut, yol seni yormasın.',
      'Fincanın dibinde ince bir gölge var; telaşsız yürüyen bugün tökezlemez.',
      'Bugün evren fısıltıyla konuşuyor; duymak için yavaşlaman gerek.',
      'Yıldız haritanda bugün dar bir geçit görünüyor; sabırla geçilir.',
      'Bugün şans uykuda; onu uyandırmaya değil, uyandığında hazır olmaya bak.',
      'Gökyüzü bugün gri bir tül germiş; parlak kararları yarına sakla.',
      'Bugün taşlar yerine tam oturmamış; sağlam bastığın yerden ayrılma.',
      'Temkin bugün kalkanın olsun; ölçülü adım seni yormaz.',
      'Küçük işaretler bugün fısıltıyla konuşuyor; kulak kabartan yolunu bulur.',
    ],
    SkorBandi.orta: <String>[
      'Dengeli bir gün seni bekliyor; akışına bırak, akış seni taşır.',
      'Bugün terazi tam ortada duruyor; hangi kefeye dokunursan o ağır basar.',
      'Falında sakin bir deniz görünüyor; kürek çekene yol, bekleyene huzur var.',
      'Bugün evren kartlarını göstermiyor ama masadan da kalkmıyor.',
      'Ne rüzgâr ne durgunluk; bugün rotayı senin ellerin çiziyor.',
      'Bugün kapılar ne kilitli ne ardına kadar açık; nazikçe it, açılır.',
      'Yıldızlar bugün seyirci; sahne senin, oyunu sen kurarsın.',
      'Terazi bugün senin avucunda; dokunduğun kefe ağır basar.',
      'Ne acele ne durgunluk; bugünün ritmini senin nefesin belirliyor.',
    ],
    SkorBandi.yuksek: <String>[
      'Rüzgâr arkandan esiyor; fırsatlara açık ol, yelkenler dolacak.',
      'Bugün falında altın bir çizgi parlıyor; yürüdüğün yol aydınlanıyor.',
      'Evren bugün senden yana kıpırdıyor; küçük işaretleri kaçırma.',
      'Bugün şans kapının önünde dolaşıyor; bir selam ver, içeri girer.',
      'Yıldızların dizilişi bugün güzel bir haberin habercisi.',
      'Bugün ellerin bereketli; dokunduğun iş şekil alır.',
      'Gökyüzü bugün cömert; isteklerini yüksek sesle söylemekten çekinme.',
      'Kapılar bugün yağlı menteşede; hafif bir dokunuş yeter, açılır.',
      'Talih bugün adımına eşlik ediyor; niyetini net tut, yolu şaşma.',
    ],
    SkorBandi.cokYuksek: <String>[
      'Yıldızlar bu gece senin adını fısıldamış; kapılar dokunmadan açılacak.',
      'Bugün kaderin sayfası altın mürekkeple yazılmış; cesur ol.',
      'Evren bugün bütün ışıklarını sana çevirmiş; sahnenin tadını çıkar.',
      'Böyle günler yılda birkaç kez gelir; bugün dilediğin kapıyı çal.',
      'Falında dolunay gibi parlak bir gün duruyor; büyük hayaline uzan.',
      'Bugün şans seninle aynı yöne yürüyor; adımlarını büyük at.',
      'Kader bugün cömertliğin şahı; avuçlarını açık tut.',
      'Bereket bugün kucağına akıyor; kollarını sonuna kadar aç.',
      'Yıldızların tamamı bugün senin lehine dizilmiş; büyük düşünmekten korkma.',
    ],
  };

  static const Map<LuckCategory, Map<KategoriTonu, List<String>>>
  _ortaTr = <LuckCategory, Map<KategoriTonu, List<String>>>{
    LuckCategory.ask: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Kalp işlerinde bugün sözcükleri tartarak seç; yanlış anlamalar pusuda.',
        'Aşk bugün nazlı bir misafir; kapıyı zorlamak yerine sofrayı hazırla.',
        'Gönül telleri bugün gergin; küçük bir sessizlik en güzel cevap olabilir.',
        'Bugün kalbini serin tut; duyguların dalgası akşama durulur.',
        'Aşkta bugün suskunluk altın; söylenmeyen söz seni koruyabilir.',
        'Gönlünü bugün sert rüzgâra açma; nazik davranan yıpranmadan geçer.',
      ],
      KategoriTonu.orta: <String>[
        'Aşk cephesinde su akışında bir gün; küçük bir jest büyük yankı bulur.',
        'Kalbin bugün dengede; içten bir bakış kapıyı aralamaya yeter.',
        'Bugün gönül bahçen bakım istiyor; bir tatlı söz toprağı canlandırır.',
        'Aşkta bugün orta şiddette bir meltem var; savrulmadan süzülebilirsin.',
        'Gönül bahçen bugün ılık; bir tatlı söz toprağı yeşertir.',
        'Bugün aşkta terazi ortada; içten bir bakış kefeyi senden yana eğer.',
      ],
      KategoriTonu.yuksek: <String>[
        'Kalbin bugün mıknatıs gibi; cesur bir adım güzel karşılık bulur.',
        'Aşk yıldızın bugün pırıl pırıl; saklanan duygular gün ışığına çıkmak istiyor.',
        'Bugün gönül kapıları ardına kadar açık; içeri güzellik girecek.',
        'Kalp işlerinde bugün şans senden yana; ilk adımı beklemek yazık olur.',
        'Aşk bugün kapını çalmaya hazır; perdeyi arala, ışık içeri dolsun.',
        'Kalbin bugün ışık saçıyor; sustuğun sözü söylemenin tam vakti.',
      ],
    },
    LuckCategory.para: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Kesenin ağzını bugün sıkı tut; parlak görünen teklif içini göstermez.',
        'Para bugün ürkek bir kuş; avucunu kapatma ama savurma da.',
        'Bugün bereket dinleniyor; harcamayı yarına ertelemek kazanç sayılır.',
        'Cüzdanın bugün sessizlik istiyor; büyük pazarlıkları başka güne bırak.',
        'Bereket bugün nazlanıyor; kesenin ağzını yarına düğümle.',
        'Parlak teklif bugün aldatıcı; ince yazıyı iki kez oku.',
      ],
      KategoriTonu.orta: <String>[
        'Para akışın bugün dengede; birikime atılan küçük taş yarın köprü olur.',
        'Kazanç bugün sabırlı olanın sofrasına oturuyor; acele pazarlık etme.',
        'Bugün bereket ölçülü akıyor; ölçülü isteyen payını alır.',
        'Maddi işlerde bugün terazi düz; hesabını bilen gülümser.',
        'Kazanç bugün usul usul akıyor; sabırlı kova taşmadan dolar.',
        'Bugün maddi pusula düz; ölçülü giden yolunu şaşırmaz.',
      ],
      KategoriTonu.yuksek: <String>[
        'Cebine doğru esen bir bereket rüzgârı var; gözünü açık tut.',
        'Bugün fırsat kokusu havada; kazanç kapısı hafif aralık duruyor.',
        'Para yıldızın bugün yükselişte; emeğin karşılığı yolda.',
        'Bugün bolluk senin sokağından geçiyor; pencereyi açık bırak.',
        'Bugün bereket rüzgârı yelkenini dolduruyor; rotayı fırsata çevir.',
        'Kazanç kapısı bugün aralık; nazikçe itersen ardına kadar açılır.',
      ],
    },
    LuckCategory.saglik: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Bedenin bugün alçak sesle sitem ediyor; tempoyu düşür, onu duy.',
        'Enerji kaynağın bugün kısık ateşte; kendini közlemeden ısın.',
        'Bugün bedenin mola istiyor; dinlenmek tembellik değil, tamir.',
        'Sağlık terazin bugün hassas; ağır yükleri başkasıyla paylaş.',
        'Bedenin bugün alçak sesle mola istiyor; onu duymazdan gelme.',
        'Enerjin bugün kısık ateşte; közü üfleme, dinlenmesine izin ver.',
      ],
      KategoriTonu.orta: <String>[
        'Enerjin bugün sakin bir nehir; hafif bir yürüyüş suyu coşturur.',
        'Beden ile zihin bugün el sıkışmış; bu barışı taze havayla besle.',
        'Bugün sağlığın dengede; erken uyku bu dengeyi mühürler.',
        'Enerji depon bugün yarım dolu; küçük molalar üstünü tamamlar.',
        'Bedenin bugün ölçülü bir tempoda; hafif bir esneme onu şenlendirir.',
        'Bugün beden ile zihin uyumda; taze hava bu uyumu perçinler.',
      ],
      KategoriTonu.yuksek: <String>[
        'Bugün bedenin hafif, adımların yaylı; formunun tadını çıkar.',
        'Enerjin bugün taşkın bir pınar; biriktirme, harekete dök.',
        'Sağlık yıldızın bugün parlak; ertelediğin o sporun tam günü.',
        'Bugün içinde taze bir güç dolaşıyor; zor işleri bugüne çek.',
        'Bugün gücün taşkın; onu güzel bir alışkanlığa yönlendir.',
        'Bedenin bugün kanatlı; ertelediğin hareketi bugüne al.',
      ],
    },
    LuckCategory.risk: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Bugün zar tutmanın günü değil; garantiye oynayan kazançlı çıkar.',
        'Şansını bugün sınama; köprüden geçerken korkuluğu bırakma.',
        'Bugün kumar taşları soğuk; elini masadan uzak tutmak erdem.',
        'Risk terazisi bugün ters tartıyor; emin olmadığın yola girme.',
        'Zar bugün senden yana dönmüyor; eli masaya sürme.',
        'Bugün emniyeti elden bırakma; garanti yol seni güldürür.',
      ],
      KategoriTonu.orta: <String>[
        'Bugün hesaplı cesaretin günü; ölçüp biçtiğin adım tutar.',
        'Risk bugün ne dost ne düşman; içgüdüne küçük bir pay bırak.',
        'Bugün orta boy cesaretler ödüllenir; dev adımları haftaya sakla.',
        'Zarlar bugün kararsız; küçük oyna, büyük öğren.',
        'Cesaretini bugün ölç tart; hesaplı hamle geri tepmez.',
        'Bugün orta boy adımlar güvende; dev sıçramayı ileriye yaz.',
      ],
      KategoriTonu.yuksek: <String>[
        'Cesaret bugün ödüllendiriliyor; ertelediğin o adımı at.',
        'Bugün şans cesurların masasında oturuyor; sandalyeni çek.',
        'Risk yıldızın bugün parlıyor; kalbinin evet dediğine kulak ver.',
        'Bugün atılan cesur tohum bereketli toprağa düşer.',
        'Bugün cesurun sofrası kurulu; sandalyeni çekmekten çekinme.',
        'Rüzgâr bugün tam arkanda; ertelediğin hamleyi şimdi yap.',
      ],
    },
    LuckCategory.sosyal: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Kalabalık bugün yorucu bir uğultu; küçük ve samimi olanda kal.',
        'Bugün sözler kolay eğilip bükülür; derin sohbetleri yarına sakla.',
        'Sosyal gökyüzün bugün bulutlu; yalnız geçen bir akşam iyi gelir.',
        'Bugün herkese yetişmeye çalışma; kendine ayırdığın saat kazançtır.',
        'Kalabalık bugün yorucu bir uğultu; sessiz köşen sana şifa olur.',
        'Sözler bugün kolay bükülüyor; ağzından çıkanı bir kez daha tart.',
      ],
      KategoriTonu.orta: <String>[
        'Sosyal enerjin bugün dengede; eski bir dosta ses vermek içini ısıtır.',
        'Bugün çevrende sakin bir hareketlilik var; seçtiğin sohbet keyif verir.',
        'İnsanlar bugün sana kulak veriyor; sözünü tane tane söyle.',
        'Bugün küçük bir buluşma beklenmedik bir güzellik doğurabilir.',
        'Çevrende bugün ılık bir hareket var; seçtiğin sohbet içini ısıtır.',
        'İnsanlar bugün sana kulak kabartıyor; sözünü sakin ve tane tane söyle.',
      ],
      KategoriTonu.yuksek: <String>[
        'Bugün ortamın yıldızı sensin; davetlere çekinmeden evet de.',
        'Sosyal gökyüzün bugün şenlikli; yeni bir yüz eski bir kapıyı açabilir.',
        'Bugün sözlerin tatlı, enerjin bulaşıcı; insanlar etrafında toplanacak.',
        'Kalabalık bugün sana güç veriyor; sahneden kaçma, ortasına yürü.',
        'Bugün ortamın merkezinde sen varsın; davetlere gülümseyerek koş.',
        'Sözlerin bugün bal; çevrende halka kendiliğinden genişleyecek.',
      ],
    },
  };

  static const List<String> _kapanisTr = <String>[
    'Akşam olduğunda bugüne küçük bir teşekkür borçlu olacaksın.',
    'Unutma, fal bir aynadır; içine bakan kendi ışığını görür.',
    'Gün batarken bugünün sana bıraktığı işareti not et.',
    'Kader fısıldar, bağırmaz; kulağını gönlüne yakın tut.',
    'Bugünün küçük tesadüfleri yarının büyük hikâyesini yazıyor.',
    'Ay bu gece senin penceren için de doğacak.',
    'Şans hazırlıklı olanı sever; sen payına düşeni yaptın say.',
    'Ne olursa olsun, bugün de senin hikâyene bir satır ekleyecek.',
    'Yolun sonunda değil, yolun kendisinde saklıdır bereket.',
    'Bugünü sabırla taşıyan, yarını hafiflemiş karşılar.',
    'Evren hesabını uzun tutar; bugün eksileni yarın fazlasıyla verir.',
    'İçindeki pusula bugün de doğruyu gösteriyor; ona güven.',
    'Gökyüzü her gece yıldız sayar; senin dileğin de listededir.',
    'Kapanan her kapının menteşesinde yeni bir kapının sesi vardır.',
  ];

  static const List<String> _tavsiyeTr = <String>[
    'Bugün ilk hissettiğine güven; ikinci tahmin şansı kaçırır.',
    'Cebinde taşıdığın küçük bir nesne bugün sana uğur getirecek.',
    'Bugün birine beklemediği bir iltifat et; yankısı sana döner.',
    'Gün içinde beş dakikalık bir sessizlik bugün zihnini toplar.',
    'Bugün eski bir fotoğrafa bak; hatırladığın şey yol gösterecek.',
    'Pencereni sabah ilk iş aç; taze hava bugünkü şansını içeri alır.',
    'Bugün su iç, çok iç; berrak zihin berrak talih çeker.',
    'Ertelediğin küçük işi bugün bitir; ferahlığı akşamı güzelleştirir.',
    'Bugün yeşil gördüğün yerde bir nefes dur; toprak enerji verir.',
    'Kalabalıkta ismini duyarsan bugün gülümse; iyi haber yakındır.',
    'Bugün defterine tek cümle yaz; yıl sonunda kehanet gibi okunur.',
    'Ayakkabılarını bugün özenle bağla; sağlam adım sağlam gün getirir.',
    'Bugün tanımadığın birine yol ver; açtığın yol sana geri açılır.',
    'Akşam gökyüzüne bir kez bak; ilk gördüğün yıldıza dileğini bırak.',
    'Bugün müzik aç ve bir şarkıyı sonuna kadar dinle; cevap sözlerde.',
    'Kırık ya da eskimiş bir şeyi bugün onar; talih tamir sever.',
    'Bugün cüzdanını düzenle; para düzen gördüğü yere yerleşir.',
    'Bir fincanı bugün yavaş iç; acele edilmeyen keyif bereket çağırır.',
    'Bugün az konuş, çok dinle; kulağına değecek bir cümle kıymetli.',
    'Yürüdüğün yolda bugün bir kez geri dön ve baktığın yere gülümse.',
    'Bugün masanın bir köşesini boşalt; boşluk yeni gelene yer açar.',
    'Sevdiğin bir kokuyu bugün üstüne sür; güzel koku güzel haber çeker.',
    'Bugün küçük bir söz ver ve tut; tutulan söz talihin tohumudur.',
    'Elini bugün toprağa ya da bir yaprağa değdir; köklenmek iyi gelir.',
    'Bugün erken yat; yarının şansı dinlenmiş gözlerle daha iyi görünür.',
    'Bir listeye bugün üç şükür maddesi yaz; şükür bolluğun anahtarıdır.',
  ];

  // ---------------------------------------------------------------------------
  // İNGİLİZCE havuzlar (TR ile birebir aynı uzunluk ve anahtarlar)
  // ---------------------------------------------------------------------------

  static const Map<SkorBandi, List<String>>
  _acilisEn = <SkorBandi, List<String>>{
    SkorBandi.cokDusuk: <String>[
      'The sky has drawn its curtain today; the universe asks you for silence.',
      'The stars gaze at another shore tonight; stay in your own harbor today.',
      'Fate has tied its knots tight today; do not force them open, wait.',
      'The wind blows against you today; a day to lower the sails and drop anchor.',
      'Your fortune is like a foggy morning today; do not rush until the road appears.',
      'The universe leaves no door ajar today; forcing the key only breaks the lock.',
      'The moon has turned its face from you today; waiting for its light is wisest.',
      'Fate has withdrawn its hand today; postpone your move to tomorrow as well.',
      'Patience is your most loyal companion today; the one who rushes trips on the road.',
    ],
    SkorBandi.dusuk: <String>[
      'Today is a cautious day; keep your steps small so the road will not tire you.',
      'A faint shadow rests at the bottom of your cup; the unhurried do not stumble today.',
      'The universe speaks in a whisper today; you must slow down to hear it.',
      'A narrow pass shows on your star chart today; it is crossed with patience.',
      'Luck is asleep today; aim not to wake it, but to be ready when it wakes.',
      'The sky has drawn a grey veil today; save your bright decisions for tomorrow.',
      'The stones have not fully settled today; do not leave the ground you stand firm on.',
      'Let caution be your shield today; a measured step will not wear you out.',
      'Small signs speak in whispers today; the one who listens closely finds the way.',
    ],
    SkorBandi.orta: <String>[
      'A balanced day awaits you; let go into the flow, and the flow will carry you.',
      'The scale stands right at the center today; whichever pan you touch tips it.',
      'A calm sea shows in your fortune; passage for the one who rows, peace for the one who waits.',
      'The universe does not show its cards today, but it does not leave the table either.',
      'Neither wind nor stillness; today your own hands chart the course.',
      'The doors are neither locked nor wide open today; push gently and they open.',
      'The stars are spectators today; the stage is yours, you set the play.',
      'The scale rests in your palm today; the pan you touch tips heavier.',
      'Neither haste nor stillness; your own breath sets today\'s rhythm.',
    ],
    SkorBandi.yuksek: <String>[
      'The wind blows at your back; stay open to chances and the sails will fill.',
      'A golden line shines in your fortune today; the road you walk is lighting up.',
      'The universe stirs in your favor today; do not miss the small signs.',
      'Luck lingers at your door today; give it a greeting and it steps inside.',
      'The alignment of the stars today heralds good news.',
      'Your hands are bountiful today; whatever you touch takes shape.',
      'The sky is generous today; do not hesitate to speak your wishes aloud.',
      'The doors are on oiled hinges today; a light touch is enough to open them.',
      'Fortune walks beside your step today; keep your intent clear and hold the way.',
    ],
    SkorBandi.cokYuksek: <String>[
      'The stars have whispered your name tonight; doors will open before you touch them.',
      'Today the page of your fate is written in golden ink; be bold.',
      'The universe has turned all its lights on you today; enjoy the stage.',
      'Days like this come only a few times a year; knock on any door you wish today.',
      'A day as bright as a full moon stands in your fortune; reach for your great dream.',
      'Luck walks the same direction as you today; take your steps wide.',
      'Fate is the king of generosity today; keep your palms open.',
      'Abundance flows into your lap today; open your arms all the way.',
      'Every star is aligned in your favor today; do not be afraid to think big.',
    ],
  };

  static const Map<LuckCategory, Map<KategoriTonu, List<String>>>
  _ortaEn = <LuckCategory, Map<KategoriTonu, List<String>>>{
    LuckCategory.ask: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'In matters of the heart, weigh your words today; misunderstandings lie in wait.',
        'Love is a coy guest today; instead of forcing the door, set the table.',
        'The heartstrings are taut today; a small silence may be the sweetest answer.',
        'Keep your heart cool today; the wave of your feelings will settle by evening.',
        'In love, silence is golden today; the word left unspoken may protect you.',
        'Do not open your heart to harsh winds today; the gentle one passes through unworn.',
      ],
      KategoriTonu.orta: <String>[
        'On the love front, a day that flows like water; a small gesture finds a great echo.',
        'Your heart is balanced today; a sincere glance is enough to open the door.',
        'Your heart\'s garden asks for care today; a sweet word revives the soil.',
        'In love there is a mild breeze today; you can glide without being swept away.',
        'Your heart\'s garden is warm today; a sweet word turns the soil green.',
        'In love the scale sits centered today; a sincere glance tips the pan your way.',
      ],
      KategoriTonu.yuksek: <String>[
        'Your heart is like a magnet today; a bold step finds a lovely response.',
        'Your love star is gleaming today; hidden feelings long to come into the light.',
        'The doors of the heart are wide open today; beauty will step inside.',
        'In matters of the heart, luck is on your side today; do not wait for the first step.',
        'Love is ready to knock on your door today; part the curtain and let the light in.',
        'Your heart radiates light today; it is the perfect time to say the unspoken word.',
      ],
    },
    LuckCategory.para: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Keep your purse tight today; the offer that looks shiny hides its inside.',
        'Money is a timid bird today; do not close your palm, but do not scatter it either.',
        'Abundance is resting today; postponing a purchase to tomorrow counts as gain.',
        'Your wallet asks for quiet today; leave big bargains for another day.',
        'Abundance is playing coy today; knot your purse shut until tomorrow.',
        'The shiny offer is deceptive today; read the fine print twice.',
      ],
      KategoriTonu.orta: <String>[
        'Your money flow is balanced today; a small stone toward savings becomes a bridge.',
        'Earnings sit at the table of the patient today; do not bargain in haste.',
        'Abundance flows in measure today; the one who asks in measure receives a share.',
        'In money matters the scale is level today; the one who knows their sums smiles.',
        'Earnings flow slowly today; the patient bucket fills without overflowing.',
        'The money compass points level today; the one who goes measured holds the way.',
      ],
      KategoriTonu.yuksek: <String>[
        'A wind of abundance blows toward your pocket; keep your eyes open.',
        'The scent of opportunity is in the air today; the door of earnings stands ajar.',
        'Your money star is rising today; the reward for your effort is on its way.',
        'Plenty is passing down your street today; leave the window open.',
        'The wind of abundance fills your sail today; turn your course toward opportunity.',
        'The door of earnings is ajar today; if you push gently it opens wide.',
      ],
    },
    LuckCategory.saglik: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Your body reproaches you in a low voice today; slow the pace and hear it.',
        'Your energy source is on a low flame today; warm up without scorching yourself.',
        'Your body asks for a break today; rest is not laziness but repair.',
        'Your health scale is delicate today; share the heavy loads with someone.',
        'Your body quietly asks for a pause today; do not pretend not to hear it.',
        'Your energy is on a low flame today; do not blow on the embers, let it rest.',
      ],
      KategoriTonu.orta: <String>[
        'Your energy is a calm river today; a light walk makes the water lively.',
        'Body and mind have shaken hands today; feed this peace with fresh air.',
        'Your health is balanced today; early sleep seals this balance.',
        'Your energy tank is half full today; small breaks top it up.',
        'Your body keeps a measured pace today; a light stretch cheers it up.',
        'Body and mind are in harmony today; fresh air rivets that harmony.',
      ],
      KategoriTonu.yuksek: <String>[
        'Your body is light today, your steps springy; enjoy your good form.',
        'Your energy is an overflowing spring today; do not hoard it, pour it into motion.',
        'Your health star is bright today; the very day for the exercise you postpone.',
        'A fresh strength moves within you today; pull the hard tasks into today.',
        'Your strength overflows today; steer it into a good habit.',
        'Your body is winged today; bring the movement you postponed into today.',
      ],
    },
    LuckCategory.risk: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Today is not a day to roll the dice; the one who plays it safe comes out ahead.',
        'Do not test your luck today; do not let go of the railing while crossing the bridge.',
        'The gambling stones are cold today; keeping your hand off the table is a virtue.',
        'The scale of risk weighs against you today; do not set out on a road you doubt.',
        'The dice do not turn your way today; do not push your hand onto the table.',
        'Do not let go of safety today; the sure road is the one that makes you smile.',
      ],
      KategoriTonu.orta: <String>[
        'Today is a day for calculated courage; the step you measure will hold.',
        'Risk is neither friend nor foe today; leave a small share to your instinct.',
        'Medium-sized courage is rewarded today; save the giant steps for next week.',
        'The dice are undecided today; play small, learn big.',
        'Weigh your courage today; a calculated move does not backfire.',
        'Medium steps are safe today; pencil the giant leap in for later.',
      ],
      KategoriTonu.yuksek: <String>[
        'Courage is rewarded today; take that step you keep postponing.',
        'Luck sits at the table of the brave today; pull up your chair.',
        'Your risk star shines today; listen to what your heart says yes to.',
        'The brave seed sown today falls on fertile soil.',
        'The table of the brave is set today; do not hesitate to pull up your chair.',
        'The wind is right at your back today; make the move you postponed now.',
      ],
    },
    LuckCategory.sosyal: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'The crowd is a tiring hum today; stay with the small and sincere.',
        'Words bend and twist easily today; save deep conversations for tomorrow.',
        'Your social sky is cloudy today; an evening spent alone will do you good.',
        'Do not try to keep up with everyone today; the hour kept for yourself is a gain.',
        'The crowd is a tiring hum today; your quiet corner will be your remedy.',
        'Words twist easily today; weigh once more what leaves your mouth.',
      ],
      KategoriTonu.orta: <String>[
        'Your social energy is balanced today; reaching out to an old friend warms you.',
        'There is a calm liveliness around you today; the conversation you choose brings joy.',
        'People are listening to you today; speak your words one by one.',
        'A small meeting today may give rise to an unexpected beauty.',
        'There is a warm stir around you today; the conversation you choose warms you.',
        'People are leaning in to listen today; speak calmly, one word at a time.',
      ],
      KategoriTonu.yuksek: <String>[
        'You are the star of the room today; say yes to invitations without hesitation.',
        'Your social sky is festive today; a new face may open an old door.',
        'Your words are sweet and your energy contagious today; people will gather around you.',
        'The crowd gives you strength today; do not flee the stage, walk to its center.',
        'You are at the center of the room today; run to invitations with a smile.',
        'Your words are honey today; the circle around you will widen on its own.',
      ],
    },
  };

  static const List<String> _kapanisEn = <String>[
    'When evening comes you will owe this day a small thank-you.',
    'Remember, a fortune is a mirror; whoever looks into it sees their own light.',
    'As the sun sets, note the sign this day has left you.',
    'Fate whispers, it does not shout; keep your ear close to your heart.',
    'Today\'s small coincidences are writing tomorrow\'s great story.',
    'The moon will rise for your window too tonight.',
    'Luck loves the prepared; consider your part already done.',
    'Whatever happens, today will add another line to your story.',
    'Abundance is hidden not at the road\'s end but in the road itself.',
    'Whoever carries today with patience meets tomorrow lighter.',
    'The universe keeps a long ledger; what is short today it repays tomorrow.',
    'The compass within you points true today too; trust it.',
    'The sky counts its stars each night; your wish is on the list too.',
    'In the hinge of every closing door is the sound of a new one.',
  ];

  static const List<String> _tavsiyeEn = <String>[
    'Trust your first feeling today; second-guessing lets the chance slip.',
    'A small object you carry in your pocket will bring you luck today.',
    'Give someone an unexpected compliment today; its echo will return to you.',
    'Five minutes of silence during the day will gather your mind today.',
    'Look at an old photograph today; what you remember will guide you.',
    'Open your window first thing in the morning; fresh air lets today\'s luck in.',
    'Drink water today, plenty of it; a clear mind draws clear fortune.',
    'Finish the small task you postponed today; the relief will brighten your evening.',
    'Pause for a breath wherever you see green today; the earth gives energy.',
    'If you hear your name in a crowd today, smile; good news is near.',
    'Write a single sentence in your notebook today; by year\'s end it reads like a prophecy.',
    'Tie your shoes with care today; a firm step brings a firm day.',
    'Give way to a stranger today; the path you open opens back to you.',
    'Look up at the evening sky once; leave your wish with the first star you see.',
    'Play some music today and hear one song to the end; the answer is in the lyrics.',
    'Mend something broken or worn today; fortune loves repair.',
    'Tidy your wallet today; money settles where it finds order.',
    'Drink one cup slowly today; a pleasure taken unhurried calls abundance.',
    'Speak little and listen much today; one sentence worth hearing is precious.',
    'On your path today, turn back once and smile at where you looked.',
    'Clear one corner of your desk today; empty space makes room for what is coming.',
    'Wear a scent you love today; a lovely scent draws lovely news.',
    'Make a small promise today and keep it; a kept promise is the seed of fortune.',
    'Touch soil or a leaf today; taking root does you good.',
    'Go to bed early today; tomorrow\'s luck looks better through rested eyes.',
    'Write three things you are grateful for today; gratitude is the key to plenty.',
  ];
}
