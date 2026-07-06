import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/storage/app_storage.dart';
import 'core/storage/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/daily_luck/daily_luck_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive kutuları açılır ve provider'lara override ile bağlanır;
  // kutu provider'ları bilerek override'sız çalışmaz (bkz. providers.dart).
  await AppStorage.baslat();
  runApp(
    ProviderScope(
      overrides: <Override>[
        userProfileBoxProvider.overrideWithValue(AppStorage.userProfileBox),
        dailyRecordsBoxProvider.overrideWithValue(AppStorage.dailyRecordsBox),
      ],
      child: const KaderApp(),
    ),
  );
}

/// Uygulamanın kök widget'ı: temayı bağlar ve ana ekranı açar.
///
/// Onboarding akışı (Session 6) gelene kadar uygulama doğrudan
/// [DailyLuckScreen] ile başlar.
class KaderApp extends StatelessWidget {
  /// Varsayılan kurucu.
  const KaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const DailyLuckScreen(),
    );
  }
}
