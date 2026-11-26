import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/luck_engine/luck_engine.dart';
import 'profile_config.dart';

/// Doğum ülkesi seçimi için ülke listesi (CLDR adları, küçük dosya).
final FutureProvider<List<Ulke>> ulkelerProvider = FutureProvider<List<Ulke>>(
  (Ref ref) async => Ulkeler.kompaktOku(
    // Önbelleğe alınmaz: sağlayıcı sonucu zaten tutar.
    await rootBundle.loadString(ProfileConfig.ulkelerAsset, cache: false),
  ),
);

/// Türkiye dışı şehir verisi ve listede ayırt edilmesi gereken aynı adlar.
class SehirVerisi {
  /// Şehirler (kalabalıktan tenhaya) ve aynı adlar kümesiyle oluşturur.
  const SehirVerisi({required this.sehirler, required this.ayniAdlar});

  /// Asset'teki bütün şehirler.
  final List<DunyaSehri> sehirler;

  /// Aynı ülkede birden çok kez geçen adlar (bkz.
  /// [DunyaSehirleri.ayniAdlar]).
  final Set<String> ayniAdlar;

  /// Listede gösterilecek ad.
  String gorunenAd(DunyaSehri s) => DunyaSehirleri.gorunenAd(s, ayniAdlar);
}

/// Şehir verisi (~1,2 MB). Yalnız biri Türkiye dışında bir ülke seçince
/// okunur; bir kez okunur ve uygulama boyunca tutulur.
final FutureProvider<SehirVerisi> sehirVerisiProvider =
    FutureProvider<SehirVerisi>((Ref ref) async {
      final List<DunyaSehri> sehirler = DunyaSehirleri.kompaktOku(
        // Önbelleğe alınmaz: ~1,6 MB metin bellekte iki kez durmasın;
        // sağlayıcı ayrıştırılmış listeyi tutar.
        await rootBundle.loadString(ProfileConfig.sehirlerAsset, cache: false),
      );
      return SehirVerisi(
        sehirler: sehirler,
        ayniAdlar: DunyaSehirleri.ayniAdlar(sehirler),
      );
    });
