import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: KaderApp()));
}

/// Uygulamanın kök widget'ı.
///
/// Temayı bağlar ve şimdilik boş ana ekranı ([_PlaceholderHome]) açar.
/// Gerçek ana ekran Session 3'te `features/daily_luck` altına gelecek.
class KaderApp extends StatelessWidget {
  /// Varsayılan kurucu.
  const KaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _PlaceholderHome(),
    );
  }
}

/// Session 0 için geçici ana ekran: ortada "Kader" yazısı.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Kader',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
