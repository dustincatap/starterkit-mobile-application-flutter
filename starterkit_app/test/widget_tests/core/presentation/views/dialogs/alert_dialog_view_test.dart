import 'package:flutter_test/flutter_test.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_router.gr.dart';
import 'package:starterkit_app/core/presentation/views/dialogs/alert_dialog_view.dart';
import 'package:starterkit_app/features/app/presentation/views/app.dart';

import '../../../../../widget_test_utils.dart';

void main() {
  group(AlertDialogView, () {
    setUp(() async {
      await setUpWidgetTest();
    });

    group('should have title, messsage and primary action button when secondary text is null', () {
      for (final Device device in Device.all) {
        testWidgets('for ${device.name}', (WidgetTester tester) async {
          tester.setupDevice(device);

          const String expectedMessage = 'message';
          const String expectedTitle = 'title';
          const String expectedPrimaryText = 'primaryText';

          await tester.pumpWidget(
            App(
              initialRoute: AlertDialogViewRoute(
                message: expectedMessage,
                title: expectedTitle,
                primaryText: expectedPrimaryText,
                secondaryText: null,
              ),
            ),
          );
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(AlertDialogView),
            tester.matchGoldenFile('alert_dialog_view_title_message_and_primary_action_button', device),
          );
          expect(find.text(expectedMessage), findsOneWidget);
          expect(find.text(expectedTitle), findsOneWidget);
          expect(find.text(expectedPrimaryText), findsOneWidget);
        });
      }
    });

    group('should have title, messsage and primary and secondary action buttons when shown', () {
      for (final Device device in Device.all) {
        testWidgets('for ${device.name}', (WidgetTester tester) async {
          tester.setupDevice(device);

          const String expectedMessage = 'message';
          const String expectedTitle = 'title';
          const String expectedPrimaryText = 'primaryText';
          const String expectedSecondaryText = 'secondaryText';

          await tester.pumpWidget(
            App(
              initialRoute: AlertDialogViewRoute(
                message: expectedMessage,
                title: expectedTitle,
                primaryText: expectedPrimaryText,
                secondaryText: expectedSecondaryText,
              ),
            ),
          );
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(AlertDialogView),
            tester.matchGoldenFile('alert_dialog_view_title_message_and_primary_and_secondary_action_buttons', device),
          );
          expect(find.text(expectedMessage), findsOneWidget);
          expect(find.text(expectedTitle), findsOneWidget);
          expect(find.text(expectedPrimaryText), findsOneWidget);
          expect(find.text(expectedSecondaryText), findsOneWidget);
        });
      }
    });
  });
}
