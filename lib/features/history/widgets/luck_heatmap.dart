import 'package:flutter/material.dart';

import '../../../core/content/content_config.dart';
import '../../../core/localization/app_dil.dart';
import '../../../core/storage/daily_record.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../daily_luck/tr_strings.dart';
import '../history_config.dart';
import '../history_strings.dart';

/// GitHub-tarzı şans heatmap'i: son [HistoryConfig.pencereGunu] gün,
/// hafta sütunları × 7 gün satırı (Pazartesi üst → Pazar alt).
///
/// Hücre rengi skordan (`SkorBandi.bandiBul` → [HistoryConfig.bandRampasi])
/// gelir; kayıtsız günler [HistoryConfig.bosGunRengi], bugünden sonraki
/// günler görünmez. Kayıtlı hücreye dokununca gün + skor SnackBar'ı çıkar.
///
/// Yatay kaydırılır ve ilk açılışta sona kayar (bugün görünür). Kaydırma
/// için [ScrollController] tutulduğundan StatefulWidget'tır (setState
/// kullanılmaz — CLAUDE.md kural 5).
class LuckHeatmap extends StatefulWidget {
  /// [kayitlar] tüm günlük kayıtlar, [bugun] pencere çıpası.
  const LuckHeatmap({
    required this.kayitlar,
    required this.bugun,
    required this.dil,
    super.key,
  });

  /// Gösterilecek tüm kayıtlar.
  final List<DailyRecord> kayitlar;

  /// Bugünün tarihi (pencerenin son günü).
  final DateTime bugun;

  /// Aktif uygulama dili (gün adları, hücre metinleri için).
  final AppDil dil;

  @override
  State<LuckHeatmap> createState() => _LuckHeatmapState();
}

class _LuckHeatmapState extends State<LuckHeatmap> {
  final ScrollController _kaydirma = ScrollController();

  /// Bir satırın (hücre + alt boşluk) kapladığı dikey yer.
  static const int _haftaninGunu = 7;

  @override
  void initState() {
    super.initState();
    // İlk layout sonrası sona kay: en güncel günler görünür olsun.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_kaydirma.hasClients) {
        _kaydirma.jumpTo(_kaydirma.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _kaydirma.dispose();
    super.dispose();
  }

  /// Saatten arındırılmış gün.
  DateTime _gunuNormalle(DateTime g) => DateTime(g.year, g.month, g.day);

  @override
  Widget build(BuildContext context) {
    final DateTime sonGun = _gunuNormalle(widget.bugun);
    // Pencerenin ilk günü, ardından o güne-veya-öncesine düşen Pazartesi.
    final DateTime ilkGun = DateTime(
      sonGun.year,
      sonGun.month,
      sonGun.day - (HistoryConfig.pencereGunu - 1),
    );
    final DateTime gridBaslangic = DateTime(
      ilkGun.year,
      ilkGun.month,
      ilkGun.day - (ilkGun.weekday - 1),
    );
    final int gridGunSayisi = sonGun.difference(gridBaslangic).inDays + 1;
    final int haftaSayisi = (gridGunSayisi / _haftaninGunu).ceil();

    // Hızlı arama için gün anahtarı → kayıt eşlemesi (O(1)).
    final Map<String, DailyRecord> gunToKayit = <String, DailyRecord>{
      for (final DailyRecord k in widget.kayitlar) gunAnahtari(k.gun): k,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _gunEtiketleri(context),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: SingleChildScrollView(
            controller: _kaydirma,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int hafta = 0; hafta < haftaSayisi; hafta++)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: HistoryConfig.hucreAraligi,
                    ),
                    child: _haftaSutunu(
                      context,
                      gridBaslangic,
                      hafta,
                      sonGun,
                      gunToKayit,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Soldaki gün etiketleri sütunu (Pt, Sa, Ça, ...).
  Widget _gunEtiketleri(BuildContext context) {
    final TextStyle? stil = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary);
    // Gün kısaltmaları yalnızca görsel kılavuz → semantics'e girmez.
    return ExcludeSemantics(
      child: Column(
        children: <Widget>[
          for (int gun = 0; gun < _haftaninGunu; gun++)
            Container(
              height: HistoryConfig.hucreBoyutu,
              margin: const EdgeInsets.only(bottom: HistoryConfig.hucreAraligi),
              alignment: Alignment.centerRight,
              child: Text(
                TrStrings.gunAdlari(widget.dil)[gun].substring(0, 2),
                style: stil,
              ),
            ),
        ],
      ),
    );
  }

  /// Tek bir hafta sütunu: 7 gün hücresi.
  Widget _haftaSutunu(
    BuildContext context,
    DateTime gridBaslangic,
    int hafta,
    DateTime sonGun,
    Map<String, DailyRecord> gunToKayit,
  ) {
    return Column(
      children: <Widget>[
        for (int gunIndeksi = 0; gunIndeksi < _haftaninGunu; gunIndeksi++)
          _hucre(
            context,
            DateTime(
              gridBaslangic.year,
              gridBaslangic.month,
              gridBaslangic.day + hafta * _haftaninGunu + gunIndeksi,
            ),
            sonGun,
            gunToKayit,
          ),
      ],
    );
  }

  /// Tek gün hücresi. Bugünden sonra → görünmez; kayıtsız → boş renk;
  /// kayıtlı → bant rengi + dokunulabilir.
  Widget _hucre(
    BuildContext context,
    DateTime gun,
    DateTime sonGun,
    Map<String, DailyRecord> gunToKayit,
  ) {
    final bool gelecek = gun.isAfter(sonGun);
    final DailyRecord? kayit = gelecek ? null : gunToKayit[gunAnahtari(gun)];

    final Color renk = gelecek
        ? Colors.transparent
        : kayit == null
        ? HistoryConfig.bosGunRengi
        : HistoryConfig.bandRampasi[SkorBandi.bandiBul(kayit.sonuc.genelSkor)]!;

    final Widget kutu = Container(
      width: HistoryConfig.hucreBoyutu,
      height: HistoryConfig.hucreBoyutu,
      margin: const EdgeInsets.only(bottom: HistoryConfig.hucreAraligi),
      decoration: BoxDecoration(
        color: renk,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );

    // Boş/gelecek hücre yalnızca görseldir → semantics ağacından çıkar.
    if (kayit == null) {
      return ExcludeSemantics(child: kutu);
    }
    // Kayıtlı hücre: tarih + skor etiketli tek dokunulabilir düğüm.
    return Semantics(
      button: true,
      container: true,
      label: HistoryStrings.hucreErisim(
        widget.dil,
        TrStrings.tarihMetni(widget.dil, gun),
        kayit.sonuc.genelSkor,
      ),
      child: GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              HistoryStrings.hucreDetay(
                widget.dil,
                TrStrings.tarihMetni(widget.dil, gun),
                kayit.sonuc.genelSkor,
              ),
            ),
          ),
        ),
        child: kutu,
      ),
    );
  }
}
