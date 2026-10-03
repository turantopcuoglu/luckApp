import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/koleksiyon_repository.dart';
import '../../core/storage/providers.dart';
import '../daily_luck/daily_luck_providers.dart';
import 'koleksiyon_katalogu.dart';

/// Bugünün kartı: katalogdaki kart ve çekilişin nadir olup olmadığı.
class GununKarti {
  /// [kart] ve [nadir] ile oluşturur.
  const GununKarti({required this.kart, required this.nadir});

  /// Bugün gelen kart.
  final KoleksiyonKarti kart;

  /// Nadir çekiliş mi?
  final bool nadir;
}

/// Bugünün kartı; (kullanıcı, gün) çiftinden deterministik türer
/// (`LuckEngine.gununKarti`, CLAUDE.md kural 8).
final Provider<GununKarti> gununKartiProvider = Provider<GununKarti>((
  Ref ref,
) {
  final KartCekilisi cekilis = ref
      .watch(luckEngineProvider)
      .gununKarti(
        kullanici: ref.watch(aktifProfilProvider).seed,
        gun: ref.watch(bugunProvider),
        kartSayisi: KoleksiyonKatalogu.kartlar.length,
      );
  return GununKarti(
    kart: KoleksiyonKatalogu.kartlar[cekilis.indeks],
    nadir: cekilis.nadir,
  );
});

/// Kazanılmış kartlar (kimlik → kayıt). Kazanım sonrası invalidate edilir.
final Provider<Map<String, KazanilanKart>> koleksiyonProvider =
    Provider<Map<String, KazanilanKart>>(
      (Ref ref) => ref.watch(koleksiyonRepositoryProvider).kartlar(),
    );

/// Bugünün kartını koleksiyona işler (kart açılınca çağrılır).
///
/// Hive bellek içi durumu senkron güncellediğinden yazma beklenmeden
/// [koleksiyonProvider] tazelenir; aynı gün tekrar çağrılması zararsızdır.
Future<KazanmaSonucu> bugununKartiniKazan(WidgetRef ref) {
  final GununKarti gunun = ref.read(gununKartiProvider);
  final Future<KazanmaSonucu> sonuc = ref
      .read(koleksiyonRepositoryProvider)
      .kazan(
        kartId: gunun.kart.id,
        gun: ref.read(bugunProvider),
        nadir: gunun.nadir,
      );
  ref.invalidate(koleksiyonProvider);
  return sonuc;
}
