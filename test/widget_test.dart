import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securemail/main.dart';

void main() {
  testWidgets('SecureMail renders the splash screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SecureMail(),
      ),
    );

    expect(find.text('SECURE'), findsOneWidget);
    expect(find.text('MAIL'), findsOneWidget);
  });
}
