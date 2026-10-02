import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';

/// Reklam altyapısının uygulamaya açılan yüzü.
///
/// Arayüz ve iş kuralları yalnızca bu soyutlamayı bilir; testlerde
/// [BosReklamServisi] kullanılır, üretimde [AdMobReklamServisi].
abstract class ReklamServisi {
  /// Rıza akışını yürütür ve reklam SDK'sını başlatır.
  Future<void> baslat();

  /// Reklam isteği yapılabilir mi? (SDK hazır + rıza durumu uygun)
  bool get hazir;

  /// Ödüllü reklamı gösterir; kullanıcı ödülü kazandıysa true.
  Future<bool> odulluGoster();

  /// Geçiş reklamını gösterir; gösterildiyse true.
  Future<bool> gecisGoster();

  /// Kullanıcıya gizlilik seçenekleri formu gösterilmeli mi?
  bool get gizlilikSecenekleriGerekli;

  /// UMP gizlilik seçenekleri formunu açar.
  Future<void> gizlilikSecenekleriniGoster();

  /// Yalnızca geliştirme: rıza durumunu sıfırlar.
  Future<void> rizayiSifirla();
}

/// Hiçbir şey yapmayan servis (testler ve reklamsız ortamlar).
class BosReklamServisi implements ReklamServisi {
  /// Varsayılan kurucu.
  const BosReklamServisi();

  @override
  Future<void> baslat() async {}

  @override
  bool get hazir => false;

  @override
  Future<bool> odulluGoster() async => false;

  @override
  Future<bool> gecisGoster() async => false;

  @override
  bool get gizlilikSecenekleriGerekli => false;

  @override
  Future<void> gizlilikSecenekleriniGoster() async {}

  @override
  Future<void> rizayiSifirla() async {}
}

/// Google AdMob + UMP (User Messaging Platform) uygulaması.
///
/// Akış (Google'ın önerdiği sıra):
/// 1. Her açılışta `requestConsentInfoUpdate` ile rıza bilgisi tazelenir.
/// 2. Gerekirse rıza formu gösterilir (AEA/UK/CH kullanıcıları).
/// 3. `canRequestAds` true ise Mobile Ads SDK başlatılır ve reklamlar
///    önceden yüklenir.
///
/// Tüm eklenti çağrıları hata yakalamayla sarılıdır: reklam altyapısının
/// bir hatası uygulamanın ana akışını asla durdurmaz.
class AdMobReklamServisi implements ReklamServisi {
  bool _baslatildi = false;
  bool _gizlilikGerekli = false;
  RewardedAd? _odullu;
  InterstitialAd? _gecis;
  Completer<void>? _odulluYukleniyor;

  @override
  bool get hazir => _baslatildi;

  @override
  bool get gizlilikSecenekleriGerekli => _gizlilikGerekli;

  @override
  Future<void> baslat() async {
    try {
      await _rizaBilgisiniTazele();
      if (await ConsentInformation.instance.canRequestAds()) {
        await _sdkBaslat();
      }
      _gizlilikGerekli = await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } on PlatformException catch (hata) {
      debugPrint('Reklam başlatılamadı: $hata');
    } on MissingPluginException catch (hata) {
      debugPrint('Reklam eklentisi yok: $hata');
    }
  }

