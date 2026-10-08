/// Kişisel Yıl Raporu: bir takvim yılının kişiye özel okuması.
///
/// [yillikRaporOkumasi], doğum tarihinden kişisel yılı ve yılın 12
/// kişisel ayını hesaplar; yılın rehberini, ay ay okumayı, kişinin
/// doğasına göre akışta/zorlu ayları ve varsa yıl içindeki yaşam dönemi
/// geçişini bölümler hâlinde dizer. Rastgele seçim yoktur: aynı kişi ve
/// aynı yıl HER ZAMAN aynı raporu verir (CLAUDE.md kural 8).
library;

import '../luck_engine/luck_engine.dart';
import 'content_config.dart';
import 'dongu_metinleri.dart';
import 'icerik_paketi.dart';
import 'rapor_metinleri.dart';
import 'slot_doldurucu.dart';
import 'tr_icerik_paketi.dart';
import 'yillik_rapor_metinleri.dart';
import 'yorum_yonu.dart';

/// Yıllık rapor bölümlerinin türleri (sıra = ekrandaki sıra).
enum YillikBolumTuru {
  /// Kişisel yılın teması.
  tema,

  /// Yıl içinde yeni yaşam dönemine geçiş (varsa).
  donemGecisi,

  /// Yılın fırsatları.
  firsatlar,

  /// Dikkat edilecekler.
  dikkat,

  /// Yılın aşka etkisi.
  ask,

  /// Yılın iş ve paraya etkisi.
  isVePara,

  /// Kişinin doğasıyla aynı yönde akan aylar (varsa).
  akisAylari,

  /// Kişinin doğasını zorlayan aylar (varsa).
  zorluAylar,

  /// Yılın sorusu ve niyet çalışması.
  niyet,
}

/// Bir ayın kişinin doğasıyla buluşma biçimi.
enum AyAkisi {
  /// Ayın teması kişinin doğasıyla aynı yönde.
  akis,

  /// Ne destekleyici ne zorlayıcı.
  dengeli,

  /// Ayın teması kişinin gölge yanına dokunuyor.
  zorlu,
}

/// Yıllık raporun tek bölümü.
class YillikBolum {
  /// Tüm alanlarıyla bölüm oluşturur.
  const YillikBolum({
    required this.tur,
    required this.baslik,
    required this.metin,
    required this.premium,
  });

  /// Bölüm türü.
  final YillikBolumTuru tur;

  /// Bölüm başlığı.
  final String baslik;

  /// Gösterime hazır metin.
  final String metin;

  /// Ücretli rapor içeriği mi?
  final bool premium;
}

/// Yılın bir ayının okuması.
class YillikAy {
  /// Tüm alanlarıyla ay oluşturur.
  const YillikAy({
    required this.ay,
    required this.kisiselAy,
    required this.baslik,
    required this.metin,
    required this.akis,
    required this.premium,
  });

  /// Takvim ayı (1-12).
  final int ay;

  /// Kişisel ay sayısı (1-9).
  final int kisiselAy;

  /// Kart başlığı ("Mart · Emek ve düzen ayı").
  final String baslik;

  /// Ayın metni.
  final String metin;

  /// Ayın kişinin doğasıyla buluşması.
  final AyAkisi akis;

  /// Ücretli rapor içeriği mi?
  final bool premium;
}

/// Kişisel Yıl Raporu'nun tamamı.
class YillikRaporOkumasi {
  /// Tüm alanlarıyla okuma oluşturur.
  const YillikRaporOkumasi({
    required this.yil,
    required this.kisiselYil,
    required this.yilLakabi,
    required this.bolumler,
    required this.aylar,
  });

  /// Takvim yılı.
  final int yil;

  /// Kişisel yıl sayısı (1-9).
  final int kisiselYil;

  /// Yılın lakabı ("Tohum Yılı").
  final String yilLakabi;

  /// Sıralı rapor bölümleri.
  final List<YillikBolum> bolumler;

  /// Ocak → Aralık ay okumaları.
  final List<YillikAy> aylar;
}

