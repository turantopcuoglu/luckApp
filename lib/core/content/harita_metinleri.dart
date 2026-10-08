/// Doğum haritası metinleri: Ay burcu (duygusal dünya) ve Yükselen
/// (ilk izlenim, hayata yaklaşım).
///
/// Güneş burcu metinleri `BurcMetinleri.oz`'dadır. Yazım kuralları için
/// bkz. `sayi_metinleri.dart`; ek olarak:
/// - Ay metinleri iç dünyayı ("duygularını…"), Yükselen metinleri dış
///   görünüşü ("ilk izlenimde…") anlatır; ikisi aynı cümleyi kurmaz.
/// - Belirsizlik notları dürüsttür: hangi bilginin eksik olduğunu ve
///   neyi değiştirebileceğini söyler, sonucu olduğundan kesin göstermez.
library;

import '../luck_engine/luck_engine.dart';
import 'tr_icerik_paketi.dart';

/// Doğum haritası metin havuzları.
abstract final class HaritaMetinleri {
  /// Ay burcuna göre duygusal dünya.
  static const Map<Burc, String> aylar = <Burc, String>{
    Burc.koc:
        'Ay burcun Koç: duygularını hızlı ve doğrudan yaşarsın. Öfken de '
        'sevincin de çabuk yükselir, çabuk geçer. Kendini güvende hissetmek '
        'için harekete geçmen, bir şeyi kendi elinle çözmen gerekir. Beklemek '
        'seni duygusal olarak yorar; sabır, öğrenmen gereken en değerli '
        'duygusal beceri.',
    Burc.boga:
        'Ay burcun Boğa: duygusal huzurunu istikrarda, tanıdık yüzlerde ve '
        'küçük keyiflerde bulursun. İyi bir yemek, rahat bir ev, güvendiğin '
        'biri seni hemen sakinleştirir. Değişime yavaş alışırsın; ani '
        'sarsıntılar seni beklenenden çok etkiler. Sadakatin derindir, '
        'kırıldığında ise affetmen zaman alır.',
    Burc.ikizler:
        'Ay burcun İkizler: duygularını konuşarak, yazarak ve düşünerek '
        'anlamlandırırsın. Merakın moralinin en iyi destekçisidir; yeni bir '
        'bilgi ya da güzel bir sohbet gününü hemen değiştirir. Duygularının '
        'derinine inmek yerine onları açıklamaya yatkınsın. Zihnin '
        'durmadığında huzursuzlanabilirsin; kendine sessiz anlar tanımak '
        'dengeni korur.',
    Burc.yengec:
        'Ay burcun Yengeç: Ay en rahat ettiği burçta. Duygusal dünyan derin, '
        'sezgilerin güçlü. Aile, yuva ve geçmiş anılar sana güven verir; '
        'sevdiklerini korumak içgüdün. Hassasiyetin bazen alınganlığa '
        'dönüşebilir; duygularını içine kapatmak yerine paylaştığında '
        'rahatlarsın. Kendine de şefkat göstermeyi öğrenmek duygusal dengenin temelidir.',
    Burc.aslan:
        'Ay burcun Aslan: duygusal olarak görülmeye, takdir edilmeye ve '
        'sevildiğini hissetmeye ihtiyaç duyarsın. Sevgini cömertçe ve '
        'gösterişli biçimde ifade edersin. Gururun incindiğinde derin '
        'yaralanırsın. Kendine duyduğun sevgi başkalarının alkışına bağlı '
        'olmadığında en güçlü hâline ulaşırsın.',
    Burc.basak:
        'Ay burcun Başak: duygularını düzen kurarak ve işe yarar bir şey '
        'yaparak dengelersin. Sevgini pratik yardımlarla, küçük ayrıntılara '
        'gösterdiğin özenle ifade edersin. Kaygılandığında her şeyi kontrol '
        'etmek isteyebilirsin. Kendine karşı eleştirel sesini yumuşatmak '
        'duygusal huzurunun anahtarı.',
    Burc.terazi:
        'Ay burcun Terazi: duygusal huzurunu uyumlu ilişkilerde ve güzel '
        'ortamlarda bulursun. Çatışma seni hemen yorar; araları bulmak için '
        'kendi duygunu geri planda bırakabilirsin. Yalnız kalmaktan çok, bir '
        'ilişkinin içinde kendini tamamlanmış hissedersin. Kendi ihtiyacını '
        'da dile getirmek ilişkilerini daha sağlam kılar.',
    Burc.akrep:
        'Ay burcun Akrep: duygularını yoğun, derin ve tutkulu yaşarsın. '
        'Güvenmen zaman alır, güvendiğinde ise sonuna kadar bağlanırsın. '
        'Yüzeyin altındakini sezme yeteneğin güçlü. Kırgınlıkları uzun süre '
        'içinde taşıyabilirsin; bırakmayı öğrendiğinde bu yoğunluk bir '
        'dönüşüm gücüne dönüşür.',
    Burc.yay:
        'Ay burcun Yay: duygusal olarak özgürlüğe, umuda ve anlam arayışına '
        'ihtiyaç duyarsın. Zor anlarda bile iyimserliğini korursun; yolculuk, '
        'öğrenmek ya da yeni bir ufuk seni toparlar. Kısıtlandığını '
        'hissettiğinde huzursuzlanırsın. Duygularından kaçmak yerine onlarla '
        'bir süre kalmak seni derinleştirir.',
    Burc.oglak:
        'Ay burcun Oğlak: duygularını kontrollü ve sorumlu biçimde yaşarsın. '
        'Güvende hissetmek için bir plana, bir hedefe ve sağlam bir zemine '
        'ihtiyaç duyarsın. Zayıflığını göstermek sana zor gelir; sevgini '
        'sözden çok yaptıklarınla gösterirsin. Kendine yumuşamak için izin '
        'verdiğinde iç dünyan hafifler.',
    Burc.kova:
        'Ay burcun Kova: duygularına biraz mesafeden bakmayı seversin. '
        'Arkadaşlık, özgürlük ve kendin olabildiğin ilişkiler sana güven '
        'verir. Kalabalık içinde bile kendine ait bir alan istersin. '
        'Duygularını analiz etmek yerine bazen sadece hissetmek, insanlarla '
        'bağını derinleştirir.',
    Burc.balik:
        'Ay burcun Balık: duygusal dünyan sınırsız ve şefkatli. Başkalarının '
        'duygularını kendi duygun gibi hissedersin; sezgilerin ve hayal gücün '
        'çok güçlü. Yorulduğunda müzik, sanat ya da yalnızlık seni toparlar. '
        'Kendi sınırlarını korumak, bu hassasiyetin seni yormasını önler.',
  };