  Future<void> _rizaBilgisiniTazele() {
    final Completer<void> bitti = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(tagForUnderAgeOfConsent: false),
      () async {
        // Form gerekmiyorsa bu çağrı hemen döner.
        await ConsentForm.loadAndShowConsentFormIfRequired((FormError? hata) {
          if (hata != null) {
            debugPrint('Rıza formu hatası: ${hata.message}');
          }
        });
        if (!bitti.isCompleted) {
          bitti.complete();
        }
      },
      (FormError hata) {
        debugPrint('Rıza bilgisi alınamadı: ${hata.message}');
        if (!bitti.isCompleted) {
          bitti.complete();
        }
      },
    );
    return bitti.future;
  }

  Future<void> _sdkBaslat() async {
    if (_baslatildi) {
      return;
    }
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(maxAdContentRating: AdsConfig.icerikDerecesi),
    );
    _baslatildi = true;
    unawaited(_odulluYukle());
    _gecisYukle();
  }

  Future<void> _odulluYukle() {
    if (_odullu != null) {
      return Future<void>.value();
    }
    if (_odulluYukleniyor != null) {
      return _odulluYukleniyor!.future;
    }
    final Completer<void> tamam = Completer<void>();
    _odulluYukleniyor = tamam;
    RewardedAd.load(
      adUnitId: AdsConfig.odulluBirim,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd reklam) {
          _odullu = reklam;
          _odulluYukleniyor = null;
          tamam.complete();
        },
        onAdFailedToLoad: (LoadAdError hata) {
          debugPrint('Ödüllü reklam yüklenemedi: ${hata.message}');
          _odulluYukleniyor = null;
          tamam.complete();
        },
      ),
    );
    return tamam.future;
  }

  void _gecisYukle() {
    if (_gecis != null) {
      return;
    }
    InterstitialAd.load(
      adUnitId: AdsConfig.gecisBirim,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd reklam) => _gecis = reklam,
        onAdFailedToLoad: (LoadAdError hata) =>
            debugPrint('Geçiş reklamı yüklenemedi: ${hata.message}'),
      ),
    );
  }

  @override
  Future<bool> odulluGoster() async {
    if (!_baslatildi) {
      return false;
    }
    if (_odullu == null) {
      await _odulluYukle().timeout(
        AdsConfig.yuklemeZamanAsimi,
        onTimeout: () {},
      );
    }
    final RewardedAd? reklam = _odullu;
    if (reklam == null) {
      return false;
    }
    _odullu = null;

    final Completer<bool> sonuc = Completer<bool>();
    bool kazandi = false;
    reklam.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (RewardedAd r) {
        r.dispose();
        if (!sonuc.isCompleted) {
          sonuc.complete(kazandi);
        }
        unawaited(_odulluYukle());
      },
      onAdFailedToShowFullScreenContent: (RewardedAd r, AdError hata) {
        r.dispose();
        if (!sonuc.isCompleted) {
          sonuc.complete(false);
        }
        unawaited(_odulluYukle());
      },
    );
    await reklam.show(
      onUserEarnedReward: (AdWithoutView r, RewardItem odul) => kazandi = true,
    );
    return sonuc.future;
  }

  @override
  Future<bool> gecisGoster() async {
    final InterstitialAd? reklam = _gecis;
    if (!_baslatildi || reklam == null) {
      _gecisYukle();
      return false;
    }
    _gecis = null;
    final Completer<bool> sonuc = Completer<bool>();
    reklam.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (InterstitialAd r) {
        r.dispose();
        if (!sonuc.isCompleted) {
          sonuc.complete(true);
        }
        _gecisYukle();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd r, AdError hata) {
        r.dispose();
        if (!sonuc.isCompleted) {
          sonuc.complete(false);
        }
        _gecisYukle();
      },
    );
    await reklam.show();
    return sonuc.future;
  }

  @override
  Future<void> gizlilikSecenekleriniGoster() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((FormError? hata) {
        if (hata != null) {
          debugPrint('Gizlilik formu hatası: ${hata.message}');
        }
      });
      // Kullanıcı rızasını değiştirmiş olabilir.
      if (await ConsentInformation.instance.canRequestAds()) {
        await _sdkBaslat();
      }
    } on PlatformException catch (hata) {
      debugPrint('Gizlilik formu açılamadı: $hata');
    }
  }

  @override
  Future<void> rizayiSifirla() async {
    try {
      await ConsentInformation.instance.reset();
    } on PlatformException catch (hata) {
      debugPrint('Rıza sıfırlanamadı: $hata');
    }
  }
}
