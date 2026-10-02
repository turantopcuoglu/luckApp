import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/harita_okumasi.dart';
import '../../core/content/rapor_okumasi.dart';
import '../../core/content/yillik_rapor.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/user_profile.dart';
import '../daily_luck/daily_luck_providers.dart';

/// Aktif kullanıcının derin numeroloji raporu (metinsiz ham veri).
///
/// Yalnızca doğum tarihi ve tam ada bağlıdır; profil değişince yeniden
/// hesaplanır.
final Provider<NumerolojiRaporu> numerolojiRaporuProvider =
    Provider<NumerolojiRaporu>((Ref ref) {
      final UserProfile profil = ref.watch(aktifProfilProvider);
      return NumerolojiRaporu.hesapla(
        dogumTarihi: profil.dogumTarihi,
        tamAd: profil.tamAd,
      );
    });

/// Aktif kullanıcının bugünkü rapor okuması (aktif dönem güne bağlıdır).
final Provider<RaporOkumasi> raporOkumasiProvider = Provider<RaporOkumasi>(
  (Ref ref) => raporOkumasi(
    rapor: ref.watch(numerolojiRaporuProvider),
    gun: ref.watch(bugunProvider),
  ),
);

/// Aktif kullanıcının [yil] takvim yılı için Kişisel Yıl Raporu.
final ProviderFamily<YillikRaporOkumasi, int> yillikRaporProvider =
    Provider.family<YillikRaporOkumasi, int>(
      (Ref ref, int yil) => yillikRaporOkumasi(
        rapor: ref.watch(numerolojiRaporuProvider),
        yil: yil,
      ),
    );

/// Aktif kullanıcının doğum haritası okuması (Güneş, Ay, Yükselen).
///
/// Doğum saati yoksa Ay öğlen için hesaplanır ve Yükselen hesaplanmaz;
/// saat dilimi Türkiye'nin o tarihteki kuralından bulunur.
final Provider<HaritaOkumasi> haritaOkumasiProvider = Provider<HaritaOkumasi>(
  (Ref ref) {
    final UserProfile p = ref.watch(aktifProfilProvider);
    final int? dakika = p.dogumSaatiDakika;
    final bool saatVar = dakika != null;
    final DateTime yerel = DateTime(
      p.dogumTarihi.year,
      p.dogumTarihi.month,
      p.dogumTarihi.day,
      saatVar ? dakika ~/ Duration.minutesPerHour : EngineConfig.bilinmeyenSaat,
      saatVar ? dakika % Duration.minutesPerHour : 0,
    );
    final SaatDilimiSonucu dilim = TurkiyeSaatDilimi.utcFarki(yerel);
    final int? plaka = p.dogumIliPlaka;
    final Il? il = plaka == null ? null : TurkiyeIlleri.plakadan(plaka);
    return haritaOkumasi(
      harita: DogumHaritasi.hesapla(
        yerelDogum: yerel,
        utcFarkiSaat: dilim.farkSaat.toDouble(),
        saatBiliniyor: saatVar,
        enlem: il?.enlem,
        boylam: il?.boylam,
      ),
      saatBiliniyor: saatVar,
      konumBiliniyor: il != null,
      saatDilimiKesin: dilim.kesin,
    );
  },
);
