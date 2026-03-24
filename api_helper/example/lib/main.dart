import 'package:api_request_helper/api_helper_rana.dart';
import 'package:flutter/material.dart';

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
      title: 'API Helper Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PostsPage(apiClient: apiClient),
    );
  }
}

class PostsPage extends StatefulWidget {
  final ApiClient apiClient;
  const PostsPage({super.key, required this.apiClient});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<dynamic>? posts;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final response = await widget.apiClient.get<List<dynamic>>(
      "/posts",
      options: ApiRequestOptions(saveInLocal: true, isIsolate: true),
      onUpdate: (updatedResponse) {
        if (updatedResponse.data != null && mounted) {
          setState(() {
            posts = updatedResponse.data;
            isLoading = false;
          });
          widget.apiClient.manualLog(
            "Posts updated from network in background",
          );
        }
      },
    );

    if (response.data != null && mounted) {
      setState(() {
        posts = response.data;
        isLoading = false;
      });
      if (response.isFromCache) {
        widget.apiClient.manualLog("Showing posts from local storage");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Posts (Cache then Network)")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts?.length ?? 0,
              itemBuilder: (context, index) {
                final post = posts![index];
                return ListTile(
                  title: Text(post['title']),
                  subtitle: Text(post['body']),
                );
              },
            ),
    );
  }
}
