import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_veri;
import 'package:timezone/timezone.dart' as tz;

import '../../core/localization/app_dil.dart';
import '../daily_luck/tr_strings.dart';
import 'feedback_config.dart';
import 'feedback_strings.dart';

/// [NotificationService] örneğini sağlar (testte sahtesiyle override
/// edilebilir).
final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((Ref ref) => NotificationService());

/// Lokal bildirimlerin kurulumu, izni ve planlaması.
///
/// Tüm plugin çağrıları [PlatformException]/[MissingPluginException]'a
/// karşı korunur: bildirim alt yapısı olmayan ortamlarda (testler)
/// uygulama davranışı bozulmaz, çağrılar sessizce false döner.
class NotificationService {
  /// Varsayılan kurucu.
  NotificationService();

  final FlutterLocalNotificationsPlugin _eklenti =
      FlutterLocalNotificationsPlugin();

  /// Eklentiyi başlatır; uygulama bir bildirime dokunularak mı
  /// açıldı bilgisini döndürür. [bildirimeDokunuldu] uygulama
  /// açıkken akşam bildirimine dokunulunca çağrılır.
  Future<bool> baslat({required void Function() bildirimeDokunuldu}) async {
    try {
      tz_veri.initializeTimeZones();

      const InitializationSettings ayarlar = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // İzin, onboarding sonunda açıkça istenir (izinIste).
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _eklenti.initialize(
        ayarlar,
        onDidReceiveNotificationResponse: (NotificationResponse yanit) {
          if (yanit.payload == FeedbackConfig.feedbackPayload) {
            bildirimeDokunuldu();
          }
        },
      );

      // Uygulama kapalıyken akşam bildirimine dokunulup açıldıysa
      // çağıran taraf feedback ekranını göstermelidir.
      final NotificationAppLaunchDetails? acilis = await _eklenti
          .getNotificationAppLaunchDetails();
      return (acilis?.didNotificationLaunchApp ?? false) &&
          acilis?.notificationResponse?.payload ==
              FeedbackConfig.feedbackPayload;
      // ignore: avoid_catches_without_on_clauses - plugin altyapısı
      // olmayan ortamda Error (LateInitializationError) da fırlar.
    } catch (_) {
      return false; // plugin yok (test ortamı) veya platform hatası
    }
  }

  /// Bildirim iznini ister; verildiyse true.
  ///
  /// Android 13+ çalışma zamanı izni, iOS ilk kurulum izni buradan
  /// akar (onboarding sonunda çağrılır — plan madde 4).
  Future<bool> izinIste() async {
    try {
      final bool? android = await _eklenti
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      final bool? ios = await _eklenti
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      // Platformlardan hangisi mevcutsa onun cevabı geçerlidir.
      return android ?? ios ?? false;
      // ignore: avoid_catches_without_on_clauses - bkz. baslat.
    } catch (_) {
      return false;
    }
  }

  /// Planlanmış tüm bildirimleri iptal eder.
  ///
  /// Ayarlar'da bildirimler kapatıldığında çağrılır; hiçbir
  /// hatırlatma tetiklenmemesini sağlar. Diğer çağrılar gibi plugin
  /// yoksa sessizce geçer.
  Future<void> iptalEt() async {
    try {
      await _eklenti.cancelAll();
      // ignore: avoid_catches_without_on_clauses - bkz. baslat.
    } catch (_) {
      // Plugin yok (test) veya platform hatası: sessiz geç.
    }
  }

