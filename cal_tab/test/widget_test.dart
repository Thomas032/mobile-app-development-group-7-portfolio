import 'package:cal_tab/app/app.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/in_memory_secure_key_value_store.dart';

void main() {
  testWidgets('renders the app shell', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(
            InMemorySecureKeyValueStore(),
          ),
        ],
        child: const CalTabApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CalTab'), findsOneWidget);
  });
}
