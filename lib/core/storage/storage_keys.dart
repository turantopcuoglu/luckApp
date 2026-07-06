/// Hive kutu adları ve kayıt anahtarları.
///
/// Magic string yasağı gereği depolama katmanındaki tüm anahtarlar
/// buradan okunur (CLAUDE.md kural 6).
abstract final class StorageKeys {
  /// Kullanıcı profili kutusunun adı (plan Session 2, madde 1).
  static const String userProfileBox = 'user_profile';

  /// Günlük kayıtlar kutusunun adı: gün anahtarı → sonuç + feedback.
  static const String dailyRecordsBox = 'daily_records';

  /// user_profile kutusunda profil map'inin saklandığı tek anahtar.
  static const String profilKaydi = 'profil';
}

/// [gun] tarihini saatten bağımsız `yyyy-MM-dd` kutu anahtarına çevirir.
///
/// daily_records kutusunun anahtar formatıdır; motorun seed formatıyla
/// aynı gösterimi kullanır ki gün tanımı iki katmanda ayrışmasın.
String gunAnahtari(DateTime gun) {
  final String yil = gun.year.toString().padLeft(4, '0');
  final String ay = gun.month.toString().padLeft(2, '0');
  final String tarih = gun.day.toString().padLeft(2, '0');
  return '$yil-$ay-$tarih';
}
