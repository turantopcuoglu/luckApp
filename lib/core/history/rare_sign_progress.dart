import '../content/rare_sign_id.dart';

/// Kullanıcıya açıklanabilen, satın alma veya rastlantı içermeyen koşul türü.
enum RareSignCondition {
  /// Gerçek ilk kart açılışı.
  firstReveal,

  /// Farklı değerlendirme günleri.
  feedbackDays,

  /// Farklı kanıtlı katılım günleri.
  participationDays,

  /// Doğrulanmış ilk paylaşım olayı; menünün açılması yeterli değildir.
  firstShare,

  /// En az iki boş günden sonra katılım.
  returnAfterBreak,

  /// Açılmış kartlarda farklı arketipler.
  distinctArchetypes,

  /// En az 92 genel skorlu bir kartın açılması.
  brightCard,
}

/// Bir nadir kartın mevcut geçmişe göre koşul uygunluğu; kalıcı ödül defteri değil.
class RareSignProgress {
  /// [eligibleOn] kesin saat değil, koşulun ilk sağlandığı takvim günüdür.
  const RareSignProgress({
    required this.id,
    required this.condition,
    required this.current,
    required this.target,
    required this.eligibleOn,
    this.evidenceAvailable = true,
  });

  /// Hazır koleksiyon görselinin sabit kimliği.
  final RareSignId id;

  /// Yerelleştirilmiş açıklamanın seçileceği koşul.
  final RareSignCondition condition;

  /// Hedefi aşmayan mevcut ilerleme.
  final int current;

  /// Koşul için gereken sayı; tek olaylarda 1.
  final int target;

  /// Koşul ilk kez sağlanmışsa gün, değilse null.
  final DateTime? eligibleOn;

  /// Paylaşım gibi henüz kaydı bağlanmamış olayları ayırt eder.
  final bool evidenceAvailable;

  /// Geçerli girdilerde kartın açılma koşulu sağlanıyor mu?
  bool get isUnlocked => eligibleOn != null;
}
