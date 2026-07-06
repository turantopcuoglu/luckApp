import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../luck_engine/luck_engine.dart';
import 'luck_history_repository.dart';
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
final Provider<LuckEngine> luckEngineProvider =
    Provider<LuckEngine>((Ref ref) => const LuckEngine());

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
