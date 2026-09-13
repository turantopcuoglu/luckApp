import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  test('anonim kimlik adapterı deterministik ve sürüm alanı ayrılmıştır', () {
    final UserSeed seed = UserSeed.fromRituelKimligi('same-id');
    final UserSeed again = UserSeed.fromRituelKimligi('same-id');
    expect(seed.isimHash, again.isimHash);
    expect(seed.dogumTarihi, DateTime.utc(2000));
    expect(
      seed.isimHash,
      isNot(UserSeed.fromRituelKimligi('other-id').isimHash),
    );
    expect(
      seed.isimHash,
      isNot(
        UserSeed.fromIsim(
          isim: 'same-id',
          dogumTarihi: DateTime.utc(2000),
        ).isimHash,
      ),
    );
    expect(() => UserSeed.fromRituelKimligi('  '), throwsArgumentError);
  });
}
