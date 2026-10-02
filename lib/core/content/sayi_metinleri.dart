/// Numeroloji sayılarının kalıcı kişilik metinleri.
///
/// YAZIM REHBERİ (tüm içerik havuzları için geçerlidir):
/// - İkinci tekil, sıcak ve mistik ama gündelik dilde; somut sahneler
///   ("ertelediğin mesaj", "masadaki dağınıklık") soyut övgüden iyidir.
/// - Her karakterde bir güçlü yan ve bir gölge yan birlikte anlatılır;
///   yalnızca övgü güveni düşürür, küçük bir kusur artırır.
/// - İki yönlü cümleler (dışarıdan X, içeride Y) okurun kendini
///   bulmasını sağlar; ama sayının karakterinden kopmaz — aynı sayının
///   bütün bölümleri aynı kişiyi anlatır.
/// - Gelecek kesin dille anlatılmaz ("olacak" yerine "kapı aralanıyor").
/// - Sağlık, para ve hukuk konularında yönlendirici tavsiye YOK
///   (teşhis, ilaç, yatırım ürünü adı geçmez); yasaklı ifade listesi
///   bütünlük testlerindedir.
/// - Cümleler kendi içinde tamdır; başka bölümdeki cümleye gönderme yok.
library;

/// Bir numeroloji sayısının tüm kalıcı metinleri.
class SayiKarakteri {
  /// Tüm alanlarıyla karakter oluşturur.
  const SayiKarakteri({
    required this.lakap,
    required this.anahtarlar,
    required this.oz,
    required this.gucluYanlar,
    required this.golgeYan,
    required this.askta,
    required this.isteVeParada,
    required this.yasamDersi,
    required this.iliskide,
  });

  /// Kısa lakap ("Öncü").
  final String lakap;

  /// Üç anahtar kelime.
  final List<String> anahtarlar;

  /// Özün: karakterin genel anlatımı.
  final String oz;

  /// Güçlü yanlar.
  final String gucluYanlar;

  /// Gölge yan (dikkat edilmesi gereken eğilim).
  final String golgeYan;

  /// Aşkta nasıl biri.
  final String askta;

  /// İş ve para ilişkisi.
  final String isteVeParada;

  /// Yaşam dersi.
  final String yasamDersi;

  /// Uyum ekranı için: ilişkide nasıl biri (üçüncü şahıs değil, kısa).
  final String iliskide;
}

