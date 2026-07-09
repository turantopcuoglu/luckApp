import '../luck_engine/luck_category.dart';
import 'content_config.dart';
import 'sans_rengi.dart';

/// Günlük yorumun kombinatoryal metin havuzları.
///
/// Yorum üç bağımsız cümleden birleşir: açılış (genel skor bandı) +
/// orta (baskın kategori × ton) + kapanış (banttan bağımsız). Her
/// cümle kendi başına tamdır; cümleler arası zamir gönderimi YASAK ki
/// her kombinasyon doğal okunsun. Ton: falcı sesi — mistik ama sıcak,
/// ikinci tekil şahıs, somut imgeler; sayı/yüzde/mekanik ifade yok.
abstract final class FortunePools {
  /// Genel skor bandına göre açılış cümleleri.
  static const Map<SkorBandi, List<String>> acilisCumleleri =
      <SkorBandi, List<String>>{
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

  /// Baskın kategori ve tonuna göre orta cümleler.
  ///
  /// Günün en yüksek skorlu kategorisi hakkında konuşur; açılışla ve
  /// kapanışla dilbilgisel bağı yoktur.
  static const Map<LuckCategory, Map<KategoriTonu, List<String>>>
      ortaCumleleri = <LuckCategory, Map<KategoriTonu, List<String>>>{
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

  /// Banttan bağımsız kapanış cümleleri.
  static const List<String> kapanisCumleleri = <String>[
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

  /// Yorumdan bağımsız günün tavsiyeleri.
  static const List<String> gununTavsiyeleri = <String>[
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

  /// Günün şans renkleri (ad + tam opak ARGB).
  static const List<SansRengi> sansRenkleri = <SansRengi>[
    SansRengi(ad: 'Gece Mavisi', hexArgb: 0xFF1B2A4A),
    SansRengi(ad: 'Altın Sarısı', hexArgb: 0xFFF4C95D),
    SansRengi(ad: 'Nar Kırmızısı', hexArgb: 0xFFB23A48),
    SansRengi(ad: 'Zümrüt Yeşili', hexArgb: 0xFF2E8B57),
    SansRengi(ad: 'Lavanta Moru', hexArgb: 0xFF8B7EC8),
    SansRengi(ad: 'Gül Kurusu', hexArgb: 0xFFC08081),
    SansRengi(ad: 'Turkuaz', hexArgb: 0xFF30B8B2),
    SansRengi(ad: 'Kehribar', hexArgb: 0xFFDC9A3E),
    SansRengi(ad: 'Fildişi', hexArgb: 0xFFF5EFE0),
    SansRengi(ad: 'Bakır', hexArgb: 0xFFB0653A),
    SansRengi(ad: 'Orman Yeşili', hexArgb: 0xFF1F5C40),
    SansRengi(ad: 'Lila', hexArgb: 0xFFB79FD4),
    SansRengi(ad: 'Mercan', hexArgb: 0xFFE9705F),
    SansRengi(ad: 'Duman Grisi', hexArgb: 0xFF8C93A0),
    SansRengi(ad: 'Safir', hexArgb: 0xFF2456A6),
    SansRengi(ad: 'Ay Işığı', hexArgb: 0xFFE8E3D3),
  ];
}
