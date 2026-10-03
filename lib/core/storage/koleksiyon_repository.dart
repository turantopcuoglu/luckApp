import 'package:hive/hive.dart';

import 'storage_keys.dart';

/// Koleksiyonda kazanılmış bir kartın kaydı.
class KazanilanKart {
  /// Tüm alanlarıyla kayıt oluşturur.
  const KazanilanKart({
    required this.ilkGun,
    required this.sonGun,
    required this.nadir,
    required this.gunSayisi,
  });

  /// Hive map'inden kayıt kurar.
  factory KazanilanKart.fromMap(Map<dynamic, dynamic> map) => KazanilanKart(
    ilkGun: DateTime.parse(map[_ilkGun] as String),
    sonGun: DateTime.parse(map[_sonGun] as String),
    nadir: map[_nadir] as bool? ?? false,
    gunSayisi: map[_gunSayisi] as int? ?? 1,
  );

  static const String _ilkGun = 'ilkGun';
  static const String _sonGun = 'sonGun';
  static const String _nadir = 'nadir';
  static const String _gunSayisi = 'gunSayisi';

  /// Kartın ilk kazanıldığı gün.
  final DateTime ilkGun;

  /// Kartın en son kazanıldığı gün.
  final DateTime sonGun;

  /// Kart en az bir kez nadir çekilişle kazanıldı mı?
  final bool nadir;

  /// Kartın kaç farklı günde kazanıldığı.
  final int gunSayisi;

  /// Hive'a yazılacak map.
  Map<String, dynamic> toMap() => <String, dynamic>{
    _ilkGun: gunAnahtari(ilkGun),
    _sonGun: gunAnahtari(sonGun),
    _nadir: nadir,
    _gunSayisi: gunSayisi,
  };
}

/// Kazanma işleminin sonucu (ekranda "yeni" / "nadir oldu" rozeti için).
enum KazanmaSonucu {
  /// Kart koleksiyona ilk kez girdi.
  yeni,

  /// Zaten vardı; bu kez nadir çekilişle geldi ve nadire yükseldi.
  nadireYukseldi,

  /// Zaten vardı; gün sayısı arttı.
  tekrar,

  /// Bu gün zaten kaydedilmişti; değişiklik yok.
  degismedi,
}

/// app_state kutusundaki koleksiyon kaydı üzerinde okuma/yazma.
///
/// Kayıt, kart kimliği → [KazanilanKart] map'idir. Kart kimlikleri
/// arayüz kataloğundan gelir; depolama katmanı kataloğu bilmez.
class KoleksiyonRepository {
  /// Açık bir app_state kutusuyla repository oluşturur.
  const KoleksiyonRepository(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  /// Kazanılmış tüm kartlar (kimlik → kayıt).
  Map<String, KazanilanKart> kartlar() {
    final Map<dynamic, dynamic>? ham = _box.get(StorageKeys.koleksiyonKaydi);
    if (ham == null) {
      return const <String, KazanilanKart>{};
    }
    return <String, KazanilanKart>{
      for (final MapEntry<dynamic, dynamic> g in ham.entries)
        if (g.key is String && g.value is Map)
          g.key as String: KazanilanKart.fromMap(
            g.value as Map<dynamic, dynamic>,
          ),
    };
  }

  /// [kartId] kartını [gun] günü için kazandırır; [nadir] çekilişse kart
  /// nadire yükselir (bir kez nadir olan kart nadir kalır).
  ///
  /// Aynı gün için tekrar çağrılması zararsızdır (idempotent): gün sayısı
  /// bir gün içinde yalnızca bir kez artar.
  Future<KazanmaSonucu> kazan({
    required String kartId,
    required DateTime gun,
    required bool nadir,
  }) async {
    final DateTime tarih = DateTime(gun.year, gun.month, gun.day);
    final Map<String, KazanilanKart> mevcut = kartlar();
    final KazanilanKart? eski = mevcut[kartId];

    final KazanmaSonucu sonuc;
    final KazanilanKart yeni;
    if (eski == null) {
      sonuc = KazanmaSonucu.yeni;
      yeni = KazanilanKart(
        ilkGun: tarih,
        sonGun: tarih,
        nadir: nadir,
        gunSayisi: 1,
      );
    } else if (eski.sonGun == tarih) {
      // Aynı gün: yalnızca (olası) nadir yükseltmesi işlenir.
      if (!nadir || eski.nadir) {
        return KazanmaSonucu.degismedi;
      }
      sonuc = KazanmaSonucu.nadireYukseldi;
      yeni = KazanilanKart(
        ilkGun: eski.ilkGun,
        sonGun: eski.sonGun,
        nadir: true,
        gunSayisi: eski.gunSayisi,
      );
    } else {
      sonuc = nadir && !eski.nadir
          ? KazanmaSonucu.nadireYukseldi
          : KazanmaSonucu.tekrar;
      yeni = KazanilanKart(
        ilkGun: eski.ilkGun,
        sonGun: tarih,
        nadir: eski.nadir || nadir,
        gunSayisi: eski.gunSayisi + 1,
      );
    }

    await _box.put(StorageKeys.koleksiyonKaydi, <String, dynamic>{
      for (final MapEntry<String, KazanilanKart> g in mevcut.entries)
        g.key: g.value.toMap(),
      kartId: yeni.toMap(),
    });
    return sonuc;
  }
}
