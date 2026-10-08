import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/arac_okumalari.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/gunluk_okuma.dart';
import 'package:kader/core/content/harita_metinleri.dart';
import 'package:kader/core/content/icerik_paketi.dart';
import 'package:kader/core/content/kisisel_havuzlar.dart';
import 'package:kader/core/content/neden_metinleri.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/content/slot_doldurucu.dart';
import 'package:kader/core/content/tr_icerik_paketi.dart';
import 'package:kader/core/content/turkce_ek.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

/// Her adı köşeli parantez içine alan sahte paket: birleştiricilerin
/// adları gerçekten paketten okuduğunu (enum etiketinden değil) gösterir.
final class _IsaretliPaket implements IcerikPaketi {
  const _IsaretliPaket();

  String _isaretle(String s) => '[$s]';

  @override
  IcerikDili get dil => IcerikDili.en;

  @override
  String burcAdi(Burc burc) => _isaretle(trIcerik.burcAdi(burc));

  @override
  String elementAdi(BurcElementi element) =>
      _isaretle(trIcerik.elementAdi(element));

  @override
  String kategoriAdi(LuckCategory kategori) =>
      _isaretle(trIcerik.kategoriAdi(kategori));

  @override
  String ayEvresiAdi(AyEvresi evre) => _isaretle(trIcerik.ayEvresiAdi(evre));

  @override
  String uyumDerecesiAdi(UyumDerecesi derece) =>
      _isaretle(trIcerik.uyumDerecesiAdi(derece));

  @override
  String enerjiTarziAdi(EnerjiTarzi tarz) =>
      _isaretle(trIcerik.enerjiTarziAdi(tarz));

  @override
  String kararTarziAdi(KararTarzi tarz) =>
      _isaretle(trIcerik.kararTarziAdi(tarz));

  @override
  String iliskiDurumuAdi(IliskiDurumu durum) =>
      _isaretle(trIcerik.iliskiDurumuAdi(durum));

  @override
  String ugrasAdi(Ugras ugras) => _isaretle(trIcerik.ugrasAdi(ugras));

  @override
  String ugrasAlani(Ugras? ugras) => _isaretle(trIcerik.ugrasAlani(ugras));

  @override
  String iyelik(String isim) => '$isim’s';
}