  /// Günlük bildirimleri (yeniden) planlar.
  ///
  /// - Akşam (varsayılan 21:00): her gün tekrar eden tek bildirim
  ///   (dokunulunca feedback ekranı açılır).
  /// - Sabah (varsayılan 08:30): önümüzdeki
  ///   [FeedbackConfig.sabahGunSayisi] gün için, güne göre değişen
  ///   metinli tek seferlik bildirimler. Her açılışta pencere tazelenir.
  ///
  /// [aksamDakika]/[sabahDakika] gün-içi dakika (0-1439) olarak özel
  /// saat verir; `null` ise [FeedbackConfig] varsayılanları kullanılır.
  /// Böylece mevcut çağrı yerleri değişmeden çalışır.
  Future<void> gunlukBildirimleriPlanla({
    required DateTime simdi,
    required AppDil dil,
    int? aksamDakika,
    int? sabahDakika,
    int? sansliSaatBaslangiciSaati,
  }) async {
    try {
      await _eklenti.cancelAll();

      // Özel saat verilmişse dakikayı saat:dakikaya böl, yoksa
      // yapılandırma varsayılanını kullan.
      final (int aksamSaatDeger, int aksamDakikaDeger) = aksamDakika == null
          ? (FeedbackConfig.aksamSaat, FeedbackConfig.aksamDakika)
          : saatDakikaAyir(aksamDakika);
      final (int sabahSaatDeger, int sabahDakikaDeger) = sabahDakika == null
          ? (FeedbackConfig.sabahSaat, FeedbackConfig.sabahDakika)
          : saatDakikaAyir(sabahDakika);

      const NotificationDetails detaylar = NotificationDetails(
        android: AndroidNotificationDetails(
          FeedbackConfig.kanalId,
          FeedbackConfig.kanalAd,
          channelDescription: FeedbackConfig.kanalAciklama,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      // Not: tz.local kurulmamışsa UTC'dir; TZDateTime.from mutlak ANI
      // korur, dolayısıyla planlanan ilk tetikleme her zaman doğrudur.
      // Günlük tekrar (DateTimeComponents.time) o dilimdeki duvar
      // saatine kilitlenir — Türkiye'de yaz saati uygulanmadığı için
      // bu, her gün aynı yerel saate denk gelir.
      final tz.TZDateTime aksam = tz.TZDateTime.from(
        sonrakiZaman(simdi, saat: aksamSaatDeger, dakika: aksamDakikaDeger),
        tz.local,
      );
      await _eklenti.zonedSchedule(
        FeedbackConfig.aksamBildirimId,
        'Kader',
        FeedbackStrings.aksamSorusu(dil),
        aksam,
        detaylar,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: FeedbackConfig.feedbackPayload,
      );

      // Sabahlar: metin güne göre değiştiği için tek tek planlanır.
      for (int i = 0; i < FeedbackConfig.sabahGunSayisi; i++) {
        final DateTime hedef = sonrakiZaman(
          simdi,
          saat: sabahSaatDeger,
          dakika: sabahDakikaDeger,
        ).add(Duration(days: i));
        await _eklenti.zonedSchedule(
          FeedbackConfig.sabahBildirimBaslangicId + i,
          'Kader',
          sabahMetni(hedef, dil),
          tz.TZDateTime.from(hedef, tz.local),
          detaylar,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      // Şanslı saat: yalnız BUGÜN, tek seferlik. Saat henüz geçmediyse
      // planlanır; geçtiyse atlanır (yarının şanslı saati farklı olduğu
      // için kaydırılmaz — her açılışta yeniden hesaplanır).
      if (sansliSaatBaslangiciSaati != null) {
        final DateTime? ani = bugunSansliSaatAni(
          simdi,
          sansliSaatBaslangiciSaati,
        );
        if (ani != null) {
          await _eklenti.zonedSchedule(
            FeedbackConfig.sansliSaatBildirimId,
            'Kader',
            sansliSaatMetni(ani, dil),
            tz.TZDateTime.from(ani, tz.local),
            detaylar,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            // Tek seferlik: matchDateTimeComponents yok. Payload yok —
            // dokunuş feedback ekranı değil, uygulamayı normal açar.
          );
        }
      }
      // ignore: avoid_catches_without_on_clauses - bkz. baslat.
    } catch (_) {
      // Plugin yoksa (test) veya platform reddederse sessiz geç.
    }
  }

  /// [simdi]den sonraki ilk [saat]:[dakika] anını döndürür.
  ///
  /// Saat henüz geçmediyse bugünü, geçtiyse yarını seçer. Saf ve
  /// statiktir ki tek başına test edilebilsin.
  static DateTime sonrakiZaman(
    DateTime simdi, {
    required int saat,
    required int dakika,
  }) {
    final DateTime bugunku = DateTime(
      simdi.year,
      simdi.month,
      simdi.day,
      saat,
      dakika,
    );
    return bugunku.isAfter(simdi)
        ? bugunku
        : bugunku.add(const Duration(days: 1));
  }

  /// Bir saatteki dakika sayısı (saat ↔ gün-içi dakika dönüşümü).
  static const int _dakikaBirSaat = 60;

  /// Gün-içi [guniciDakika] (0-1439) değerini (saat, dakika) çiftine
  /// böler. Saf ve statiktir ki tek başına test edilebilsin.
  static (int saat, int dakika) saatDakikaAyir(int guniciDakika) {
    return (guniciDakika ~/ _dakikaBirSaat, guniciDakika % _dakikaBirSaat);
  }

  /// [saat]:[dakika]yı gün-içi dakikaya (0-1439) çevirir —
  /// [saatDakikaAyir]'ın tersi.
  static int dakikayaCevir(int saat, int dakika) =>
      saat * _dakikaBirSaat + dakika;

  /// [saat]:[dakika]yı `HH:MM` (24 saat) metnine çevirir.
  ///
  /// Lokalizasyon-BAĞIMSIZDIR (BuildContext/MaterialLocalizations
  /// gerektirmez): Ayarlar gövdesi böylece cihaz diline bağlı kalmaz.
  /// Saf ve statiktir, tek başına test edilebilir.
  static String saatMetni(int saat, int dakika) {
    final String ss = saat.toString().padLeft(2, '0');
    final String dd = dakika.toString().padLeft(2, '0');
    return '$ss:$dd';
  }

  /// [gun] için sabah bildirim metnini seçer.
  ///
  /// Gün sayısından türetilen tohumla rastgele ama deterministik:
  /// aynı gün hep aynı varyasyon, ardışık günlerde farklı dağılım.
  static String sabahMetni(DateTime gun, AppDil dil) {
    final int gunNumarasi =
        DateTime(gun.year, gun.month, gun.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    final Random rnd = Random(gunNumarasi);
    final List<String> havuz = TrStrings.sabahBildirimVaryasyonlari(dil);
    return havuz[rnd.nextInt(havuz.length)];
  }

  /// Bugün [baslangiciSaati]:00 anını döndürür; [simdi]yi geçmişse
  /// `null` (yarına KAYDIRMAZ — yarının şanslı saati farklıdır).
  ///
  /// Saf ve statiktir: tek başına test edilebilir.
  static DateTime? bugunSansliSaatAni(DateTime simdi, int baslangiciSaati) {
    final DateTime ani = DateTime(
      simdi.year,
      simdi.month,
      simdi.day,
      baslangiciSaati,
    );
    return ani.isAfter(simdi) ? ani : null;
  }

  /// [gun] için şanslı saat bildirim metnini seçer.
  ///
  /// [sabahMetni] ile aynı deterministik desen: gün numarasından türeyen
  /// tohumla varyasyon seçilir.
  static String sansliSaatMetni(DateTime gun, AppDil dil) {
    final int gunNumarasi =
        DateTime(gun.year, gun.month, gun.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    final Random rnd = Random(gunNumarasi);
    final List<String> havuz = TrStrings.sansliSaatBildirimVaryasyonlari(dil);
    return havuz[rnd.nextInt(havuz.length)];
  }
}
