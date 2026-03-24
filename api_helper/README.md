# api_helper

A powerful Flutter package for robust API integration with built-in caching, isolate support, and auto-token refresh.

## Features

- **Standard HTTP Methods**: Support for GET, POST, PUT, DELETE, and MULTIPART.
- **Local Caching (Hive)**: Optional caching for any request. For GET requests, it supports a "Cache-then-Network" strategy.
- **Isolate Support**: Perform heavy parsing or requests in a background isolate to keep the UI smooth.
- **Token Management**: Automatic Bearer token insertion and refresh token handling via interceptors.
- **Comprehensive Logging**: Detailed request/response logs with support for manual user logs.
- **State Management Agnostic**: Works seamlessly with Provider, BLoC, GetX, Riverpod, etc.

## Getting Started

### 1. Initialization
Initialize the `ApiClient` with your base URL and optional token handlers.

```dart
final apiClient = ApiClient(
  baseUrl: "https://api.example.com",
  getToken: () async => "your_token",
  onRefreshToken: () async => { /* refresh logic */ },
);
await apiClient.init(); // Initialize Hive
```

### 2. Basic Requests
Use the helper methods for quick requests.

```dart
final response = await apiClient.get<Map<String, dynamic>>("/users");
```

### 3. Cache-then-Network Strategy
Enable `saveInLocal` and provide an `onUpdate` callback.

```dart
final response = await apiClient.get<List<dynamic>>(
  "/posts",
  options: ApiRequestOptions(saveInLocal: true),
  onUpdate: (updatedResponse) {
    // Update UI with fresh data
  },
);
```

### 4. Background Isolates
Use the `isIsolate` flag to run the request in a separate isolate.

```dart
final response = await apiClient.get(
  "/large-data",
  options: ApiRequestOptions(isIsolate: true),
);
```

## Implementation Details

- **Cache Service**: Uses [Hive](https://pub.dev/packages/hive) for fast, local key-value storage.
- **Network Client**: Built on [Dio](https://pub.dev/packages/dio) with custom interceptors.
- **Isolates**: Uses Flutter's `compute` for easy multi-threading.
