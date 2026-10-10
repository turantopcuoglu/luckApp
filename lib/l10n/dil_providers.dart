import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/content/icerik_paketi.dart';
import '../core/storage/providers.dart';
import 'app_localizations.dart';
import 'dil_config.dart';

/// Uygulama dilini çözer (K3).
///
/// Öncelik: kullanıcının Ayarlar'daki [tercih]i; yoksa İngilizce yayında
/// ise [cihazDilKodu] ("tr" → Türkçe, diğer her dil → İngilizce); İngilizce
/// henüz yayında değilse ([ingilizceYayinda] `false`) Türkçe.
IcerikDili uygulamaDiliniCoz({
  required IcerikDili? tercih,
  required String cihazDilKodu,
  bool ingilizceYayinda = DilConfig.ingilizceYayinda,
}) {
  if (tercih != null) {
    return tercih;
  }
  if (!ingilizceYayinda || cihazDilKodu == DilConfig.turkceKodu) {
    return IcerikDili.tr;
  }
  return IcerikDili.en;
}

/// Saklanan dil kodunu dile çevirir; bilinmeyen/boş kod `null` (tercih yok).
IcerikDili? dilKodundan(String? kod) {
  for (final IcerikDili d in IcerikDili.values) {
    if (d.name == kod) {
      return d;
    }
  }
  return null;
}

/// Dilin `MaterialApp.locale` karşılığı.
Locale dilLocale(IcerikDili dil) => Locale(dil.name);

/// Cihazın birincil dil kodu ("tr", "en" …).
///
/// Açılışta bir kez okunur; testlerde override edilir.
final Provider<String> cihazDilKoduProvider = Provider<String>(
  (Ref ref) => PlatformDispatcher.instance.locale.languageCode,
);

/// Kullanıcının Ayarlar'daki dil tercihi (`null` = cihaz dili).
class DilTercihi extends Notifier<IcerikDili?> {
  @override
  IcerikDili? build() =>
      dilKodundan(ref.watch(uygulamaDurumuRepositoryProvider).durum.dilKodu);

  /// Tercihi kaydeder; [dil] `null` ise cihaz diline döner.
  ///
  /// Arayüz beklemeden yeni dile geçer, kayıt arkadan tamamlanır.
  Future<void> sec(IcerikDili? dil) {
    state = dil;
    return ref.read(uygulamaDurumuRepositoryProvider).dilKaydet(dil?.name);
  }
}

/// Kullanıcının dil tercihi.
final NotifierProvider<DilTercihi, IcerikDili?> dilTercihiProvider =
    NotifierProvider<DilTercihi, IcerikDili?>(DilTercihi.new);

/// Uygulamanın görünen dili: arayüz (`MaterialApp.locale`) ve ileride
/// içerik paketi (E5+) bu tek kaynaktan okur.
final Provider<IcerikDili> uygulamaDiliProvider = Provider<IcerikDili>(
  (Ref ref) => uygulamaDiliniCoz(
    tercih: ref.watch(dilTercihiProvider),
    cihazDilKodu: ref.watch(cihazDilKoduProvider),
  ),
);

/// Uygulama dilindeki arayüz metinleri, `BuildContext` olmadan.
///
/// Widget ağacının dışında metin üreten kod içindir: ekrana konmadan
/// çizilen paylaşım kartı ve planlanan bildirimler. Widget'lar
/// `AppLocalizations.of(context)` kullanmaya devam eder.
final Provider<AppLocalizations> arayuzMetinleriProvider =
    Provider<AppLocalizations>(
      (Ref ref) =>
          lookupAppLocalizations(dilLocale(ref.watch(uygulamaDiliProvider))),
    );
