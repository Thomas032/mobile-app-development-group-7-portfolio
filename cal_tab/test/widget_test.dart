import 'package:cal_tab/app/app.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/in_memory_secure_key_value_store.dart';

void main() {
  testWidgets('renders the app shell', (tester) async {
    // GoalStep stacks 3×112-px ChoiceCards plus headers — taller than the
    // default 800×600 test viewport.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
