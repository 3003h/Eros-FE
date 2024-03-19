import 'package:eros_fe/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  testWidgets('Test search page', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    await tester.pump();
    expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
    expect(find.byIcon(FontAwesomeIcons.filter), findsNothing);

    await tester.tap(find.byIcon(CupertinoIcons.search));
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.search), findsNothing);
    expect(find.byIcon(FontAwesomeIcons.filter), findsOneWidget);
  });
}