/// Sayı metin havuzları.
abstract final class SayiMetinleri {
  /// Yaşam yolu sayısına göre karakterler (1-9, 11, 22, 33).
  static const Map<int, SayiKarakteri> yasamYolu = <int, SayiKarakteri>{
    1: SayiKarakteri(
      lakap: 'Öncü',
      anahtarlar: <String>['cesaret', 'bağımsızlık', 'başlatma'],
      oz:
          'Yaşam yolu 1 olanlar bir kapının önünde uzun süre bekleyemez. '
          'Sen de çoğu zaman ilk adımı atan, "ben hallederim" diyen tarafsın. '
          'Kalabalık bir masada bile kararın nereye gideceğini sezer, '
          'gerekirse yönü sen çizersin. İçinde sessiz ama sürekli yanan '
          'bir motor var: bir hedefin olmadığında huzursuzlanır, bir hedef '
          'bulduğunda tuhaf biçimde sakinleşirsin.',
      gucluYanlar:
          'Belirsizlik seni dondurmaz; aksine harekete geçirir. '
          'Başkalarının "şimdi olmaz" dediği yerde yol açabilir, yarım kalmış '
          'bir işi tek başına sırtlanabilirsin. Kararlarını savunurken '
          'sesin titremez ve bu, çevrendekilere güven verir. Yeni bir '
          'şeye başlamanın ilk kıvılcımı çoğu zaman senden çıkar.',
      golgeYan:
          'Aynı motor bazen frene basmayı unutur. Başkalarının '
          'yavaşlığına sabrın kısa olabilir, yardım istemeyi zayıflık '
          'sanabilirsin. "Ben yaparım" dediğin her iş, zamanla yalnız '
          'taşıdığın bir yüke dönüşebilir. Haklı olduğunu bildiğin anlarda '
          'bile bir kez dinlemek, sandığından çok kapı açar.',
      askta:
          'Aşkta ilk hamleyi yapmaktan çekinmezsin; ilgini belli eder, '
          'tutkuyla bağlanırsın. Ama kendine ait bir alanın kalmadığında '
          'boğulmuş hissedersin. Seni en çok, hayranlık duyduğun ve '
          'aynı zamanda sana nefes aldıran biri mutlu eder. Kırıldığında '
          'bunu göstermek yerine susmayı seçebilirsin.',
      isteVeParada:
          'Talimat beklemek yerine inisiyatif alabildiğin '
          'işlerde parlarsın: yöneticilik, kendi işini kurmak ya da bir '
          'projeyi sıfırdan ayağa kaldırmak. Parayla ilişkin cesurdur; '
          'fırsatı erken görürsün. Tek tuzağın, hızın hesabın önüne '
          'geçtiği anlardır.',
      yasamDersi:
          'Senin dersin, liderliğin yalnızlık demek olmadığını '
          'öğrenmek. Başkalarına yer açtığında gücün azalmaz, çoğalır. '
          'En büyük işlerini tek başına değil, sana güvenen birkaç kişiyle '
          'yan yana yürürken başaracaksın.',
      iliskide:
          'İlişkide yön veren, ilk adımı atan ve tutkulu olan taraf; '
          'kendine ait bir nefes alanı ister.',
    ),
    2: SayiKarakteri(
      lakap: 'Arabulucu',
      anahtarlar: <String>['uyum', 'sezgi', 'incelik'],
      oz:
          'Yaşam yolu 2 olanlar bir odaya girdiğinde havayı ilk hisseden '
          'kişidir. Sen de kimin gergin, kimin kırgın olduğunu çoğu zaman '
          'söylenmeden anlarsın. Sesin yüksek olmayabilir ama varlığın '
          'ortamı yumuşatır. İnsanlar dertlerini sana anlatır; sen de '
          'dinlerken aslında kendi duygularını da tartarsın.',
      gucluYanlar:
          'Sabrın ve inceliğin, sert geçebilecek konuşmaları '
          'bile yumuşatır. Ayrıntıyı görür, iki uç arasında köprü kurarsın. '
          'Ekip işinde görünmeyen yapıştırıcı çoğu zaman sensin. Sezgilerin '
          'güçlüdür; "bir şey doğru değil" dediğinde genellikle haklı '
          'çıkarsın.',
      golgeYan:
          'Herkes mutlu olsun diye kendi isteğini sona bırakabilirsin. '
          'Karar anında uzun uzun tartmak, fırsatın geçmesine yol açabilir. '
          'Küçük bir eleştiriyi günlerce içinde taşıyabilirsin. "Hayır" '
          'demek sana ağır gelir; ama söylenmeyen her hayır, içinde sessiz '
          'bir yorgunluğa dönüşür.',
      askta:
          'Aşkta sadık, romantik ve özenlisin. Küçük jestleri hatırlar, '
          'sevdiğinin ruh halini ondan önce fark edersin. Seni en çok '
          'duygularını ciddiye alan biri mutlu eder. Tartışmadan kaçmak '
          'için susmak yerine, istediğini nazikçe söylemek ilişkini '
          'derinleştirir.',
      isteVeParada:
          'İşbirliği, danışmanlık, arabuluculuk, tasarım ve '
          'ayrıntı isteyen işler sana yakışır. Ön planda olmasan da işin '
          'aksamamasını sağlayan kişi olursun. Parada temkinlisin; ani '
          'kararlar yerine güvenli ve düzenli ilerlemeyi seçersin.',
      yasamDersi:
          'Senin dersin, kendi sesinin de masada yeri olduğunu '
          'kabul etmek. Uyum, kendini silmek değil; senin de dahil olduğun '
          'bir denge kurmaktır. İstediğini söylediğin gün, ilişkilerin '
          'daha az yorucu ve daha çok besleyici olacak.',
      iliskide:
          'İlişkide özenli, sezgisi güçlü ve uyum arayan taraf; '
          'duygularının duyulmasına ihtiyaç duyar.',
    ),
    3: SayiKarakteri(
      lakap: 'Anlatıcı',
      anahtarlar: <String>['ifade', 'neşe', 'yaratıcılık'],
      oz:
          'Yaşam yolu 3 olanlar hayatı anlatılacak bir hikâye gibi yaşar. '
          'Sen de bir olayı aktarırken insanları güldürmeyi, merak '
          'uyandırmayı bilirsin. Kafanda aynı anda birkaç fikir döner; '
          'bazen hangisine başlayacağını seçmek, işin kendisinden zor '
          'gelir. Dışarıdan neşeli görünürken içeride düşündüğünden daha '
          'hassas bir yerin var.',
      gucluYanlar:
          'Kelimelerle, renklerle ya da sesle kendini ifade etme '
          'yeteneğin güçlü. Ortamın enerjisini yükseltir, sıkıcı bir işi '
          'bile oyuna çevirebilirsin. İnsanlarla kolay bağ kurar, fikirleri '
          'çekici hale getirirsin. Zor bir günde bile espri bulabilmen, '
          'hem sana hem çevrene iyi gelir.',
      golgeYan:
          'Enerjin dağıldığında çok şeye başlayıp azını bitirebilirsin. '
          'Eleştiri, göründüğünden daha derin yaralayabilir seni. Canın '
          'sıkıldığında ağır konuları şakayla geçiştirme eğilimin var. '
          'Tek bir işe odaklandığın dönemlerde, yeteneğinin gerçek '
          'boyutunu görürsün.',
      askta:
          'Aşkta eğlenceli, sıcak ve cömertsin; sevdiğini güldürmek '
          'sana keyif verir. İlgi görmek ve beğenildiğini duymak senin '
          'için önemlidir. Monotonluk seni soğutur; küçük sürprizler ve '
          'birlikte yeni deneyimler bağını canlı tutar.',
      isteVeParada:
          'Yazı, tasarım, sahne, iletişim, satış ve eğitim gibi '
          'kendini ifade edebildiğin alanlarda parlarsın. Parayı kazanmakta '
          'yaratıcı, harcamakta cömertsin. Kazancının bir kısmını "sonraki '
          'fikrin" için ayırmak seni rahatlatır.',
      yasamDersi:
          'Senin dersin, yeteneğini dağıtmadan derinleştirmek. '
          'Her şeye biraz dokunmak yerine birkaç şeye gerçekten sahip '
          'çıktığında, sesin çok daha uzağa ulaşacak. Neşen bir kaçış değil, '
          'bir güç olduğunda en parlak halinle görünürsün.',
      iliskide:
          'İlişkide neşe ve renk getiren, ilgi ve takdir bekleyen; '
          'monotonluktan sıkılan taraf.',
    ),
    4: SayiKarakteri(
      lakap: 'Kurucu',
      anahtarlar: <String>['düzen', 'emek', 'güvenilirlik'],
      oz:
          'Yaşam yolu 4 olanlar sağlam zemine basmadan adım atmayı sevmez. '
          'Sen de bir işin nasıl yapılacağını kafanda adım adım kurar, sonra '
          'sabırla uygularsın. Söz verdiğinde tutarsın; bu yüzden insanlar '
          'zor bir anda ilk sana döner. Dışarıdan ciddi görünebilirsin ama '
          'yakınların, düzenin altındaki sıcaklığını bilir.',
      gucluYanlar:
          'Disiplinin ve dayanıklılığın başkalarının vazgeçtiği '
          'yerde seni yolda tutar. Karmaşayı sisteme dönüştürür, soyut '
          'fikirleri uygulanabilir planlara çevirirsin. Güvenilirliğin, '
          'yıllar içinde biriken en değerli sermayendir. Pratik zekân '
          'krizlerde sakin kalmanı sağlar.',
      golgeYan:
          'Planın dışına çıkan her şey seni gerebilir. "Doğru yol '
          'bu" diye düşündüğünde esnemek zorlaşır; bazen kontrolü bırakmak '
          'yerine daha çok sıkarsın. Kendine de başkalarına da yüksek '
          'standart koyarsın. Mola vermeyi hak edilmesi gereken bir ödül '
          'gibi görmek, yorgunluğunu biriktirebilir.',
      askta:
          'Aşkta sadık, istikrarlı ve korumacısın. Sevgini büyük '
          'sözlerden çok, yaptıklarınla gösterirsin: tamir edilen bir '
          'eşya, hatırlanan bir randevu. Güven duymadan tam açılmazsın. '
          'Arada bir planı bozup kendiliğinden bir şey yapmak, ilişkine '
          'beklenmedik bir tat katar.',
      isteVeParada:
          'Planlama, mühendislik, finans, yönetim, zanaat ve '
          'sistem kurmayı gerektiren işlerde güçlüsün. Parayı adım adım, '
          'emekle büyütmeyi seversin. Senin için en iyi kazanç, uzun '
          'vadede güven veren kazançtır.',
      yasamDersi:
          'Senin dersin, esnekliğin düzeni bozmadığını görmek. '
          'Rüzgâra göre eğilen ağaç kırılmaz. Planına küçük boşluklar '
          'bıraktığında hem hayat hem sen daha rahat nefes alacaksınız.',
      iliskide:
          'İlişkide güven veren, sözünü tutan ve istikrar arayan '
          'taraf; sevgisini emekle gösterir.',
    ),
    5: SayiKarakteri(
      lakap: 'Gezgin',
      anahtarlar: <String>['özgürlük', 'merak', 'değişim'],
      oz:
          'Yaşam yolu 5 olanlar aynı rotada uzun süre yürümekten sıkılır. '
          'Sen de yeni bir yer, yeni bir fikir ya da yeni bir insan '
          'karşısında canlanırsın. Hayatı deneyimleyerek öğrenirsin; '
          'başkalarının kitaptan okuduğunu sen yaşayarak bilirsin. İçinde '
          'hem maceraperest hem de kendine bir yuva arayan iki ses var.',
      gucluYanlar:
          'Uyum yeteneğin olağanüstü: plan değiştiğinde en hızlı '
          'toparlanan sensin. Meraklısın, çok yönlüsün, insanlarla kolay '
          'konuşursun. Değişimden korkmaman, başkalarının kaçırdığı '
          'fırsatları görmeni sağlar. Enerjin bulaşıcıdır.',
      golgeYan:
          'Sıkıldığında bir işi, bir yeri ya da bir sohbeti yarıda '
          'bırakabilirsin. Özgürlük isteğin bazen sorumluluktan kaçmak '
          'gibi okunabilir. Aşırıya kaçmaya — fazla çalışmaya, fazla '
          'harcamaya, fazla koşturmaya — yatkınsın. Tek bir şeye bağlı '
          'kalmanın da bir tür özgürlük olduğunu keşfetmek sana iyi gelir.',
      askta:
          'Aşkta heyecanlı, çekici ve spontanesin. Birlikte yeni şeyler '
          'deneyebildiğin biriyle parlarsın. Kısıtlandığını hissettiğinde '
          'geri çekilirsin; güvenildiğini hissettiğinde ise şaşırtıcı '
          'derecede sadık olabilirsin.',
      isteVeParada:
          'Hareket, iletişim ve çeşitlilik içeren işler sana göre: '
          'seyahat, medya, satış, pazarlama, serbest çalışma. Kazancın '
          'dalgalı olabilir; iyi dönemlerde bir kenara ayırdığın pay, '
          'özgürlüğünün en sağlam güvencesidir.',
      yasamDersi:
          'Senin dersin, özgürlüğü sorumlulukla dengelemek. '
          'Kaçmak için değil, keşfetmek için hareket ettiğinde her yolculuk '
          'seni biraz daha kendine yaklaştıracak.',
      iliskide:
          'İlişkide heyecan ve yenilik getiren, alan tanındığında '
          'sadakatiyle şaşırtan taraf.',
    ),
    6: SayiKarakteri(
      lakap: 'Koruyucu',
      anahtarlar: <String>['şefkat', 'sorumluluk', 'yuva'],
      oz:
          'Yaşam yolu 6 olanlar sevdikleri için bir sığınak kurmak ister. '
          'Sen de birinin eksiğini fark ettiğinde, istemese bile tamamlamaya '
          'koşarsın. Güzelliğe, düzene ve adalete duyarlısın; bir ortamın '
          'huzursuz olması seni doğrudan etkiler. İnsanlar yanında kendini '
          'güvende hisseder.',
      gucluYanlar:
          'Şefkatin ve sorumluluk duygun, çevrendekilere dayanak '
          'olur. Estetik bir gözün var: bir odayı, bir sofrayı, bir günü '
          'güzelleştirebilirsin. Dinlemeyi ve öğüt vermeyi bilirsin. '
          'Söz konusu sevdiklerin olduğunda cesaretin artar.',
      golgeYan:
          'Herkesi korumaya çalışırken kendi ihtiyaçlarını unutabilirsin. '
          'Yardımın bazen karşı tarafın istemediği bir kontrole dönüşebilir. '
          'Mükemmeliyetçilik ve "bensiz olmaz" düşüncesi yorgunluğunu '
          'artırır. Teşekkür görmediğinde içten içe kırılırsın.',
      askta:
          'Aşkta bağlı, sıcak ve yuva kurucusun. Sevdiğine özen '
          'göstermek senin dilindir. Aynı özeni geri görmek istersin; '
          'dengesiz ilişkiler seni hızla tüketir. Sevginin karşılığını '
          'açıkça istemek, bencillik değil sağlıklı bir sınırdır.',
      isteVeParada:
          'Eğitim, danışmanlık, tasarım, bakım, insan kaynakları '
          've topluma hizmet eden işlerde anlam bulursun. Parayı güven ve '
          'huzur için kazanırsın; sevdiklerine harcamak sana keyif verir, '
          'kendine ayırmayı ise sık unutursun.',
      yasamDersi:
          'Senin dersin, sınır koymanın da bir sevgi biçimi olduğunu '
          'öğrenmek. Önce kendi fincanını doldurduğunda, başkalarına '
          'verdiklerin tükenmeden akmaya devam edecek.',
      iliskide:
          'İlişkide şefkatli, yuva kuran ve özen gösteren; aynı özeni '
          'geri görmek isteyen taraf.',
    ),
    7: SayiKarakteri(
      lakap: 'Arayıcı',
      anahtarlar: <String>['iç görü', 'derinlik', 'sorgu'],
      oz:
          'Yaşam yolu 7 olanlar yüzeyde kalan cevaplarla yetinmez. Sen de '
          'bir konunun "neden"ini bulmadan rahat etmezsin. Kalabalıkta '
          'bulunabilirsin ama asıl yenilenmen yalnız kaldığında olur. '
          'Dışarıdan mesafeli görünebilirsin; güvendiğin birkaç kişi ise '
          'içindeki derin ve sıcak dünyayı bilir.',
      gucluYanlar:
          'Analitik zekân ve sezgin bir arada çalışır: ayrıntıyı '
          'inceler, büyük resmi sezersin. Kolay kandırılmazsın; sahte olanı '
          'hissedersin. Tek başına derinleşebilme yeteneğin, uzmanlaşmanı '
          'kolaylaştırır. Sessizliğin içinde çok şey biriktirirsin.',
      golgeYan:
          'Duygularını kafanda çözmeye çalışırken paylaşmayı '
          'erteleyebilirsin. Şüphecilik seni korur ama bazen güzel bir '
          'fırsata da mesafe koydurur. Yalnızlık isteğin, istemeden '
          'yalnızlaşmaya dönebilir. Her şeyi anlamadan karar vermemek, '
          'bazen hiç karar vermemek anlamına gelir.',
      askta:
          'Aşkta yavaş açılır, derin bağlanırsın. Zihinsel bir yakınlık '
          'hissetmeden kalbini tam vermezsin. Seni en çok, sessizliğini '
          'kişisel algılamayan ve merakını paylaşan biri mutlu eder. '
          'Hissettiğini söylediğin anlar, ilişkini beklenmedik ölçüde '
          'güçlendirir.',
      isteVeParada:
          'Araştırma, bilim, teknoloji, yazılım, psikoloji, '
          'felsefe ve uzmanlık gerektiren işlerde güçlüsün. Parada '
          'dikkatlisin; bilmediğin bir şeye kolay girmezsin. Bilgin '
          'derinleştikçe kazancının da sessizce büyüdüğünü görürsün.',
      yasamDersi:
          'Senin dersin, güvenmek ve paylaşmak. Her cevabı tek '
          'başına bulmak zorunda değilsin. Kalbini birine açtığın gün, '
          'aradığın anlamın bir kısmının zaten yanında olduğunu fark '
          'edeceksin.',
      iliskide:
          'İlişkide derin, sadık ama yavaş açılan; zihinsel yakınlık '
          've kendine ait sessizlik isteyen taraf.',
    ),
    8: SayiKarakteri(
      lakap: 'Yönetici',
      anahtarlar: <String>['güç', 'hedef', 'bereket'],
      oz:
          'Yaşam yolu 8 olanlar hayatın somut sonuçlarıyla ilgilenir. Sen '
          'de bir işin sadece fikrinde değil, sonucunda da görünmek '
          'istersin. Güç, sorumluluk ve maddi dünya seni hem cezbeder hem '
          'sınar. Dışarıdan kendinden emin görünürken, içinde "yeterince '
          'başardım mı?" diye soran bir ses de taşırsın.',
      gucluYanlar:
          'Organize etme, yönetme ve büyük resmi görme yeteneğin '
          'güçlü. Zorluk karşısında dayanıklısın; düştüğün yerden daha '
          'güçlü kalkarsın. İnsanların potansiyelini fark eder, doğru '
          'kişiyi doğru işe koyarsın. Emeğinin karşılığını istemekten '
          'çekinmezsin.',
      golgeYan:
          'Hedefe kilitlendiğinde dinlenmeyi, sevdiklerini ya da '
          'kendi duygularını ikinci sıraya itebilirsin. Kontrolü bırakmak '
          'zor gelir. Başarıyı yalnızca rakamlarla ölçmek, elde ettiğinden '
          'keyif almanı engelleyebilir. Yumuşak olmak zayıf olmak '
          'değildir.',
      askta:
          'Aşkta koruyucu, cömert ve güçlü bir partnersin. Sevdiğinin '
          'güvende olmasını istersin. Duygularını göstermek yerine sorun '
          'çözmeyi seçebilirsin; bazen karşı taraf yalnızca dinlenmek ister. '
          'Kırılganlığını gösterdiğin anlar ilişkini derinleştirir.',
      isteVeParada:
          'Yönetim, girişimcilik, finans, hukuk, gayrimenkul ve '
          'büyük organizasyonlarda doğal olarak öne çıkarsın. Parayla '
          'ilişkin güçlüdür ama inişli çıkışlı dönemler de yaşayabilirsin. '
          'Kazandığını paylaşmak, bereketin dolaşımını hızlandırır.',
      yasamDersi:
          'Senin dersin, gücü dengeyle kullanmak. Maddi başarı ile '
          'iç huzur arasında seçim yapmak zorunda değilsin. Başardıklarını '
          'sevdiklerinle paylaştığında, kazancın gerçek anlamını bulacaksın.',
      iliskide:
          'İlişkide koruyucu, cömert ve kararlı; duygularını çoğu zaman '
          'eylemle gösteren taraf.',
    ),
    9: SayiKarakteri(
      lakap: 'Bilge Kalp',
      anahtarlar: <String>['şefkat', 'idealizm', 'tamamlama'],
      oz:
          'Yaşam yolu 9 olanlar dünyanın yükünü biraz omzunda hisseder. '
          'Sen de haksızlık karşısında sessiz kalmakta zorlanır, yabancı '
          'birinin derdine bile ortak olursun. Geniş bir kalbin ve yaşından '
          'olgun bir bakışın var. Çoğu insan senin yanında anlaşıldığını '
          'hisseder.',
      gucluYanlar:
          'Şefkatin, hoşgörün ve farklı insanları anlama yeteneğin '
          'güçlü. Sanatla, anlamla ve iyilikle ilgili konularda ilham '
          'verirsin. Bir şeyi bitirmeyi, kapatmayı ve yeni bir sayfaya '
          'hazırlanmayı başkalarından iyi bilirsin. Cömertliğin karşılık '
          'beklemez.',
      golgeYan:
          'Geçmişi, eski ilişkileri ya da hayal kırıklıklarını '
          'bırakmak sana zor gelebilir. Herkese yardım ederken kendini '
          'ihmal edebilirsin. İdealin ile gerçek arasındaki mesafe seni '
          'zaman zaman kırgın ve yorgun bırakır. Bazen "yeter" demek de '
          'bir iyiliktir.',
      askta:
          'Aşkta koşulsuz, romantik ve derinsin. Sevdiğinin en iyi '
          'halini görür, onu olduğundan büyük sevebilirsin. Aynı derinliği '
          'görmediğinde sessizce uzaklaşırsın. Beklentilerini söylemek, '
          'kırılmadan önce seni korur.',
      isteVeParada:
          'Sanat, eğitim, sosyal sorumluluk, danışmanlık, rehberlik '
          've insanlara dokunan işlerde anlam bulursun. Parayı bir amaç için '
          'kazanmak seni motive eder. Verirken kendine de pay ayırmak, '
          'uzun vadede daha çok vermeni sağlar.',
      yasamDersi:
          'Senin dersin, bırakmak. Kapanan her kapı bir kayıp değil, '
          'bir tamamlanmadır. Geçmişe teşekkür edip ellerini boşalttığında, '
          'yeni başlangıçlar senin için daha kolay gelecek.',
      iliskide:
          'İlişkide derin, affedici ve koşulsuz seven; aynı derinliği '
          'görmek isteyen taraf.',
    ),
    11: SayiKarakteri(
      lakap: 'Sezgici (Usta Sayı)',
      anahtarlar: <String>['ilham', 'sezgi', 'vizyon'],
      oz:
          'Yaşam yolu 11 bir usta sayıdır: 2\'nin inceliğini çok daha '
          'yoğun bir sezgiyle taşır. Sen de bazen nedenini açıklayamadığın '
          'ama sonradan doğru çıkan hisler yaşarsın. İnsanlar yanında '
          'ilham alır; sen ise bu yoğunluğu taşırken zaman zaman yorulursun. '
          'İçinde hem çok hassas hem de çok güçlü bir taraf var.',
      gucluYanlar:
          'Sezgin, yaratıcılığın ve başkalarını ilhamla harekete '
          'geçirme yeteneğin güçlü. Görünmeyen bağlantıları görür, büyük '
          'bir fikri başkalarına hissettirebilirsin. Empatin derindir; '
          'birinin söylemediğini duyarsın. Doğru zamanda söylediğin tek '
          'cümle, birinin yönünü değiştirebilir.',
      golgeYan:
          'Yüksek hassasiyetin, kaygıya ve kendinden şüpheye dönüşebilir. '
          'İdealinle kendini kıyaslayıp "yeterli değilim" hissine '
          'kapılabilirsin. Uyaran fazlası seni hızla tüketir. Sezgini '
          'somut adımlarla desteklemediğinde, fikirlerin havada kalabilir.',
      askta:
          'Aşkta ruhsal bir bağ ararsın; yüzeysel ilişkiler seni hızla '
          'boşaltır. Çok sezgisel bir partnersin, sevdiğinin iç dünyasını '
          'okursun. Kendi ihtiyaçlarını da o kadar açık dile getirdiğinde, '
          'aradığın derinliği bulursun.',
      isteVeParada:
          'İlham veren roller sana göre: eğitim, sanat, danışmanlık, '
          'rehberlik, yaratıcı liderlik. Parayla ilişkin dalgalı olabilir; '
          'sezgine güvendiğin kadar, sade bir bütçeye de güvenmek seni '
          'rahatlatır.',
      yasamDersi:
          'Senin dersin, sezgine güvenirken ayaklarını yere basmak. '
          'Vizyonun büyüktür; onu küçük ve somut adımlara böldüğünde, '
          'ilhamın başkalarının hayatında gerçek bir iz bırakacak.',
      iliskide:
          'İlişkide sezgisi çok güçlü, ruhsal bağ arayan ve hassas '
          'taraf; anlaşılmaya ihtiyaç duyar.',
    ),
    22: SayiKarakteri(
      lakap: 'Usta Kurucu (Usta Sayı)',
      anahtarlar: <String>['vizyon', 'inşa', 'kalıcılık'],
      oz:
          'Yaşam yolu 22 bir usta sayıdır: 4\'ün sağlamlığını büyük bir '
          'vizyonla birleştirir. Sen de hayal kurarken bile "bu nasıl '
          'yapılır?" diye düşünürsün. Küçük hedefler seni tatmin etmez; '
          'kalıcı bir şey bırakmak istersin. Bu büyüklük bazen içinde '
          'sessiz bir baskı olarak da hissedilir.',
      gucluYanlar:
          'Büyük fikirleri uygulanabilir planlara çevirme yeteneğin '
          'nadir bulunur. Hem vizyoner hem pratiksin. İnsanları ortak bir '
          'amaç etrafında toplayabilir, uzun soluklu işlerde dayanıklılık '
          'gösterirsin. Sabrın ve disiplinin, hayalinin altındaki temeldir.',
      golgeYan:
          'Kendine yüklediğin beklenti ağır gelebilir; "her şey benim '
          'omzumda" hissi yorgunluğunu artırır. Mükemmel olmayacaksa hiç '
          'başlamamak gibi bir tuzağa düşebilirsin. Kontrolü paylaşmak, '
          'büyük işlerin tek başına değil ekiple yapıldığını hatırlatır.',
      askta:
          'Aşkta güvenilir, sadık ve ortak hedefler kurmayı seven bir '
          'partnersin. Birlikte bir gelecek inşa edebildiğin biriyle '
          'huzur bulursun. İş yoğunluğunda sevgini ertelememek, ilişkinin '
          'temelini sağlam tutar.',
      isteVeParada:
          'Büyük projeler, mimari, mühendislik, kurumsal yönetim, '
          'toplumsal girişimler ve kalıcı yapılar kurmak sana göre. Parayı '
          'bir araç olarak görürsün; uzun vadeli ve sağlam planlarla '
          'büyütmeyi tercih edersin.',
      yasamDersi:
          'Senin dersin, büyük hayali küçük adımlara bölmek ve '
          'yolculuğun kendisine de değer vermek. Bugün koyduğun tek taş, '
          'yarın kurulacak yapının vazgeçilmez parçasıdır.',
      iliskide:
          'İlişkide güven veren, ortak gelecek kurmak isteyen ve '
          'sorumluluk alan taraf.',
    ),
    33: SayiKarakteri(
      lakap: 'Usta Öğretmen (Usta Sayı)',
      anahtarlar: <String>['koşulsuz sevgi', 'rehberlik', 'fedakârlık'],
      oz:
          'Yaşam yolu 33 bir usta sayıdır: 6\'nın şefkatini çok daha geniş '
          'bir çevreye yayar. Sen de insanların yükünü hafifletmeye, onlara '
          'yol göstermeye doğal bir çekim duyarsın. Yanında olanlar kendini '
          'kabul edilmiş hisseder. Bu yoğun verme isteği, kendine ayırdığın '
          'zamanı kolayca yutabilir.',
      gucluYanlar:
          'Koşulsuz şefkatin, sabrın ve öğretme yeteneğin güçlü. '
          'Zor bir durumda insanları sakinleştirir, onlara umut verirsin. '
          'Sözlerin iyileştirici bir etki bırakır. Güzelliği ve anlamı '
          'birleştiren bir bakışın var.',
      golgeYan:
          'Herkesin sorununu kendi sorumluluğun gibi görebilirsin. '
          'Kendini feda etmek, zamanla kırgınlık ve tükenmişlik biriktirir. '
          'Başkalarından da aynı fedakârlığı beklemek hayal kırıklığı '
          'yaratabilir. Yardım etmemek bazen karşındakinin büyümesine '
          'alan açar.',
      askta:
          'Aşkta derin, fedakâr ve besleyicisin. Sevdiğinin gelişimini '
          'desteklemek sana mutluluk verir. Kendi ihtiyaçlarını da '
          'ilişkinin merkezine koyduğunda, verdiğin sevgi tükenmeden '
          'çoğalır.',
      isteVeParada:
          'Öğretmenlik, rehberlik, danışmanlık, sanat ve topluma '
          'hizmet eden alanlarda anlam bulursun. Para senin için bir hedef '
          'değil, iyilik yapabilmenin aracıdır; kendine ayırdığın payı '
          'suçluluk duymadan korumak önemlidir.',
      yasamDersi:
          'Senin dersin, önce kendine şefkat göstermek. Kendi '
          'ışığını koruduğunda, yol gösterdiğin insanlar da o ışıkta '
          'daha net görecek.',
      iliskide:
          'İlişkide fedakâr, besleyici ve rehberlik eden; kendi '
          'ihtiyaçlarını unutmaya yatkın taraf.',
    ),
  };

