import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/fortune_composer.dart';
import '../../core/content/gunluk_okuma.dart';
import '../../core/content/sayi_metinleri.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import '../ads/banner_reklam_alani.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../daily_luck/tr_strings.dart';
import '../legal/legal_texts.dart';
import '../premium/kilit_secenekleri.dart';
import '../premium/premium_providers.dart';
import 'dogum_haritasi_screen.dart';
import 'hesap_metni.dart';
import 'kilitli_bolum_karti.dart';
import 'numeroloji_raporu_screen.dart';
import 'profile_config.dart';
import 'profile_strings.dart';
import 'tam_ad_duzenle.dart';

/// Kader Profili: kullanıcının sabit numeroloji sayıları, burcu ve
/// uzun kişilik okuması.
///
/// Rakibin en sevilen yanı olan "beni anlattı" hissini üreten ekran:
/// sayılar şeffaf biçimde hesaplanır, metinler sayının karakterinden
/// yazılmıştır. İlk üç bölüm ücretsizdir; kalanı Premium ya da günlük
/// ödüllü reklamla açılır.
class KaderProfiliScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const KaderProfiliScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final UserProfile profil = ref.watch(aktifProfilProvider);
    final KaderProfili kader = profil.kaderProfili;
    final bool kilitli = ref.watch(profilKilitliProvider);
    final List<ProfilBolumu> bolumler = profilOkumasi(
      okuyucu: profil.okuyucu,
      gun: ref.watch(bugunProvider),
    );
    final SayiKarakteri karakter =
        SayiMetinleri.yasamYolu[kader.yasamYolu.deger]!;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            Text(ProfileStrings.baslik, style: yazi.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ProfileStrings.aciklama,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            _KimlikKarti(profil: profil, kader: kader, karakter: karakter),
            const SizedBox(height: AppSpacing.md),
            const BuyukUcluKarti(),
            const SizedBox(height: AppSpacing.md),
            _SayiKarolari(kader: kader),
            if (kader.isimSayisi == null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.edit_note_rounded,
                      color: AppColors.gold),
                  title: const Text(ProfileStrings.tamAdEksikBaslik),
                  subtitle: const Text(ProfileStrings.tamAdEksikAciklama),
                  onTap: () => unawaited(tamAdiDuzenle(context, ref)),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.gold,
                ),
                title: const Text(ProfileStrings.raporGirisBaslik),
                subtitle: const Text(ProfileStrings.raporGirisAciklama),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(
                  Navigator.of(context).push(
                    fadeThroughRoute<void>(const NumerolojiRaporuScreen()),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final ProfilBolumu bolum in bolumler) ...<Widget>[
              KilitliBolumKarti(
                baslik: bolum.baslik,
                metin: bolum.metin,
                kilitli: bolum.premium && kilitli,
                onKilidiAc: () => unawaited(
                  kilitSecenekleriniGoster(
                    context,
                    ref,
                    kilitAnahtari: KilitAnahtarlari.profil,
                    aciklama: ProfileStrings.kilitAciklamasi,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            BannerReklamAlani(goster: ref.watch(bannerGosterilebilirProvider)),
            const SizedBox(height: AppSpacing.md),
            Text(
              YasalMetinler.kisaNot,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Ad, doğum tarihi, burç ve yaşam yolu lakabı.
class _KimlikKarti extends StatelessWidget {
  const _KimlikKarti({
    required this.profil,
    required this.kader,
    required this.karakter,
  });

  final UserProfile profil;
  final KaderProfili kader;
  final SayiKarakteri karakter;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(profil.tamAd ?? profil.isim, style: yazi.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${TrStrings.tarihMetni(profil.dogumTarihi).split(',').first} · '
              '${kader.burc.etiket} (${kader.burc.element.etiket})',
              style: yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                Chip(label: Text(karakter.lakap)),
                for (final String anahtar in karakter.anahtarlar)
                  Chip(label: Text(anahtar)),
                if (kader.burcSinirGunu)
                  const Chip(
                    avatar: Icon(Icons.info_outline, size: AppSpacing.md),
                    label: Text(ProfileStrings.sinirGunu),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dört sayı karosu (yaşam yolu, isim, ruh, kişilik).
class _SayiKarolari extends ConsumerWidget {
  const _SayiKarolari({required this.kader});

  final KaderProfili kader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<(String, SayiHesabi?)> karolar = <(String, SayiHesabi?)>[
      (ProfileStrings.yasamYolu, kader.yasamYolu),
      (ProfileStrings.isimSayisi, kader.isimSayisi),
      (ProfileStrings.ruhSayisi, kader.ruhSayisi),
      (ProfileStrings.kisilikSayisi, kader.kisilikSayisi),
    ];
    return Row(
      children: <Widget>[
        for (int i = 0; i < karolar.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _SayiKarosu(
              etiket: karolar[i].$1,
              hesap: karolar[i].$2,
              onTap: karolar[i].$2 == null
                  ? () => unawaited(tamAdiDuzenle(context, ref))
                  : () => _hesabiGoster(context, karolar[i].$1, karolar[i].$2!),
            ),
          ),
        ],
      ],
    );
  }

  void _hesabiGoster(BuildContext context, String etiket, SayiHesabi hesap) {
    final TextTheme yazi = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext _) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$etiket ${hesap.deger}'
                '${hesap.ustaMi ? ' · ${ProfileStrings.ustaSayi}' : ''}',
                style: yazi.titleLarge?.copyWith(color: AppColors.gold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(ProfileStrings.nasilHesaplandi, style: yazi.titleSmall),
              const SizedBox(height: AppSpacing.md),
              for (final HesapSatiri satir in hesapSatirlari(hesap))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: ProfileConfig.adimEtiketGenisligi,
                        child: Text(
                          satir.etiket,
                          style: yazi.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          satir.islem,
                          style: yazi.bodyMedium?.copyWith(
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ProfileStrings.sistemNotu,
                style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SayiKarosu extends StatelessWidget {
  const _SayiKarosu({
    required this.etiket,
    required this.hesap,
    required this.onTap,
  });

  final String etiket;
  final SayiHesabi? hesap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.xs,
          ),
          child: Column(
            children: <Widget>[
              Text(
                hesap == null ? '+' : '${hesap!.deger}',
                style: yazi.headlineMedium?.copyWith(color: AppColors.gold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                hesap == null ? ProfileStrings.tamAdEkle : etiket,
                style: yazi.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
