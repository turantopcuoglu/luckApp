import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Motorun kullanıcıya özgü deterministik girdisi.
///
/// Aynı [isimHash] + [dogumTarihi] çifti, aynı gün için her zaman aynı
/// skoru üretir (CLAUDE.md kural 8).
class UserSeed {
  /// [isimHash] ve [dogumTarihi] ile bir kullanıcı tohumu oluşturur.
  const UserSeed({required this.isimHash, required this.dogumTarihi});

  /// Ham isimden hash üreterek tohum oluşturur.
  ///
  /// İsim trim'lenip küçük harfe çevrilir ki "Turan " ile "turan"
  /// aynı kullanıcı sayılsın; sonra SHA-256 hex'i alınır.
  factory UserSeed.fromIsim({
    required String isim,
    required DateTime dogumTarihi,
  }) {
    final String normalize = isim.trim().toLowerCase();
    final String hash = sha256.convert(utf8.encode(normalize)).toString();
    return UserSeed(isimHash: hash, dogumTarihi: dogumTarihi);
  }

  /// Anonim v2 kimliğini mevcut motor girdisine dönüştürür.
  ///
  /// Sabit UTC tarih bir doğum tarihi değildir; eski motorun iki parçalı
  /// girdisini koruyan sürümlü bir sabitleyicidir. İsim ve tercihler katılmaz.
  factory UserSeed.fromRituelKimligi(String kimlik) {
    if (kimlik.trim().isEmpty) {
      throw ArgumentError.value(kimlik, 'kimlik', 'Kimlik boş olamaz.');
    }
    final String hash = sha256
        .convert(utf8.encode('kader:rituel:v2:$kimlik'))
        .toString();
    return UserSeed(isimHash: hash, dogumTarihi: DateTime.utc(2000));
  }

  /// Sürüme göre isim veya anonim ritüel kimliğinin SHA-256 hex özeti.
  final String isimHash;

  /// V1 doğum tarihi veya v2 için sabit UTC algoritma girdisi.
  final DateTime dogumTarihi;
}
