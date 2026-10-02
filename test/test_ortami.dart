import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/premium/premium_providers.dart';

/// Widget testleri için geçici Hive kutuları ve provider override'ları.
///
/// Kutular her testte benzersiz adla açılır: buton callback'lerinden
/// (FakeAsync içinde) yapılan yazmaların disk kilidi test sonunda
/// açılmadığı için kutular diskten silinmez, geçici dizin işletim
/// sistemine bırakılır (bkz. onboarding testi notu).
class TestOrtami {
  static int _sayac = 0;

  /// Geçici Hive dizini.
  late Directory dizin;

  /// user_profile kutusu.
  late Box<Map<dynamic, dynamic>> profil;

  /// daily_records kutusu.
  late Box<Map<dynamic, dynamic>> kayit;

  /// app_state kutusu.
  late Box<Map<dynamic, dynamic>> durum;

  /// kisiler kutusu.
  late Box<Map<dynamic, dynamic>> kisiler;

  /// Hive'ı geçici dizinde başlatıp dört kutuyu açar.
  Future<void> kur(String ad) async {
    dizin = await Directory.systemTemp.createTemp(ad);
    Hive.init(dizin.path);
    _sayac++;
    profil = await Hive.openBox<Map<dynamic, dynamic>>('${ad}_p_$_sayac');
    kayit = await Hive.openBox<Map<dynamic, dynamic>>('${ad}_k_$_sayac');
    durum = await Hive.openBox<Map<dynamic, dynamic>>('${ad}_d_$_sayac');
    kisiler = await Hive.openBox<Map<dynamic, dynamic>>('${ad}_s_$_sayac');
  }

  /// Uygulamanın ihtiyaç duyduğu tüm override'lar.
  List<Override> overridelar({
    required DateTime gun,
    bool premium = false,
    List<Override> ek = const <Override>[],
  }) =>
      <Override>[
        userProfileBoxProvider.overrideWithValue(profil),
        dailyRecordsBoxProvider.overrideWithValue(kayit),
        appStateBoxProvider.overrideWithValue(durum),
        kisilerBoxProvider.overrideWithValue(kisiler),
        bugunProvider.overrideWithValue(gun),
        if (premium) entitlementProvider.overrideWith((Ref ref) => true),
        ...ek,
      ];
}
