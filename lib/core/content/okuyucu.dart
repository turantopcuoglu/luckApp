import '../luck_engine/luck_engine.dart';

/// Kullanıcının kendini nasıl tanımladığı: enerji tarzı.
enum EnerjiTarzi {
  /// Enerjisini yalnız kalınca toplar.
  iceDonuk(etiket: 'Yalnız kalınca toplanırım'),

  /// Enerjisini insanlarla toplar.
  disaDonuk(etiket: 'İnsanlarla şarj olurum');

  const EnerjiTarzi({required this.etiket});

  /// Seçenek metni.
  final String etiket;
}

/// Karar verirken öne çıkan taraf.
enum KararTarzi {
  /// Önce kalbini dinler.
  kalp(etiket: 'Önce kalbimi dinlerim'),

  /// Önce aklını ve hesabı dinler.
  akil(etiket: 'Önce aklımı dinlerim');

  const KararTarzi({required this.etiket});

  /// Seçenek metni.
  final String etiket;
}

/// İlişki durumu (aşk yorumlarının doğru kişiye konuşması için).
enum IliskiDurumu {
  /// İlişkisi yok.
  bekar(etiket: 'Bekarım'),

  /// Bir ilişkisi var.
  iliskide(etiket: 'İlişkim var'),

  /// Evli.
  evli(etiket: 'Evliyim');

  const IliskiDurumu({required this.etiket});

  /// Seçenek metni.
  final String etiket;

  /// Partneri olan bir durum mu?
  bool get partnerliMi => this != IliskiDurumu.bekar;
}

/// Günün büyük bölümünü neyin doldurduğu.
enum Ugras {
  /// Bir işte çalışıyor.
  calisiyor(etiket: 'Çalışıyorum', alan: 'işin'),

  /// Öğrenci.
  ogrenci(etiket: 'Öğrenciyim', alan: 'derslerin'),

  /// İş arıyor.
  isArayan(etiket: 'İş arıyorum', alan: 'iş arayışın'),

  /// Kendi işini yürütüyor.
  girisimci(etiket: 'Kendi işim var', alan: 'projelerin'),

  /// Evle ve aileyle meşgul.
  evde(etiket: 'Ev ve aileyle meşgulüm', alan: 'evdeki düzenin');

  const Ugras({required this.etiket, required this.alan});

  /// Seçenek metni.
  final String etiket;

  /// Cümle içinde özne olarak kullanılan ad öbeği ("Bugün {alan} …").
  final String alan;
}

/// Kullanıcının onboarding'de verdiği tercih cevapları.
///
/// Tüm alanlar opsiyoneldir: soru atlanabilir; atlanan soruya bağlı
/// metinler genel havuzdan seçilir.
class OkuyucuTercihleri {
  /// Tüm alanları opsiyonel tercih seti.
  const OkuyucuTercihleri({this.enerji, this.karar, this.iliski, this.ugras});

  /// Enerji tarzı.
  final EnerjiTarzi? enerji;

  /// Karar tarzı.
  final KararTarzi? karar;

  /// İlişki durumu.
  final IliskiDurumu? iliski;

  /// Günlük uğraş.
  final Ugras? ugras;

  /// Seçili alanları değiştirilmiş kopya döndürür.
  OkuyucuTercihleri copyWith({
    EnerjiTarzi? enerji,
    KararTarzi? karar,
    IliskiDurumu? iliski,
    Ugras? ugras,
  }) => OkuyucuTercihleri(
    enerji: enerji ?? this.enerji,
    karar: karar ?? this.karar,
    iliski: iliski ?? this.iliski,
    ugras: ugras ?? this.ugras,
  );

  @override
  bool operator ==(Object other) =>
      other is OkuyucuTercihleri &&
      other.enerji == enerji &&
      other.karar == karar &&
      other.iliski == iliski &&
      other.ugras == ugras;

  @override
  int get hashCode => Object.hash(enerji, karar, iliski, ugras);
}

/// İçerik birleştiricisinin tek girdisi: yorumu okuyacak kişi.
class Okuyucu {
  /// Tüm alanlarıyla okuyucu oluşturur.
  const Okuyucu({
    required this.isim,
    required this.seed,
    required this.profil,
    this.tercihler = const OkuyucuTercihleri(),
  });

  /// Selamlamada ve metinde kullanılan görünen ad.
  final String isim;

  /// Motor tohumu (skor ve içerik seçimi için).
  final UserSeed seed;

  /// Sabit kimlik katmanı (numeroloji + burç).
  final KaderProfili profil;

  /// Onboarding tercih cevapları.
  final OkuyucuTercihleri tercihler;
}
