/// Doğum haritasının okunabilir hâli: Güneş, Ay ve Yükselen ("büyük
/// üçlü").
///
/// [haritaOkumasi], motorun [DogumHaritasi] sonucunu ekran bölümlerine
/// çevirir ve belirsizlikleri dürüstçe not eder: Ay o gün burç
/// değiştirdiyse ya da Yükselen sınırdaysa komşu burcun yorumu da
/// "alternatif" bölüm olarak eklenir. Rastgele seçim yoktur (CLAUDE.md
/// kural 8).
library;

import '../luck_engine/luck_engine.dart';
import 'harita_metinleri.dart';
import 'icerik_paketi.dart';
import 'tr_icerik_paketi.dart';

/// Harita bölümünün türü.
enum HaritaBolumTuru {
  /// Ay burcu.
  ay,

  /// Yükselen.
  yukselen,
}

/// Harita okumasının tek bölümü.
class HaritaBolumu {
  /// Tüm alanlarıyla bölüm oluşturur.
  const HaritaBolumu({
    required this.tur,
    required this.burc,
    required this.baslik,
    required this.metin,
    required this.alternatif,
    required this.premium,
  });

  /// Bölüm türü.
  final HaritaBolumTuru tur;

  /// Bölümün anlattığı burç.
  final Burc burc;

  /// Bölüm başlığı.
  final String baslik;

  /// Gösterime hazır metin.
  final String metin;

  /// Belirsizlik nedeniyle eklenen komşu burç yorumu mu?
  final bool alternatif;

  /// Ücretli içerik mi? (Ay ücretsiz; Yükselen yorumu premium.)
  final bool premium;
}

/// Doğum haritası okumasının tamamı.
class HaritaOkumasi {
  /// Tüm alanlarıyla okuma oluşturur.
  const HaritaOkumasi({
    required this.gunes,
    required this.ay,
    required this.yukselen,
    required this.ozet,
    required this.bolumler,
    required this.notlar,
  });

  /// Güneş burcu.
  final Burc gunes;

  /// Ay burcu.
  final Burc ay;

  /// Yükselen; saat ya da konum yoksa null.
  final Burc? yukselen;

  /// "Güneş Balık · Ay Yay · Yükselen Kova".
  final String ozet;

  /// Sıralı bölümler (alternatifler ait oldukları bölümün hemen ardında).
  final List<HaritaBolumu> bolumler;

  /// Belirsizlik ve eksik bilgi notları (gösterim sırasıyla).
  final List<String> notlar;
}

/// [boylam]ın en yakın sınırının öbür tarafındaki burç.
Burc komsuBurc(double boylam) {
  final double burcIci =
      Astronomi.normalize(boylam) % EngineConfig.burcGenisligi;
  final double yarim = EngineConfig.burcGenisligi / 2;
  // Sınırın öbür yanına yarım burç kadar geçip o burcu oku.
  return burcIci < yarim
      ? Astronomi.burc(boylam - burcIci - yarim)
      : Astronomi.burc(boylam + (EngineConfig.burcGenisligi - burcIci) + yarim);
}

/// [harita] için okuma.
///
/// [saatBiliniyor] ve [konumBiliniyor] eksik bilgi notunu, [saatDilimiKesin]
/// (bkz. `TurkiyeSaatDilimi`) Yükselen güvenilirlik notunu belirler.
///
/// [paket]: içerik dili. Bu okumanın metinleri henüz yalnız Türkçe;
/// İngilizce havuzlar E9 oturumunda pakete bağlanır.
HaritaOkumasi haritaOkumasi({
  required DogumHaritasi harita,
  required bool saatBiliniyor,
  required bool konumBiliniyor,
  bool saatDilimiKesin = true,
  IcerikPaketi paket = trIcerik,
}) {
  final List<HaritaBolumu> bolumler = <HaritaBolumu>[];
  final List<String> notlar = <String>[];

  // ---- Ay ----
  final Burc ay = harita.ayBurcu;
  bolumler.add(
    HaritaBolumu(
      tur: HaritaBolumTuru.ay,
      burc: ay,
      baslik: HaritaMetinleri.ayBasligi(ay),
      metin: HaritaMetinleri.aylar[ay]!,
      alternatif: false,
      premium: false,
    ),
  );
  if (!harita.ayBurcuKesin) {
    final Burc komsu = komsuBurc(harita.ayBoylami);
    notlar.add(
      saatBiliniyor
          ? HaritaMetinleri.aySinirda(ay, komsu)
          : HaritaMetinleri.ayGunIcindeDegisiyor(ay, komsu),
    );
    bolumler.add(
      HaritaBolumu(
        tur: HaritaBolumTuru.ay,
        burc: komsu,
        baslik: HaritaMetinleri.alternatifBasligi(
          HaritaMetinleri.ayTuru,
          komsu,
        ),
        metin: HaritaMetinleri.aylar[komsu]!,
        alternatif: true,
        premium: false,
      ),
    );
  }

  // ---- Yükselen ----
  final Burc? yukselen = harita.yukselen;
  if (yukselen == null) {
    notlar.add(HaritaMetinleri.yukselenIcinBilgiEksik);
  } else {
    bolumler.add(
      HaritaBolumu(
        tur: HaritaBolumTuru.yukselen,
        burc: yukselen,
        baslik: HaritaMetinleri.yukselenBasligi(yukselen),
        metin: HaritaMetinleri.yukselenler[yukselen]!,
        alternatif: false,
        premium: true,
      ),
    );
    if (!saatDilimiKesin) {
      notlar.add(HaritaMetinleri.saatDilimiBelirsiz);
    }
    if (harita.yukselenSinirda) {
      final Burc komsu = komsuBurc(harita.yukselenBoylami!);
      notlar.add(HaritaMetinleri.yukselenSinirda(yukselen, komsu));
      bolumler.add(
        HaritaBolumu(
          tur: HaritaBolumTuru.yukselen,
          burc: komsu,
          baslik: HaritaMetinleri.alternatifBasligi(
            HaritaMetinleri.yukselenTuru,
            komsu,
          ),
          metin: HaritaMetinleri.yukselenler[komsu]!,
          alternatif: true,
          premium: true,
        ),
      );
    }
  }

  return HaritaOkumasi(
    gunes: harita.gunesBurcu,
    ay: ay,
    yukselen: yukselen,
    ozet: HaritaMetinleri.ozet(harita.gunesBurcu, ay, yukselen),
    bolumler: bolumler,
    notlar: notlar,
  );
}
