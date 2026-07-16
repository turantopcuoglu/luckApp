import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'widget_config.dart';
import 'widget_payload.dart';

/// [HomeWidgetService] örneğini sağlar (testte sahtesiyle override edilir).
final Provider<HomeWidgetService> homeWidgetServiceProvider =
    Provider<HomeWidgetService>((Ref ref) => HomeWidgetService());

/// Ana ekran widget'ına veri yazan native köprü servisi.
///
/// `home_widget` paketi üzerinden Android SharedPreferences / iOS App
/// Group UserDefaults'a yazar ve widget'ı yeniler. Tüm çağrılar
/// [PlatformException]/[MissingPluginException]'a karşı korunur: widget
/// altyapısı olmayan ortamlarda (testler, widget eklenmemiş cihaz)
/// uygulama davranışı BOZULMAZ (kural: açılış asla çökmez).
class HomeWidgetService {
  /// Varsayılan kurucu.
  HomeWidgetService();

  /// [yuku] verisini widget deposuna yazar ve widget'ı yeniler.
  ///
  /// Başarısızlıkta sessizce yutar (widget opsiyonel bir yüzeydir).
  Future<void> yaz(WidgetPayload yuku) async {
    try {
      // iOS App Group (Android'de zararsız); veri paylaşımı için gerekli.
      await HomeWidget.setAppGroupId(WidgetConfig.appGroupId);
      // Skor String olarak yazılır: native tarafta tip uyuşmazlığı
      // (SharedPreferences ClassCastException) riskini kaldırır ve zaten
      // metin olarak gösterilir.
      await HomeWidget.saveWidgetData<String>(
        WidgetConfig.anahtarSkor,
        '${yuku.skor}',
      );
      await HomeWidget.saveWidgetData<String>(
        WidgetConfig.anahtarTarih,
        yuku.tarih,
      );
      await HomeWidget.saveWidgetData<String>(
        WidgetConfig.anahtarTeaser,
        yuku.teaser,
      );
      await HomeWidget.updateWidget(
        androidName: WidgetConfig.androidProvider,
        iOSName: WidgetConfig.iosName,
      );
    } on PlatformException catch (_) {
      // Widget altyapısı yok/başarısız → yut.
    } on MissingPluginException catch (_) {
      // Test ortamı (plugin yok) → yut.
    }
  }
}
