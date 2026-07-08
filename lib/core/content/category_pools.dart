import '../luck_engine/luck_category.dart';
import 'content_config.dart';

/// Kategori detay sayfasının metin havuzları.
///
/// Detay yorumu iki cümleden birleşir: açılış (kategori × ton) +
/// tavsiye (kategori). Cümleler kendi başına tamdır; aralarında zamir
/// gönderimi yoktur. Ton kuralları için bkz. `fortune_pools.dart`.
abstract final class CategoryPools {
  /// (kategori, ton) başına açılış cümleleri.
  static const Map<LuckCategory, Map<KategoriTonu, List<String>>>
      kategoriAcilislari = <LuckCategory, Map<KategoriTonu, List<String>>>{
    LuckCategory.ask: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Kalp işlerinde bugün acele etme; yanlış anlaşılmalara açık bir gün.',
        'Aşk gökyüzün bugün puslu; net cevapları sisin dağılacağı güne bırak.',
        'Bugün duygular kırılgan cam gibi; taşırken iki elinle tut.',
        'Gönül bahçende bugün rüzgâr sert; fidelerini sabırla koru.',
        'Bugün kalbine değil takvime bak; bazı sohbetlerin vakti gelmemiş.',
      ],
      KategoriTonu.orta: <String>[
        'Aşk cephesinde dengeli bir gün; küçük jestler büyük kapılar açar.',
        'Kalbin bugün sakin sularda; nazik bir dokunuş dalgayı güzelleştirir.',
        'Bugün aşkta ne fırtına ne durgunluk; içten bir söz yeterli rüzgâr.',
        'Gönül işlerinde bugün orta şeker bir gün; tatlandırmak senin elinde.',
        'Bugün duygular dengede; kalbini açan kapıyı da açık bulur.',
      ],
      KategoriTonu.yuksek: <String>[
        'Kalbin bugün mıknatıs gibi; cesur bir adım karşılık bulabilir.',
        'Aşk yıldızın bugün pırıl pırıl; bakışların bile mektup gibi okunuyor.',
        'Bugün gönül kapıların ardına kadar açık; güzellik davetsiz gelir.',
        'Kalp işlerinde bugün rüzgâr senden yana; söylenmemiş sözün günü.',
        'Bugün aşk cesaretle geleni ödüllendiriyor; ilk adım senden olsun.',
      ],
    },
    LuckCategory.para: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Cüzdanını bugün sıkı tut; plansız harcama pişmanlık getirir.',
        'Para bugün ürkek; parlak tekliflerin arka yüzünü çevirip bak.',
        'Bugün bereket mola vermiş; kesenin ağzını yarına kadar bağlı tut.',
        'Maddi işlerde bugün buzlu yol var; yavaş giden kaymaz.',
        'Bugün alışveriş listeni kısalt; azla yetinen çok kazanır.',
      ],
      KategoriTonu.orta: <String>[
        'Para akışın dengede; birikim için fena bir gün değil.',
        'Kazanç bugün sessiz akan bir dere; sabırlı kova dolduran kazanır.',
        'Bugün maddi terazi düz; hesap defterine düşen not yarın kıymetlenir.',
        'Para işlerinde bugün ölçülü adımlar tutuyor; büyük sıçramayı bekle.',
        'Bugün bereket ölçüyle dağıtılıyor; payını isteyen alır.',
      ],
      KategoriTonu.yuksek: <String>[
        'Fırsat kokusu var; gözünü açık tut, kazanç kapıda.',
        'Para yıldızın bugün yükselişte; emeğinin karşılığı yaklaşıyor.',
        'Bugün bolluk senin sokaktan geçiyor; kapının önünü boş bırakma.',
        'Maddi işlerde bugün altın saat; ertelenen görüşmenin tam günü.',
        'Bugün cebine doğru tatlı bir rüzgâr esiyor; yelkenini aç.',
      ],
    },
    LuckCategory.saglik: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Enerjin düşük seyredebilir; bedenini dinle, tempoyu düşür.',
        'Bugün bedenin fısıltıyla yardım istiyor; kulak ver, ağırdan al.',
        'Sağlık terazin bugün hassas; yükünü paylaş, omzunu koru.',
        'Bugün pilin kısık; şarjı dinlenmekte, telaşta değil.',
        'Beden bugün nazlı; ona sıcak bir mola ve erken bir uyku borçlusun.',
      ],
      KategoriTonu.orta: <String>[
        'Enerji dengen yerinde; hafif bir yürüyüş iyi gelir.',
        'Bugün beden ile zihin barışık; taze hava bu barışı perçinler.',
        'Sağlığın bugün sakin bir nehir; küçük bir hareket suyu şenlendirir.',
        'Bugün enerjin idareli aktarılıyor; molalarla çoğaltabilirsin.',
        'Beden bugün dengede; su ve uyku bu dengenin bekçileri.',
      ],
      KategoriTonu.yuksek: <String>[
        'Kendini hafif hissedeceksin; formunun tadını çıkar.',
        'Enerjin bugün taşkın bir pınar; harekete dökmezsen taşar.',
        'Sağlık yıldızın bugün parlak; ertelediğin sporun tam günü.',
        'Bugün adımların yaylı, nefesin derin; zor işleri bugüne çek.',
        'Beden bugün senden razı; bu gücü güzel bir alışkanlığa yatır.',
      ],
    },
    LuckCategory.risk: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Bugün şansını zorlamanın günü değil; garantiye oyna.',
        'Zarlar bugün soğuk; masadan uzak duran kazançlı çıkar.',
        'Bugün köprüden geçerken korkuluğu bırakma; emniyet erdemdir.',
        'Risk terazisi bugün ters tartıyor; emin olmadığın kapıyı çalma.',
        'Bugün içgüdün bile temkin öneriyor; ona uy, pişman olmazsın.',
      ],
      KategoriTonu.orta: <String>[
        'Hesaplı riskler alınabilir; içgüdüne biraz pay bırak.',
        'Bugün orta boy cesaretlerin günü; ölçüp biçtiğin adım tutar.',
        'Zarlar bugün kararsız; küçük oyna, dersini büyük al.',
        'Bugün cesaret ile temkin el ele; ikisini birden cebinde taşı.',
        'Risk bugün ne dost ne düşman; kapıyı aralık tut, ardına kadar açma.',
      ],
      KategoriTonu.yuksek: <String>[
        'Cesaret bugün ödüllendiriliyor; o adımı at.',
        'Bugün şans cesurların masasına oturmuş; sandalyeni çek.',
        'Risk yıldızın bugün parlıyor; kalbinin evet dediğine güven.',
        'Bugün atılan cesur tohum bereketli toprağa düşüyor.',
        'Ertelediğin hamlenin günü bugün; rüzgâr tam arkanda.',
      ],
    },
    LuckCategory.sosyal: <KategoriTonu, List<String>>{
      KategoriTonu.dusuk: <String>[
        'Kalabalık bugün yorabilir; küçük ve samimi kal.',
        'Bugün sözler kolay bükülüyor; derin sohbetleri yarına sakla.',
        'Sosyal gökyüzün bugün bulutlu; kendinle geçen saat kazançtır.',
        'Bugün herkese yetişme; bir kişiye tam yetişmek yeter.',
        'Gürültü bugün fikrini bulandırır; sessiz köşen sana iyi gelecek.',
      ],
      KategoriTonu.orta: <String>[
        'Sosyal enerjin dengede; eski bir dosta ses ver.',
        'Bugün çevrende tatlı bir hareketlilik var; seçtiğin sohbet keyif verir.',
        'İnsanlar bugün seni duymaya hazır; sözünü tane tane söyle.',
        'Bugün küçük bir buluşma beklenmedik güzellik doğurabilir.',
        'Sosyal sularda bugün sakin bir yüzüş var; akıntıya gerek yok.',
      ],
      KategoriTonu.yuksek: <String>[
        'Bugün ortamın yıldızı sensin; davetlere evet de.',
        'Sosyal gökyüzün şenlikli; yeni bir yüz eski bir kapıyı açabilir.',
        'Bugün sözlerin tatlı, enerjin bulaşıcı; çevrende halka genişler.',
        'Kalabalık bugün sana güç veriyor; sahnenin ortasına yürü.',
        'Bugün kurduğun köprü uzun yıllar ayakta kalacak cinsten.',
      ],
    },
  };

  /// Kategori başına tavsiye cümleleri (detay yorumunun ikinci cümlesi).
  static const Map<LuckCategory, List<String>> kategoriTavsiyeleri =
      <LuckCategory, List<String>>{
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
}
