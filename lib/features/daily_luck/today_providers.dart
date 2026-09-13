import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/daily_experience.dart';
import '../../core/content/daily_experience_composer.dart';
import '../../core/storage/providers.dart';
import 'daily_luck_providers.dart';

/// Saklanmış motor sonucundan günlük deneyim; görünümde kilitler ayrıca maskelenir.
final Provider<AsyncValue<DailyExperience>> dailyExperienceProvider =
    Provider<AsyncValue<DailyExperience>>((Ref ref) {
      final result = ref.watch(gununSansiProvider);
      final profile = ref.watch(aktifProfilProvider);
      final language = ref.watch(dilProvider);
      final engine = ref.watch(luckEngineProvider);
      return result.whenData(
        (value) => composeDailyExperience(
          motor: engine,
          kullanici: profile.seed,
          sonuc: value,
          dil: language,
        ),
      );
    });

/// Kalıcı açılış kaydını okur; geçici animasyon durumu bu değeri değiştirmez.
final ProviderFamily<bool, DateTime> todayRevealedProvider =
    Provider.family<bool, DateTime>(
      (Ref ref, DateTime day) =>
          ref.watch(gunlukKayitProvider(day))?.revealedAt != null,
    );

/// Paylaşım sırasında tekrar gönderimi engeller; ekran kapanınca sıfırlanır.
final AutoDisposeStateProvider<bool> todaySharingProvider =
    StateProvider.autoDispose<bool>((Ref ref) => false);
