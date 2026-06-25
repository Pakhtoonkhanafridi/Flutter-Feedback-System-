import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feedback_app/app.dart';

void main() {
  testWidgets('drawer opens feedback form and validates required text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const FeedbackApp());

    expect(find.text('Feedback Hub'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Feedback').last);
    await tester.pumpAndSettle();

    expect(find.text('Tell us about your experience'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Submit'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Please tell us about your experience'), findsOneWidget);
  });

  testWidgets('feedback layout fits compact mobile viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const FeedbackApp());
    expectNoFlutterException(tester);

    await tester.tap(find.text('Share feedback'));
    await tester.pumpAndSettle();
    expectNoFlutterException(tester);

    expect(find.text('Feedback'), findsOneWidget);
    expect(find.text('Tell us about your experience'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Submit'),
      250,
      scrollable: find.byType(Scrollable).last,
    );

    expectNoFlutterException(tester);
  });
}

void expectNoFlutterException(WidgetTester tester) {
  final exception = tester.takeException();
  if (exception is FlutterError) {
    debugPrint(exception.toStringDeep());
    for (final diagnostic in exception.diagnostics) {
      debugPrint(diagnostic.toStringDeep());
    }
    debugDumpRenderTree();
  } else if (exception != null) {
    debugPrint(exception.toString());
  }
  expect(exception, isNull);
}