  /// Yükselen burca göre ilk izlenim ve hayata yaklaşım.
  static const Map<Burc, String> yukselenler = <Burc, String>{
    Burc.koc:
        'Yükselenin Koç: ilk izlenimde enerjik, cesur ve doğrudan görünürsün. '
        'Bir ortama girdiğinde fark edilirsin; insanlar senden harekete '
        'geçmeni bekler. Tepkilerin hızlıdır, bazen düşünmeden konuşabilirsin. '
        "Hayata 'önce yap, sonra düşün' diyerek yaklaşırsın. Sabırsız görünebileceğini bilmek ilk izlenimini daha da güçlendirir.",
    Burc.boga:
        'Yükselenin Boğa: ilk izlenimde sakin, güvenilir ve sıcak görünürsün. '
        'Acele etmeyen tavrın çevrene huzur verir. Görünüşüne, rahatına ve '
        'çevrendeki güzelliğe özen gösterirsin. Yeni durumlara temkinle '
        'yaklaşır, bir kez karar verdiğinde kolay vazgeçmezsin. İnatçı görünmemek için fikrini değiştirmeye açık olduğunu belli etmek iyi gelir.',
    Burc.ikizler:
        'Yükselenin İkizler: ilk izlenimde meraklı, konuşkan ve genç ruhlu '
        'görünürsün. Her ortamda sohbet başlatabilir, farklı insanlarla '
        'kolayca bağ kurarsın. Enerjin hızlıdır; aynı anda birçok şeyle '
        'ilgilenmeyi seversin. Hayata öğrenerek ve sorular sorarak '
        'yaklaşırsın. Dağınık görünmemek için sözünü verdiğin şeyleri takip etmek güvenini artırır.',
    Burc.yengec:
        'Yükselenin Yengeç: ilk izlenimde yumuşak, şefkatli ve korumacı '
        'görünürsün. İnsanlar yanında kendini evinde gibi hisseder. Yeni bir '
        'ortamda önce çevreyi tartar, güvendikten sonra açılırsın. Hayata '
        'duygularınla ve sezgilerinle yaklaşırsın. Mesafeli göründüğün ilk anlarda küçük bir gülümseme kapıyı hemen aralar.',
    Burc.aslan:
        'Yükselenin Aslan: ilk izlenimde kendinden emin, sıcak ve göz alıcı '
        'görünürsün. Bir odaya girdiğinde varlığın hissedilir. Cömert ve '
        'gururlu bir duruşun var; insanlar sana doğal bir lider gibi bakar. '
        'Hayata yüreğini ortaya koyarak yaklaşırsın. Başkalarına da sahne bırakmak karizmanı daha sevimli kılar.',
    Burc.basak:
        'Yükselenin Başak: ilk izlenimde düzenli, dikkatli ve ölçülü '
        'görünürsün. Ayrıntıları fark eder, işleri doğru yapmaya özen '
        'gösterirsin. Mütevazı duruşunun altında keskin bir zekâ vardır. '
        'Hayata analiz ederek ve faydalı olmaya çalışarak yaklaşırsın. Fazla eleştirel görünmemek için takdirini de sesli söylemek işe yarar.',
    Burc.terazi:
        'Yükselenin Terazi: ilk izlenimde zarif, nazik ve uyumlu görünürsün. '
        'Diplomatik tavrın insanları rahatlatır; kolayca sevilirsin. Estetiğe '
        've dengeye önem verirsin. Hayata ilişkiler üzerinden, karşındakini '
        'de hesaba katarak yaklaşırsın. Kararsız görünmemek için küçük konularda bile net bir tercih yapmak saygınlığını artırır.',
    Burc.akrep:
        'Yükselenin Akrep: ilk izlenimde gizemli, güçlü ve etkileyici '
        'görünürsün. Bakışların derin, duruşun kararlıdır; kendini kolay '
        'açmazsın. İnsanlar seni hem merak eder hem de biraz çekinir. Hayata '
        'sezgilerinle ve derine bakarak yaklaşırsın. Soğuk görünmemek için ilk adımda biraz sıcaklık göstermek ilişkileri kolaylaştırır.',
    Burc.yay:
        'Yükselenin Yay: ilk izlenimde neşeli, açık sözlü ve maceracı '
        'görünürsün. İyimserliğin bulaşıcıdır; insanlar yanında ferahlar. '
        'Özgürlüğüne düşkünsün, kalıplara sığmayı sevmezsin. Hayata '
        'keşfederek ve büyük resme bakarak yaklaşırsın. Fazla rahat görünmemek için ayrıntılara biraz özen göstermek yeterli.',
    Burc.oglak:
        'Yükselenin Oğlak: ilk izlenimde ciddi, olgun ve güvenilir '
        'görünürsün. Yaşından büyük bir duruşun olabilir; insanlar sana '
        'sorumluluk emanet eder. Zamanla açılan, ince bir mizah anlayışın '
        'vardır. Hayata hedef koyarak ve adım adım ilerleyerek yaklaşırsın. Ulaşılmaz görünmemek için zaman zaman yumuşak yanını göstermek ilişkilerini derinleştirir.',
    Burc.kova:
        'Yükselenin Kova: ilk izlenimde özgün, arkadaş canlısı ve biraz sıra '
        'dışı görünürsün. Farklı fikirlerin ve bağımsız duruşunla dikkat '
        'çekersin. Herkesle iyi geçinir ama mesafeni korursun. Hayata '
        'yenilikçi ve özgür bir bakışla yaklaşırsın. Uzak görünmemek için duygularını da arada bir dile getirmek iyi olur.',
    Burc.balik:
        'Yükselenin Balık: ilk izlenimde yumuşak, hayalperest ve anlayışlı '
        'görünürsün. İnsanlar sana kolayca açılır; empatin hemen hissedilir. '
        'Çevrenin havasını sünger gibi emersin. Hayata sezgilerinle, hayal '
        'gücünle ve şefkatle yaklaşırsın. Fazla dalgın görünmemek için ayağını yere basan küçük alışkanlıklar seni destekler.',
  };

