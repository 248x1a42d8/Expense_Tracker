
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/main.dart';
import '../lib/providers/expense_provider.dart';
import '../lib/providers/income_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Expense Tracker dashboard loads', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          ChangeNotifierProvider(create: (_) => IncomeProvider()),
        ],
        child: const ExpenseTrackerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Total Income'), findsOneWidget);
    expect(find.text('Remaining Balance'), findsOneWidget);
  });
}