void main() {
  group('TrIcerikPaketi', () {
    // Geçiş boyunca enum etiketleri ile paket tabloları aynı kalmalı;
    // aksi hâlde ekranlar (hâlâ etiket okuyan) ile okumalar ayrışır.
    test('dili Türkçe', () {
      expect(trIcerik.dil, IcerikDili.tr);
    });

    test('motor adları enum etiketleriyle aynı', () {
      for (final Burc b in Burc.values) {
        expect(trIcerik.burcAdi(b), b.etiket, reason: b.name);
      }
      for (final BurcElementi e in BurcElementi.values) {
        expect(trIcerik.elementAdi(e), e.etiket, reason: e.name);
      }
      for (final LuckCategory k in LuckCategory.values) {
        expect(trIcerik.kategoriAdi(k), k.etiket, reason: k.name);
      }
      for (final AyEvresi a in AyEvresi.values) {
        expect(trIcerik.ayEvresiAdi(a), a.etiket, reason: a.name);
      }
      for (final UyumDerecesi d in UyumDerecesi.values) {
        expect(trIcerik.uyumDerecesiAdi(d), d.etiket, reason: d.name);
      }
    });

    test('tercih seçenekleri ve uğraş öbekleri enum alanlarıyla aynı', () {
      for (final EnerjiTarzi t in EnerjiTarzi.values) {
        expect(trIcerik.enerjiTarziAdi(t), t.etiket, reason: t.name);
      }
      for (final KararTarzi t in KararTarzi.values) {
        expect(trIcerik.kararTarziAdi(t), t.etiket, reason: t.name);
      }
      for (final IliskiDurumu d in IliskiDurumu.values) {
        expect(trIcerik.iliskiDurumuAdi(d), d.etiket, reason: d.name);
      }
      for (final Ugras u in Ugras.values) {
        expect(trIcerik.ugrasAdi(u), u.etiket, reason: u.name);
        expect(trIcerik.ugrasAlani(u), u.alan, reason: u.name);
      }
      expect(trIcerik.ugrasAlani(null), KisiselHavuzlar.varsayilanUgrasAlani);
    });

    test('iyelik Türkçe ek kurallarını kullanır', () {
      for (final String isim in <String>['Ayşe', 'Turan', 'Işıl', 'Ömer']) {
        expect(trIcerik.iyelik(isim), TurkceEk.ilgi(isim));
      }
      expect(trIcerik.iyelik('Ayşe'), "Ayşe'nin");
    });

    test('Türkçe metin dosyaları adları paketten alır', () {
      expect(HaritaMetinleri.ayBasligi(Burc.yengec), 'Ay burcun · Yengeç');
      expect(
        HaritaMetinleri.ozet(Burc.balik, Burc.yay, null),
        'Güneş Balık · Ay Yay · Yükselen ?',
      );
      expect(NedenMetinleri.ayEvresiEtiketi(AyEvresi.dolunay, 3), 'Dolunay +3');
    });
  });

  group('birleştiriciler paket parametresi', () {
    const LuckEngine motor = LuckEngine();
    const IcerikPaketi isaretli = _IsaretliPaket();
    final DateTime dogum = DateTime(1992, 3, 25); // Koç, Ateş
    final DateTime gun = DateTime(2027, 2, 14);
    final Okuyucu okuyucu = Okuyucu(
      isim: 'Ayşe',
      seed: UserSeed.fromIsim(isim: 'Ayşe', dogumTarihi: dogum),
      profil: KaderProfili.hesapla(dogumTarihi: dogum, tamAd: 'Ayşe Yılmaz'),
      tercihler: const OkuyucuTercihleri(ugras: Ugras.ogrenci),
    );

    test('slot sözlüğü adları ve iyeliği paketten alır', () {
      final Map<String, String> tr = slotSozlugu(okuyucu);
      final Map<String, String> s = slotSozlugu(okuyucu, paket: isaretli);
      expect(tr[SlotAnahtarlari.burc], 'Koç');
      expect(tr[SlotAnahtarlari.isimIlgi], "Ayşe'nin");
      expect(tr[SlotAnahtarlari.ugrasAlani], 'derslerin');
      expect(s[SlotAnahtarlari.burc], '[Koç]');
      expect(s[SlotAnahtarlari.isimIlgi], 'Ayşe’s');
      expect(s[SlotAnahtarlari.ugrasAlani], '[derslerin]');
    });

    test('profil ve uyum başlıkları paketteki adları kullanır', () {
      final ProfilBolumu burc = profilOkumasi(
        okuyucu: okuyucu,
        gun: gun,
        paket: isaretli,
      ).firstWhere((ProfilBolumu b) => b.tur == ProfilBolumTuru.burc);
      expect(burc.baslik, '[Koç] burcu · [Ateş]');

      final UyumOkumasi u = uyumOkumasi(
        okuyucu: okuyucu,
        digerIsim: 'Mert',
        digerProfil: KaderProfili.hesapla(dogumTarihi: DateTime(1991, 7, 30)),
        paket: isaretli,
      );
      expect(
        u.bolumler.map((UyumBolumu b) => b.baslik),
        contains('[Koç] & [Aslan]'),
      );
    });

    test('varsayılan paket Türkçedir: açık trIcerik aynı çıktıyı verir', () {
      final LuckResult sonuc = motor.hesapla(kullanici: okuyucu.seed, gun: gun);
      expect(
        gunlukOkuma(motor: motor, okuyucu: okuyucu, sonuc: sonuc).kartMetni,
        gunlukOkuma(
          motor: motor,
          okuyucu: okuyucu,
          sonuc: sonuc,
          paket: trIcerik,
        ).kartMetni,
      );
      expect(
        isimOkumasi(
          IsimAnalizi.hesapla('Ayşe Yılmaz')!,
        ).map((AracBolumu b) => b.metin),
        isimOkumasi(
          IsimAnalizi.hesapla('Ayşe Yılmaz')!,
          paket: trIcerik,
        ).map((AracBolumu b) => b.metin),
      );
    });
  });
}
