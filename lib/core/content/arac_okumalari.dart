/// Keşfet araçlarının okumaları: numara analizi, isim analizi, bebek ismi.
///
/// Motorun metinsiz sonuçlarını (`NumaraAnalizi`, `IsimAnalizi`,
/// `IsimUyumu`) gösterime hazır metinlere çevirir. Rastgele seçim yoktur;
/// aynı girdi HER ZAMAN aynı okumayı verir (CLAUDE.md kural 8).
library;

import '../luck_engine/luck_engine.dart';
import 'arac_metinleri.dart';
import 'content_config.dart';
import 'icerik_paketi.dart';
import 'rapor_metinleri.dart';
import 'sayi_metinleri.dart';
import 'slot_doldurucu.dart';
import 'tr_icerik_paketi.dart';

/// Bir araç okumasının tek bölümü.
class AracBolumu {
  /// Tüm alanlarıyla bölüm oluşturur.
  const AracBolumu({
    required this.baslik,
    required this.metin,
    required this.premium,
  });

  /// Bölüm başlığı.
  final String baslik;

  /// Gösterime hazır metin.
  final String metin;

  /// Ücretli içerik mi?
  final bool premium;
}

/// Numara analizinin okuması (tamamı ücretsiz ve paylaşılabilir).
class NumaraOkumasi {
  /// Tüm alanlarıyla okuma oluşturur.
  const NumaraOkumasi({
    required this.analiz,
    required this.lakap,
    required this.baslik,
    required this.metin,
  });

  /// Motorun analizi.
  final NumaraAnalizi analiz;

  /// Sayının lakabı ("Usta İlham").
  final String lakap;

  /// Başlık ("Numaranın sayısı 11 · Usta İlham").
  final String baslik;

  /// Metin (varsa karmik notuyla).
  final String metin;
}

/// Bebek ismi uyumunun okuması.
class BebekIsmiOkumasi {
  /// Tüm alanlarıyla okuma oluşturur.
  const BebekIsmiOkumasi({
    required this.uyum,
    required this.bant,
    required this.iliskiCumleleri,
  });

  /// Motorun uyum sonucu.
  final IsimUyumu uyum;

  /// Puanın bandı (etiket + açıklama).
  final UyumBandi bant;

  /// Her referans kişi için ilişki cümlesi (referans sırasıyla).
  final List<String> iliskiCumleleri;
}

/// [analiz] için numara okuması.
///
/// [paket]: içerik dili. Bu okumanın metinleri henüz yalnız Türkçe;
/// İngilizce havuzlar E9 oturumunda pakete bağlanır.
NumaraOkumasi numaraOkumasi(
  NumaraAnalizi analiz, {
  IcerikPaketi paket = trIcerik,
}) {
  final NumaraMetni m = AracMetinleri.numaralar[analiz.deger]!;
  final int? karmik = analiz.karmikBorc;
  return NumaraOkumasi(
    analiz: analiz,
    lakap: m.lakap,
    baslik: AracMetinleri.numaraBasligi(analiz.deger, m.lakap),
    metin: <String>[
      m.metin,
      if (karmik != null)
        AracMetinleri.numaraKarmikNotu(
          karmik,
          RaporMetinleri.karmikBorclar[karmik]!.lakap,
        ),
    ].join(' '),
  );
}

