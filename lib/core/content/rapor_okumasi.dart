/// Derin numeroloji raporunun okunabilir hâli.
///
/// [raporOkumasi], motorun metinsiz [NumerolojiRaporu]nu ekran sırasına
/// dizilmiş bölümlere çevirir. Hiçbir rastgele seçim yoktur: aynı rapor
/// ve aynı gün HER ZAMAN aynı okumayı verir (CLAUDE.md kural 8). Gün
/// yalnızca kişinin hangi yaşam döneminde olduğunu belirler.
library;

import '../luck_engine/luck_engine.dart';
import 'icerik_paketi.dart';
import 'rapor_metinleri.dart';
import 'tr_icerik_paketi.dart';

/// Rapor bölümlerinin türleri (sıra = ekrandaki sıra).
enum RaporBolumTuru {
  /// İçinde bulunulan dönemin zirvesi (fırsat teması).
  aktifZirve,

  /// İçinde bulunulan dönemin zorluğu (ders teması).
  aktifZorluk,

  /// Sıradaki dönemin önizlemesi.
  sonrakiDonem,

  /// Bir karmik borç sayısı (ya da hiç olmaması).
  karmikBorc,

  /// İsimde eksik sayılar.
  karmikDers,

  /// İsimde en sık geçen sayı(lar).
  gizliTutku,

  /// Olgunluk sayısı.
  olgunluk,

  /// Temel taşı ve tepe taşı harfleri.
  harfler,

  /// Denge sayısı.
  denge,
}

/// Raporun tek bölümü.
class RaporBolumu {
  /// Tüm alanlarıyla bölüm oluşturur.
  const RaporBolumu({
    required this.tur,
    required this.baslik,
    required this.metin,
    required this.premium,
  });

  /// Bölüm türü.
  final RaporBolumTuru tur;

  /// Bölüm başlığı.
  final String baslik;

  /// Gösterime hazır metin.
  final String metin;

  /// Ücretli rapor içeriği mi?
  final bool premium;
}

/// Zaman çizelgesindeki bir dönemin özeti.
class DonemOzeti {
  /// Tüm alanlarıyla özet oluşturur.
  const DonemOzeti({
    required this.donem,
    required this.yasAraligi,
    required this.zirveOzeti,
    required this.zorlukOzeti,
    required this.aktif,
  });

  /// Motorun dönem verisi.
  final YasamDonemi donem;

  /// Yaş aralığı etiketi ("32-41 yaş").
  final String yasAraligi;

  /// Zirvenin tek cümlelik özeti.
  final String zirveOzeti;

  /// Zorluğun tek cümlelik özeti.
  final String zorlukOzeti;

  /// Kişi şu an bu dönemde mi?
  final bool aktif;
}

/// Derin numeroloji raporunun tamamı.
class RaporOkumasi {
  /// [zamanCizelgesi] ve [bolumler] ile okuma oluşturur.
  const RaporOkumasi({required this.zamanCizelgesi, required this.bolumler});

  /// Dört dönemin özeti (sırayla); ücretsiz önizleme olarak gösterilir.
  final List<DonemOzeti> zamanCizelgesi;

  /// Sıralı rapor bölümleri.
  final List<RaporBolumu> bolumler;
}

