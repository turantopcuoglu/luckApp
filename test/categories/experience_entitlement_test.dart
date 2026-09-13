import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/experience_dimension.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/features/categories/categories_config.dart';
import 'package:kader/features/categories/entitlement.dart';

void main() {
  test(
    'Bağ ve Üretim eski Aşk ve Para kilitleriyle aynı politikayı kullanır',
    () {
      expect(CategoriesConfig.kilitliAlanlar, <ExperienceDimension>{
        ExperienceDimension.bag,
        ExperienceDimension.uretim,
      });
      expect(CategoriesConfig.kilitliKategoriler, <LuckCategory>{
        LuckCategory.ask,
        LuckCategory.para,
      });
    },
  );

  test(
    'premium açılıp kapanınca eski ve yeni tüketiciler birlikte güncellenir',
    () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      // Abonelikler, açık ekranların yetki değişimini izlediği durumu temsil eder.
      for (final ExperienceDimension alan in ExperienceDimension.values) {
        container.listen(alanKilitliProvider(alan), (_, _) {});
        container.listen(kategoriKilitliProvider(alan.kategori), (_, _) {});
      }
      for (final bool premium in <bool>[false, true, false]) {
        container.read(entitlementProvider.notifier).state = premium;
        for (final ExperienceDimension alan in ExperienceDimension.values) {
          final bool beklenen =
              !premium &&
              (alan == ExperienceDimension.bag ||
                  alan == ExperienceDimension.uretim);
          expect(container.read(alanKilitliProvider(alan)), beklenen);
          expect(
            container.read(kategoriKilitliProvider(alan.kategori)),
            beklenen,
          );
        }
      }
    },
  );
}
