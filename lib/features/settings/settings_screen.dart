import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/fortune_composer.dart';
import '../../core/localization/app_dil.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../feedback/notification_service.dart';
import 'settings_config.dart';
import 'settings_strings.dart';

/// Ayarlar ekranı: isim düzenleme, bildirim tercihleri ve hakkında
/// (Phase 1). Ana ekrandaki dişli ikonundan açılır.
///
/// İsim [TextEditingController] için [ConsumerStatefulWidget] kullanılır
/// (CLAUDE.md kural 5: setState yalnız lokal denetleyici için).
class SettingsScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// İsim alanının denetleyicisi.
  final TextEditingController _isimKontrol = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mevcut isimle doldur; profil her koşulda geçerli (onboarding sonrası).
    _isimKontrol.text = ref.read(aktifProfilProvider).isim;
  }

  @override
  void dispose() {
    _isimKontrol.dispose();
    super.dispose();
  }

  /// Profili kaydeder ve aktif profil sağlayıcısını tazeler.
  ///
  /// Hive bellek içi kutuyu anında günceller; disk yazması bilinçli
  /// olarak beklenmez (ProfileFormScreen ile aynı desen). Böylece UI
  /// takılmaz ve okuma yolları güncel değeri hemen görür.
  void _profilKaydet(UserProfile yeni) {
    unawaited(ref.read(userRepositoryProvider).kaydet(yeni));
    ref.invalidate(aktifProfilProvider);
  }

  /// İsmi doğrular, yeniden-hesaplama uyarısını gösterir ve onayda kaydeder.
  Future<void> _isimKaydet() async {
    final AppDil dil = ref.read(dilProvider);
    final String yeniIsim = _isimKontrol.text.trim();
    if (yeniIsim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SettingsStrings.isimBosUyarisi(dil))),
      );
      return;
    }

    final UserProfile profil = ref.read(aktifProfilProvider);
    if (yeniIsim == profil.isim) {
      return; // Değişiklik yok.
    }

    final bool onay =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) => AlertDialog(
            title: Text(SettingsStrings.isimUyariBaslik(dil)),
            content: Text(SettingsStrings.isimUyariMetin(dil)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(SettingsStrings.uyariVazgec(dil)),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(SettingsStrings.uyariDevam(dil)),
              ),
            ],
          ),
        ) ??
        false;
    if (!onay || !mounted) {
      return;
    }

    _profilKaydet(profil.copyWith(isim: yeniIsim));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(SettingsStrings.isimKaydedildi(dil))),
    );
  }

  /// Uygulama dilini değiştirir: profile yazar, sağlayıcıları tazeler
  /// (dilProvider aktifProfil'i izlediğinden tüm ağaç yeniden kurulur).
  void _dilSec(AppDil yeni) {
    if (ref.read(dilProvider) == yeni) {
      return;
    }
    _profilKaydet(ref.read(aktifProfilProvider).copyWith(dil: yeni));
  }

  /// Bildirimleri açar/kapatır: kapatınca iptal eder, açınca planlar.
  Future<void> _bildirimlerToggle(bool acik) async {
    final UserProfile yeni = ref
        .read(aktifProfilProvider)
        .copyWith(bildirimlerAcik: acik);
    _profilKaydet(yeni);

    final NotificationService servis = ref.read(notificationServiceProvider);
    if (acik) {
      await servis.gunlukBildirimleriPlanla(
        simdi: DateTime.now(),
        dil: ref.read(dilProvider),
        aksamDakika: yeni.aksamBildirimDakika,
        sabahDakika: yeni.sabahBildirimDakika,
        sansliSaatBaslangiciSaati: _sansliSaatSenkron(),
      );
    } else {
      await servis.iptalEt();
    }
  }

  /// Şanslı saati BLOKLAMADAN, cache'deki bugünkü sonuçtan hesaplar.
  ///
  /// Ana ekran bugünün sonucunu zaten çözdüğü için değer genelde
  /// hazırdır; değilse `null` döner (zararsız — bir sonraki açılışta
  /// main.dart planlar). UI event handler'ında `await` KULLANMAZ
  /// (donma/askıda kalma riskini önler).
  int? _sansliSaatSenkron() {
    final LuckResult? sonuc = ref.read(gununSansiProvider).valueOrNull;
    if (sonuc == null) {
      return null;
    }
    return gununSansliSaatBaslangici(
      motor: ref.read(luckEngineProvider),
      kullanici: ref.read(aktifProfilProvider).seed,
      sonuc: sonuc,
    );
  }

  /// Akşam ([aksam] true) veya sabah hatırlatma saatini seçtirir ve
  /// yeni saatle bildirimleri yeniden planlar.
  Future<void> _saatSec({required bool aksam}) async {
    final UserProfile profil = ref.read(aktifProfilProvider);
    final int mevcutDakika = aksam
        ? profil.aksamBildirimDakika ?? SettingsConfig.varsayilanAksamDakika
        : profil.sabahBildirimDakika ?? SettingsConfig.varsayilanSabahDakika;
    final (int saat, int dakika) = NotificationService.saatDakikaAyir(
      mevcutDakika,
    );

    final TimeOfDay? secilen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: saat, minute: dakika),
    );
    if (secilen == null || !mounted) {
      return;
    }

    final int yeniDakika = NotificationService.dakikayaCevir(
      secilen.hour,
      secilen.minute,
    );
    final UserProfile yeni = aksam
        ? profil.copyWith(aksamBildirimDakika: yeniDakika)
        : profil.copyWith(sabahBildirimDakika: yeniDakika);
    _profilKaydet(yeni);

    await ref
        .read(notificationServiceProvider)
        .gunlukBildirimleriPlanla(
          simdi: DateTime.now(),
          dil: ref.read(dilProvider),
          aksamDakika: yeni.aksamBildirimDakika,
          sabahDakika: yeni.sabahBildirimDakika,
          sansliSaatBaslangiciSaati: _sansliSaatSenkron(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final UserProfile profil = ref.watch(aktifProfilProvider);
    final AppDil dil = ref.watch(dilProvider);
    final bool bildirimlerAcik = profil.bildirimlerAcik;

    final int aksamDakika =
        profil.aksamBildirimDakika ?? SettingsConfig.varsayilanAksamDakika;
    final int sabahDakika =
        profil.sabahBildirimDakika ?? SettingsConfig.varsayilanSabahDakika;
    final (int aksamS, int aksamD) = NotificationService.saatDakikaAyir(
      aksamDakika,
    );
    final (int sabahS, int sabahD) = NotificationService.saatDakikaAyir(
      sabahDakika,
    );

    return Scaffold(
      appBar: AppBar(title: Text(SettingsStrings.baslik(dil))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // — İsim bölümü —
              Text(
                SettingsStrings.isimBolumu(dil),
                style: yaziTemasi.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _isimKontrol,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _isimKaydet,
                    child: Text(SettingsStrings.isimKaydet(dil)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // — Dil bölümü —
              Text(
                SettingsStrings.dilBolumu(dil),
                style: yaziTemasi.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<AppDil>(
                segments: const <ButtonSegment<AppDil>>[
                  ButtonSegment<AppDil>(
                    value: AppDil.tr,
                    label: Text(SettingsStrings.dilTurkce),
                  ),
                  ButtonSegment<AppDil>(
                    value: AppDil.en,
                    label: Text(SettingsStrings.dilIngilizce),
                  ),
                ],
                selected: <AppDil>{dil},
                onSelectionChanged: (Set<AppDil> secim) => _dilSec(secim.first),
              ),
              const SizedBox(height: AppSpacing.xl),

              // — Bildirim bölümü —
              Text(
                SettingsStrings.bildirimBolumu(dil),
                style: yaziTemasi.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(SettingsStrings.bildirimAcik(dil)),
                value: bildirimlerAcik,
                activeThumbColor: AppColors.gold,
                onChanged: _bildirimlerToggle,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: bildirimlerAcik,
                title: Text(SettingsStrings.aksamHatirlatma(dil)),
                trailing: Text(
                  NotificationService.saatMetni(aksamS, aksamD),
                  style: yaziTemasi.titleMedium?.copyWith(
                    color: bildirimlerAcik
                        ? AppColors.gold
                        : AppColors.textSecondary,
                  ),
                ),
                onTap: bildirimlerAcik ? () => _saatSec(aksam: true) : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: bildirimlerAcik,
                title: Text(SettingsStrings.sabahHatirlatma(dil)),
                trailing: Text(
                  NotificationService.saatMetni(sabahS, sabahD),
                  style: yaziTemasi.titleMedium?.copyWith(
                    color: bildirimlerAcik
                        ? AppColors.gold
                        : AppColors.textSecondary,
                  ),
                ),
                onTap: bildirimlerAcik ? () => _saatSec(aksam: false) : null,
              ),
              const SizedBox(height: AppSpacing.xl),

              // — Hakkında bölümü —
              Text(
                SettingsStrings.hakkindaBolumu(dil),
                style: yaziTemasi.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${SettingsStrings.surumEtiketi(dil)}: '
                '${SettingsConfig.uygulamaSurumu}',
                style: yaziTemasi.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                SettingsStrings.eglenceAmacli(dil),
                style: yaziTemasi.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
