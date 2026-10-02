import 'package:hive/hive.dart';

import '../luck_engine/luck_engine.dart';

/// Uyum ekranında kayıtlı kişinin kullanıcıya göre rolü.
enum KisiRolu {
  /// Sevgili / eş.
  partner(etiket: 'Partnerim'),

  /// Hoşlanılan / tanışılan kişi.
  aday(etiket: 'Hoşlandığım biri'),

  /// Arkadaş.
  arkadas(etiket: 'Arkadaşım'),

  /// Aile üyesi.
  aile(etiket: 'Ailemden');

  const KisiRolu({required this.etiket});

  /// Kullanıcıya gösterilecek Türkçe etiket.
  final String etiket;
}

/// Uyum hesabı için kaydedilmiş kişi.
///
/// Veriler yalnızca cihazda saklanır; gizlilik politikasında belirtildiği
/// gibi hiçbir sunucuya gönderilmez.
class KayitliKisi {
  /// Tüm alanlarıyla kişi oluşturur.
  const KayitliKisi({
    required this.id,
    required this.ad,
    required this.dogumTarihi,
    required this.rol,
  });

  /// Hive map'inden kişi kurar.
  factory KayitliKisi.fromMap(Map<dynamic, dynamic> map) => KayitliKisi(
        id: map[_id] as String,
        ad: map[_ad] as String,
        dogumTarihi: DateTime.parse(map[_dogum] as String),
        rol: KisiRolu.values.firstWhere(
          (KisiRolu r) => r.name == map[_rol],
          orElse: () => KisiRolu.arkadas,
        ),
      );

  static const String _id = 'id';
  static const String _ad = 'ad';
  static const String _dogum = 'dogumTarihi';
  static const String _rol = 'rol';

  /// Benzersiz kimlik.
  final String id;

  /// Kişinin (tercihen tam) adı.
  final String ad;

  /// Doğum tarihi.
  final DateTime dogumTarihi;

  /// Kullanıcıya göre rolü.
  final KisiRolu rol;

  /// Görünen kısa ad: tam adın ilk kelimesi.
  String get kisaAd => ad.trim().split(RegExp(r'\s+')).first;

  /// Kişinin sabit profili.
  KaderProfili get profil =>
      KaderProfili.hesapla(dogumTarihi: dogumTarihi, tamAd: ad);

  /// Hive'a yazılacak map.
  Map<String, dynamic> toMap() => <String, dynamic>{
        _id: id,
        _ad: ad,
        _dogum: dogumTarihi.toIso8601String(),
        _rol: rol.name,
      };
}

/// kisiler kutusu üzerinde okuma/yazma.
class KisiRepository {
  /// Açık bir kisiler kutusuyla repository oluşturur.
  const KisiRepository(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  /// Tüm kişiler, kimlik (ekleme zamanı) sırasıyla.
  List<KayitliKisi> tumu() {
    final List<KayitliKisi> kisiler = _box.values
        .map(KayitliKisi.fromMap)
        .toList()
      ..sort((KayitliKisi a, KayitliKisi b) => a.id.compareTo(b.id));
    return kisiler;
  }

  /// Kişi sayısı.
  int get sayi => _box.length;

  /// [kisi]yi ekler ya da günceller.
  Future<void> kaydet(KayitliKisi kisi) => _box.put(kisi.id, kisi.toMap());

  /// [id] kimlikli kişiyi siler.
  Future<void> sil(String id) => _box.delete(id);

  /// Zaman damgasından sıralanabilir yeni kimlik üretir.
  static String yeniKimlik(DateTime simdi) =>
      simdi.microsecondsSinceEpoch.toString().padLeft(20, '0');
}
