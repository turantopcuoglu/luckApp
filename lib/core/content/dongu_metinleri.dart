import '../luck_engine/luck_engine.dart';

/// Günlük yorumun tonunu belirleyen üç seviye (genel skor bandından).
enum GunTonu {
  /// Temkinli gün (skor bandı çok düşük / düşük).
  dusuk,

  /// Dengeli gün (orta bant).
  orta,

  /// Açık gün (yüksek / çok yüksek bant).
  yuksek,
}

/// Kişisel yıl metni: başlık + profil ekranı paragrafı + günlük kısa
/// cümle varyantları.
class KisiselYilMetni {
  /// Tüm alanlarıyla metin oluşturur.
  const KisiselYilMetni({
    required this.baslik,
    required this.uzun,
    required this.gunluk,
  });

  /// Yılın teması ("Tohum Yılı").
  final String baslik;

  /// Profil ekranındaki yıl paragrafı.
  final String uzun;

  /// Günlük okumadaki kısa yıl bağlamı varyantları.
  final List<String> gunluk;
}

/// Zaman döngülerinin (kişisel yıl/ay/gün, ay evresi) metin havuzları.
///
/// Yazım rehberi için bkz. `sayi_metinleri.dart`. Yer tutucular:
/// `{isim}`, `{kisiselGun}`, `{kisiselYil}`, `{yil}`, `{ugrasAlani}`.
abstract final class DonguMetinleri {
  /// Kişisel gün sayısına (1-9) göre günün başlık varyantları.
  static const Map<int, List<String>> gunBasliklari = <int, List<String>>{
    1: <String>['Başlangıç Günü', 'İlk Adım Günü', 'Tohum Günü'],
    2: <String>['Sabır Günü', 'Köprü Günü', 'Yakınlaşma Günü'],
    3: <String>['İfade Günü', 'Renk Günü', 'Paylaşma Günü'],
    4: <String>['Temel Atma Günü', 'Düzen Günü', 'Emek Günü'],
    5: <String>['Değişim Günü', 'Keşif Günü', 'Rüzgâr Günü'],
    6: <String>['Yuva Günü', 'Şefkat Günü', 'Özen Günü'],
    7: <String>['İç Ses Günü', 'Derinleşme Günü', 'Sessizlik Günü'],
    8: <String>['Güç Günü', 'Hasat Günü', 'Karar Günü'],
    9: <String>['Tamamlama Günü', 'Bırakma Günü', 'Kapanış Günü'],
  };

