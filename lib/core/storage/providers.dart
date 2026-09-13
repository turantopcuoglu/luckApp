import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../luck_engine/luck_engine.dart';
import 'daily_record.dart';
import 'luck_history_repository.dart';
import 'user_profile_factory.dart';
import 'user_repository.dart';

/// Açık user_profile kutusunu sağlar.
///
/// Uygulama açılışında `AppStorage.baslat()` sonrası ProviderScope
/// override'ı ile gerçek kutuya bağlanır:
/// `userProfileBoxProvider.overrideWithValue(AppStorage.userProfileBox)`.
/// Override edilmeden okunursa hata fırlatır — bu kasıtlıdır.
final Provider<Box<Map<dynamic, dynamic>>> userProfileBoxProvider =
    Provider<Box<Map<dynamic, dynamic>>>(
      (Ref ref) => throw UnimplementedError(
        'userProfileBoxProvider açılışta override edilmelidir.',
      ),
    );

/// Açık daily_records kutusunu sağlar (override kuralı yukarıdakiyle aynı).
final Provider<Box<Map<dynamic, dynamic>>> dailyRecordsBoxProvider =
    Provider<Box<Map<dynamic, dynamic>>>(
      (Ref ref) => throw UnimplementedError(
        'dailyRecordsBoxProvider açılışta override edilmelidir.',
      ),
    );

/// Durumsuz şans motoru örneği.
final Provider<LuckEngine> luckEngineProvider = Provider<LuckEngine>(
  (Ref ref) => const LuckEngine(),
);

/// Testte anonim kimlik üretimini değiştirme noktası.
final Provider<UserProfileFactory> userProfileFactoryProvider =
    Provider<UserProfileFactory>((Ref ref) => const UserProfileFactory());

/// Hive değişiklikleri UI tarafından ayrıca invalidate gerektirmeden izlenir.
final StreamProvider<BoxEvent> profilDegisiklikleriProvider =
    StreamProvider<BoxEvent>(
      (Ref ref) => ref.watch(userProfileBoxProvider).watch(),
    );

/// Günlük kayıt yazımı, reveal ve feedback için ortak yenileme kaynağı.
final StreamProvider<BoxEvent> kayitDegisiklikleriProvider =
    StreamProvider<BoxEvent>(
      (Ref ref) => ref.watch(dailyRecordsBoxProvider).watch(),
    );

/// Belirli günün kalıcı kart/feedback durumu; tarih anahtarı saati yoksayar.
final AutoDisposeProviderFamily<DailyRecord?, DateTime> gunlukKayitProvider =
    Provider.autoDispose.family<DailyRecord?, DateTime>((
      Ref ref,
      DateTime gun,
    ) {
      ref.watch(kayitDegisiklikleriProvider);
      return ref.watch(luckHistoryRepositoryProvider).getir(gun);
    });

/// Kullanıcı profili repository'si.
final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>(
      (Ref ref) => UserRepository(ref.watch(userProfileBoxProvider)),
    );

/// Günlük şans kayıtları repository'si.
final Provider<LuckHistoryRepository> luckHistoryRepositoryProvider =
    Provider<LuckHistoryRepository>(
      (Ref ref) => LuckHistoryRepository(ref.watch(dailyRecordsBoxProvider)),
    );
