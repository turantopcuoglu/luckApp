import '../luck_engine/luck_engine.dart';
import 'tr_icerik_paketi.dart';

/// Doğum haritasından kurulan kısa portre cümleleri: yükselen burcun
/// dışarıya gösterdiği yüz ile Ay burcunun iç dünyası.
///
/// Günlük okumanın açılış paragrafında, sayı sesinin konuşmadığı günlerde
/// yer alır. İki amaca hizmet eder:
/// - Kişi kendi doğum verisinin (doğum saati ve yeri) okumada karşılığını
///   görür; onboarding'de sorulan bilgi boşa sorulmuş olmaz.
/// - "Dışarıdan böyle görünürsün, içinde ise şöylesin" karşıtlığı kişinin
///   kendini en çok tanıdığı anlatım biçimidir; burada tahmin değil,
///   haritanın iki ayrı noktasından gelir.
///
/// İfadeler doğum haritası metinleriyle (`harita_metinleri.dart`) aynı
/// portreyi anlatır: profilde Ay burcu için ne deniyorsa burada onun kısa
/// hâli vardır. Cümleler yargı ya da öğüt içermez; yalnızca tarif eder.
abstract final class KimlikMetinleri {
  /// Yükselen burcun ilk izlenimi: "… görünürsün" ve "seni … gösterir"
  /// kalıplarına oturan sıfat öbekleri.
  static const Map<Burc, List<String>> disGorunus = <Burc, List<String>>{
    Burc.koc: <String>[
      'enerjik, cesur ve doğrudan',
      'hızlı karar veren, harekete hazır biri gibi',
    ],
    Burc.boga: <String>[
      'sakin, güvenilir ve sıcak',
      'acele etmeyen, huzur veren biri gibi',
    ],
    Burc.ikizler: <String>[
      'meraklı, konuşkan ve genç ruhlu',
      'her ortamda sohbet açabilen biri gibi',
    ],
    Burc.yengec: <String>[
      'yumuşak, şefkatli ve korumacı',
      'önce çevresini tartan, temkinli biri gibi',
    ],
    Burc.aslan: <String>[
      'kendinden emin, sıcak ve göz alıcı',
      'girdiği odada fark edilen biri gibi',
    ],
    Burc.basak: <String>[
      'düzenli, dikkatli ve ölçülü',
      'ayrıntıyı kaçırmayan, mütevazı biri gibi',
    ],
    Burc.terazi: <String>[
      'zarif, nazik ve uyumlu',
      'herkesi rahatlatan, diplomatik biri gibi',
    ],
    Burc.akrep: <String>[
      'gizemli, güçlü ve etkileyici',
      'kendini kolay açmayan, kararlı biri gibi',
    ],
    Burc.yay: <String>[
      'neşeli, açık sözlü ve maceracı',
      'iyimserliği bulaşan, rahat biri gibi',
    ],
    Burc.oglak: <String>[
      'ciddi, olgun ve güvenilir',
      'sorumluluk emanet edilen, ağırbaşlı biri gibi',
    ],
    Burc.kova: <String>[
      'özgün, arkadaş canlısı ve biraz sıra dışı',
      'herkesle iyi geçinen ama mesafesini koruyan biri gibi',
    ],
    Burc.balik: <String>[
      'yumuşak, hayalperest ve anlayışlı',
      'insanların kolayca açıldığı, şefkatli biri gibi',
    ],
  };

  /// Ay burcunun iç dünyası: "içinde ise …" kalıbına oturan, ikinci tekil
  /// şahısla yazılmış yan cümleler (küçük harfle başlar, noktasız).
  static const Map<Burc, List<String>> icDunya = <Burc, List<String>>{
    Burc.koc: <String>[
      'duygularını hızlı ve doğrudan yaşarsın',
      'beklemeye pek tahammülün yoktur',
    ],
    Burc.boga: <String>[
      'huzuru istikrarda ve tanıdık yüzlerde ararsın',
      'ani değişimler seni belli ettiğinden çok sarsar',
    ],
    Burc.ikizler: <String>[
      'duygularını konuşarak ve düşünerek anlamlandırırsın',
      'zihnin durmadığında huzursuzlanırsın',
    ],
    Burc.yengec: <String>[
      'her şeyi derinden hisseder, sevdiklerini korumak istersin',
      'kırıldığında bunu çoğu zaman kimseye söylemezsin',
    ],
    Burc.aslan: <String>[
      'görülmeye ve takdir edilmeye ihtiyaç duyarsın',
      'gururun incindiğinde belli ettiğinden derin yaralanırsın',
    ],
    Burc.basak: <String>[
      'duygularını düzen kurarak dengelersin',
      'kaygılandığında her şeyi kontrol etmek istersin',
    ],
    Burc.terazi: <String>[
      'huzuru uyumlu ilişkilerde ararsın',
      'araları bulmak için kendi duygunu geri planda bırakırsın',
    ],
    Burc.akrep: <String>[
      'her şeyi yoğun ve derinden yaşarsın',
      'güvenmen zaman alır, güvendiğinde sonuna kadar bağlanırsın',
    ],
    Burc.yay: <String>[
      'özgürlüğe ve umuda ihtiyaç duyarsın',
      'kısıtlandığını hissettiğinde huzursuzlanırsın',
    ],
    Burc.oglak: <String>[
      'duygularını kontrollü yaşar, zayıflığını kolay göstermezsin',
      'güvende hissetmek için sağlam bir zemin ararsın',
    ],
    Burc.kova: <String>[
      'duygularına biraz mesafeden bakarsın',
      'kalabalık içinde bile kendine ait bir alan istersin',
    ],
    Burc.balik: <String>[
      'başkalarının duygusunu kendi duygun gibi hissedersin',
      'yorulduğunda kendi köşene çekilmek istersin',
    ],
  };

