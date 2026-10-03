import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/storage/koleksiyon_repository.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/uygulama_durumu.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> kutu;
  late KoleksiyonRepository repo;

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('koleksiyon_test');
    Hive.init(geciciDizin.path);
    kutu = await Hive.openBox<Map<dynamic, dynamic>>(StorageKeys.appStateBox);
    repo = KoleksiyonRepository(kutu);
  });

  tearDown(() async {
    await kutu.deleteFromDisk();
    await geciciDizin.delete(recursive: true);
  });

  final DateTime pazartesi = DateTime(2026, 7, 6, 9, 30);
  final DateTime sali = DateTime(2026, 7, 7, 22, 10);

  test('boş kutuda koleksiyon boş', () {
    expect(repo.kartlar(), isEmpty);
  });

  test('ilk kazanım yeni kart olarak kaydedilir (saat yok sayılır)', () async {
    final KazanmaSonucu s = await repo.kazan(
      kartId: 'pusula',
      gun: pazartesi,
      nadir: false,
    );
    expect(s, KazanmaSonucu.yeni);
    final KazanilanKart k = repo.kartlar()['pusula']!;
    expect(k.ilkGun, DateTime(2026, 7, 6));
    expect(k.sonGun, DateTime(2026, 7, 6));
    expect(k.nadir, isFalse);
    expect(k.gunSayisi, 1);
  });

  test('aynı gün tekrar kazanmak değişiklik yapmaz (idempotent)', () async {
    await repo.kazan(kartId: 'pusula', gun: pazartesi, nadir: false);
    final KazanmaSonucu s = await repo.kazan(
      kartId: 'pusula',
      gun: DateTime(2026, 7, 6, 23),
      nadir: false,
    );
    expect(s, KazanmaSonucu.degismedi);
    expect(repo.kartlar()['pusula']!.gunSayisi, 1);
  });

  test('başka gün tekrar kazanınca gün sayısı artar, ilk gün korunur',
      () async {
    await repo.kazan(kartId: 'pusula', gun: pazartesi, nadir: false);
    final KazanmaSonucu s = await repo.kazan(
      kartId: 'pusula',
      gun: sali,
      nadir: false,
    );
    expect(s, KazanmaSonucu.tekrar);
    final KazanilanKart k = repo.kartlar()['pusula']!;
    expect(k.gunSayisi, 2);
    expect(k.ilkGun, DateTime(2026, 7, 6));
    expect(k.sonGun, DateTime(2026, 7, 7));
  });

  test('nadir çekiliş kartı nadire yükseltir; nadir kart nadir kalır',
      () async {
    await repo.kazan(kartId: 'pusula', gun: pazartesi, nadir: false);
    expect(
      await repo.kazan(kartId: 'pusula', gun: sali, nadir: true),
      KazanmaSonucu.nadireYukseldi,
    );
    expect(repo.kartlar()['pusula']!.nadir, isTrue);
    await repo.kazan(
      kartId: 'pusula',
      gun: DateTime(2026, 7, 8),
      nadir: false,
    );
    expect(repo.kartlar()['pusula']!.nadir, isTrue);
  });

  test('farklı kartlar birbirini ezmez ve diskten geri okunur', () async {
    await repo.kazan(kartId: 'pusula', gun: pazartesi, nadir: false);
    await repo.kazan(kartId: 'dolunay', gun: sali, nadir: true);
    await kutu.close();
    kutu = await Hive.openBox<Map<dynamic, dynamic>>(StorageKeys.appStateBox);
    final Map<String, KazanilanKart> kartlar = KoleksiyonRepository(
      kutu,
    ).kartlar();
    expect(kartlar.keys, unorderedEquals(<String>['pusula', 'dolunay']));
    expect(kartlar['dolunay']!.nadir, isTrue);
  });

  test('uygulama durumu kaydıyla aynı kutuyu bozmadan paylaşır', () async {
    final UygulamaDurumuRepository durum = UygulamaDurumuRepository(kutu);
    await durum.ilkAcilisiIsaretle(pazartesi);
    await repo.kazan(kartId: 'pusula', gun: pazartesi, nadir: false);
    expect(durum.durum.ilkAcilis, pazartesi);
    expect(repo.kartlar(), hasLength(1));
  });
}