  /// Kişisel yıl (1-9) metinleri.
  static const Map<int, KisiselYilMetni> kisiselYil = <int, KisiselYilMetni>{
    1: KisiselYilMetni(
      baslik: 'Tohum Yılı',
      uzun:
          '{yil} senin için bir 1 yılı: dokuz yıllık yeni bir döngünün '
          'ilk sayfası. Bu yıl ektiğin fikirler, kurduğun alışkanlıklar ve '
          'verdiğin kararlar önümüzdeki yılların yönünü belirler. Cesur '
          'başlangıçlara, yeni işlere ve kendine ait bir yol çizmeye açık '
          'bir yıl. Tek dikkat noktası: her şeyi aynı anda başlatmak yerine '
          'en çok önemsediğin birkaç tohumu seçmek.',
      gunluk: <String>[
        '{yil} senin için bir 1 yılı: yeni döngünün tohum yılı. Bugün '
            'attığın küçük adımlar yılın geri kalanına iz bırakıyor.',
        'Kişisel yılın 1; bu yıl başlangıçların yılı. Bugünkü küçük '
            'cesaretler, büyük bir yolun ilk taşları.',
        '1 yılındasın; evren senden ertelemeden başlamanı istiyor.',
      ],
    ),
    2: KisiselYilMetni(
      baslik: 'Sabır ve Ortaklık Yılı',
      uzun:
          '{yil} senin için bir 2 yılı: geçen yıl ektiklerinin sessizce '
          'kök saldığı bir dönem. Hız değil sabır, tek başına koşmak değil '
          'iş birliği ön planda. İlişkiler, ortaklıklar ve duygusal bağlar '
          'bu yıl derinleşebilir. Sonuçlar yavaş görünse de toprağın altında '
          'çok şey oluyor; beklemeyi bir boşluk değil bir hazırlık olarak gör.',
      gunluk: <String>[
        '{yil} senin için bir 2 yılı: sabrın ve ortaklığın yılı. Bugün '
            'tek başına zorlamak yerine birlikte ilerlemek daha kolay.',
        'Kişisel yılın 2; kökler toprağın altında büyüyor. Görünmeyen '
            'ilerlemeye güven.',
        '2 yılındasın; ilişkiler ve uyum bu yılın asıl gündemi.',
      ],
    ),
    3: KisiselYilMetni(
      baslik: 'İfade ve Genişleme Yılı',
      uzun:
          '{yil} senin için bir 3 yılı: kendini ifade etmenin, sosyal '
          'çevreni genişletmenin ve yaratıcılığın yılı. Önceki iki yılda '
          'kurduklarının meyveleri renklenmeye başlar. Yeni insanlar, yeni '
          'fikirler ve keyifli fırsatlar kapıyı çalabilir. Dikkat noktası: '
          'enerjini çok fazla yöne dağıtmamak ve söz verdiklerini tutmak.',
      gunluk: <String>[
        '{yil} senin için bir 3 yılı: kendini ifade etmenin yılı. Bugün '
            'sesini duyurmak için doğal bir akış var.',
        'Kişisel yılın 3; bu yıl paylaştıkça büyüyorsun.',
        '3 yılındasın; neşe ve yaratıcılık bu yılın yakıtı.',
      ],
    ),
    4: KisiselYilMetni(
      baslik: 'Temel Atma Yılı',
      uzun:
          '{yil} senin için bir 4 yılı: çalışmanın, düzen kurmanın ve '
          'sağlam temeller atmanın yılı. Parlak sürprizlerden çok, emeğin '
          'karşılığını adım adım aldığın bir dönem. Ev, iş, bütçe ya da '
          'alışkanlıklar gibi hayatının iskeletini güçlendirmek için ideal. '
          'Yorgunluk hissettiğinde, bu yıl kurduğun her şeyin sonraki '
          'yılları taşıyacağını hatırla.',
      gunluk: <String>[
        '{yil} senin için bir 4 yılı: temel atma yılı. Bugünkü sabırlı '
            'emek, yılın sonunda sağlam bir zemine dönüşecek.',
        'Kişisel yılın 4; bu yıl düzen ve istikrar yılı.',
        '4 yılındasın; hızdan çok sağlamlık kazandırıyor.',
      ],
    ),
    5: KisiselYilMetni(
      baslik: 'Değişim Yılı',
      uzun:
          '{yil} senin için bir 5 yılı: dokuz yıllık döngünün ortası ve '
          'değişimin yılı. Taşınma, yeni bir iş, yeni bir ilişki ya da yeni '
          'bir bakış açısı gibi hayatını hareketlendiren gelişmeler olası. '
          'Esnek kaldıkça fırsatlar çoğalır. Dikkat noktası: özgürlük '
          'isteğinin aceleye ve aşırılığa dönüşmemesi.',
      gunluk: <String>[
        '{yil} senin için bir 5 yılı: değişimin yılı. Bugün esneyebildiğin '
            'ölçüde yeni kapılar açılıyor.',
        'Kişisel yılın 5; hareket ve yenilik bu yılın anahtarı.',
        '5 yılındasın; rüzgâr sık yön değiştiriyor, yelkenini ayarlamayı öğren.',
      ],
    ),
    6: KisiselYilMetni(
      baslik: 'Yuva ve Sorumluluk Yılı',
      uzun:
          '{yil} senin için bir 6 yılı: sevgi, aile, ev ve sorumluluk '
          'konularının öne çıktığı bir yıl. İlişkiler derinleşebilir, '
          'yaşadığın alanı güzelleştirme isteği artabilir. Başkalarına '
          'destek olurken kendi ihtiyaçlarını da gözetmek bu yılın sınavı. '
          'Verdiğin emek, sevdiklerinle kurduğun bağda karşılık bulur.',
      gunluk: <String>[
        '{yil} senin için bir 6 yılı: yuvanın ve sevginin yılı. Bugün '
            'yakınlarına gösterdiğin özen sana huzur olarak dönüyor.',
        'Kişisel yılın 6; bu yıl sorumluluk ve şefkat yılı.',
        '6 yılındasın; önce kendi fincanını doldurmayı unutma.',
      ],
    ),
    7: KisiselYilMetni(
      baslik: 'İç Görü Yılı',
      uzun:
          '{yil} senin için bir 7 yılı: içe dönmenin, öğrenmenin ve anlam '
          'aramanın yılı. Dışarıdaki koşuşturmadan çok içindeki soruların '
          'önem kazandığı bir dönem. Eğitim, araştırma, manevi arayış ve '
          'kendini tanıma için çok verimli. Yalnız kalma isteğin artabilir; '
          'bu bir kayıp değil, bir yeniden ayarlanmadır.',
      gunluk: <String>[
        '{yil} senin için bir 7 yılı: iç görünün yılı. Bugün sessizlikte '
            'bulduğun cevaplar değerli.',
        'Kişisel yılın 7; bu yıl derinleşme ve öğrenme yılı.',
        '7 yılındasın; hızlanmak yerine anlamak kazandırıyor.',
      ],
    ),
    8: KisiselYilMetni(
      baslik: 'Hasat ve Güç Yılı',
      uzun:
          '{yil} senin için bir 8 yılı: emeğinin karşılığını alabileceğin, '
          'kariyer ve maddi konuların öne çıktığı bir yıl. Sorumluluk ve '
          'görünürlük artabilir; kararlı adımlar ödüllendirilir. Dikkat '
          'noktası: hedeflere odaklanırken dengeyi, dinlenmeyi ve '
          'sevdiklerini ikinci plana atmamak.',
      gunluk: <String>[
        '{yil} senin için bir 8 yılı: hasat yılı. Bugün kararlılığın '
            'karşılık bulmaya yakın.',
        'Kişisel yılın 8; bu yıl güç ve sonuç yılı.',
        '8 yılındasın; emeğinin değerini bilmek ve istemek bu yılın dersi.',
      ],
    ),
    9: KisiselYilMetni(
      baslik: 'Tamamlama Yılı',
      uzun:
          '{yil} senin için bir 9 yılı: dokuz yıllık döngünün kapanışı. '
          'Artık sana hizmet etmeyen ilişkileri, alışkanlıkları ve yükleri '
          'bırakmanın yılı. Bir şeylerin bitmesi kayıp gibi hissedilebilir '
          'ama aslında yeni döngüye yer açılıyor. Affetmek, ayıklamak ve '
          'teşekkür etmek bu yıl sana hafiflik getirir.',
      gunluk: <String>[
        '{yil} senin için bir 9 yılı: kapanışların ve ayıklamanın yılı. '
            'Bugün "neyi bırakmalıyım?" sorusu arka planda çalışıyor.',
        'Kişisel yılın 9; bu yıl tamamlama yılı, yeni döngü kapıda.',
        '9 yılındasın; bıraktıkça hafifliyor, hafifledikçe yer açıyorsun.',
      ],
    ),
  };

