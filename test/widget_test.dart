import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bollywood_guess/core/providers.dart';
import 'package:bollywood_guess/main.dart';
import 'package:bollywood_guess/services/ads/ads_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots to splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          adsServiceProvider.overrideWithValue(FakeAdsService()),
        ],
        child: const BollywoodGuessApp(),
      ),
    );
    await tester.pump();
    expect(find.textContaining('BOLLYWOOD'), findsWidgets);

    // Flush splash navigation timer so no pending timers remain.
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();
  });
}