  /// Yükselen ve Ay burcu birlikte biliniyorken kullanılan kalıplar.
  /// Yer tutucular: `{dis}`, `{ic}`, `{Ic}` (büyük harfle başlayan),
  /// `{yukselen}`, `{ay}`.
  static const List<String> ikiliKaliplar = <String>[
    'Dışarıdan {dis} görünürsün; içinde ise {ic}.',
    'İlk bakışta {dis} görünsen de iç dünyanda {ic}.',
    'Yükselenin {yukselen} seni {dis} gösterir; Ay burcun {ay} ise içeride '
        'başka konuşur: {ic}.',
    '{Ic}; dışarıya ise çoğu zaman {dis} görünürsün.',
  ];

  /// Yalnızca Ay burcu biliniyorken (doğum saati ya da yeri yok)
  /// kullanılan kalıplar.
  static const List<String> ayKaliplari = <String>[
    'Ay burcun {ay} olduğu için iç dünyanda {ic}.',
    'İç dünyanda {ic}; bunu en yakınların bilir.',
  ];

  /// Yalnızca yükselen biliniyorken (Ay o gün burç değiştirdiği için
  /// kesin değilken) kullanılan kalıplar.
  static const List<String> yukselenKaliplari = <String>[
    'Yükselenin {yukselen} olduğu için ilk izlenimde {dis} görünürsün.',
    'İnsanlar seni önce {dis} görür; gerisini zamanla tanırlar.',
  ];

  /// [dogumAyi] ve [yukselen] için doldurulmuş portre cümleleri: kalıp ×
  /// dış görünüş ifadesi × iç dünya ifadesi. İkisi de bilinmiyorsa boş
  /// liste döner (okuma o zaman portresiz kurulur).
  ///
  /// Sıra sabittir (kalıp, sonra dış, sonra iç); seçim dışarıda
  /// deterministik indeksle yapılır.
  static List<String> portreler({Burc? dogumAyi, Burc? yukselen}) {
    final List<String> kaliplar = dogumAyi != null && yukselen != null
        ? ikiliKaliplar
        : dogumAyi != null
        ? ayKaliplari
        : yukselen != null
        ? yukselenKaliplari
        : const <String>[];
    // Bilinmeyen tarafın ifadesi kalıpta geçmez; tek bir boş değer
    // döngünün bir kez dönmesini sağlar.
    final List<String> dislar = yukselen == null
        ? const <String>['']
        : disGorunus[yukselen]!;
    final List<String> icler = dogumAyi == null
        ? const <String>['']
        : icDunya[dogumAyi]!;
    return <String>[
      for (final String kalip in kaliplar)
        for (final String dis in dislar)
          for (final String ic in icler)
            kalip
                .replaceAll('{dis}', dis)
                .replaceAll('{ic}', ic)
                .replaceAll('{Ic}', _buyukBasla(ic))
                .replaceAll(
                  '{yukselen}',
                  yukselen == null ? '' : trIcerik.burcAdi(yukselen),
                )
                .replaceAll(
                  '{ay}',
                  dogumAyi == null ? '' : trIcerik.burcAdi(dogumAyi),
                ),
    ];
  }

  /// [s]nin ilk harfi Türkçe kurallarıyla büyütülmüş hâli (i → İ, ı → I).
  static String _buyukBasla(String s) {
    if (s.isEmpty) {
      return s;
    }
    final String ilk = switch (s[0]) {
      'i' => 'İ',
      'ı' => 'I',
      final String h => h.toUpperCase(),
    };
    return '$ilk${s.substring(1)}';
  }
}
