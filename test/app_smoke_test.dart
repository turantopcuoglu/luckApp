import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/main.dart';

void main() {
  testWidgets('uygulama açılır ve "Kader" yazısını gösterir', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KaderApp()));
    expect(find.text('Kader'), findsOneWidget);
  });
}