  /// Ruh sayısına göre "içindeki ses" metinleri.
  static const Map<int, String> ruhSayisi = <int, String>{
    1:
        'Ruh sayın 1: İçinde, kimseye danışmadan kendi yolunu çizme isteği '
        'var. En derinde, kendi başardığın bir şeyle anılmayı istersin. '
        'Başkalarının onayı hoşuna gitse de asıl huzuru "bunu ben yaptım" '
        'dediğin anda bulursun.',
    2:
        'Ruh sayın 2: İçinde, sevilmek ve bir bütünün parçası olmak isteyen '
        'yumuşak bir ses var. En derinde huzur, anlaşıldığını hissettiğin '
        'bir yakınlıktır. Kavga değil uyum ararsın; ama bu uyumun içinde '
        'senin sesinin de duyulmasına ihtiyacın var.',
    3:
        'Ruh sayın 3: İçinde anlatılmayı bekleyen hikâyeler, çizilmeyi '
        'bekleyen renkler var. En derinde, kendini özgürce ifade ettiğin '
        'anlarda canlı hissedersin. Susturulmak ya da görmezden gelinmek '
        'seni en çok yoran şeydir.',
    4:
        'Ruh sayın 4: İçinde güvenli bir zemine basma isteği var. En derinde, '
        'emeğinin kalıcı bir şeye dönüştüğünü görmek seni doyurur. '
        'Belirsizlik seni rahatsız eder; düzen ise içindeki sesi sakinleştirir.',
    5:
        'Ruh sayın 5: İçinde kapıları açık tutmak isteyen bir ses var. En '
        'derinde, seçme özgürlüğün olduğunu bilmek sana nefes aldırır. '
        'Kısıtlandığını hissettiğinde huzursuzlanır, yeni bir deneyimle '
        'yeniden canlanırsın.',
    6:
        'Ruh sayın 6: İçinde sevdiklerini güvende görme isteği var. En '
        'derinde huzur, etrafındakilerin iyi olduğunu bildiğin bir akşamdır. '
        'Sevgi vermek sana doğal gelir; almayı öğrenmek ise içindeki sesin '
        'asıl ihtiyacıdır.',
    7:
        'Ruh sayın 7: İçinde anlamı arayan sessiz bir ses var. En derinde, '
        'bir konuyu gerçekten kavradığın anın dinginliğini ararsın. '
        'Kalabalık seni yorar; yalnız geçen bir saat ise pusulanı yeniden '
        'ayarlar.',
    8:
        'Ruh sayın 8: İçinde bir iz bırakma ve güç sahibi olma isteği var. '
        'En derinde, kendi hayatının kontrolünün sende olduğunu bilmek '
        'seni güvende hissettirir. Başarı senin için bir sonuç değil, bir '
        'özgürlük biçimidir.',
    9:
        'Ruh sayın 9: İçinde dünyayı biraz daha iyi bir yer yapma isteği '
        'var. En derinde, bir başkasının hayatına dokunduğunu bilmek seni '
        'doyurur. Haksızlık seni içten sarsar; iyilik ise en hızlı '
        'toparlanma yolundur.',
    11:
        'Ruh sayın 11 (usta sayı): İçinde ilhamla konuşan, çok ince bir '
        'ses var. En derinde, hislerinin boşuna olmadığını, bir anlamı '
        'olduğunu bilmek istersin. Sezgine güvendiğin anlar, en çok '
        'kendin olduğun anlardır.',
    22:
        'Ruh sayın 22 (usta sayı): İçinde büyük ve kalıcı bir şey inşa etme '
        'isteği var. En derinde, hayallerinin gerçek dünyada karşılık '
        'bulduğunu görmek seni doyurur. Küçük düşünmek içindeki sese dar '
        'gelir.',
    33:
        'Ruh sayın 33 (usta sayı): İçinde koşulsuz şefkatle dolu bir ses '
        'var. En derinde, sevginin birini iyileştirdiğini görmek sana '
        'anlam verir. Kendine de aynı şefkati gösterdiğinde bu ses daha '
        'berrak duyulur.',
  };

