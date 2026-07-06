/// Şans motoru — saf Dart, UI/Flutter bilmez (CLAUDE.md kural 3).
///
/// Kullanım:
/// ```dart
/// final motor = LuckEngine();
/// final sonuc = motor.hesapla(
///   kullanici: UserSeed.fromIsim(isim: 'Turan', dogumTarihi: dt),
///   gun: DateTime(2026, 7, 6),
/// );
/// ```
library;

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'engine_config.dart';
import 'luck_category.dart';
import 'luck_modifier.dart';
import 'luck_result.dart';
import 'modifiers.dart';
import 'score_transform.dart';
import 'user_seed.dart';

export 'engine_config.dart';
export 'luck_category.dart';
export 'luck_modifier.dart';
export 'luck_result.dart';
export 'modifiers.dart';
export 'score_transform.dart';
export 'user_seed.dart';

/// Deterministik günlük şans skoru üreticisi.
///
/// Aynı ([UserSeed], gün) çifti her zaman aynı [LuckResult]'ı üretir;
/// bunu bozan değişiklik reddedilir (CLAUDE.md kural 8).
class LuckEngine {
  /// Motor durumsuzdur; const olarak oluşturulabilir.
  const LuckEngine();

  /// [kullanici] için [gun] gününün şans sonucunu hesaplar.
  ///
  /// [sonUcGunSkorlari] verilirse ve ortalaması
  /// [EngineConfig.dusukSeriEsigi]'nin altındaysa güne +5..+10 puanlık
  /// "seri dengesi" bias'ı uygulanır (plan Session 1, madde 6).
  LuckResult hesapla({
    required UserSeed kullanici,
    required DateTime gun,
    List<int> sonUcGunSkorlari = const <int>[],
  }) {
    // Gün saatten arındırılır: hem seed hem modifiyerler yalnızca
    // tarihe bakar, böylece gün içinde her açılış aynı sonucu verir.
    final DateTime tarih = DateTime(gun.year, gun.month, gun.day);
    final Random rnd = Random(_seedUret(kullanici, tarih));

    // 1) Ham kategori skorları: enum tanım sırasıyla üretilir ki
    //    Random çağrı sırası (dolayısıyla determinizm) sabit kalsın.
    final Map<LuckCategory, int> hamSkorlar = <LuckCategory, int>{
      for (final LuckCategory kategori in LuckCategory.values)
        kategori: sekillendir(rnd.nextDouble()),
    };

    // 2) Güne bağlı modifiyerler (kullanıcıdan bağımsız, deterministik).
    final List<LuckModifier> modifiyerler = <LuckModifier>[
      ayEvresiModifiyeri(tarih),
      numerolojiModifiyeri(tarih),
    ];

    // 3) Seri dengesi: kötü giden bir seriyi telafi eden pozitif bias.
    final LuckModifier? bias = _seriDengesi(sonUcGunSkorlari, rnd);
    if (bias != null) {
      modifiyerler.add(bias);
    }

    // 4) Modifiyer toplamı tüm kategorilere uygulanır ve 0-100'e kırpılır.
    final int toplamEtki =
        modifiyerler.fold(0, (int toplam, LuckModifier m) => toplam + m.etki);
    final Map<LuckCategory, int> skorlar = <LuckCategory, int>{
      for (final MapEntry<LuckCategory, int> e in hamSkorlar.entries)
        e.key: (e.value + toplamEtki)
            .clamp(EngineConfig.skorMin, EngineConfig.skorMaks),
    };

    // 5) Genel skor: kategori ağırlıklarıyla ortalama.
    final double agirlikliToplam = LuckCategory.values.fold(
      0,
      (double toplam, LuckCategory k) => toplam + skorlar[k]! * k.agirlik,
    );

    return LuckResult(
      gun: tarih,
      genelSkor: agirlikliToplam.round(),
      kategoriSkorlari: skorlar,
      modifiyerler: modifiyerler,
    );
  }

  /// (kullanıcı, gün) çiftinden deterministik RNG tohumu üretir.
  ///
  /// Girdi dizgisi: isimHash + doğum tarihi ISO-8601 + gün yyyy-MM-dd.
  /// SHA-256 özetinin ilk 8 baytı big-endian int'e çevrilir.
  int _seedUret(UserSeed kullanici, DateTime gun) {
    final String girdi = kullanici.isimHash +
        kullanici.dogumTarihi.toIso8601String() +
        _gunAnahtari(gun);
    final List<int> ozet = sha256.convert(utf8.encode(girdi)).bytes;

    int seed = 0;
    // İlk 8 bayt 64-bit int'e paketlenir; taşma Dart'ta sarmalanır,
    // Random tohumu için sorun değildir.
    for (int i = 0; i < 8; i++) {
      seed = (seed << 8) | ozet[i];
    }
    return seed;
  }

  /// Günü saatten bağımsız 'yyyy-MM-dd' anahtarına çevirir.
  String _gunAnahtari(DateTime gun) {
    final String yil = gun.year.toString().padLeft(4, '0');
    final String ay = gun.month.toString().padLeft(2, '0');
    final String tarih = gun.day.toString().padLeft(2, '0');
    return '$yil-$ay-$tarih';
  }

  /// Son üç gün ortalaması eşiğin altındaysa +5..+10 bias üretir.
  LuckModifier? _seriDengesi(List<int> sonUcGunSkorlari, Random rnd) {
    if (sonUcGunSkorlari.isEmpty) {
      return null;
    }
    final double ortalama =
        sonUcGunSkorlari.reduce((int a, int b) => a + b) /
            sonUcGunSkorlari.length;
    if (ortalama >= EngineConfig.dusukSeriEsigi) {
      return null;
    }
    final int aralik =
        EngineConfig.seriBiasMaks - EngineConfig.seriBiasMin + 1;
    final int etki = EngineConfig.seriBiasMin + rnd.nextInt(aralik);
    return LuckModifier(ad: seriDengesiAdi, etki: etki);
  }
}
