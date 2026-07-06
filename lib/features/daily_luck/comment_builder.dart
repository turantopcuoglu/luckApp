import '../../core/luck_engine/luck_engine.dart';
import 'daily_luck_config.dart';
import 'tr_strings.dart';

/// [sonuc] için 2-3 cümlelik günlük yorum metni üretir.
///
/// İlk cümle genel skorun aralığından, sonraki cümleler etkisi en
/// büyük modifiyerlerden şablonla türetilir (plan Session 3, madde 2).
String gunYorumu(LuckResult sonuc) {
  // Modifiyerler mutlak etkiye göre sıralanır: en belirleyici olanlar
  // yoruma girer, sıfır etkili olanlar geride kalır.
  final List<LuckModifier> siralanmis = List<LuckModifier>.of(
    sonuc.modifiyerler,
  )..sort((LuckModifier a, LuckModifier b) => b.etki.abs() - a.etki.abs());

  final Iterable<String> modifiyerCumleleri = siralanmis
      .take(DailyLuckConfig.yorumModifiyerSayisi)
      .map((LuckModifier m) => TrStrings.modifiyerCumlesi(m.ad, m.etki));

  return <String>[
    TrStrings.skorAcilisCumlesi(sonuc.genelSkor),
    ...modifiyerCumleleri,
  ].join(' ');
}
