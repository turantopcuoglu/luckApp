import 'luck_engine.dart';

/// Bir günün koleksiyon kartı çekilişi: katalogdaki kartın indeksi ve
/// bu çekilişin nadir olup olmadığı.
class KartCekilisi {
  /// [indeks] ve [nadir] ile çekiliş oluşturur.
  const KartCekilisi({required this.indeks, required this.nadir});

  /// Katalogdaki kartın indeksi (`0 <= indeks < kartSayisi`).
  final int indeks;

  /// Nadir çekiliş mi? (kart nadir çerçeveyle kazanılır).
  final bool nadir;

  @override
  bool operator ==(Object other) =>
      other is KartCekilisi && other.indeks == indeks && other.nadir == nadir;

  @override
  int get hashCode => Object.hash(indeks, nadir);

  @override
  String toString() => 'KartCekilisi($indeks, nadir: $nadir)';
}

/// Günün koleksiyon kartı seçimi (saf Dart, CLAUDE.md kural 3).
///
/// Kart, motorun tekrarsız döngüsel seçimiyle belirlenir: [kartSayisi]
/// günlük her döngüde her kart tam bir kez gelir, böylece koleksiyon
/// düzenli dolar. Nadirlik bağımsız bir tohumdan türer (ortalama
/// [EngineConfig.nadirKartPaydasi] günde bir). Aynı (kullanıcı, gün,
/// kartSayisi) her zaman aynı çekilişi verir (kural 8); skor ve okuma
/// tohumlarına dokunmaz.
extension KoleksiyonSecimi on LuckEngine {
  /// [kullanici] için [gun] gününün kart çekilişi.
  ///
  /// Not: [kartSayisi] değişirse döngü yeniden karılır; katalog yalnızca
  /// sonuna kart eklenerek büyütülmelidir.
  KartCekilisi gununKarti({
    required UserSeed kullanici,
    required DateTime gun,
    required int kartSayisi,
  }) {
    final int indeks = donguselIndeks(
      kullanici: kullanici,
      gun: gun,
      amac: EngineConfig.koleksiyonAmaci,
      havuzBoyutu: kartSayisi,
    );
    final bool nadir =
        secimIndeksi(
          kullanici: kullanici,
          gun: gun,
          amac: EngineConfig.koleksiyonNadirAmaci,
          havuzBoyutu: EngineConfig.nadirKartPaydasi,
        ) ==
        0;
    return KartCekilisi(indeks: indeks, nadir: nadir);
  }
}
