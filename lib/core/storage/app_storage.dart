import 'package:hive_flutter/hive_flutter.dart';

import 'storage_keys.dart';

/// Hive'ın başlatılması ve kutuların açılması.
///
/// Uygulama açılışında (runApp öncesi) [baslat] çağrılır; ardından
/// provider override'ları kutu getter'ları üzerinden bağlanır
/// (bkz. `providers.dart`).
abstract final class AppStorage {
  /// Uygulamanın açtığı tüm kutu adları.
  static const List<String> kutuAdlari = <String>[
    StorageKeys.userProfileBox,
    StorageKeys.dailyRecordsBox,
    StorageKeys.appStateBox,
    StorageKeys.kisilerBox,
  ];

  /// Hive'ı uygulama belgeleri dizininde başlatır ve kutuları açar.
  static Future<void> baslat() async {
    await Hive.initFlutter();
    for (final String ad in kutuAdlari) {
      await Hive.openBox<Map<dynamic, dynamic>>(ad);
    }
  }

  /// Açık user_profile kutusu ([baslat] sonrası kullanılabilir).
  static Box<Map<dynamic, dynamic>> get userProfileBox =>
      Hive.box<Map<dynamic, dynamic>>(StorageKeys.userProfileBox);

  /// Açık daily_records kutusu ([baslat] sonrası kullanılabilir).
  static Box<Map<dynamic, dynamic>> get dailyRecordsBox =>
      Hive.box<Map<dynamic, dynamic>>(StorageKeys.dailyRecordsBox);

  /// Açık app_state kutusu ([baslat] sonrası kullanılabilir).
  static Box<Map<dynamic, dynamic>> get appStateBox =>
      Hive.box<Map<dynamic, dynamic>>(StorageKeys.appStateBox);

  /// Açık kisiler kutusu ([baslat] sonrası kullanılabilir).
  static Box<Map<dynamic, dynamic>> get kisilerBox =>
      Hive.box<Map<dynamic, dynamic>>(StorageKeys.kisilerBox);
}
