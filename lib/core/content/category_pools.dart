import '../localization/app_dil.dart';
import '../luck_engine/luck_category.dart';
import 'content_config.dart';

/// Kategori detay sayfasının metin havuzları (TR + EN).
///
/// Detay yorumu iki cümleden birleşir: açılış (kategori × ton) +
/// tavsiye (kategori). Cümleler kendi başına tamdır; aralarında zamir
/// gönderimi yoktur. Ton kuralları için bkz. `fortune_pools.dart`.
///
/// **Determinizm (kural 8):** TR ve EN havuzları birebir aynı uzunlukta
/// ve aynı enum anahtarlarla tutulur.
abstract final class CategoryPools {
  /// (kategori, ton) başına açılış cümleleri ([dil]'e göre).
  static Map<LuckCategory, Map<KategoriTonu, List<String>>> kategoriAcilislari(
    AppDil dil,
  ) => dil.sec(_acilisTr, _acilisEn);

  /// Kategori başına tavsiye cümleleri ([dil]'e göre).
  static Map<LuckCategory, List<String>> kategoriTavsiyeleri(AppDil dil) =>
      dil.sec(_tavsiyeTr, _tavsiyeEn);

  // ---------------------------------------------------------------------------
  // TÜRKÇE
  // ---------------------------------------------------------------------------