/// [rapor] için [gun] tarihindeki rapor okumasını üretir.
///
/// Ücretsiz kısım: zaman çizelgesi ve içinde bulunulan dönemin zirvesi.
/// Diğer bölümler premium'dur. İsim tabanlı bölümler, rapor tam ad
/// olmadan hesaplandıysa listede yer almaz.
///
/// [paket]: içerik dili. Bu okumanın metinleri henüz yalnız Türkçe;
/// İngilizce havuzlar E8 oturumunda pakete bağlanır.
RaporOkumasi raporOkumasi({
  required NumerolojiRaporu rapor,
  required DateTime gun,
  IcerikPaketi paket = trIcerik,
}) {
  final YasamDonemi aktif = rapor.aktifDonem(gun);
  final List<RaporBolumu> bolumler = <RaporBolumu>[
    RaporBolumu(
      tur: RaporBolumTuru.aktifZirve,
      baslik: RaporMetinleri.aktifZirveBasligi(aktif.zirve),
      metin: RaporMetinleri.zirveler[aktif.zirve]!.uzun,
      premium: false,
    ),
    RaporBolumu(
      tur: RaporBolumTuru.aktifZorluk,
      baslik: RaporMetinleri.aktifZorlukBasligi(aktif.zorluk),
      metin: RaporMetinleri.zorluklar[aktif.zorluk]!.uzun,
      premium: true,
    ),
  ];

  // Son dönemde sıradaki dönem yoktur.
  if (aktif.sira < rapor.donemler.length) {
    final YasamDonemi sonraki = rapor.donemler[aktif.sira];
    bolumler.add(
      RaporBolumu(
        tur: RaporBolumTuru.sonrakiDonem,
        baslik: RaporMetinleri.sonrakiDonemBasligi(
          RaporMetinleri.yasAraligi(sonraki),
        ),
        metin: <String>[
          RaporMetinleri.zirveler[sonraki.zirve]!.kisa,
          RaporMetinleri.zorluklar[sonraki.zorluk]!.kisa,
        ].join(' '),
        premium: true,
      ),
    );
  }

  bolumler.addAll(_karmikBorcBolumleri(rapor.karmikBorclar));

  final List<int>? dersler = rapor.karmikDersler;
  if (dersler != null) {
    bolumler.add(
      RaporBolumu(
        tur: RaporBolumTuru.karmikDers,
        baslik: RaporMetinleri.karmikDersBasligi,
        metin: dersler.isEmpty
            ? RaporMetinleri.karmikDersYok
            : dersler
                  .map((int s) => RaporMetinleri.karmikDersler[s]!)
                  .join(' '),
        premium: true,
      ),
    );
  }

  final List<int>? tutku = rapor.gizliTutku;
  if (tutku != null) {
    bolumler.add(
      RaporBolumu(
        tur: RaporBolumTuru.gizliTutku,
        baslik: RaporMetinleri.gizliTutkuBasligi,
        metin: <String>[
          RaporMetinleri.gizliTutkuGirisi(tutku),
          ...tutku.map((int s) => RaporMetinleri.gizliTutkular[s]!),
        ].join(' '),
        premium: true,
      ),
    );
  }

  final int? olgunluk = rapor.olgunluk;
  if (olgunluk != null) {
    bolumler.add(
      RaporBolumu(
        tur: RaporBolumTuru.olgunluk,
        baslik: RaporMetinleri.olgunlukBasligi(olgunluk),
        metin: RaporMetinleri.olgunluk[olgunluk]!,
        premium: true,
      ),
    );
  }

  final HarfBilgisi? ilk = rapor.temelTasi;
  final HarfBilgisi? son = rapor.tepeTasi;
  if (ilk != null && son != null) {
    bolumler.add(
      RaporBolumu(
        tur: RaporBolumTuru.harfler,
        baslik: RaporMetinleri.harfBasligi(ilk.harf, son.harf),
        metin: <String>[
          RaporMetinleri.temelTaslari[ilk.harf] ??
              RaporMetinleri.temelTasiDegere[ilk.deger]!,
          RaporMetinleri.tepeTaslari[son.deger]!,
        ].join(' '),
        premium: true,
      ),
    );
  }

  final int? denge = rapor.dengeSayisi;
  if (denge != null) {
    bolumler.add(
      RaporBolumu(
        tur: RaporBolumTuru.denge,
        baslik: RaporMetinleri.dengeBasligi(denge),
        metin: RaporMetinleri.dengeler[denge]!,
        premium: true,
      ),
    );
  }

  return RaporOkumasi(
    zamanCizelgesi: <DonemOzeti>[
      for (final YasamDonemi d in rapor.donemler)
        DonemOzeti(
          donem: d,
          yasAraligi: RaporMetinleri.yasAraligi(d),
          zirveOzeti: RaporMetinleri.zirveler[d.zirve]!.kisa,
          zorlukOzeti: RaporMetinleri.zorluklar[d.zorluk]!.kisa,
          aktif: d.sira == aktif.sira,
        ),
    ],
    bolumler: bolumler,
  );
}

/// Karmik borç bölümleri: aynı sayı birden çok hesapta görülürse tek
/// bölümde birleştirilir; hiç yoksa tek bir "borç yok" bölümü döner.
List<RaporBolumu> _karmikBorcBolumleri(List<KarmikBorc> borclar) {
  if (borclar.isEmpty) {
    return const <RaporBolumu>[
      RaporBolumu(
        tur: RaporBolumTuru.karmikBorc,
        baslik: RaporMetinleri.karmikBorcYokBasligi,
        metin: RaporMetinleri.karmikBorcYok,
        premium: true,
      ),
    ];
  }
  // Sayıların ilk görülme sırası korunur (motorun kaynak sırası).
  final Map<int, List<KarmikKaynak>> kaynaklar = <int, List<KarmikKaynak>>{};
  for (final KarmikBorc b in borclar) {
    kaynaklar.putIfAbsent(b.sayi, () => <KarmikKaynak>[]).add(b.kaynak);
  }
  return <RaporBolumu>[
    for (final MapEntry<int, List<KarmikKaynak>> e in kaynaklar.entries)
      RaporBolumu(
        tur: RaporBolumTuru.karmikBorc,
        baslik: RaporMetinleri.karmikBorcBasligi(
          e.key,
          RaporMetinleri.karmikBorclar[e.key]!.lakap,
        ),
        metin: <String>[
          RaporMetinleri.karmikKaynakCumlesi(e.value),
          RaporMetinleri.karmikBorclar[e.key]!.metin,
        ].join(' '),
        premium: true,
      ),
  ];
}
