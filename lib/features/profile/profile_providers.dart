import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/rapor_okumasi.dart';
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
