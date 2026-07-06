import 'package:hive_flutter/hive_flutter.dart';

import 'storage_keys.dart';

/// Hive'ın başlatılması ve kutuların açılması.
///
/// Uygulama açılışında (runApp öncesi) [baslat] çağrılır; ardından
/// provider override'ları [userProfileBox] ve [dailyRecordsBox]
/// üzerinden bağlanır (bkz. `providers.dart`).
abstract final class AppStorage {
  /// Hive'ı uygulama belgeleri dizininde başlatır ve kutuları açar.
  static Future<void> baslat() async {
    await Hive.initFlutter();
    await Hive.openBox<Map<dynamic, dynamic>>(StorageKeys.userProfileBox);
    await Hive.openBox<Map<dynamic, dynamic>>(StorageKeys.dailyRecordsBox);
  }

  /// Açık user_profile kutusu ([baslat] sonrası kullanılabilir).
  static Box<Map<dynamic, dynamic>> get userProfileBox =>
      Hive.box<Map<dynamic, dynamic>>(StorageKeys.userProfileBox);

  /// Açık daily_records kutusu ([baslat] sonrası kullanılabilir).
  static Box<Map<dynamic, dynamic>> get dailyRecordsBox =>
      Hive.box<Map<dynamic, dynamic>>(StorageKeys.dailyRecordsBox);
}
