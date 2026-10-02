/// Kişisel Yıl Raporu'nun metin havuzları.
///
/// Rapor bir takvim yılını (ör. 2027) kişinin kişisel yıl sayısı (1-9)
/// üzerinden anlatır: yılın teması `DonguMetinleri.kisiselYil`'den gelir;
/// bu dosya yılın rehberini (fırsatlar, dikkat, aşk, iş ve para, niyet) ve
/// ay ay okumayı (kişisel ay 1-9) taşır.
///
/// Yazım kuralları (bkz. `sayi_metinleri.dart` ve `rapor_metinleri.dart`)
/// ek olarak:
/// - Olay kehaneti yok: "olacak" değil "gündeme gelebilir", "için uygun".
/// - Para metinlerinde yatırım ürünü ya da yönlendirme yok.
/// - Ay metinleri bir yılda en fazla iki kez görülür; her kişisel ayın iki
///   farklı varyantı vardır (ilk geliş A, ikinci geliş B).
library;

/// Bir kişisel yılın rehber metinleri.
class YilRehberi {
  /// Tüm alanlarıyla rehber oluşturur.
  const YilRehberi({
    required this.firsatlar,
    required this.dikkat,
    required this.ask,
    required this.isVePara,
    required this.niyet,
  });

  /// Yılın sunduğu fırsatlar.
  final String firsatlar;

  /// Yılın tuzakları ve dikkat edilecekler.
  final String dikkat;

  /// Yılın aşka etkisi.
  final String ask;

  /// Yılın iş ve paraya etkisi.
  final String isVePara;

  /// Yılın sorusu ve önerilen niyet çalışması.
  final String niyet;
}

/// Bir kişisel ayın lakabı ve iki metin varyantı.
class AyTemasi {
  /// Tüm alanlarıyla tema oluşturur.
  const AyTemasi({required this.lakap, required this.varyantlar});

  /// Ayın kısa lakabı ("Başlangıç ayı").
  final String lakap;

  /// Ayın metni; yılda ilk gelişinde [0], ikincisinde [1].
  final List<String> varyantlar;
}