  /// İsim (Kader/İfade) sayısına göre "dünyaya yansıman" metinleri.
  static const Map<int, String> isimSayisi = <int, String>{
    1:
        'İsim sayın 1: Dünyaya kararlı ve bağımsız biri olarak yansırsın. '
        'İnsanlar senden yön, cesaret ve ilk adım bekler. Adının titreşimi, '
        'yeni şeyler başlatma sorumluluğunu omzuna koyar.',
    2:
        'İsim sayın 2: Dünyaya nazik, güvenilir ve uzlaştırıcı biri olarak '
        'yansırsın. İnsanlar senden anlayış ve denge bekler. Görünmeyen '
        'emeklerin, çevrendeki uyumun temelidir.',
    3:
        'İsim sayın 3: Dünyaya neşeli, konuşkan ve yaratıcı biri olarak '
        'yansırsın. İnsanlar senden renk, fikir ve hafiflik bekler. '
        'Kelimelerin başkalarının gününü değiştirebilir.',
    4:
        'İsim sayın 4: Dünyaya sağlam, çalışkan ve güvenilir biri olarak '
        'yansırsın. İnsanlar senden plan ve süreklilik bekler. Sözün, '
        'imzan kadar değerlidir.',
    5:
        'İsim sayın 5: Dünyaya hareketli, meraklı ve çok yönlü biri olarak '
        'yansırsın. İnsanlar senden yenilik ve cesur fikirler bekler. '
        'Değişimin öncüsü olarak görülürsün.',
    6:
        'İsim sayın 6: Dünyaya şefkatli, sorumlu ve estetik biri olarak '
        'yansırsın. İnsanlar senden destek ve huzur bekler. Bulunduğun '
        'yeri güzelleştirme gücün var.',
    7:
        'İsim sayın 7: Dünyaya derin, bilgili ve biraz gizemli biri olarak '
        'yansırsın. İnsanlar senden analiz ve doğru soruyu bekler. '
        'Söylediklerin az ama akılda kalıcıdır.',
    8:
        'İsim sayın 8: Dünyaya güçlü, sonuç odaklı ve otoriter biri olarak '
        'yansırsın. İnsanlar senden yönetim ve kararlılık bekler. Başardığın '
        'işler adını kendiliğinden duyurur.',
    9:
        'İsim sayın 9: Dünyaya cömert, hoşgörülü ve ilham veren biri olarak '
        'yansırsın. İnsanlar senden anlayış ve geniş bir bakış bekler. '
        'Etkin, tanıdığın çevrenin çok ötesine uzanabilir.',
    11:
        'İsim sayın 11 (usta sayı): Dünyaya ilham veren ve sezgisi güçlü '
        'biri olarak yansırsın. İnsanlar senden vizyon ve umut bekler. Bu '
        'beklenti bazen ağır gelse de sana verilmiş bir yetenektir.',
    22:
        'İsim sayın 22 (usta sayı): Dünyaya büyük işler başarabilecek, '
        'sağlam bir kurucu olarak yansırsın. İnsanlar senden kalıcı ve '
        'somut sonuçlar bekler.',
    33:
        'İsim sayın 33 (usta sayı): Dünyaya şefkatli bir rehber olarak '
        'yansırsın. İnsanlar yanında öğrenir, büyür ve teselli bulur.',
  };