  /// Ay evresine göre kısa cümleler (neden açıklamasında da kullanılır).
  static const Map<AyEvresi, List<String>> ayEvresi = <AyEvresi, List<String>>{
    AyEvresi.yeniAy: <String>[
      'Gökyüzünde yeni ay var: niyet koyma ve sessiz başlangıç zamanı.',
      'Ay görünmez halde; enerji içe dönük, niyetler için uygun bir zaman.',
    ],
    AyEvresi.buyuyenHilal: <String>[
      'Ay büyüyen hilalde: yeni ektiklerin filizleniyor.',
      'İnce bir hilal büyüyor; küçük adımlar cesaret kazanıyor.',
    ],
    AyEvresi.ilkDordun: <String>[
      'Ay ilk dördünde: harekete geçme ve engeli aşma zamanı.',
      'Yarım ay büyüyor; kararlarını eyleme dökmek için enerji var.',
    ],
    AyEvresi.buyuyenSiskin: <String>[
      'Ay dolunaya yaklaşıyor: işleri olgunlaştırma ve ince ayar zamanı.',
      'Şişkin ay büyüyor; sabrın meyvesi yakın.',
    ],
    AyEvresi.dolunay: <String>[
      'Gökyüzünde dolunay var: duygular ve görünürlük zirvede.',
      'Dolunay ışığı her şeyi aydınlatıyor; gizli kalan açığa çıkabilir.',
    ],
    AyEvresi.kuculenSiskin: <String>[
      'Ay küçülmeye başladı: paylaşma ve şükran zamanı.',
      'Işık yavaşça azalıyor; elde ettiklerini fark etme zamanı.',
    ],
    AyEvresi.sonDordun: <String>[
      'Ay son dördünde: ayıklama ve bırakma zamanı.',
      'Yarım ay küçülüyor; gereksiz yüklerden hafiflemek kolay.',
    ],
    AyEvresi.kuculenHilal: <String>[
      'Ay küçülen hilalde: dinlenme ve kapanış zamanı.',
      'Ayın son ince ışığı; yeni döngüden önce nefes al.',
    ],
  };
}