  // ---- Başlıklar ----

  /// Burcun Türkçe adı (içerik paketinden; enum etiketine bağlı değil).
  static String _ad(Burc b) => trIcerik.burcAdi(b);

  /// Ay bölümü başlığı.
  static String ayBasligi(Burc b) => 'Ay burcun · ${_ad(b)}';

  /// Yükselen bölümü başlığı.
  static String yukselenBasligi(Burc b) => 'Yükselenin · ${_ad(b)}';

  /// Alternatif (komşu burç) bölümü başlığı.
  static String alternatifBasligi(String tur, Burc b) => '$tur ${_ad(b)} ise';

  /// Alternatif Ay bölümü türü.
  static const String ayTuru = 'Ay burcun';

  /// Alternatif Yükselen bölümü türü.
  static const String yukselenTuru = 'Yükselenin';

  /// Büyük üçlü özeti ("Güneş Balık · Ay Yay · Yükselen Kova"); bilinmeyen
  /// Yükselen "?" olarak yazılır.
  static String ozet(Burc gunes, Burc ay, Burc? yukselen) =>
      'Güneş ${_ad(gunes)} · Ay ${_ad(ay)} · '
      'Yükselen ${yukselen == null ? '?' : _ad(yukselen)}';

  // ---- Belirsizlik notları ----

