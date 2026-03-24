import 'package:api_helper_rana/api_request_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late ApiClient apiClient;
  late DioAdapter dioAdapter;

  setUp(() async {
    apiClient = ApiClient(baseUrl: "https://test.com");
    dioAdapter = DioAdapter(dio: apiClient.dio);
  });

  test('GET request works', () async {
    const data = {'id': 1, 'title': 'test'};
    dioAdapter.onGet('/test', (server) => server.reply(200, data));

    final response = await apiClient.get<Map<String, dynamic>>('/test');
    expect(response.statusCode, 200);
    expect(response.data?['title'], 'test');
  });

  test('POST request works', () async {
    const data = {'id': 1};
    dioAdapter.onPost(
      '/test',
      (server) => server.reply(201, data),
      data: Matchers.any,
    );

    final response = await apiClient.post<Map<String, dynamic>>(
      '/test',
      data: {'name': 'new'},
    );
    expect(response.statusCode, 201);
    expect(response.data?['id'], 1);
  });

  test('PUT request works', () async {
    const data = {'updated': true};
    dioAdapter.onPut(
      '/test',
      (server) => server.reply(200, data),
      data: Matchers.any,
    );

    final response = await apiClient.put<Map<String, dynamic>>(
      '/test',
      data: {'id': 1},
    );
    expect(response.statusCode, 200);
    expect(response.data?['updated'], true);
  });

  test('DELETE request works', () async {
    dioAdapter.onDelete('/test', (server) => server.reply(204, null));

    final response = await apiClient.delete('/test');
    expect(response.statusCode, 204);
  });

  test('Multipart request works', () async {
    dioAdapter.onPost(
      '/upload',
      (server) => server.reply(200, {'success': true}),
      data: Matchers.any,
    );

    final response = await apiClient.multipart('/upload', {
      'file': 'dummy_data',
    });
    expect(response.statusCode, 200);
    expect(response.data?['success'], true);
  });
}
