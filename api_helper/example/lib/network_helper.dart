import 'package:api_helper_rana/api_helper_rana.dart';

class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();
  factory NetworkHelper() => _instance;

  late final ApiClient apiClient;

  NetworkHelper._internal() {
    apiClient = ApiClient(
      baseUrl: "https://jsonplaceholder.typicode.com",
      getToken: () async => "YOUR_BEARER_TOKEN",
      onRefreshToken: () async {
        // Handle token refresh logic here
      },
    );
  }

  Future<void> init() async {
    await apiClient.init();
  }
}

// Global instance
final networkHelper = NetworkHelper();
