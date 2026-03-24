# api_helper_rana

A robust Flutter package for API integration with Hive caching, background isolates, and auto-token refresh.

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

## Token Management

You can easily save and retrieve authentication tokens using the built-in helper methods.

```dart
// Save tokens (usually after login)
await apiClient.setAccessToken("your_access_token");
await apiClient.setRefreshToken("your_refresh_token");

// Get tokens (often used in the ApiClient constructor)
final token = apiClient.getAccessToken();

// Clear tokens (on logout)
await apiClient.logout();
```

## Request Examples

### GET Request (with Cache then Network)
Returns cached data immediately, then fetches and updates in the background.

```dart
final response = await apiClient.get<List<dynamic>>(
  "/posts",
  options: ApiRequestOptions(saveInLocal: true, isIsolate: true),
  onUpdate: (updatedResponse) {
    // Handle background update
  },
);
```

### POST Request
```dart
final response = await apiClient.post<Map<String, dynamic>>(
  "/posts",
  data: {'title': 'foo', 'body': 'bar', 'userId': 1},
);
```

### PUT Request
```dart
final response = await apiClient.put<Map<String, dynamic>>(
  "/posts/1",
  data: {'id': 1, 'title': 'foo', 'body': 'bar', 'userId': 1},
);
```

### DELETE Request
```dart
final response = await apiClient.delete("/posts/1");
```

### MULTIPART Request (File Upload)
```dart
final response = await apiClient.multipart(
  "/upload",
  {
    'file': await MultipartFile.fromFile('path/to/file.jpg'),
    'name': 'api_helper_rana',
  },
);
```

## Local Storage & Caching

The package provides built-in support for persistent local storage using Hive.

### 1. Automatic Caching
Simply set `saveInLocal: true` in the `ApiRequestOptions`. 

- **GET Requests**: Implements the "Cache-First" pattern. It returns cached data immediately while fetching fresh data in the background (triggered via `onUpdate`).
- **POST/PUT Requests**: Automatically persists the success response to local storage for future reference.

```dart
final response = await apiClient.get<List<dynamic>>(
  "/posts",
  options: ApiRequestOptions(saveInLocal: true),
  onUpdate: (updatedResponse) {
    // Handle background update
  },
);
```

### 2. Manual Cache Interaction
You can also manually interact with the `CacheService` if needed:

```dart
// Save data manually
await apiClient.cacheService.saveData("custom_key", {"data": "value"});

// Get data manually
final data = apiClient.cacheService.getData("custom_key");

// Clear all cache
await apiClient.cacheService.clearCache();
```

## Manual Logging
```dart
apiClient.manualLog("User clicked refresh button");
```

## Credits
Built with [Dio](https://pub.dev/packages/dio), [Hive](https://pub.dev/packages/hive), and [Logger](https://pub.dev/packages/logger).