/// Kişisel Yıl Raporu metin havuzları.
abstract final class YillikRaporMetinleri {
  /// Kişisel yıl (1-9) → yılın rehberi.
  static const Map<int, YilRehberi> rehberler = <int, YilRehberi>{
    1: YilRehberi(
      firsatlar:
          'Bu yılın en büyük fırsatı yeni bir şey başlatmak: bir iş, bir '
          'eğitim, bir taşınma ya da uzun süredir kafanda dönen bir proje. '
          'Kapılar ilk adımı atana açılır. Yılın ilk yarısında aldığın '
          'kararlar sonraki dokuz yılın havasını belirleyebilir; bu yüzden ne '
          'istediğini netleştirmek için çok değerli bir zaman.',
      dikkat:
          'Hevesle çok fazla şeye birden başlamak enerjini dağıtabilir. '
          'Başkalarının onayını beklerken fırsatları kaçırma eğilimine de '
          'dikkat et. Yalnız hissettiğin anlar olabilir; bu, kendi yolunu '
          'çizerken doğal bir duygu. Sabırsızlık en büyük tuzağın: tohumlar '
          'bir gecede filizlenmez.',
      ask:
          'Aşkta yeni bir sayfa açılabilir: bekarsan yeni tanışmalara, bir '
          'ilişkin varsa ilişkinde yeni bir ritim kurmaya açık bir yıl. Kendi '
          'ihtiyaçlarını netleştirmek ilişkide de daha dürüst olmanı sağlar. '
          'İlk adımı atmaktan çekinme. '
          'Yıl boyunca kalbinin sesini başkalarının beklentilerinden ayırmak sana netlik verir.',
      isVePara:
          'İş ve parada inisiyatif alma yılı. Yeni bir iş, bir terfi ya da '
          'kendi işini kurma fikri gündeme gelebilir. Kazancın hemen '
          'büyümeyebilir; ama bu yıl attığın temeller ileriki yıllarda '
          'karşılığını verir. Risk alırken planlı olmak seni korur.',
      niyet:
          "Yılın sorusu: 'Ben gerçekten ne başlatmak istiyorum?' Bu yıl için "
          'tek cümlelik bir niyet yaz ve onu her gün görebileceğin bir yere '
          'koy.',
    ),
    2: YilRehberi(
      firsatlar:
          'Bu yılın fırsatı ilişkilerde ve iş birliklerinde. Geçen yıl '
          'başlattığın şeyler şimdi sabır ve incelik istiyor. Doğru ortaklar, '
          'destekleyici dostluklar ve derinleşen bağlar bu yılın asıl '
          'kazancı. Sezgilerin güçlü; insanları ve durumları okuma becerin '
          'sana yol gösterir.',
      dikkat:
          'İşler istediğin hızda ilerlemeyebilir; bu durum seni '
          'sabırsızlandırabilir. Başkalarını memnun etmek için kendi '
          'ihtiyaçlarını bastırma eğilimine dikkat et. Duygusal hassasiyetin '
          'artabilir; küçük kırgınlıkları büyütmeden konuşmak önemli. '
          'Kararsız kaldığın anlarda sezgine güvenmek, herkesin fikrini tek tek sormaktan daha çok işe yarar. Bu yıl nazikçe hayır demeyi öğrenmek de bir kazanç.',
      ask:
          'Aşk açısından yakınlaşma ve bağlılık yılı. Mevcut ilişkin '
          'derinleşebilir ya da anlamlı bir birliktelik başlayabilir. '
          'Romantizm ve şefkat ön planda; dinlemek ve anlaşılmak bu yıl '
          'ilişkinin anahtarı. '
          'Partnerinle küçük ritüeller kurmak ya da bekarsan acele etmeden tanımak, bu yılın ilişkilerine sağlam bir zemin hazırlar.',
      isVePara:
          'İşte ekip çalışması ve ortaklıklar öne çıkar. Tek başına koşmak '
          'yerine güvenilir insanlarla çalışmak kazandırır. Para tarafında '
          'büyük sıçramalar yerine yavaş ama istikrarlı bir ilerleme '
          'beklenebilir; anlaşmaları ayrıntılarıyla okumak önemli. '
          'Bir ortaklık teklifi gelirse güveni ve iş bölümünü baştan konuşmak ileride seni korur.',
      niyet:
          "Yılın sorusu: 'Kiminle birlikte büyümek istiyorum?' Hayatındaki en "
          'değerli üç ilişkiyi düşün ve her birine bu yıl ne katabileceğini '
          'yaz.',
    ),
    3: YilRehberi(
      firsatlar:
          'Bu yıl kendini ifade etmenin, yaratıcılığın ve sosyal hayatın yılı. '
          'Yazmak, konuşmak, paylaşmak ve üretmek için enerjin yüksek. Çevren '
          'genişler; yeni dostluklar ve beklenmedik bağlantılar kapı '
          'açabilir. Hayattan keyif almak bu yıl bir lüks değil, bir ihtiyaç.',
      dikkat:
          'Enerjini çok fazla alana dağıtmak, hiçbirini bitirememene yol '
          'açabilir. Harcamalar sosyal hayatla birlikte artabilir. Sözlerin '
          'etkili ama yanlış anlaşılmaya da açık; özellikle öfkeliyken '
          'konuşmadan önce bir an durmak iyi olur. '
          'Kendini fazla açıkta hissettiğin anlarda biraz geri çekilip enerjini toplamak dengeni korur.',
      ask:
          'Aşkta neşe, flört ve eğlence ön planda. Bekarsan sosyal ortamlarda '
          'tanışmalar kolaylaşır; ilişkin varsa birlikte yaşanan yeni '
          'deneyimler bağınızı canlandırır. Duygularını sözlerle göstermek bu '
          'yıl özellikle değerli. '
          'Bu yıl birlikte gülebildiğin insanlar kalbine en kolay ulaşanlar olabilir.',
      isVePara:
          'İşte iletişim, tanıtım, satış ve yaratıcı üretim gerektiren '
          'alanlarda parlarsın. Görünür olmak kazancını artırabilir. Para '
          'tarafında gelir kadar harcamaların da artabileceği bir yıl; keyfi '
          'bütçeyle dengelemek önemli. '
          'Bir yan uğraşı ya da hobini gelir kapısına dönüştürme fikri de gündeme gelebilir; küçük bir denemeyle başlamak yeterli.',
      niyet:
          "Yılın sorusu: 'Ben neyi ifade etmek istiyorum?' Bu yıl üretmek ya "
          'da paylaşmak istediğin bir şeyi seç ve ona her hafta düzenli zaman '
          'ayır.',
    ),
    4: YilRehberi(
      firsatlar:
          'Bu yıl sağlam temeller kurma yılı. Emek, düzen ve disiplinle '
          'attığın her adım kalıcı sonuçlar üretir. Bir meslekte derinleşmek, '
          'bir ev ya da birikim hedefi, sağlıklı bir rutin oluşturmak için en '
          'verimli yıllardan biri. Bu yılki çaban sonraki yılların '
          'özgürlüğünü hazırlar.',
      dikkat:
          'Tempo yorucu olabilir; işler hiç bitmiyormuş gibi gelebilir. '
          'Katılaşmaya, her şeyi kontrol etmeye ve dinlenmeyi ertelemeye '
          'dikkat et. Bedeninin verdiği yorgunluk sinyallerini ciddiye almak '
          'bu yıl özellikle önemli. '
          'Sorumlulukları paylaşmak ve her şeyi kusursuz yapma beklentisini gevşetmek yılı çok daha hafif geçirmeni sağlar.',
      ask:
          'Aşkta güven ve istikrar yılı. İlişkiler daha ciddi bir zemine '
          'oturabilir; ortak planlar, ev ya da gelecek konuşmaları gündeme '
          'gelebilir. Romantizm geri planda kalabilir; küçük jestler bu '
          'dengeyi korur. '
          'Birlikte bir hedef koymak ilişkine hem güven hem de ortak bir heyecan katar.',
      isVePara:
          'İşte çalışkanlığın görünür olur ama sonuçlar zaman alır. Bütçe '
          'yapmak, borçları düzenlemek ve birikim planı kurmak için çok '
          'verimli bir yıl. Hızlı kazanç vaatlerinden uzak durmak seni korur. '
          'Bu yıl kurduğun düzenli alışkanlıklar önümüzdeki yıllarda maddi rahatlığının temelini oluşturabilir.',
      niyet:
          "Yılın sorusu: 'Hangi temeli kurarsam beş yıl sonra kendime teşekkür "
          "ederim?' O temelin ilk taşını bu ay koy.",
    ),
    5: YilRehberi(
      firsatlar:
          'Bu yıl hareket, değişim ve özgürlük yılı. Yeni yerler, yeni '
          'insanlar ve yeni deneyimler kapını çalabilir. Uzun süredir '
          'sıkıştığın bir kalıptan çıkmak için cesaretin artar. Esnek '
          'kaldıkça yıl sana beklemediğin fırsatlar sunar. '
          'Yeni bir dil, yeni bir şehir ya da yeni bir çevre ufkunu genişletebilir.',
      dikkat:
          'Ani kararlar ve aşırılıklar bu yılın tuzağı olabilir. Her yeni '
          'şeye koşarken sorumluluklarını ihmal etmemeye dikkat et. '
          'Huzursuzluk hissettiğinde bunun bir değişim ihtiyacı mı yoksa '
          'kaçma isteği mi olduğunu ayırt etmek önemli. '
          'Değişimin içinde sana güven veren küçük bir rutini korumak savrulmanı önler.',
      ask:
          'Aşkta heyecan ve sürpriz yılı. Beklenmedik tanışmalar, hızlı '
          'başlayan ilişkiler ya da mevcut ilişkide yenilenme isteği öne '
          'çıkabilir. Özgürlük ihtiyacını partnerinle açıkça konuşmak '
          'bağınızı korur. '
          'Bekarsan farklı ortamlarda tanışmaya açık ol; bir ilişkin varsa birlikte yapacağınız bir yolculuk ya da yeni bir deneyim bağınızı tazeleyebilir.',
      isVePara:
          'İşte değişim rüzgârı esebilir: yeni bir pozisyon, yeni bir alan ya '
          'da seyahat içeren işler gündeme gelebilir. Kazanç dalgalı olabilir; '
          'iyi aylarda bir kenara ayırmak dalgalanmayı yumuşatır. '
          'Yeni fırsatları değerlendirirken sözleşme ve koşulları dikkatle okumak esnekliğini güvenceye alır.',
      niyet:
          "Yılın sorusu: 'Hayatımda neyi değiştirmeye hazırım?' Bu yıl "
          'deneyeceğin üç yeni şeyi yaz ve her birine bir ay ver.',
    ),
    6: YilRehberi(
      firsatlar:
          'Bu yıl aile, yuva ve sevgi yılı. Ev, aile ilişkileri, yakın '
          'dostluklar ve topluluk hayatının merkezine yerleşir. Birine destek '
          'olmak, bir yuva kurmak ya da evini güzelleştirmek için güçlü bir '
          'yıl. Verdiğin özen sevgi olarak geri döner.',
      dikkat:
          'Sorumlulukların artabilir; herkesin yükünü taşımaya çalışmak seni '
          'yorabilir. Mükemmeliyetçiliğe ve başkalarının hayatına fazla '
          'karışmaya dikkat et. Kendine ayırdığın zamanı korumak bu yıl bir '
          'lüks değil, ihtiyaç. '
          'Yardım etmek ile başkalarının sorumluluğunu üstlenmek arasındaki farkı gözetmek hem ilişkilerini hem seni korur.',
      ask:
          'Aşkta bağlılık ve sorumluluk yılı. Nişan, evlilik, birlikte yaşama '
          'ya da ilişkiyi bir üst seviyeye taşıma konuları gündeme gelebilir. '
          'Bekarsan güven veren, yuva kurmaya açık biri dikkatini çekebilir. '
          'İlişkin varsa birlikte ev ya da aile planları yapmak, bekarsan kendi yuvana dair hayalini netleştirmek bu yılın güzel işleri arasında.',
      isVePara:
          'İşte hizmet, bakım, eğitim ve insanlarla ilgilenen alanlarda '
          'emeğin görünür olur. Ev ve aile giderleri bütçede ağırlık '
          'kazanabilir. Sevdiklerin için harcarken kendi güvenceni de korumak '
          'önemli. '
          'Ev için büyük bir harcama düşünüyorsan bütçeni önceden planlamak gönül rahatlığı sağlar.',
      niyet:
          "Yılın sorusu: 'Sevgiyi nasıl hem vermeyi hem almayı öğrenirim?' Bu "
          'yıl kendin için yapacağın küçük bir şefkat ritüeli belirle.',
    ),
    7: YilRehberi(
      firsatlar:
          'Bu yıl içe dönüş, öğrenme ve derinleşme yılı. Okumak, araştırmak, '
          'bir alanda uzmanlaşmak ya da hayatın anlamı üzerine düşünmek için '
          'ideal bir dönem. Sessiz zamanlar sana netlik verir; bu yıl '
          'edindiğin bilgelik ileriki yıllarda yolunu aydınlatır.',
      dikkat:
          'Kendini fazla geri çekmek yalnızlık hissini artırabilir. Her şeyi '
          'kafanda çözmeye çalışmak yerine güvendiğin insanlarla konuşmak iyi '
          'gelir. Dış dünyada hızlı sonuçlar beklemek bu yıl hayal kırıklığı '
          'yaratabilir; asıl ilerleme içeride. '
          'Kendine ayırdığın sessiz zamanı korurken birkaç güvenilir bağı da canlı tutmak dengeni sağlar.',
      ask:
          'Aşkta derinlik yılı. Yüzeysel ilişkiler seni tatmin etmeyebilir; '
          'zihinsel ve ruhsal yakınlık arayışı öne çıkar. İlişkin varsa '
          'birlikte geçirilen sessiz zamanlar ve derin sohbetler bağınızı '
          'güçlendirir. '
          'Bekarsan aceleyle değil, gerçekten tanıyarak bağlanmak isteyebilirsin; bu yıl için yerinde bir tercih.',
      isVePara:
          'İşte araştırma, analiz, uzmanlık ve planlama gerektiren işlerde '
          'güçlüsün. Büyük atılımlar yerine strateji kurma ve kendini '
          'geliştirme yılı. Maddi kararlarda acele etmemek ve iyi araştırmak '
          'seni korur. Bir eğitime, sertifikaya ya da uzmanlık alanına '
          'ayırdığın zaman ilerleyen yıllarda değerini artırabilir.',
      niyet:
          "Yılın sorusu: 'Kendim hakkında neyi henüz anlamadım?' Bu yıl "
          'düzenli olarak yazmak ya da düşünmek için kendine sessiz bir zaman '
          'ayır.',
    ),
    8: YilRehberi(
      firsatlar:
          'Bu yıl güç, başarı ve hasat yılı. Geçmiş yıllarda verdiğin emeğin '
          'karşılığını görme ihtimalin yüksek. Kariyerde yükselmek, kendi '
          'işini büyütmek, önemli anlaşmalar yapmak ve maddi hedeflere '
          'ulaşmak için güçlü bir yıl. Kararlılığın ve yönetme becerin öne '
          'çıkar.',
      dikkat:
          'Hırs ve kontrol isteği ilişkilerini zorlayabilir. Çok çalışırken '
          'bedenini ve sevdiklerini ihmal etmemeye dikkat et. Gücünü adil '
          'kullanmak ve maddi kararlarda dengeli olmak bu yılın asıl sınavı. '
          'Başarıyı yalnızca rakamlarla ölçmek yerine iç huzurunu da hesaba kattığında yıl çok daha doyurucu geçer.',
      ask:
          'Aşkta güç dengeleri gündeme gelebilir. Ciddi ve geleceğe dönük '
          'ilişkiler öne çıkar; birlikte hedef koymak bağınızı güçlendirir. İş '
          'yoğunluğunun ilişkine yer bırakmasına özen göstermek önemli. '
          'Bekarsan kendinden emin ve hedefleri olan biri dikkatini çekebilir; ilişkin varsa birlikte büyük bir plan yapmak sizi yakınlaştırır.',
      isVePara:
          'İş ve parada parlama yılı: terfi, zam, önemli maddi kararlar ya da '
          'işini büyütme fırsatları gündeme gelebilir. Emeğinin değerini '
          'istemekten çekinme. Büyük harcamaları ve riskleri iyi hesaplamak '
          'kazancını korur. '
          'Kazancın arttığı dönemlerde bir kısmını güvenceye ayırmak yılın hasadını kalıcı kılar.',
      niyet:
          "Yılın sorusu: 'Gücümü neyi inşa etmek için kullanmak istiyorum?' "
          'Bu yıl ulaşmak istediğin somut bir hedefi rakamlarıyla yaz.',
    ),
    9: YilRehberi(
      firsatlar:
          'Bu yıl tamamlama, bırakma ve arınma yılı. Dokuz yıllık bir döngünün '
          'son halkasındasın. Artık sana hizmet etmeyen ilişkileri, işleri ve '
          'alışkanlıkları geride bırakmak için en doğru zaman. Şefkatin ve '
          'hoşgörün güçlü; başkalarına yardım etmek sana derin bir anlam '
          'verir.',
      dikkat:
          'Bitişler duygusal olarak yorucu olabilir; bir şeylere fazla '
          'tutunmak süreci zorlaştırır. Yeni büyük başlangıçları gelecek yıla '
          'bırakmak daha iyi olabilir. Geçmişte kalan kırgınlıkları tekrar '
          'tekrar düşünmek yerine onlara bir nokta koymaya çalış. '
          'Bitenlerin yasını tutmak da sürecin doğal bir parçası; kendine bu alanı tanımak seni hafifletir.',
      ask:
          'Aşkta kapanış ve affediş yılı. Tamamlanmış bir ilişki sona '
          'erebilir ya da mevcut ilişkin eski yüklerden arınarak '
          'derinleşebilir. Geçmişle barışmak kalbini yeni bir sayfaya '
          'hazırlar. Bekarsan eski bir bağı yeniden canlandırmak yerine kendi iç '
          'dünyanı toparlamak, gelecek yılın yeni başlangıcına hazırlık '
          'olabilir.',
      isVePara:
          'İşte bir dönemin sonu yaklaşabilir: bir projeyi tamamlamak, bir '
          'işten ayrılmak ya da yön değiştirmek gündeme gelebilir. Para '
          'tarafında eski borçları kapatmak ve gereksiz giderleri ayıklamak '
          'için iyi bir yıl. '
          'Yeni bir işe ya da büyük bir maddi karara atılmadan önce yıl sonunu beklemek daha sağlıklı olabilir.',
      niyet:
          "Yılın sorusu: 'Yeni döngüye neyi götürmek istemiyorum?' Bırakmak "
          'istediğin üç şeyi yaz ve yıl boyunca onlarla vedalaşmaya çalış.',
    ),
  };