  /// Kişilik sayısına göre "ilk izlenim" metinleri.
  static const Map<int, String> kisilikSayisi = <int, String>{
    1: 'Kişilik sayın 1: İlk izlenimde kendinden emin ve kararlı görünürsün.',
    2: 'Kişilik sayın 2: İlk izlenimde sakin, nazik ve ulaşılabilir görünürsün.',
    3: 'Kişilik sayın 3: İlk izlenimde sıcak, esprili ve çekici görünürsün.',
    4: 'Kişilik sayın 4: İlk izlenimde ciddi, düzenli ve güvenilir görünürsün.',
    5: 'Kişilik sayın 5: İlk izlenimde enerjik, rahat ve meraklı görünürsün.',
    6: 'Kişilik sayın 6: İlk izlenimde şefkatli, zarif ve güven veren görünürsün.',
    7: 'Kişilik sayın 7: İlk izlenimde mesafeli, derin ve gizemli görünürsün.',
    8: 'Kişilik sayın 8: İlk izlenimde güçlü, iddialı ve profesyonel görünürsün.',
    9: 'Kişilik sayın 9: İlk izlenimde olgun, anlayışlı ve karizmatik görünürsün.',
    11: 'Kişilik sayın 11: İlk izlenimde farklı, ilham veren ve hassas görünürsün.',
    22: 'Kişilik sayın 22: İlk izlenimde ağırbaşlı, yetkin ve güvenilir görünürsün.',
    33: 'Kişilik sayın 33: İlk izlenimde şefkatli, sakin ve bilge görünürsün.',
  };
}
