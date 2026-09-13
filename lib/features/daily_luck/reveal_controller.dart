import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/providers.dart';
import 'today_providers.dart';

/// Kartın açık durumları; sonuç yalnız kalıcı yazımdan sonra görünür.
enum RevealPhase {
  /// Dokunma bekleniyor.
  concealed,

  /// Kart koreografisi çalışıyor.
  revealing,

  /// Animasyon bitti; kalıcı yazım bekleniyor.
  saving,

  /// Kayıt tamamlandı, sonuç gösterilebilir.
  revealed,

  /// Kayıt başarısız; aynı güne yeniden yazma denenebilir.
  error,
}

/// Günlük açılış durumu ve yalnız bu açılışa ait giriş animasyonu işareti.
class RevealState {
  /// Değiştirilemez durum.
  const RevealState(this.phase, {this.fresh = false});

  /// Açılışın mevcut aşaması.
  final RevealPhase phase;

  /// Önceden açılmış kartta false; otomatik hareket ve haptic tekrarlanmaz.
  final bool fresh;
}

/// Testlerde saat sabitlenebilir; gösterilen gün ile yazma zamanı ayrıdır.
final Provider<DateTime Function()> revealClockProvider =
    Provider<DateTime Function()>((Ref ref) => DateTime.now);

/// Kalıcı yazma sınırı; arayüz testleri disk beklemek yerine kontrollü Future verir.
final Provider<Future<void> Function(DateTime, DateTime)> revealWriterProvider =
    Provider<Future<void> Function(DateTime, DateTime)>((Ref ref) {
      final repository = ref.watch(luckHistoryRepositoryProvider);
      return (DateTime day, DateTime time) =>
          repository.revealKaydet(day, revealedAt: time);
    });

/// Gün ve ekran ömrüne bağlı, tekrar girişlere kapalı açılış makinesi.
class RevealController
    extends AutoDisposeFamilyNotifier<RevealState, DateTime> {
  bool _disposed = false;
  @override
  RevealState build(DateTime arg) {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return RevealState(
      ref.read(todayRevealedProvider(arg))
          ? RevealPhase.revealed
          : RevealPhase.concealed,
    );
  }

  /// Sadece kapalı kart kullanıcı eylemiyle açılabilir.
  bool start() {
    if (state.phase != RevealPhase.concealed) return false;
    state = const RevealState(RevealPhase.revealing);
    return true;
  }

  /// Yalnız animasyon tamamlandığında çağrılır; çift callback tek yazımdır.
  Future<void> complete() async {
    if (state.phase != RevealPhase.revealing) return;
    await _persist();
  }

  /// Disk hatasında koreografiyi/haptic'i tekrarlamadan kaydı yeniden dener.
  Future<void> retry() async {
    if (state.phase != RevealPhase.error) return;
    await _persist();
  }

  Future<void> _persist() async {
    state = const RevealState(RevealPhase.saving);
    try {
      await ref.read(revealWriterProvider)(
        arg,
        ref.read(revealClockProvider)(),
      );
      if (_disposed) return;
      state = const RevealState(RevealPhase.revealed, fresh: true);
    } catch (_) {
      if (!_disposed) state = const RevealState(RevealPhase.error);
    }
  }
}

/// Her günlük kart ayrı makineye sahiptir; yeniden açılış depodan başlar.
final AutoDisposeNotifierProviderFamily<RevealController, RevealState, DateTime>
revealControllerProvider = NotifierProvider.autoDispose
    .family<RevealController, RevealState, DateTime>(RevealController.new);

/// Platform hataları kartın açılmasını engellemeyen, sınırlı dokunsal geri bildirim.
class RevealHaptics {
  /// Varsayılan platform servisi.
  const RevealHaptics();

  /// Mühürde tek hafif dokunuş.
  Future<void> seal() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      /* Opsiyonel donanım. */
    }
  }

  /// Başarılı ilk açılışta en fazla bir orta dokunuş.
  Future<void> result() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      /* Opsiyonel donanım. */
    }
  }
}

/// Testlerde haptic sayacıyla değiştirilebilir.
final Provider<RevealHaptics> revealHapticsProvider = Provider<RevealHaptics>(
  (Ref ref) => const RevealHaptics(),
);
