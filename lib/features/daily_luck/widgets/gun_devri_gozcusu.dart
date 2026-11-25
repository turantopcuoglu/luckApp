import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../daily_luck_config.dart';
import '../daily_luck_providers.dart';

/// Günün sınırlarını izleyen gözcü: takvim günü değiştiğinde uygulamayı
/// yeni güne geçirir, akşam olduğunda akşam kartını açar.
///
/// İki anı izler:
/// - Uygulama arka plandan öne geldiğinde (kullanıcı uygulamayı kapatmadan
///   akşam ya da ertesi sabah açtığında) saati kontrol eder.
/// - Uygulama ekrandayken bir sınır geçilirse (akşam kartı saati ya da
///   gece yarısı) bir zamanlayıcıyla aynı kontrolü yapar.
///
/// Her iki durumda da [GunDevri.tazele] ve [AksamDevri.tazele] çağrılır;
/// sınır geçilmediyse hiçbir şey olmaz. Uygulamanın kökünü sarar ve
/// çocuğunu olduğu gibi çizer.
class GunDevriGozcusu extends ConsumerStatefulWidget {
  /// [child]'ı saran gözcü oluşturur.
  const GunDevriGozcusu({
    required this.child,
    this.saat = DateTime.now,
    super.key,
  });

  /// Sarılan widget (uygulamanın kökü).
  final Widget child;

  /// Şimdiki zamanı veren saat; testlerde sahte saatle değiştirilir.
  final DateTime Function() saat;

  @override
  ConsumerState<GunDevriGozcusu> createState() => _GunDevriGozcusuState();
}

class _GunDevriGozcusuState extends ConsumerState<GunDevriGozcusu> {
  late final AppLifecycleListener _yasamDongusu;
  Timer? _zamanlayici;

  @override
  void initState() {
    super.initState();
    _yasamDongusu = AppLifecycleListener(onResume: _kontrolEt);
    _zamanlayiciyiKur();
  }

  /// Günü ve akşam durumunu kontrol eder, zamanlayıcıyı yeniden kurar
  /// (uygulama arka plandayken zamanlayıcı çalışmamış olabilir).
  void _kontrolEt() {
    final DateTime simdi = widget.saat();
    // Önce gün: gün değiştiyse akşam durumu yeni günün saatinden kurulur.
    ref.read(gunDevriProvider.notifier).tazele(simdi);
    ref.read(aksamOlduProvider.notifier).tazele(simdi);
    _zamanlayiciyiKur();
  }

  /// Sıradaki sınıra (bugünün akşam kartı saati; geçtiyse gece yarısı),
  /// artı [DailyLuckConfig.gunDevriPayi], zamanlayıcı kurar; çalıştığında
  /// kontrolü yapar ve kendini bir sonraki sınır için yeniden kurar.
  void _zamanlayiciyiKur() {
    _zamanlayici?.cancel();
    final DateTime simdi = widget.saat();
    final DateTime aksam = DateTime(
      simdi.year,
      simdi.month,
      simdi.day,
      DailyLuckConfig.aksamKartiSaati,
    );
    // Ayın son gününde de doğru çalışır: DateTime taşan günü sonraki aya
    // yuvarlar.
    final DateTime yarin = DateTime(simdi.year, simdi.month, simdi.day + 1);
    final DateTime sinir = simdi.isBefore(aksam) ? aksam : yarin;
    _zamanlayici = Timer(
      sinir.difference(simdi) + DailyLuckConfig.gunDevriPayi,
      _kontrolEt,
    );
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    _yasamDongusu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