  /// Saat bilinmiyor ve Ay o gün burç değiştiriyor.
  static String ayGunIcindeDegisiyor(Burc a, Burc b) =>
      'Doğduğun gün Ay ${_ad(a)} ile ${_ad(b)} burçları arasında yer '
      'değiştiriyor. Doğum saatini eklersen hangisi olduğu netleşir; '
      'şimdilik iki yorumu da okuyabilirsin.';

  /// Saat biliniyor ama Ay burç sınırına çok yakın.
  static String aySinirda(Burc a, Burc b) =>
      'Ay doğduğun anda ${_ad(a)} ile ${_ad(b)} burçlarının sınırında. '
      'Doğum saatin bir saat kadar farklıysa Ay burcun ${_ad(b)} olabilir; '
      'iki yorumu da okuyabilirsin.';

  /// Yükselen burç sınırına çok yakın.
  static String yukselenSinirda(Burc a, Burc b) =>
      'Yükselenin ${_ad(a)} ile ${_ad(b)} sınırında. Doğum saatin '
      'birkaç dakika farklıysa Yükselenin ${_ad(b)} olabilir; iki yorumu '
      'da okuyabilirsin.';

  /// Doğum tarihinde Türkiye saat uygulaması kayıtları kesin değil.
  static const String saatDilimiBelirsiz =
      'Doğduğun tarihte Türkiye\'de uygulanan saate dair kayıtlar kesin '
      'değil; Yükselenin bir burç kayabilir. Yorumu bir eğilim olarak oku.';

  /// Yükselen için doğum saati ya da ili eksik.
  static const String yukselenIcinBilgiEksik =
      'Yükselen burcun doğum saatine ve doğduğun yere göre değişir. Doğum '
      'saatini ve ilini eklersen Yükselenini de hesaplayabiliriz.';
}