/// [analiz] için isim analizi bölümleri.
///
/// Ücretsiz: isim, ruh ve kişilik sayıları. Premium: karmik borçlar,
/// karmik dersler, gizli tutku ve ilk/son harf.
///
/// [paket]: içerik dili. Bu okumanın metinleri henüz yalnız Türkçe;
/// İngilizce havuzlar E9 oturumunda pakete bağlanır.
List<AracBolumu> isimOkumasi(
  IsimAnalizi analiz, {
  IcerikPaketi paket = trIcerik,
}) {
  final SayiHesabi? ruh = analiz.ruh;
  final SayiHesabi? kisilik = analiz.kisilik;

  // Aynı karmik sayı birden çok hesapta görülürse tek bölümde birleşir.
  final Map<int, List<KarmikKaynak>> karmik = <int, List<KarmikKaynak>>{};
  for (final KarmikBorc b in analiz.karmikBorclar) {
    karmik.putIfAbsent(b.sayi, () => <KarmikKaynak>[]).add(b.kaynak);
  }

  return <AracBolumu>[
    AracBolumu(
      baslik: AracMetinleri.isimBasligi(analiz.isim.deger),
      metin: SayiMetinleri.isimSayisi[analiz.isim.deger]!,
      premium: false,
    ),
    if (ruh != null)
      AracBolumu(
        baslik: AracMetinleri.ruhBasligi(ruh.deger),
        metin: SayiMetinleri.ruhSayisi[ruh.deger]!,
        premium: false,
      ),
    if (kisilik != null)
      AracBolumu(
        baslik: AracMetinleri.kisilikBasligi(kisilik.deger),
        metin: SayiMetinleri.kisilikSayisi[kisilik.deger]!,
        premium: false,
      ),
    for (final MapEntry<int, List<KarmikKaynak>> e in karmik.entries)
      AracBolumu(
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
    AracBolumu(
      baslik: RaporMetinleri.karmikDersBasligi,
      metin: analiz.karmikDersler.isEmpty
          ? RaporMetinleri.karmikDersYok
          : analiz.karmikDersler
                .map((int s) => RaporMetinleri.karmikDersler[s]!)
                .join(' '),
      premium: true,
    ),
    AracBolumu(
      baslik: RaporMetinleri.gizliTutkuBasligi,
      metin: <String>[
        RaporMetinleri.gizliTutkuGirisi(analiz.gizliTutku),
        ...analiz.gizliTutku.map((int s) => RaporMetinleri.gizliTutkular[s]!),
      ].join(' '),
      premium: true,
    ),
    AracBolumu(
      baslik: RaporMetinleri.harfBasligi(
        analiz.temelTasi.harf,
        analiz.tepeTasi.harf,
      ),
      metin: <String>[
        RaporMetinleri.temelTaslari[analiz.temelTasi.harf] ??
            RaporMetinleri.temelTasiDegere[analiz.temelTasi.deger]!,
        RaporMetinleri.tepeTaslari[analiz.tepeTasi.deger]!,
      ].join(' '),
      premium: true,
    ),
  ];
}

/// [puan] için bebek ismi uyum bandı.
UyumBandi bebekBandi(int puan) {
  final List<int> esikler = ContentConfig.bebekBantEsikleri;
  for (int i = 0; i < esikler.length; i++) {
    if (puan >= esikler[i]) {
      return AracMetinleri.bebekBantlari[i];
    }
  }
  return AracMetinleri.bebekBantlari.last;
}

/// [uyum] için bebek ismi okuması; [referansAdlari], uyum hesabındaki
/// doğum tarihleriyle aynı sırada kişilerin adları ya da rolleridir
/// ("Anne", "Baba").
///
/// [paket]: içerik dili. Bu okumanın metinleri henüz yalnız Türkçe;
/// İngilizce havuzlar E9 oturumunda pakete bağlanır.
BebekIsmiOkumasi bebekIsmiOkumasi(
  IsimUyumu uyum,
  List<String> referansAdlari, {
  IcerikPaketi paket = trIcerik,
}) {
  if (referansAdlari.length != uyum.iliskiler.length) {
    throw ArgumentError.value(
      referansAdlari,
      'referansAdlari',
      'Uyumdaki referans sayısıyla aynı olmalı',
    );
  }
  return BebekIsmiOkumasi(
    uyum: uyum,
    bant: bebekBandi(uyum.puan),
    iliskiCumleleri: <String>[
      for (int i = 0; i < uyum.iliskiler.length; i++)
        slotDoldur(
          AracMetinleri.bebekIliskileri[uyum.iliskiler[i]]!,
          <String, String>{SlotAnahtarlari.digerIsim: referansAdlari[i]},
        ),
    ],
  );
}
