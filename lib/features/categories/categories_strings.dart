import '../../core/luck_engine/luck_engine.dart';
import 'categories_config.dart';

/// Kategori detayı ve paywall'un Türkçe metinleri.
abstract final class CategoriesStrings {
  /// Şanslı saat kartının başlığı.
  static const String sansliSaatBaslik = 'Şanslı saat aralığın';

  /// Paywall başlığı.
  static const String paywallBaslik = 'Kader Premium';

  /// Paywall açıklaması.
  static const String paywallAciklama =
      'Aşk ve para kaderini her gün, tüm detaylarıyla gör.';

  /// Paywall'da listelenen özellikler.
  static const List<String> paywallOzellikler = <String>[
    'Aşk ve Para kategorileri açık',
    'Kategoriye özel günlük yorumlar',
    'Şanslı saat aralıkları',
  ];

  /// Paywall satın alma butonu (placeholder).
  static const String paywallButon = "Premium'a Geç";

  /// Satın alma entegrasyonu gelmeden önceki bilgi mesajı.
  static const String paywallYakinda =
      'Satın alma çok yakında burada olacak ✨';

  /// Kategori + skor aralığına göre 2 cümlelik detay yorumu üretir.
  ///
  /// İlk cümle kategori ve skor aralığından, ikinci cümle kategorinin
  /// genel tavsiyesinden gelir (plan Session 9, madde 1).
  static String kategoriYorumu(LuckCategory kategori, int skor) {
    final int aralik = skor < CategoriesConfig.dusukEsik
        ? 0
        : (skor > CategoriesConfig.yuksekEsik ? 2 : 1);
    return '${_acilisCumleleri[kategori]![aralik]} '
        '${_tavsiyeCumleleri[kategori]!}';
  }

  /// Kategori başına [düşük, orta, yüksek] açılış cümleleri.
  static const Map<LuckCategory, List<String>> _acilisCumleleri =
      <LuckCategory, List<String>>{
    LuckCategory.ask: <String>[
      'Kalp işlerinde bugün acele etme; yanlış anlaşılmalara açık bir gün.',
      'Aşk cephesinde dengeli bir gün; küçük jestler kapı açar.',
      'Kalbin bugün mıknatıs gibi; cesur bir adım karşılık bulabilir.',
    ],
    LuckCategory.para: <String>[
      'Cüzdanını bugün sıkı tut; plansız harcama pişmanlık getirir.',
      'Para akışın dengede; birikim için fena bir gün değil.',
      'Fırsat kokusu var; gözünü açık tut, kazanç kapıda.',
    ],
    LuckCategory.saglik: <String>[
      'Enerjin düşük seyredebilir; bedenini dinle, tempoyu düşür.',
      'Enerji dengen yerinde; hafif bir yürüyüş iyi gelir.',
      'Kendini hafif hissedeceksin; formunun tadını çıkar.',
    ],
    LuckCategory.risk: <String>[
      'Bugün şansını zorlamanın günü değil; garantiye oyna.',
      'Hesaplı riskler alınabilir; içgüdüne biraz pay bırak.',
      'Cesaret bugün ödüllendiriliyor; o adımı at.',
    ],
    LuckCategory.sosyal: <String>[
      'Kalabalık bugün yorabilir; küçük ve samimi kal.',
      'Sosyal enerjin dengede; eski bir dosta ses ver.',
      'Bugün ortamın yıldızı sensin; davetlere evet de.',
    ],
  };

  /// Kategori başına ikinci (tavsiye) cümle.
  static const Map<LuckCategory, String> _tavsiyeCumleleri =
      <LuckCategory, String>{
    LuckCategory.ask: 'Sevdiğine içinden geçeni bugün söylemeyi dene.',
    LuckCategory.para: 'Büyük kararları şanslı saatine denk getir.',
    LuckCategory.saglik: 'Bol su iç ve uykunu aksatma.',
    LuckCategory.risk: 'Yine de her şeyi tek karta bağlama.',
    LuckCategory.sosyal: 'Yeni bir tanışıklık sürpriz kapılar açabilir.',
  };
}
