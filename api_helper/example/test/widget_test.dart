import 'package:api_request_helper/api_helper_rana.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('App builds test', (WidgetTester tester) async {
    final apiClient = ApiClient(
      baseUrl: "https://jsonplaceholder.typicode.com",
    );
    await tester.pumpWidget(MyApp(apiClient: apiClient));
    expect(find.byType(MyApp), findsOneWidget);
  });
}