/// [rapor] sahibinin [yil] takvim yılı için Kişisel Yıl Raporu.
///
/// Ücretsiz kısım: yılın teması ve ilk [ContentConfig.yillikUcretsizAy]
/// ay. Diğer her şey premium'dur.
///
/// [paket]: içerik dili. Bu okumanın metinleri henüz yalnız Türkçe;
/// İngilizce havuzlar E8 oturumunda pakete bağlanır.
YillikRaporOkumasi yillikRaporOkumasi({
  required NumerolojiRaporu rapor,
  required int yil,
  IcerikPaketi paket = trIcerik,
}) {
  final DateTime dogum = rapor.dogumTarihi;
  final int kisiselYil = Numeroloji.kisiselYil(dogum, yil);
  final KisiselYilMetni yilMetni = DonguMetinleri.kisiselYil[kisiselYil]!;
  final YilRehberi rehber = YillikRaporMetinleri.rehberler[kisiselYil]!;
  final KarakterYonu karakter =
      YorumYonu.karakterler[Numeroloji.yasamYolu(dogum).deger]!;

  // ---- Ay ay okuma ----
  final List<int> kisiselAylar = DerinNumeroloji.kisiselAylar(dogum, yil);
  // Aynı kişisel ay yılda en fazla iki kez gelir: ilkine A, ikincisine B.
  final Map<int, int> gorulme = <int, int>{};
  final List<YillikAy> aylar = <YillikAy>[
    for (int i = 0; i < kisiselAylar.length; i++)
      () {
        final int ka = kisiselAylar[i];
        final AyTemasi tema = YillikRaporMetinleri.aylar[ka]!;
        final int sira = gorulme[ka] ?? 0;
        gorulme[ka] = sira + 1;
        final BulusmaTuru b = karakter.bulusma(ka);
        return YillikAy(
          ay: i + 1,
          kisiselAy: ka,
          baslik: YillikRaporMetinleri.ayBasligi(i + 1, tema.lakap),
          metin: tema.varyantlar[sira % tema.varyantlar.length],
          akis: switch (b) {
            BulusmaTuru.uyumlu => AyAkisi.akis,
            BulusmaTuru.dengeli => AyAkisi.dengeli,
            BulusmaTuru.zorlayici => AyAkisi.zorlu,
          },
          premium: i >= ContentConfig.yillikUcretsizAy,
        );
      }(),
  ];

  List<int> akistakiler(AyAkisi a) => <int>[
    for (final YillikAy ay in aylar)
      if (ay.akis == a) ay.ay,
  ];
  final List<int> akisAylari = akistakiler(AyAkisi.akis);
  final List<int> zorluAylar = akistakiler(AyAkisi.zorlu);

  // ---- Dönem geçişi: bu yıl girilen yaş bir dönemin başlangıcı mı? ----
  final int buYilGirilenYas = yil - dogum.year;
  YasamDonemi? yeniDonem;
  for (final YasamDonemi d in rapor.donemler) {
    if (d.sira > 1 && d.baslangicYasi == buYilGirilenYas) {
      yeniDonem = d;
    }
  }

  return YillikRaporOkumasi(
    yil: yil,
    kisiselYil: kisiselYil,
    yilLakabi: yilMetni.baslik,
    aylar: aylar,
    bolumler: <YillikBolum>[
      YillikBolum(
        tur: YillikBolumTuru.tema,
        baslik: YillikRaporMetinleri.temaBasligi(
          yil,
          yilMetni.baslik,
          kisiselYil,
        ),
        metin: slotDoldur(yilMetni.uzun, <String, String>{
          SlotAnahtarlari.yil: '$yil',
        }),
        premium: false,
      ),
      if (yeniDonem != null)
        YillikBolum(
          tur: YillikBolumTuru.donemGecisi,
          baslik: YillikRaporMetinleri.donemGecisiBasligi(
            RaporMetinleri.yasAraligi(yeniDonem),
          ),
          metin: <String>[
            YillikRaporMetinleri.donemGecisiGirisi,
            RaporMetinleri.zirveler[yeniDonem.zirve]!.kisa,
          ].join(' '),
          premium: true,
        ),
      YillikBolum(
        tur: YillikBolumTuru.firsatlar,
        baslik: YillikRaporMetinleri.firsatlarBasligi,
        metin: rehber.firsatlar,
        premium: true,
      ),
      YillikBolum(
        tur: YillikBolumTuru.dikkat,
        baslik: YillikRaporMetinleri.dikkatBasligi,
        metin: rehber.dikkat,
        premium: true,
      ),
      YillikBolum(
        tur: YillikBolumTuru.ask,
        baslik: YillikRaporMetinleri.askBasligi,
        metin: rehber.ask,
        premium: true,
      ),
      YillikBolum(
        tur: YillikBolumTuru.isVePara,
        baslik: YillikRaporMetinleri.isVeParaBasligi,
        metin: rehber.isVePara,
        premium: true,
      ),
      if (akisAylari.isNotEmpty)
        YillikBolum(
          tur: YillikBolumTuru.akisAylari,
          baslik: YillikRaporMetinleri.akisBasligi,
          metin:
              '${YillikRaporMetinleri.ayListesi(akisAylari)}. '
              '${YillikRaporMetinleri.akisAciklamasi}',
          premium: true,
        ),
      if (zorluAylar.isNotEmpty)
        YillikBolum(
          tur: YillikBolumTuru.zorluAylar,
          baslik: YillikRaporMetinleri.zorluBasligi,
          metin:
              '${YillikRaporMetinleri.ayListesi(zorluAylar)}. '
              '${YillikRaporMetinleri.zorluAciklamasi}',
          premium: true,
        ),
      YillikBolum(
        tur: YillikBolumTuru.niyet,
        baslik: YillikRaporMetinleri.niyetBasligi,
        metin: rehber.niyet,
        premium: true,
      ),
    ],
  );
}
