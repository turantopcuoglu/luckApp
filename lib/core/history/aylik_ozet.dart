import '../content/fortune_composer.dart';
import '../luck_engine/luck_engine.dart';
import '../storage/daily_record.dart';
import 'history_analiz_config.dart';

/// Bir ayın paylaşılabilir "Şans Raporu" özeti (Phase 4).
///
/// Saf değer nesnesi: Flutter/Hive bilmez, `aylikOzet` tarafından
/// deterministik üretilir. Wrapped-tarzı öne çıkanları taşır.
class AylikOzet {
  /// Tüm alanlarıyla özet oluşturur.
  const AylikOzet({
    required this.yil,
    required this.ay,
    required this.gunSayisi,
    required this.ortalamaSkor,
    required this.enSansliGun,
    required this.enSansliSkor,
    required this.baskinKategori,
    required this.altinGunSayisi,
    required this.enUzunSeri,
  });

  /// Raporun yılı.
  final int yil;

  /// Raporun ayı (1-12).
  final int ay;

  /// Bu ay kayıtlı gün sayısı.
  final int gunSayisi;

  /// Ayın ortalama genel skoru (boş ayda 0).
  final int ortalamaSkor;

  /// Ayın en şanslı günü (boş ayda null; eşitlikte en erken).
  final DateTime? enSansliGun;

  /// En şanslı günün skoru (boş ayda null).
  final int? enSansliSkor;

  /// Ay boyunca kategori skorları toplandığında baskın kategori
  /// (boş ayda null).
  final LuckCategory? baskinKategori;

  /// Ayda "Altın Gün" (skor ≥ [HistoryAnalizConfig.altinGunEsigi]) sayısı.
  final int altinGunSayisi;

  /// Ay içindeki en uzun kayıt serisi (grace'li).
  final int enUzunSeri;

  /// Bu ay hiç kayıt yok mu?
  bool get bosMu => gunSayisi == 0;
}

/// Bir tarihi saatten arındırılmış gün ordinaline çevirir.
int _gunOrdinali(DateTime gun) =>
    DateTime(gun.year, gun.month, gun.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// İki kayıt arası boşluğun seriyi sürdürüp sürdürmediği (grace: tek
/// boş gün tolere edilir).
bool _seriSurer(int fark) => fark <= 2;

/// [ordinaller] (artan, benzersiz) içindeki en uzun grace'li seriyi sayar.
int _enUzunSeri(List<int> ordinaller) {
  if (ordinaller.isEmpty) {
    return 0;
  }
  int enUzun = 1;
  int guncel = 1;
  for (int i = 1; i < ordinaller.length; i++) {
    if (_seriSurer(ordinaller[i] - ordinaller[i - 1])) {
      guncel++;
    } else {
      guncel = 1;
    }
    if (guncel > enUzun) {
      enUzun = guncel;
    }
  }
  return enUzun;
}

/// [kayitlar]dan [yil]/[ay] ayının deterministik özetini üretir (saf).
///
/// Yalnız o aya düşen kayıtlar sayılır; ay boş ise [AylikOzet.bosMu]
/// `true` (gün sayısı 0). I/O/rastgele YOK.
AylikOzet aylikOzet(
  List<DailyRecord> kayitlar, {
  required int yil,
  required int ay,
}) {
  final List<DailyRecord> aydakiler = kayitlar
      .where((DailyRecord k) => k.gun.year == yil && k.gun.month == ay)
      .toList();

  if (aydakiler.isEmpty) {
    return AylikOzet(
      yil: yil,
      ay: ay,
      gunSayisi: 0,
      ortalamaSkor: 0,
      enSansliGun: null,
      enSansliSkor: null,
      baskinKategori: null,
      altinGunSayisi: 0,
      enUzunSeri: 0,
    );
  }

  int skorToplami = 0;
  DateTime enSansliGun = aydakiler.first.gun;
  int enSansliSkor = aydakiler.first.sonuc.genelSkor;
  int altinGun = 0;
  // Ay boyunca kategori skorları toplanır → baskın kategori.
  final Map<LuckCategory, int> kategoriToplam = <LuckCategory, int>{
    for (final LuckCategory k in LuckCategory.values) k: 0,
  };

  for (final DailyRecord kayit in aydakiler) {
    final int skor = kayit.sonuc.genelSkor;
    skorToplami += skor;

    if (skor > enSansliSkor ||
        (skor == enSansliSkor && kayit.gun.isBefore(enSansliGun))) {
      enSansliSkor = skor;
      enSansliGun = kayit.gun;
    }

    if (skor >= HistoryAnalizConfig.altinGunEsigi) {
      altinGun++;
    }

    kayit.sonuc.kategoriSkorlari.forEach((LuckCategory kat, int deger) {
      kategoriToplam[kat] = (kategoriToplam[kat] ?? 0) + deger;
    });
  }

  final List<int> ordinaller =
      aydakiler.map((DailyRecord k) => _gunOrdinali(k.gun)).toSet().toList()
        ..sort();

  return AylikOzet(
    yil: yil,
    ay: ay,
    gunSayisi: aydakiler.length,
    ortalamaSkor: (skorToplami / aydakiler.length).round(),
    enSansliGun: enSansliGun,
    enSansliSkor: enSansliSkor,
    // baskinKategori enum-sıra eşitlik kuralıyla deterministik seçer.
    baskinKategori: baskinKategori(kategoriToplam),
    altinGunSayisi: altinGun,
    enUzunSeri: _enUzunSeri(ordinaller),
  );
}