  /// Kişisel ay (1-9) → ayın lakabı ve iki varyantı.
  static const Map<int, AyTemasi> aylar = <int, AyTemasi>{
    1: AyTemasi(
      lakap: 'Başlangıç ayı',
      varyantlar: <String>[
        'Yeni bir şeye başlamak için enerjinin yükseldiği bir ay. Ertelediğin '
            'bir adımı atmak, bir karar vermek ya da kendine yeni bir hedef '
            'koymak için uygun. İnisiyatif almak bu ay sana kazandırır.',
        'Ayın havası taze başlangıçlardan yana. Kafandaki bir fikri hayata '
            'geçirmek ya da hayatının bir alanında yeni bir sayfa açmak için '
            'cesaretini topla; ilk adım gerisini kolaylaştırır.',
      ],
    ),
    2: AyTemasi(
      lakap: 'Sabır ve iş birliği ayı',
      varyantlar: <String>[
        'Bu ay işler biraz yavaşlayabilir; zorlamak yerine iş birliği yapmak '
            'daha çok kazandırır. İlişkiler, ortaklıklar ve hassas konuşmalar '
            'öne çıkar. Sabrın ve inceliğin en güçlü araçların.',
        'Ayın havası yakınlaşmadan ve uzlaşmadan yana. Birlikte karar almak, '
            'birini dinlemek ya da bir kırgınlığı onarmak için güzel bir '
            'dönem. Duygusal hassasiyetin artabilir; kendine nazik davran.',
      ],
    ),
    3: AyTemasi(
      lakap: 'İfade ve paylaşım ayı',
      varyantlar: <String>[
        'Sosyal hayatın ve yaratıcılığın canlandığı bir ay. Davetlere açık '
            'ol, fikirlerini paylaş, keyif aldığın şeylere zaman ayır. '
            'Sözlerin bu ay her zamankinden etkili.',
        'Ayın havası neşeden ve iletişimden yana. Yazmak, konuşmak, üretmek '
            'ya da yeni insanlarla tanışmak için enerjin yüksek; tek dikkat '
            'noktası, enerjini çok fazla yöne dağıtmamak.',
      ],
    ),
    4: AyTemasi(
      lakap: 'Emek ve düzen ayı',
      varyantlar: <String>[
        'Bu ay odaklanma ve emek ayı. Dağınık işleri toparlamak, bir planı '
            'adım adım ilerletmek ve rutinini güçlendirmek için uygun. Bu ay '
            'verdiğin emek ilerleyen aylarda karşılığını verir.',
        'Ayın havası düzenden ve sabırlı çalışmadan yana. Bütçeni, takvimini '
            'ya da yaşam alanını düzenlemek içini rahatlatır; yorgun '
            'düştüğünde dinlenmeyi de planına eklemeyi unutma.',
      ],
    ),
    5: AyTemasi(
      lakap: 'Değişim ve hareket ayı',
      varyantlar: <String>[
        'Hareketli ve sürprizlere açık bir ay. Plan değişiklikleri, kısa '
            'yolculuklar ya da beklenmedik fırsatlar gündeme gelebilir. Esnek '
            'kaldıkça ay sana yeni kapılar açar.',
        'Ayın havası değişimden ve özgürlükten yana. Rutinin dışına çıkmak, '
            'yeni bir şey denemek ya da farklı bir yol seçmek zihnini '
            'tazeler; yalnızca ani ve büyük kararlarda bir gece beklemek iyi '
            'olur.',
      ],
    ),
    6: AyTemasi(
      lakap: 'Yuva ve sorumluluk ayı',
      varyantlar: <String>[
        'Ev, aile ve yakın ilişkilerin öne çıktığı bir ay. Sevdiklerinle '
            'vakit geçirmek, evinde bir düzenleme yapmak ya da birine destek '
            'olmak seni besler. Sorumlulukları paylaşmayı unutma.',
        'Ayın havası sevgiden ve özenden yana. Bir yakının sana ihtiyaç '
            'duyabilir; desteğin değerli. Başkalarına verdiğin özenin bir '
            'kısmını kendine ayırdığında ay dengeli geçer.',
      ],
    ),
    7: AyTemasi(
      lakap: 'İçe dönüş ayı',
      varyantlar: <String>[
        'Yavaşlama, düşünme ve kendinle baş başa kalma ayı. Bir konuyu '
            'araştırmak, bir şey öğrenmek ya da uzun süredir düşündüğün bir '
            'soruya cevap aramak için uygun. Kalabalıktan çok sessizlik seni '
            'besler.',
        'Ayın havası derinleşmekten ve sezgiden yana. Hızlı sonuçlar yerine '
            'iç netlik arayışı öne çıkar; yazmak, yürüyüş yapmak ya da sessiz '
            'zamanlar ayırmak düşüncelerini berraklaştırır.',
      ],
    ),
    8: AyTemasi(
      lakap: 'Güç ve sonuç ayı',
      varyantlar: <String>[
        'İşin, paranın ve hedeflerin öne çıktığı bir ay. Bir talebini dile '
            'getirmek, önemli bir görüşme yapmak ya da maddi bir kararı '
            'netleştirmek için güçlü bir dönem. Kararlılığın sonuç getirir.',
        'Ayın havası somut sonuçlardan yana. Emeğinin karşılığını istemekten '
            'çekinme; aynı zamanda çok çalışırken dinlenmeyi ve sevdiklerini '
            'ihmal etmemeye özen göster.',
      ],
    ),
    9: AyTemasi(
      lakap: 'Tamamlama ayı',
      varyantlar: <String>[
        'Kapanışların ve arınmanın ayı. Yarım kalan işleri bitirmek, artık '
            'işine yaramayan şeyleri bırakmak ve bir sayfayı kapatmak için '
            'uygun. Bu ay boşalttığın yer, gelecek ayın başlangıçlarına alan '
            'açar.',
        'Ayın havası bırakmaktan ve affetmekten yana. Geçmişle ilgili bir '
            'konu gündeme gelebilir; ona bir nokta koymak seni hafifletir. '
            'Yeni büyük başlangıçları önümüzdeki aya bırakmak daha iyi '
            'olabilir.',
      ],
    ),
  };

