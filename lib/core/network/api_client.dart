import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Core HTTP client for the SupportTickets API.
/// Handles request configuration, token injection, and error formatting.
class ApiClient {
  final Dio _dio;
  final SharedPreferences _prefs;

  /// Defines the key used to store the authentication token.
  static const String tokenKey = 'auth_token';

  /// Base host URL of the backend (useful for resolving relative storage paths).
  static const String hostUrl = 'http://192.168.1.69:8000';

  /// Global stream to broadcast unauthenticated events (e.g., token expired).
  /// The root application should listen to this stream to force a logout redirect.
  static final StreamController<bool> unauthenticatedStream = StreamController<bool>.broadcast();

  /// Initializes the API Client with required dependencies.
  ///
  /// [dio] The Dio instance used for HTTP requests.
  /// [prefs] The SharedPreferences instance for local storage.
  ApiClient(this._dio, this._prefs) {
    _configureDio();
  }

  /// Configures base URL, timeouts, and intercepts requests to inject tokens.
  void _configureDio() {
    _dio.options.baseUrl = '$hostUrl/api';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json', 
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString(tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global unauthorized access (e.g., token expired or invalidated)
          if (e.response?.statusCode == 401) {
            _prefs.remove(tokenKey);
            // Broadcast the event to the application root to trigger a clean route switch
            unauthenticatedStream.add(true);
          }
          return handler.next(e);
        },
      ),
    );
  }

  /// Performs a generic GET request.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters, options: options);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a generic POST request.
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(path, data: data, options: options);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a generic PUT request.
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(path, data: data, options: options);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a generic PATCH request.
  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(path, data: data, options: options);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a generic DELETE request.
  Future<Map<String, dynamic>> delete(
    String path, {
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(path, options: options);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Standardizes errors from the API into human-readable strings.
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
        return Exception(responseData['message']);
      }
      return Exception('Server error: ${error.response?.statusCode}');
    } else {
      return Exception('Network error. Please check your connection.');
    }
  }
}