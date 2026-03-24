import 'package:api_helper_rana/api_helper_rana.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient(baseUrl: "https://jsonplaceholder.typicode.com");
  await apiClient.init();

  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Helper Rana Example',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: HomePage(apiClient: apiClient),
    );
  }
}

class HomePage extends StatefulWidget {
  final ApiClient apiClient;
  const HomePage({super.key, required this.apiClient});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String responseText = "Press a button to make a request";
  bool isLoading = false;

  Future<void> _handleRequest(Future<ApiResponse> request) async {
    setState(() => isLoading = true);
    final response = await request;
    setState(() {
      isLoading = false;
      responseText = "Status: ${response.statusCode}\n"
          "From Cache: ${response.isFromCache}\n"
          "Data: ${response.data}";
    });
    widget.apiClient.manualLog("Request completed with status: ${response.statusCode}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Helper Rana")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _handleRequest(widget.apiClient.get(
                "/posts/1",
                options: ApiRequestOptions(saveInLocal: true),
                onUpdate: (update) => setState(() => responseText = "Updated: ${update.data}"),
              )),
              child: const Text("GET (with Cache)"),
            ),
            ElevatedButton(
              onPressed: () => _handleRequest(widget.apiClient.post(
                "/posts",
                data: {'title': 'foo', 'body': 'bar', 'userId': 1},
              )),
              child: const Text("POST"),
            ),
            ElevatedButton(
              onPressed: () => _handleRequest(widget.apiClient.put(
                "/posts/1",
                data: {'id': 1, 'title': 'foo', 'body': 'bar', 'userId': 1},
              )),
              child: const Text("PUT"),
            ),
            ElevatedButton(
              onPressed: () => _handleRequest(widget.apiClient.delete("/posts/1")),
              child: const Text("DELETE"),
            ),
            ElevatedButton(
              onPressed: () => _handleRequest(widget.apiClient.multipart(
                "https://httpbin.org/post", // Using httpbin for multipart test
                {
                  'file': MultipartFile.fromString('dummy content', filename: 'test.txt'),
                  'name': 'rana',
                },
              )),
              child: const Text("MULTIPART (Upload)"),
            ),
            const Divider(height: 32),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Text(
                responseText,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
          ],
        ),
      ),
    );
  }
}
