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

  /// Kullanıcı isminin SHA-256 hex özeti (ham isim saklanmaz).
  final String isimHash;

  /// Kullanıcının doğum tarihi.
  final DateTime dogumTarihi;
}