  /// Türkçe ay adları (Ocak → Aralık).
  static const List<String> ayAdlari = <String>[
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  // ---- Akış / zorlu aylar ve dönem geçişi ----

  /// Akışta olunan ayların açıklaması (ay listesinden sonra gelir).
  static const String akisAciklamasi =
      'Bu aylarda yılın temposu doğanla aynı yönde akıyor. Önemli adımlarını, '
      'başlangıçlarını ve zor konuşmalarını bu aylara planlamak işini '
      'kolaylaştırabilir.';

  /// Zorlu ayların açıklaması (ay listesinden sonra gelir).
  static const String zorluAciklamasi =
      'Bu aylarda yılın temposu alışık olduğun ritimden farklı. Büyük '
      'kararları aceleye getirmemek, kendine daha fazla alan tanımak ve '
      'planlarına esneklik payı bırakmak iyi olur.';

  /// Yıl içinde yeni bir yaşam dönemine geçiliyorsa gösterilen metin
  /// (ardından yeni dönemin zirve özeti gelir).
  static const String donemGecisiGirisi =
      'Bu yıl doğum gününle birlikte hayatının yeni bir dönemine giriyorsun. '
      'Bir önceki dönemin derslerini tamamlayıp yeni temaya alan açmak, '
      'yılın en önemli işlerinden biri olabilir. Yeni dönemin teması:';

  // ---- Başlıklar ----

  /// Yılın teması bölümü başlığı.
  static String temaBasligi(int yil, String yilLakabi, int kisiselYil) =>
      '$yil · $yilLakabi · Kişisel yıl $kisiselYil';

  /// Dönem geçişi bölümü başlığı.
  static String donemGecisiBasligi(String yasAraligi) =>
      'Yeni bir dönem başlıyor · $yasAraligi';

  /// Fırsatlar bölümü başlığı.
  static const String firsatlarBasligi = 'Yılın fırsatları';

  /// Dikkat bölümü başlığı.
  static const String dikkatBasligi = 'Dikkat etmen gerekenler';

  /// Aşk bölümü başlığı.
  static const String askBasligi = 'Bu yıl aşkta';

  /// İş ve para bölümü başlığı.
  static const String isVeParaBasligi = 'Bu yıl işte ve parada';

  /// Akış ayları bölümü başlığı.
  static const String akisBasligi = 'Akışta olduğun aylar';

  /// Zorlu aylar bölümü başlığı.
  static const String zorluBasligi = 'Zorlanabileceğin aylar';

  /// Niyet bölümü başlığı.
  static const String niyetBasligi = 'Yılın sorusu';

  /// Ay kartı başlığı ("Mart · Emek ve düzen ayı").
  static String ayBasligi(int ay, String lakap) =>
      '${ayAdlari[ay - 1]} · $lakap';

  /// Ay adlarını Türkçe bağlaçla birleştirir: "Mart", "Mart ve Temmuz",
  /// "Ocak, Mart ve Temmuz".
  static String ayListesi(List<int> aylar) {
    final List<String> adlar = <String>[
      for (final int ay in aylar) ayAdlari[ay - 1],
    ];
    if (adlar.length <= 1) {
      return adlar.join();
    }
    return '${adlar.sublist(0, adlar.length - 1).join(', ')} ve ${adlar.last}';
  }
}
