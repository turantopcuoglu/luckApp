import 'package:hive/hive.dart';

import 'storage_keys.dart';

/// Kullanıcı verisi olmayan uygulama durumu: premium önbelleği, reklam
/// sıklığı ve ilk açılış tarihi.
class UygulamaDurumu {
  /// Tüm alanları opsiyonel durum.
  const UygulamaDurumu({
    this.ilkAcilis,
    this.premiumAktif = false,
    this.premiumDogrulama,
    this.premiumUrunId,
    this.sonGecisReklami,
    this.gelistiriciPremium = false,
    this.sahipOlunanUrunler = const <String>{},
  });

  /// Hive map'inden durum kurar.
  factory UygulamaDurumu.fromMap(Map<dynamic, dynamic> map) => UygulamaDurumu(
    ilkAcilis: _tarih(map[_ilkAcilis]),
    premiumAktif: map[_premiumAktif] as bool? ?? false,
    premiumDogrulama: _tarih(map[_premiumDogrulama]),
    premiumUrunId: map[_premiumUrunId] as String?,
    sonGecisReklami: _tarih(map[_sonGecisReklami]),
    gelistiriciPremium: map[_gelistiriciPremium] as bool? ?? false,
    sahipOlunanUrunler: <String>{
      ...(map[_sahipOlunanUrunler] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>(),
    },
  );

  static const String _ilkAcilis = 'ilkAcilis';
  static const String _premiumAktif = 'premiumAktif';
  static const String _premiumDogrulama = 'premiumDogrulama';
  static const String _premiumUrunId = 'premiumUrunId';
  static const String _sonGecisReklami = 'sonGecisReklami';
  static const String _gelistiriciPremium = 'gelistiriciPremium';
  static const String _sahipOlunanUrunler = 'sahipOlunanUrunler';

  static DateTime? _tarih(Object? ham) =>
      ham is String ? DateTime.tryParse(ham) : null;

  /// Uygulamanın bu cihazda ilk açıldığı an.
  final DateTime? ilkAcilis;

  /// Mağazanın son bildirdiği abonelik durumu (çevrimdışı önbellek).
  final bool premiumAktif;

  /// Abonelik durumunun mağazadan en son doğrulandığı an.
  final DateTime? premiumDogrulama;

  /// Aktif abonelik ürününün kimliği.
  final String? premiumUrunId;

  /// En son geçiş (interstitial) reklamının gösterildiği an.
  final DateTime? sonGecisReklami;

  /// Yalnızca debug derlemede: premium simülasyonu açık mı?
  final bool gelistiriciPremium;

  /// Mağazanın son bildirdiği tek seferlik ürün sahiplikleri (ürün
  /// kimlikleri: Numeroloji Raporu, yıl raporları). Tek seferlik ürünler
  /// süresiz olduğundan çevrimdışı tolerans uygulanmaz; yalnızca geri
  /// yükleme sonucu (ör. iade) bir ürünü listeden çıkarır.
  final Set<String> sahipOlunanUrunler;

  /// Hive'a yazılacak map.
  Map<String, dynamic> toMap() => <String, dynamic>{
    _ilkAcilis: ilkAcilis?.toIso8601String(),
    _premiumAktif: premiumAktif,
    _premiumDogrulama: premiumDogrulama?.toIso8601String(),
    _premiumUrunId: premiumUrunId,
    _sonGecisReklami: sonGecisReklami?.toIso8601String(),
    _gelistiriciPremium: gelistiriciPremium,
    _sahipOlunanUrunler: sahipOlunanUrunler.toList()..sort(),
  };

  /// Seçili alanları değiştirilmiş kopya.
  UygulamaDurumu copyWith({
    DateTime? ilkAcilis,
    bool? premiumAktif,
    DateTime? premiumDogrulama,
    String? premiumUrunId,
    DateTime? sonGecisReklami,
    bool? gelistiriciPremium,
    Set<String>? sahipOlunanUrunler,
  }) => UygulamaDurumu(
    ilkAcilis: ilkAcilis ?? this.ilkAcilis,
    premiumAktif: premiumAktif ?? this.premiumAktif,
    premiumDogrulama: premiumDogrulama ?? this.premiumDogrulama,
    premiumUrunId: premiumUrunId ?? this.premiumUrunId,
    sonGecisReklami: sonGecisReklami ?? this.sonGecisReklami,
    gelistiriciPremium: gelistiriciPremium ?? this.gelistiriciPremium,
    sahipOlunanUrunler: sahipOlunanUrunler ?? this.sahipOlunanUrunler,
  );
}

/// app_state kutusu üzerinde okuma/yazma.
class UygulamaDurumuRepository {
  /// Açık bir app_state kutusuyla repository oluşturur.
  const UygulamaDurumuRepository(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  /// Mevcut durum (kayıt yoksa varsayılan).
  UygulamaDurumu get durum {
    final Map<dynamic, dynamic>? map = _box.get(StorageKeys.durumKaydi);
    return map == null ? const UygulamaDurumu() : UygulamaDurumu.fromMap(map);
  }

  /// Durumu kaydeder.
  Future<void> kaydet(UygulamaDurumu durum) =>
      _box.put(StorageKeys.durumKaydi, durum.toMap());

  /// İlk açılış tarihi yoksa [simdi] olarak yazar.
  Future<void> ilkAcilisiIsaretle(DateTime simdi) async {
    final UygulamaDurumu mevcut = durum;
    if (mevcut.ilkAcilis == null) {
      await kaydet(mevcut.copyWith(ilkAcilis: simdi));
    }
  }

  /// Mağazadan gelen abonelik durumunu önbelleğe yazar.
  ///
  /// Aktif değilse ürün kimliği temizlenir.
  Future<void> premiumuKaydet({
    required bool aktif,
    required DateTime dogrulama,
    String? urunId,
  }) {
    final UygulamaDurumu mevcut = durum;
    return kaydet(
      UygulamaDurumu(
        ilkAcilis: mevcut.ilkAcilis,
        premiumAktif: aktif,
        premiumDogrulama: dogrulama,
        premiumUrunId: aktif ? urunId : null,
        sonGecisReklami: mevcut.sonGecisReklami,
        gelistiriciPremium: mevcut.gelistiriciPremium,
        sahipOlunanUrunler: mevcut.sahipOlunanUrunler,
      ),
    );
  }

  /// Mağazanın bildirdiği tek seferlik ürün sahipliklerini önbelleğe
  /// yazar (önceki listenin yerine geçer).
  Future<void> tekSeferlikleriKaydet(Set<String> urunler) =>
      kaydet(durum.copyWith(sahipOlunanUrunler: urunler));

  /// Geçiş reklamının gösterildiği anı yazar.
  Future<void> gecisReklamiGosterildi(DateTime an) =>
      kaydet(durum.copyWith(sonGecisReklami: an));

  /// Debug premium simülasyonunu açar/kapatır.
  Future<void> gelistiriciPremiumAyarla({required bool acik}) =>
      kaydet(durum.copyWith(gelistiriciPremium: acik));
}
