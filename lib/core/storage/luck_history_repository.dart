import 'package:hive/hive.dart';

import '../luck_engine/luck_engine.dart';
import 'daily_record.dart';
import 'storage_keys.dart';

/// Günlük şans kayıtları üzerinde okuma/yazma işlemleri.
///
/// daily_records kutusunu sarmalar. "Bugünün skoru zaten üretildi mi?"
/// kontrolü ve motor bias'ı için son 3 gün skorları buradan sağlanır
/// (plan Session 2, madde 3-4).
class LuckHistoryRepository {
  /// Açık bir daily_records kutusuyla repository oluşturur.
  const LuckHistoryRepository(this._box);

  /// Bias hesabında geriye bakılan gün sayısı.
  static const int biasGunSayisi = 3;

  final Box<Map<dynamic, dynamic>> _box;

  /// [gun] için kayıt var mı?
  bool kayitVarMi(DateTime gun) => _box.containsKey(gunAnahtari(gun));

  /// [gun] kaydını döndürür; yoksa null.
  DailyRecord? getir(DateTime gun) {
    final Map<dynamic, dynamic>? map = _box.get(gunAnahtari(gun));
    return map == null ? null : DailyRecord.fromMap(map);
  }

  /// [kayit]ı kendi gününün anahtarıyla kaydeder (mevcutsa üzerine yazar).
  Future<void> kaydet(DailyRecord kayit) =>
      _box.put(gunAnahtari(kayit.gun), kayit.toMap());

  /// Bugünün sonucunu kayıttan okur; yoksa [motor] ile üretip saklar.
  ///
  /// Aynı gün ikinci açılışta motor TEKRAR ÇALIŞTIRILMAZ, kayıt okunur
  /// (plan Session 2, madde 3). İlk üretimde son 3 gün skorları motora
  /// bias parametresi olarak geçilir.
  Future<LuckResult> getirVeyaUret({
    required LuckEngine motor,
    required UserSeed kullanici,
    required DateTime gun,
  }) async {
    final DailyRecord? mevcut = getir(gun);
    if (mevcut != null) {
      return mevcut.sonuc;
    }

    final LuckResult sonuc = motor.hesapla(
      kullanici: kullanici,
      gun: gun,
      sonUcGunSkorlari: sonUcGunSkorlari(gun),
    );
    await kaydet(DailyRecord(sonuc: sonuc));
    return sonuc;
  }

  /// Kutudaki TÜM kayıtları güne göre artan sırada döndürür.
  ///
  /// Geçmiş ekranı (heatmap + özet) için kullanılır. Kutu ekleme
  /// sırasını sakladığından kronolojik heatmap için açık sıralama şart.
  List<DailyRecord> tumKayitlar() =>
      _box.values.map(DailyRecord.fromMap).toList()
        ..sort((DailyRecord a, DailyRecord b) => a.gun.compareTo(b.gun));

  /// [gun]den önceki son [biasGunSayisi] günün genel skorlarını döndürür.
  ///
  /// Kaydı olmayan günler atlanır; hiç kayıt yoksa boş liste döner
  /// (motor boş listeyi "geçmiş yok" olarak yorumlar).
  List<int> sonUcGunSkorlari(DateTime gun) {
    final List<int> skorlar = <int>[];
    for (int i = 1; i <= biasGunSayisi; i++) {
      final DailyRecord? kayit = getir(
        DateTime(gun.year, gun.month, gun.day - i),
      );
      if (kayit != null) {
        skorlar.add(kayit.sonuc.genelSkor);
      }
    }
    return skorlar;
  }

  /// [gun] kaydına akşam geri bildirimini işler (plan Session 8 hazırlığı).
  ///
  /// Kayıt yoksa [StateError] fırlatır: feedback ancak skoru üretilmiş
  /// bir güne verilebilir.
  Future<void> feedbackKaydet(
    DateTime gun, {
    required bool pozitif,
    String? emoji,
  }) {
    final DailyRecord? mevcut = getir(gun);
    if (mevcut == null) {
      throw StateError('Feedback kaydedilemez: $gun için kayıt yok.');
    }
    return kaydet(
      mevcut.copyWith(feedbackPozitif: pozitif, feedbackEmoji: emoji),
    );
  }
}
