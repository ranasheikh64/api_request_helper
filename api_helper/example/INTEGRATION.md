### 1. Using with GetX Controller

```dart
import 'package:get/get.dart';
import 'network_helper.dart';

class PostController extends GetxController {
  var posts = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  void fetchPosts() async {
    isLoading.value = true;
    final response = await networkHelper.apiClient.get<List<dynamic>>(
      "/posts",
      options: ApiRequestOptions(saveInLocal: true),
      onUpdate: (updatedResponse) {
        posts.value = updatedResponse.data ?? [];
      },
    );

    if (response.data != null) {
      posts.value = response.data!;
    }
    isLoading.value = false;
  }
}
```

### 2. Using with BLoC

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'network_helper.dart';

// Events
abstract class PostEvent {}
class FetchPosts extends PostEvent {}

// States
abstract class PostState {}
class PostInitial extends PostState {}
class PostLoading extends PostState {}
class PostLoaded extends PostState {
  final List<dynamic> posts;
  PostLoaded(this.posts);
}

// BLoC
class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostInitial()) {
    on<FetchPosts>((event, emit) async {
      emit(PostLoading());
      
      final response = await networkHelper.apiClient.get<List<dynamic>>(
        "/posts",
        options: ApiRequestOptions(saveInLocal: true),
        onUpdate: (updatedResponse) {
          // You can emit a new state here if using a Stream-based approach
          // or just update a local variable and call a refresh event.
          add(FetchPosts()); 
        },
      );

      if (response.data != null) {
        emit(PostLoaded(response.data!));
      }
    });
  }
}
```
