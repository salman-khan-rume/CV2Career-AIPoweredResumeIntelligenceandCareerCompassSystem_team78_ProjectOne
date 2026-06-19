import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cv2career/main.dart';
import 'package:cv2career/core/constants/app_strings.dart';
import 'package:cv2career/presentation/providers/auth_provider.dart';

void main() {
  testWidgets('App splash screen render test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => const Stream.empty()),
          isGuestProvider.overrideWith((ref) => true),
          userProfileProvider.overrideWith((ref) => Future.value(null)),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the splash screen shows the app name.
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);

    // Let any pending timers/animations settle
    await tester.pump(const Duration(seconds: 3));
  });
}
