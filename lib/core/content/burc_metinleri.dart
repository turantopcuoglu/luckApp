import '../luck_engine/luck_engine.dart';

/// Güneş burcu ve element metinleri.
///
/// Yazım rehberi için bkz. `sayi_metinleri.dart`.
abstract final class BurcMetinleri {
  /// Burcun kısa özü (profil ekranı).
  static const Map<Burc, String> oz = <Burc, String>{
    Burc.koc:
        'Koç burcu ateşin ilk kıvılcımıdır: hızlı karar verir, '
        'beklemekten sıkılır, cesaretiyle yol açarsın. Öfken çabuk parlar '
        'ama çabuk da söner. En iyi halinle, başkalarının çekindiği işe '
        'ilk giren kişisin.',
    Burc.boga:
        'Boğa burcu toprağın sabrını taşır: güzel olanı, sağlam '
        'olanı ve kalıcı olanı seversin. Değişime yavaş ısınırsın ama bir '
        'kez bağlandığında sadakatin sarsılmaz. Duyularına — tada, kokuya, '
        'dokunuşa — güvenirsin.',
    Burc.ikizler:
        'İkizler burcu havanın merakıdır: zihnin hızlı, sohbetin '
        'canlıdır. Aynı anda birkaç konuya ilgi duyar, farklı insanlarla '
        'kolay bağ kurarsın. Sıkıldığında dikkatin dağılır; ilgin '
        'yakalandığında ise durdurulamazsın.',
    Burc.yengec:
        'Yengeç burcu suyun şefkatidir: sevdiklerini korur, '
        'geçmişe ve anılara değer verirsin. Dışarıdan sert bir kabuk '
        'gösterebilirsin ama içerisi çok yumuşaktır. Güvende hissettiğin '
        'yerde en cömert halinle açılırsın.',
    Burc.aslan:
        'Aslan burcu ateşin sahnesidir: sıcaklığın ve özgüvenin '
        'ortamı aydınlatır. Takdir görmek sana güç verir; sevdiklerine '
        'karşı cömert ve korumacısın. Gururun kırıldığında sessizleşir, '
        'onurunu korumayı her şeyden önemli sayarsın.',
    Burc.basak:
        'Başak burcu toprağın titizliğidir: ayrıntıyı görür, '
        'işleri iyileştirmek için çabalarsın. Faydalı olmak sana anlam '
        'verir. Kendine karşı eleştirel olabilirsin; yaptığın işin '
        'kusurundan önce emeğini görmek sana iyi gelir.',
    Burc.terazi:
        'Terazi burcu havanın dengesidir: adalet, uyum ve '
        'güzellik senin için önemlidir. İnsanlar arasında köprü kurar, '
        'her iki tarafı da anlamaya çalışırsın. Karar vermek bazen uzun '
        'sürer; çünkü kimsenin kırılmasını istemezsin.',
    Burc.akrep:
        'Akrep burcu suyun derinliğidir: yoğun hisseder, yüzeyin '
        'altındakini görürsün. Güvenini kazanmak zordur ama kazanan '
        'kişiye sonuna kadar sadıksın. Dönüşüm senin doğanda var; her '
        'krizden daha güçlü çıkarsın.',
    Burc.yay:
        'Yay burcu ateşin ufkudur: özgürlüğü, keşfetmeyi ve anlam '
        'aramayı seversin. İyimserliğin bulaşıcıdır, doğruyu olduğu gibi '
        'söylersin. Kısıtlandığında huzursuzlanır, yeni bir yolculuk '
        'planıyla yeniden canlanırsın.',
    Burc.oglak:
        'Oğlak burcu toprağın dağ yoludur: hedeflerine sabırla, '
        'adım adım tırmanırsın. Sorumluluk almaktan çekinmez, emeğinle '
        'var olursun. Ciddi görünebilirsin ama yakınların senin kuru ve '
        'ince mizahını bilir.',
    Burc.kova:
        'Kova burcu havanın özgün sesidir: farklı düşünür, kalıplara '
        'kolay sığmazsın. İnsanlığa, fikirlere ve arkadaşlığa değer '
        'verirsin. Duygularını analiz ederek yaşayabilirsin; bu bazen '
        'mesafeli görünmene yol açar.',
    Burc.balik:
        'Balık burcu suyun hayal gücüdür: sezgilerin güçlü, '
        'empatin derindir. Başkalarının duygularını kolayca hisseder, '
        'sanata ve maneviyata yakın durursun. Sınırlarını korumak, bu '
        'hassas dünyanın dengesini sağlar.',
  };

  /// Doğum günü burç sınırındaysa profil burç bölümüne eklenen not.
  static const String sinirNotu =
      'Not: Doğum günün iki burcun sınırına '
      'çok yakın. Güneşin burç değiştirdiği saat yıldan yıla değiştiği için, '
      'doğum saatine göre burcun komşu burç da olabilir; kendini hangisinde '
      'daha çok bulduğuna sen karar ver.';

}
