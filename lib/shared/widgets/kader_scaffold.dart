import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';

/// SafeArea, klavye boşluğu ve okunabilir genişlik sağlayan ortak ekran kabuğu.
/// Scrollable gövdeler varsayılan olarak kendi ScrollView'ını yönetir.
class KaderScaffold extends StatelessWidget {
  /// [scrollable] kısa formlarda açılabilir; liste/grid gövdelerinde kapalı kalır.
  const KaderScaffold({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.scrollable = false,
    this.scrollController,
    this.background,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  /// Sabit veya kendi kaydırması olan sayfa içeriği.
  final Widget body;

  /// İçerikten bağımsız çizilen dekoratif arka plan.
  final Widget? background;

  /// İsteğe bağlı Material app bar.
  final PreferredSizeWidget? appBar;

  /// Shell fazında bağlanacak gezinme yüzeyi; kendi SafeArea'sını yönetir.
  final Widget? bottomNavigationBar;

  /// İçeriği tek dikey kaydırmaya sarar; iç içe kaydırma kurulmamalıdır.
  final bool scrollable;

  /// İsteğe bağlı feature denetleyicisi; yalnız scrollable gövdede kullanılır.
  final ScrollController? scrollController;

  /// Ekran kenarı boşluğu.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(padding: padding, child: body);
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (background != null) Positioned.fill(child: background!),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.maxContentWidth,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: scrollable
                      ? SingleChildScrollView(
                          controller: scrollController,
                          child: content,
                        )
                      : content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
