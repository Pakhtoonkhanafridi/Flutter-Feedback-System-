import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feedback_app/app.dart';

void main() {
  testWidgets('drawer opens feedback form and validates required text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FeedbackApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Feedback').last);
    await tester.pumpAndSettle();

    expect(find.text('Tell us what happened'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Submit feedback'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Submit feedback'));
    await tester.pumpAndSettle();

    expect(find.text('Feedback is required.'), findsOneWidget);
  });
}
