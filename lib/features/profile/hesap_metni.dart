import '../../core/luck_engine/luck_engine.dart';
import 'profile_strings.dart';

/// Bir hesap adımının okunur satırı: etiket + işlem.
class HesapSatiri {
  /// [etiket] ve [islem] ile satır oluşturur.
  const HesapSatiri({required this.etiket, required this.islem});

  /// Adımın etiketi ("Doğum yılı").
  final String etiket;

  /// İşlem metni ("1994 → 1+9+9+4 = 23 → 5").
  final String islem;
}

/// [SayiHesabi] adımlarını kullanıcıya gösterilecek satırlara çevirir.
///
/// Amaç, sonucun rastgele olmadığını adım adım göstermektir; bu yüzden
/// indirgeme zinciri (23 → 5) de açıkça yazılır.
List<HesapSatiri> hesapSatirlari(SayiHesabi hesap) => <HesapSatiri>[
      for (final HesapAdimi adim in hesap.adimlar)
        HesapSatiri(etiket: _etiket(adim.tur), islem: _islem(adim)),
    ];

String _etiket(HesapAdimTuru tur) => switch (tur) {
      HesapAdimTuru.ay => ProfileStrings.adimAy,
      HesapAdimTuru.gun => ProfileStrings.adimGun,
      HesapAdimTuru.yil => ProfileStrings.adimYil,
      HesapAdimTuru.toplam => ProfileStrings.adimToplam,
      HesapAdimTuru.harfler => ProfileStrings.adimHarfler,
      HesapAdimTuru.sesliler => ProfileStrings.adimSesliler,
      HesapAdimTuru.sessizler => ProfileStrings.adimSessizler,
    };

String _islem(HesapAdimi adim) {
  final String toplam = adim.terimler.join('+');
  final String zincir = indirgemeZinciri(adim.hamToplam)
      .skip(1)
      .map((int n) => ' → $n')
      .join();
  switch (adim.tur) {
    case HesapAdimTuru.ay:
    case HesapAdimTuru.gun:
    case HesapAdimTuru.yil:
      // Zaten indirgenmiş değer (ör. ay 03 → 3, usta gün 11 → 11) için
      // toplama işlemi gösterilmez.
      if (int.tryParse(adim.kaynak) == adim.sonuc) {
        return '${adim.kaynak} → ${adim.sonuc}';
      }
      return '${adim.kaynak} → $toplam = ${adim.hamToplam}$zincir';
    case HesapAdimTuru.toplam:
      return '$toplam = ${adim.hamToplam}$zincir';
    case HesapAdimTuru.harfler:
    case HesapAdimTuru.sesliler:
    case HesapAdimTuru.sessizler:
      final List<String> harfler = adim.kaynak.runes
          .map((int r) => String.fromCharCode(r).toUpperCase())
          .toList();
      final String ciftler = <String>[
        for (int i = 0; i < harfler.length && i < adim.terimler.length; i++)
          '${harfler[i]}${adim.terimler[i]}',
      ].join(' ');
      return '$ciftler = ${adim.hamToplam}$zincir';
  }
}

/// [ham] toplamdan başlayarak indirgeme zinciri: 23 → [23, 5];
/// usta sayıda durur: 29 → [29, 11].
List<int> indirgemeZinciri(int ham) {
  final List<int> zincir = <int>[ham];
  int kalan = ham;
  while (kalan > EngineConfig.numerolojiTabani &&
      !EngineConfig.ustaSayilar.contains(kalan)) {
    kalan = Numeroloji.rakamToplami(kalan);
    zincir.add(kalan);
  }
  return zincir;
}
