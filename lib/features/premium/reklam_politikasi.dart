import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/providers.dart';
import '../../core/storage/uygulama_durumu.dart';
import '../ads/ads_providers.dart';
import 'premium_kontrolcu.dart';
import 'premium_providers.dart';

/// Doğal bir geçiş anında (ör. kategori detayından dönüş) geçiş reklamını
/// POLİTİKA İZİN VERİRSE gösterir.
///
/// Politika [gecisReklamiGosterilebilir] içinde: premium kullanıcıya hiç,
/// ilk günlerde hiç, sonrasında en fazla ~günde bir. Onboarding, satın
/// alma ve okuma sırasında çağrılmaz.
Future<void> gecisReklamiDene(WidgetRef ref) async {
  final UygulamaDurumuRepository depo =
      ref.read(uygulamaDurumuRepositoryProvider);
  final UygulamaDurumu durum = depo.durum;
  final DateTime simdi = ref.read(saatProvider)();
  final bool uygun = gecisReklamiGosterilebilir(
    simdi: simdi,
    premium: ref.read(entitlementProvider),
    ilkAcilis: durum.ilkAcilis,
    sonGosterim: durum.sonGecisReklami,
  );
  if (!uygun) {
    return;
  }
  final bool gosterildi = await ref.read(reklamServisiProvider).gecisGoster();
  if (gosterildi) {
    await depo.gecisReklamiGosterildi(simdi);
  }
}