  static const Map<LuckCategory, Map<KategoriTonu, List<String>>>
  _acilisTr = <LuckCategory, Map<KategoriTonu, List<String>>>{
    LuckCategory.ask: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Kalp işlerinde bugün acele etme; yanlış anlaşılmalara açık bir gün.',
        'Aşk gökyüzün bugün puslu; net cevapları sisin dağılacağı güne bırak.',
        'Bugün duygular kırılgan cam gibi; taşırken iki elinle tut.',
        'Gönül bahçende bugün rüzgâr sert; fidelerini sabırla koru.',
        'Bugün kalbine değil takvime bak; bazı sohbetlerin vakti gelmemiş.',
        'Aşkta bugün acele düğüm attırır; ipin ucunu yavaş bırak.',
      ],
      KategoriTonu.orta: <String>[
        'Aşk cephesinde dengeli bir gün; küçük jestler büyük kapılar açar.',
        'Kalbin bugün sakin sularda; nazik bir dokunuş dalgayı güzelleştirir.',
        'Bugün aşkta ne fırtına ne durgunluk; içten bir söz yeterli rüzgâr.',
        'Gönül işlerinde bugün orta şeker bir gün; tatlandırmak senin elinde.',
        'Bugün duygular dengede; kalbini açan kapıyı da açık bulur.',
        'Kalbin bugün dingin; nazik bir yaklaşım kapıyı usulca aralar.',
      ],
      KategoriTonu.yuksek: <String>[
        'Kalbin bugün mıknatıs gibi; cesur bir adım karşılık bulabilir.',
        'Aşk yıldızın bugün pırıl pırıl; bakışların bile mektup gibi okunuyor.',
        'Bugün gönül kapıların ardına kadar açık; güzellik davetsiz gelir.',
        'Kalp işlerinde bugün rüzgâr senden yana; söylenmemiş sözün günü.',
        'Bugün aşk cesaretle geleni ödüllendiriyor; ilk adım senden olsun.',
        'Aşk yıldızın bugün cömert; içinden geçeni söylemenin tam vakti.',
      ],
    },
    LuckCategory.para: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Cüzdanını bugün sıkı tut; plansız harcama pişmanlık getirir.',
        'Para bugün ürkek; parlak tekliflerin arka yüzünü çevirip bak.',
        'Bugün bereket mola vermiş; kesenin ağzını yarına kadar bağlı tut.',
        'Maddi işlerde bugün buzlu yol var; yavaş giden kaymaz.',
        'Bugün alışveriş listeni kısalt; azla yetinen çok kazanır.',
        'Cebini bugün rüzgâra kapatma; savurgan el sonra üşür.',
      ],
      KategoriTonu.orta: <String>[
        'Para akışın dengede; birikim için fena bir gün değil.',
        'Kazanç bugün sessiz akan bir dere; sabırlı kova dolduran kazanır.',
        'Bugün maddi terazi düz; hesap defterine düşen not yarın kıymetlenir.',
        'Para işlerinde bugün ölçülü adımlar tutuyor; büyük sıçramayı bekle.',
        'Bugün bereket ölçüyle dağıtılıyor; payını isteyen alır.',
        'Maddi işlerde bugün sabırlı ol; ağır giden yükü sağlam taşır.',
      ],
      KategoriTonu.yuksek: <String>[
        'Fırsat kokusu var; gözünü açık tut, kazanç kapıda.',
        'Para yıldızın bugün yükselişte; emeğinin karşılığı yaklaşıyor.',
        'Bugün bolluk senin sokaktan geçiyor; kapının önünü boş bırakma.',
        'Maddi işlerde bugün altın saat; ertelenen görüşmenin tam günü.',
        'Bugün cebine doğru tatlı bir rüzgâr esiyor; yelkenini aç.',
        'Bugün kazanç kapıda bekliyor; niyetini net ve yüksek sesle söyle.',
      ],
    },
    LuckCategory.saglik: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Enerjin düşük seyredebilir; bedenini dinle, tempoyu düşür.',
        'Bugün bedenin fısıltıyla yardım istiyor; kulak ver, ağırdan al.',
        'Sağlık terazin bugün hassas; yükünü paylaş, omzunu koru.',
        'Bugün pilin kısık; şarjı dinlenmekte, telaşta değil.',
        'Beden bugün nazlı; ona sıcak bir mola ve erken bir uyku borçlusun.',
        'Bedenin bugün yavaş istiyor; temposunu ona uydur.',
      ],
      KategoriTonu.orta: <String>[
        'Enerji dengen yerinde; hafif bir yürüyüş iyi gelir.',
        'Bugün beden ile zihin barışık; taze hava bu barışı perçinler.',
        'Sağlığın bugün sakin bir nehir; küçük bir hareket suyu şenlendirir.',
        'Bugün enerjin idareli aktarılıyor; molalarla çoğaltabilirsin.',
        'Beden bugün dengede; su ve uyku bu dengenin bekçileri.',
        'Enerjin bugün ölçülü; suyunu ve uykunu ihmal etme.',
      ],
      KategoriTonu.yuksek: <String>[
        'Kendini hafif hissedeceksin; formunun tadını çıkar.',
        'Enerjin bugün taşkın bir pınar; harekete dökmezsen taşar.',
        'Sağlık yıldızın bugün parlak; ertelediğin sporun tam günü.',
        'Bugün adımların yaylı, nefesin derin; zor işleri bugüne çek.',
        'Beden bugün senden razı; bu gücü güzel bir alışkanlığa yatır.',
        'Bugün formun yerinde; bu gücü ertelediğin işe yatır.',
      ],
    },
    LuckCategory.risk: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Bugün şansını zorlamanın günü değil; garantiye oyna.',
        'Zarlar bugün soğuk; masadan uzak duran kazançlı çıkar.',
        'Bugün köprüden geçerken korkuluğu bırakma; emniyet erdemdir.',
        'Risk terazisi bugün ters tartıyor; emin olmadığın kapıyı çalma.',
        'Bugün içgüdün bile temkin öneriyor; ona uy, pişman olmazsın.',
        'Bugün garantiden şaşma; sağlam zemin seni taşır.',
      ],
      KategoriTonu.orta: <String>[
        'Hesaplı riskler alınabilir; içgüdüne biraz pay bırak.',
        'Bugün orta boy cesaretlerin günü; ölçüp biçtiğin adım tutar.',
        'Zarlar bugün kararsız; küçük oyna, dersini büyük al.',
        'Bugün cesaret ile temkin el ele; ikisini birden cebinde taşı.',
        'Risk bugün ne dost ne düşman; kapıyı aralık tut, ardına kadar açma.',
        'Bugün hesaplı adım at; ölçülen cesaret geri tepmez.',
      ],
      KategoriTonu.yuksek: <String>[
        'Cesaret bugün ödüllendiriliyor; o adımı at.',
        'Bugün şans cesurların masasına oturmuş; sandalyeni çek.',
        'Risk yıldızın bugün parlıyor; kalbinin evet dediğine güven.',
        'Bugün atılan cesur tohum bereketli toprağa düşüyor.',
        'Ertelediğin hamlenin günü bugün; rüzgâr tam arkanda.',
        'Bugün kalbin evet diyorsa dinle; rüzgâr uygun esiyor.',
      ],
    },
    LuckCategory.sosyal: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Kalabalık bugün yorabilir; küçük ve samimi kal.',
        'Bugün sözler kolay bükülüyor; derin sohbetleri yarına sakla.',
        'Sosyal gökyüzün bugün bulutlu; kendinle geçen saat kazançtır.',
        'Bugün herkese yetişme; bir kişiye tam yetişmek yeter.',
        'Gürültü bugün fikrini bulandırır; sessiz köşen sana iyi gelecek.',
        'Bugün az ama öz; kalabalıktan çok bir yakınlık iyi gelir.',
      ],
      KategoriTonu.orta: <String>[
        'Sosyal enerjin dengede; eski bir dosta ses ver.',
        'Bugün çevrende tatlı bir hareketlilik var; seçtiğin sohbet keyif verir.',
        'İnsanlar bugün seni duymaya hazır; sözünü tane tane söyle.',
        'Bugün küçük bir buluşma beklenmedik güzellik doğurabilir.',
        'Sosyal sularda bugün sakin bir yüzüş var; akıntıya gerek yok.',
        'Bugün bir selam yeni bir kapı aralayabilir; adımını at.',
      ],
      KategoriTonu.yuksek: <String>[
        'Bugün ortamın yıldızı sensin; davetlere evet de.',
        'Sosyal gökyüzün şenlikli; yeni bir yüz eski bir kapıyı açabilir.',
        'Bugün sözlerin tatlı, enerjin bulaşıcı; çevrende halka genişler.',
        'Kalabalık bugün sana güç veriyor; sahnenin ortasına yürü.',
        'Bugün kurduğun köprü uzun yıllar ayakta kalacak cinsten.',
        'Bugün enerjin bulaşıcı; ortama neşe taşıyan sen ol.',
      ],
    },
  };

  static const Map<LuckCategory, List<String>>
  _tavsiyeTr = <LuckCategory, List<String>>{
    LuckCategory.ask: <String>[
      'Sevdiğine içinden geçeni bugün söylemeyi dene.',
      'Bugün bir mesajı iki kez oku, bir kez yaz; kalp acele sevmez.',
      'Küçük bir jest hazırla; zamanlamasını kalbin bilir.',
      'Bugün dinlemeye konuşmaktan çok vakit ayır; aşk kulakta büyür.',
      'Ortak bir anıyı bugün tazele; eski fotoğraflar köprü kurar.',
    ],
    LuckCategory.para: <String>[
      'Büyük kararları şanslı saatine denk getir.',
      'Bugün üç kuruşluk da olsa bir birikim başlat; tohum küçük olur.',
      'Faturaları ve hesapları bugün gözden geçir; düzen bereket çeker.',
      'Bugün bir harcamayı yirmi dört saat beklet; sabır iyi filtredir.',
      'Emeğinin fiyatını bugün bir kez daha düşün; kendini ucuza verme.',
    ],
    LuckCategory.saglik: <String>[
      'Bol su iç ve uykunu aksatma.',
      'Bugün merdiveni asansöre tercih et; küçük adım büyük yatırım.',
      'Omuzlarını bugün ara ara gevşet; gerginlik oradan başlar.',
      'Ekranlardan bugün bir saat erken kop; gözlerin teşekkür eder.',
      'Bugün bir öğünü yavaş ye; beden acele lokmayı sevmez.',
    ],
    LuckCategory.risk: <String>[
      'Yine de her şeyi tek karta bağlama.',
      'Kaybetmeyi göze aldığından fazlasını bugün ortaya koyma.',
      'Kararından önce bugün bir gece uykusu koy; sabah daha net.',
      'Bugün B planını yazıya dök; yedek yol cesareti büyütür.',
      'İçgüdünü dinle ama bugün bir de bilene danış.',
    ],
    LuckCategory.sosyal: <String>[
      'Yeni bir tanışıklık sürpriz kapılar açabilir.',
      'Bugün bir teşekkürü sözlü söyle; yazı soğuk kalır.',
      'Uzak kalmış bir dosta bugün kısa bir selam gönder.',
      'Bugün bir davete gitmeden önce niyetini belirle; keyif niyetle gelir.',
      'Sohbette bugün bir kez daha az konuş, bir kez daha çok sor.',
    ],
  };

  // ---------------------------------------------------------------------------
  // İNGİLİZCE (TR ile birebir aynı uzunluk ve anahtarlar)
  // ---------------------------------------------------------------------------

  static const Map<LuckCategory, Map<KategoriTonu, List<String>>>
  _acilisEn = <LuckCategory, Map<KategoriTonu, List<String>>>{
    LuckCategory.ask: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'In matters of the heart, do not rush today; a day open to misunderstandings.',
        'Your love sky is hazy today; leave clear answers for the day the fog lifts.',
        'Feelings are like fragile glass today; carry them with both hands.',
        'The wind is harsh in your heart\'s garden today; guard your seedlings with patience.',
        'Look at the calendar, not your heart, today; some talks have not ripened yet.',
        'In love, haste ties knots today; let the end of the rope go slowly.',
      ],
      KategoriTonu.orta: <String>[
        'A balanced day on the love front; small gestures open large doors.',
        'Your heart is in calm waters today; a gentle touch makes the wave lovely.',
        'In love today, neither storm nor stillness; a sincere word is wind enough.',
        'A mild, sweet day in matters of the heart; the sweetening is in your hands.',
        'Feelings are balanced today; the one who opens the heart finds the door open too.',
        'Your heart is serene today; a gentle approach eases the door open.',
      ],
      KategoriTonu.yuksek: <String>[
        'Your heart is like a magnet today; a bold step may find a response.',
        'Your love star is gleaming today; even your glances read like letters.',
        'The doors of your heart are wide open today; beauty arrives uninvited.',
        'In matters of the heart the wind is on your side today; the day of the unspoken word.',
        'Love rewards the brave today; let the first step be yours.',
        'Your love star is generous today; the perfect time to say what is inside.',
      ],
    },
    LuckCategory.para: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Hold your wallet tight today; unplanned spending brings regret.',
        'Money is timid today; turn shiny offers over and check the back.',
        'Abundance is on a break today; keep your purse knotted until tomorrow.',
        'The road is icy in money matters today; the slow one does not slip.',
        'Shorten your shopping list today; the one content with little gains much.',
        'Do not open your pocket to the wind today; the wasteful hand gets cold later.',
      ],
      KategoriTonu.orta: <String>[
        'Your money flow is balanced; not a bad day for saving.',
        'Earnings are a quiet stream today; the one who fills a patient bucket wins.',
        'The money scale is level today; a note in your ledger gains value tomorrow.',
        'In money matters, measured steps hold today; wait for the big leap.',
        'Abundance is shared by measure today; the one who asks for a share gets it.',
        'Be patient in money matters today; the slow one carries the load safely.',
      ],
      KategoriTonu.yuksek: <String>[
        'There is a scent of opportunity; keep your eyes open, earnings are at the door.',
        'Your money star is rising today; the reward for your effort is near.',
        'Plenty is passing down your street today; do not leave your doorway empty.',
        'A golden hour in money matters today; the very day for the postponed meeting.',
        'A sweet wind blows toward your pocket today; open your sail.',
        'Earnings wait at the door today; state your intent clearly and aloud.',
      ],
    },
    LuckCategory.saglik: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Your energy may run low; listen to your body, ease the pace.',
        'Your body asks for help in a whisper today; heed it, take it slow.',
        'Your health scale is delicate today; share your load, protect your shoulder.',
        'Your battery is low today; the charge is in resting, not in rushing.',
        'The body is delicate today; you owe it a warm break and an early night.',
        'Your body wants slow today; match your pace to it.',
      ],
      KategoriTonu.orta: <String>[
        'Your energy balance is fine; a light walk does good.',
        'Body and mind are at peace today; fresh air rivets this peace.',
        'Your health is a calm river today; a little movement enlivens the water.',
        'Your energy is spent sparingly today; you can build it with breaks.',
        'The body is balanced today; water and sleep are the guards of that balance.',
        'Your energy is measured today; do not neglect your water and sleep.',
      ],
      KategoriTonu.yuksek: <String>[
        'You will feel light; enjoy your good form.',
        'Your energy is an overflowing spring today; if you do not move it, it overflows.',
        'Your health star is bright today; the very day for the exercise you postpone.',
        'Your steps are springy and your breath deep today; pull the hard tasks into today.',
        'The body is pleased with you today; invest this strength in a good habit.',
        'Your form is on point today; invest this strength in the task you postpone.',
      ],
    },
    LuckCategory.risk: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Today is not a day to push your luck; play it safe.',
        'The dice are cold today; the one who stays off the table comes out ahead.',
        'Do not let go of the railing while crossing the bridge today; safety is a virtue.',
        'The scale of risk weighs against you today; do not knock on a door you doubt.',
        'Even your instinct advises caution today; follow it, you will not regret it.',
        'Do not stray from the sure thing today; firm ground carries you.',
      ],
      KategoriTonu.orta: <String>[
        'Calculated risks can be taken; leave a little share to your instinct.',
        'Today is a day of medium-sized courage; the step you measure will hold.',
        'The dice are undecided today; play small, learn a big lesson.',
        'Courage and caution go hand in hand today; carry both in your pocket.',
        'Risk is neither friend nor foe today; keep the door ajar, not wide open.',
        'Take a calculated step today; measured courage does not backfire.',
      ],
      KategoriTonu.yuksek: <String>[
        'Courage is rewarded today; take that step.',
        'Luck has sat at the table of the brave today; pull up your chair.',
        'Your risk star shines today; trust what your heart says yes to.',
        'The brave seed sown today falls on fertile soil.',
        'Today is the day of the move you postponed; the wind is right at your back.',
        'If your heart says yes today, listen; the wind blows fair.',
      ],
    },
    LuckCategory.sosyal: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'The crowd may tire you today; stay small and sincere.',
        'Words bend easily today; save deep conversations for tomorrow.',
        'Your social sky is cloudy today; an hour spent with yourself is a gain.',
        'Do not keep up with everyone today; keeping up fully with one person is enough.',
        'Noise clouds your mind today; your quiet corner will do you good.',
        'Little but meaningful today; one closeness beats a crowd.',
      ],
      KategoriTonu.orta: <String>[
        'Your social energy is balanced; reach out to an old friend.',
        'There is a sweet liveliness around you today; the conversation you choose brings joy.',
        'People are ready to hear you today; speak your words one by one.',
        'A small meeting today may give rise to an unexpected beauty.',
        'A calm swim in social waters today; no need to fight the current.',
        'A greeting may open a new door today; take your step.',
      ],
      KategoriTonu.yuksek: <String>[
        'You are the star of the room today; say yes to invitations.',
        'Your social sky is festive; a new face may open an old door.',
        'Your words are sweet and your energy contagious today; the circle around you widens.',
        'The crowd gives you strength today; walk to the center of the stage.',
        'The bridge you build today is the kind that stands for years.',
        'Your energy is contagious today; be the one who carries joy to the room.',
      ],
    },
  };

  static const Map<LuckCategory, List<String>>
  _tavsiyeEn = <LuckCategory, List<String>>{
    LuckCategory.ask: <String>[
      'Try to tell your loved one what is inside you today.',
      'Read a message twice, write it once today; the heart does not love haste.',
      'Prepare a small gesture; the heart knows its timing.',
      'Spend more time listening than speaking today; love grows in the ear.',
      'Revive a shared memory today; old photographs build bridges.',
    ],
    LuckCategory.para: <String>[
      'Time big decisions to your lucky hour.',
      'Start a saving today, even a few coins; the seed starts small.',
      'Review your bills and accounts today; order draws abundance.',
      'Hold a purchase for twenty-four hours today; patience is a good filter.',
      'Reconsider the price of your effort today; do not sell yourself cheap.',
    ],
    LuckCategory.saglik: <String>[
      'Drink plenty of water and do not skimp on sleep.',
      'Choose the stairs over the elevator today; a small step is a big investment.',
      'Loosen your shoulders now and then today; tension starts there.',
      'Unplug from screens an hour early today; your eyes will thank you.',
      'Eat one meal slowly today; the body does not love a hurried bite.',
    ],
    LuckCategory.risk: <String>[
      'Still, do not stake everything on a single card.',
      'Do not put down more than you can afford to lose today.',
      'Sleep on your decision one night today; the morning is clearer.',
      'Write down a plan B today; a backup path grows courage.',
      'Listen to your instinct, but also ask someone who knows today.',
    ],
    LuckCategory.sosyal: <String>[
      'A new acquaintance may open surprising doors.',
      'Say a thank-you out loud today; writing stays cold.',
      'Send a short hello to a distant friend today.',
      'Set your intention before going to an event today; joy comes with intent.',
      'In conversation today, speak a little less and ask a little more.',
    ],
  };
}
