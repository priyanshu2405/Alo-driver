import 'dart:developer';
import 'dart:io';

import 'package:alo_ride_driver_app/data/pref/app_pref.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;

  ApiClient._internal();
  Future<void> init({required String baseUrl, required AppPref pref, required bool enableLogging}) async {
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(minutes: 1),
      receiveTimeout: const Duration(minutes: 1),
      headers: {
        HttpHeaders.acceptHeader: Headers.jsonContentType,
        HttpHeaders.contentTypeHeader: Headers.jsonContentType,
      },
    );

    _dio = Dio(options);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = pref.userToken;

          if (token.isEmpty) {
            final prefs = await SharedPreferences.getInstance();
            token = prefs.getString('user_token') ?? '';
          }

          if (token.isNotEmpty) {
            options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException e, handler) => handler.next(e),
      ),
    );

    if (enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
        responseHeader: false,
        logPrint: (obj) {
          log(obj.toString());
          /*  try {
            // Try to pretty print JSON
            final dynamic data = jsonDecode(obj.toString());
            final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
            log(prettyJson);
          } catch (e) {
            // Fallback if not JSON (like plain text or headers)
          }*/
        }
      ));
    }
  }
  Dio get client => _dio;

  /* ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
        headers: {
          HttpHeaders.acceptHeader: Headers.jsonContentType,
          HttpHeaders.contentTypeHeader: Headers.jsonContentType,
          *//* if(AppPref.instance.userToken.isNotEmpty)
        HttpHeaders.authorizationHeader : 'Bearer ${AppPref.instance.userToken}'*//*
        },
      ),
    );

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // print("AccessToken");
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('user_token');
          print("AccessToken:: $token");
          if (token?.isNotEmpty ?? false) {
            options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    ]);
  }*/

 /* void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    _dio.options.baseUrl = baseUrl;
  }*/

}
