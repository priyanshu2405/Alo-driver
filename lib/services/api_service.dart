import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = 'http://192.168.1.12:8019/api/driver/';
  // static const String userBaseUrl = 'http://192.168.1.12:8019/api/';

 static const String baseUrl = 'https://alodrive.ca/api/driver/';
 static const String userBaseUrl = 'https://alodrive.ca/api/';
  static const Duration timeoutDuration = Duration(minutes: 2);


  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers with auth token
  static Map<String, String> _headersWithAuth(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Helper method to get token when needed
  static String? _getToken() {
    try {
      final authController = Get.find<AuthController>();
      return authController.getToken();
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // GET Request
  // static Future<Map<String, dynamic>> get({
  //   required String endpoint,
  //   String? token,
  //   Map<String, String>? queryParams,
  //   bool isShow = false,
  // }) async {
  //   try {
  //     // Use provided token or get from controller
  //     final authToken = token ?? _getToken();
  //
  //     String url = '$baseUrl$endpoint';
  //     print("url : $url");3
  //     print("token : $authToken");
  //
  //     if (queryParams != null && queryParams.isNotEmpty) {
  //       final uri = Uri.parse(url);
  //       final newUri = uri.replace(queryParameters: queryParams);
  //       url = newUri.toString();
  //     }
  //
  //     final response = await http
  //         .get(
  //           Uri.parse(url),
  //           headers: authToken != null ? _headersWithAuth(authToken) : _headers,
  //         )
  //         .timeout(timeoutDuration);
  //
  //     return _handleResponse(response, isShow: isShow);
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  static Future<Map<String, dynamic>> get({
    required String endpoint,
    String? token,
    Map<String, String>? queryParams,
    bool isShow = false,
  }) async {
    try {
      final authToken = token ?? _getToken();

      String url = '$baseUrl$endpoint';

      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        final newUri = uri.replace(queryParameters: queryParams);
        url = newUri.toString();
      }

      final headers = authToken != null
          ? _headersWithAuth(authToken)
          : _headers;

      ApiLogger.request(
        method: "GET",
        url: url,
        headers: headers,
      );

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(timeoutDuration);

      ApiLogger.response(
        url: url,
        statusCode: response.statusCode,
        body: response.body,
      );

      return _handleResponse(response, isShow: isShow);

    } catch (e) {
      //ApiLogger.error(url: endpoint, error: e);
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> get1({
    required String endpoint,
    String? token,
    Map<String, String>? queryParams,
    bool isShow = false,
    bool useBaseUrl = true, // 👈 add this
  }) async {
    try {
      final authToken = token ?? _getToken();

      // 👇 use the full URL if useBaseUrl = false
      String url = useBaseUrl ? '$baseUrl$endpoint' : endpoint;

      // final headers = authToken != null
      //     ? _headersWithAuth(authToken)
      //     : _headers;
      ApiLogger.request(
        method: "GET",
        url: url,
        headers: _headersWithAuth(authToken),
      );


      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        final newUri = uri.replace(queryParameters: queryParams);
        url = newUri.toString();
      }

      final response = await http
          .get(
        Uri.parse(url),
        headers: authToken != null ? _headersWithAuth(authToken) : _headers,
      )
          .timeout(timeoutDuration);
      ApiLogger.response(
        url: url,
        statusCode: response.statusCode,
        body: response.body,
      );

      return _handleResponse(response, isShow: isShow);
    } catch (e) {
      throw _handleError(e);
    }
  }


  // POST Request
  // static Future<Map<String, dynamic>> post({
  //   required String endpoint,
  //   required Map<String, dynamic> body,
  //   String? token,
  //   bool isShow = false,
  // }) async {
  //   try {
  //     // Use provided token or get from controller
  //     final authToken = token ?? _getToken();
  //     print("token : $authToken");
  //     final response = await http
  //         .post(
  //           Uri.parse('$baseUrl$endpoint'),
  //           headers: authToken != null ? _headersWithAuth(authToken) : _headers,
  //           body: jsonEncode(body),
  //         )
  //         .timeout(timeoutDuration);
  //     print("url===>${'$baseUrl$endpoint'}");
  //     return _handleResponse(response, isShow: isShow);
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
    bool isShow = false,
  }) async {
    try {
      final authToken = token ?? _getToken();

      final url = '$baseUrl$endpoint';

      final headers = authToken != null
          ? _headersWithAuth(authToken)
          : _headers;

      ApiLogger.request(
        method: "POST",
        url: url,
        headers: headers,
        body: body,
      );

      final response = await http
          .post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(timeoutDuration);

      ApiLogger.response(
        url: url,
        statusCode: response.statusCode,
        body: response.body,
      );

      return _handleResponse(response, isShow: isShow);

    } catch (e) {
      //ApiLogger.error(url: endpoint, error: e);
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> post1({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
    bool isShow = false,
    bool useBaseUrl = true, // 👈 Add this flag
  }) async {
    try {
      final authToken = token ?? _getToken();

      // 👇 Use baseUrl only when necessary
      final url = useBaseUrl ? '$baseUrl$endpoint' : endpoint;

      print("POST URL ===> $url");
      print("BODY ===> $body");

      final response = await http
          .post(
        Uri.parse(url),
        headers: authToken != null ? _headersWithAuth(authToken) : _headers,
        body: jsonEncode(body),
      )
          .timeout(timeoutDuration);

      return _handleResponse(response, isShow: isShow);
    } catch (e) {
      throw _handleError(e);
    }
  }


  static Future<Map<String, dynamic>> chatBotApi({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
    bool isShow = false,
  }) async {
    try {
      // Use provided token or get from controller
      final authToken = token ?? _getToken();

      final response = await http
          .post(
        Uri.parse('http://bot.highconz.xyz/api/$endpoint'),
        headers: authToken != null ? _headersWithAuth(authToken) : _headers,
        body: jsonEncode(body),
      )
          .timeout(timeoutDuration);
      print("url===>${'$baseUrl$endpoint'}");
      return _handleResponse(response, isShow: isShow);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> multipartPost({
    required String endpoint,
    required Map<String, String> fields,
    String? token,
  }) async {
    var uri = Uri.parse('$baseUrl$endpoint');
    token = _getToken();

    print("uri : $uri");

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] =
        'Bearer $token'; // Replace with actual token
    request.fields.addAll(fields);

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed with status: ${response.statusCode}');
    }
  }

  // ================= MULTIPART WITH FILE =================
  static Future<Map<String, dynamic>> multipartPostWithFile({
    required String endpoint,
    required Map<String, String> fields,
    File? file,
    String fileKey = "image", // backend field name
    String? token,
    bool isShow = false,
  }) async {
    try {
      final authToken = token ?? _getToken();
      final uri = Uri.parse('$baseUrl$endpoint');

      final request = http.MultipartRequest('POST', uri);

      // Headers
      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      request.headers['Accept'] = 'application/json';

      // Fields
      request.fields.addAll(fields);

      // File
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileKey,
            file.path,
          ),
        );
      }

      final streamedResponse =
      await request.send().timeout(timeoutDuration);

      final response =
      await http.Response.fromStream(streamedResponse);

      return _handleResponse(response, isShow: isShow);
    } catch (e) {
      throw _handleError(e);
    }
  }


  // PUT Request
  static Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      // Use provided token or get from controller
      final authToken = token ?? _getToken();

      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: authToken != null ? _headersWithAuth(authToken) : _headers,
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  // static Future<Map<String, dynamic>> delete({
  //   required String endpoint,
  //   String? token,
  // }) async {
  //   try {
  //     // Use provided token or get from controller
  //     final authToken = token ?? _getToken();
  //
  //     final response = await http
  //         .delete(
  //           Uri.parse('$baseUrl$endpoint'),
  //           headers: authToken != null ? _headersWithAuth(authToken) : _headers,
  //         )
  //         .timeout(timeoutDuration);
  //
  //     return _handleResponse(response);
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  static Future<Map<String, dynamic>> delete({
    required String endpoint,
    String? token,
    bool isShow = false,
  }) async {
    try {
      /// 🔑 Get token
      final authToken = token ?? _getToken();

      /// 🔥 FULL URL
      final url = '$baseUrl$endpoint';

      /// ✅ DEBUG PRINTS (VERY IMPORTANT)
      debugPrint("🟥 DELETE URL ==> $url");
      debugPrint("🟦 TOKEN ==> $authToken");

      final response = await http
          .delete(
        Uri.parse(url),
        headers: authToken != null
            ? _headersWithAuth(authToken)
            : _headers,
      )
          .timeout(timeoutDuration);

      /// 🔥 PRINT RAW RESPONSE
      debugPrint("🟩 STATUS CODE ==> ${response.statusCode}");
      debugPrint("🟨 RESPONSE BODY ==> ${response.body}");

      return _handleResponse(response, isShow: isShow);
    } catch (e) {
      debugPrint("❌ DELETE ERROR ==> $e");
      throw _handleError(e);
    }
  }

  // PATCH Request
  static Future<Map<String, dynamic>> patch({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      // Use provided token or get from controller
      final authToken = token ?? _getToken();

      final response = await http
          .patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: authToken != null ? _headersWithAuth(authToken) : _headers,
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // File Upload
  static Future<Map<String, dynamic>> uploadFile({
    required String endpoint,
    required String filePath,
    required String fieldName,
    String? token,
    Map<String, String>? additionalFields,
  }) async {
    try {
      // Use provided token or get from controller
      final authToken = token ?? _getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      // Add headers
      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }



  static Map<String, dynamic> _handleResponse(
      http.Response response, {
        bool isShow = false,
      }) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        final decodedResponse = jsonDecode(responseBody);

        if (decodedResponse is Map<String, dynamic> &&
            decodedResponse["message"] != null) {
          _showGetXSnackbar(
            decodedResponse["message"].toString(),
            isError: false,
            isShow: isShow,
          );
        }

        return decodedResponse;
      } catch (e) {
        _showGetXSnackbar(responseBody, isError: true, isShow: isShow);
        return {'message': responseBody};
      }
    } else {
      String errorMessage = '';

      try {
        final decodedError = jsonDecode(responseBody);

        // ✅ HANDLE VALIDATION ERRORS (422)
        if (decodedError['errors'] != null &&
            decodedError['errors'] is Map) {

          final errorsMap = decodedError['errors'] as Map<String, dynamic>;

          // Extract first error message
          errorMessage = errorsMap.values
              .first
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '');

        }
        // ✅ NORMAL MESSAGE
        else if (decodedError['message'] != null) {
          errorMessage = decodedError['message'].toString();
        }
        // ✅ FALLBACK
        else {
          errorMessage = _getErrorMessage(statusCode, responseBody);
        }
      } catch (e) {
        errorMessage = _getErrorMessage(statusCode, responseBody);
      }

      _showGetXSnackbar(errorMessage, isError: true, isShow: isShow);

      throw ApiException(
        statusCode: statusCode,
        message: errorMessage,
      );
    }
  }


  static void _showGetXSnackbar(
    String message, {
    bool isError = false,
    bool isShow = false,
  }) {
    if (isShow == true) {
      Get.snackbar(
        isError ? "Error" : "Success",
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor:
            isError
                ? Colors.red.withOpacity(0.8)
                : AppColors.secondary.withOpacity(0.5),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(5),
        borderRadius: 8,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      );
    }
  }

  // Error handler
  static ApiException _handleError(dynamic error) {
    if (error is SocketException) {
      return ApiException(statusCode: 0, message: 'No internet connection');
    } else if (error is HttpException) {
      return ApiException(statusCode: 0, message: 'HTTP error occurred');
    } else if (error is ApiException) {
      return error;
    } else {
      return ApiException(
        statusCode: 0,
        message: 'An unexpected error occurred: ${error.toString()}',
      );
    }
  }

  // Get error message based on status code
  static String _getErrorMessage(int statusCode, String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded['message'] != null) {
        return decoded['message'];
      }
    } catch (e) {
      // If JSON decode fails, use default messages
    }

    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized access';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Resource not found';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      case 422:
        return 'Unprocessable Entity';
      default:
        return 'Request failed with status: $statusCode';
    }
  }
}

// Custom Exception Class
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}


class ApiLogger {
  static void request({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    final buffer = StringBuffer();

    buffer.writeln("━━━━━━━━━━ API REQUEST ━━━━━━━━━━");
    buffer.writeln("METHOD  : $method");
    buffer.writeln("URL     : $url");

    if (headers != null) {
      buffer.writeln("HEADERS : ${jsonEncode(headers)}");
    }

    if (body != null) {
      buffer.writeln("BODY    : ${jsonEncode(body)}");
    }

    buffer.writeln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    print(buffer.toString());
  }

  static void response({
    required String url,
    required int statusCode,
    dynamic body,
  }) {
    final buffer = StringBuffer();

    buffer.writeln("━━━━━━━━━━ API RESPONSE ━━━━━━━━━━");
    buffer.writeln("URL        : $url");
    buffer.writeln("STATUSCODE : $statusCode");

    if (body != null) {
      log("RESPONSE   : $body");
    }

    buffer.writeln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    print(buffer.toString());
  }
}
// static void error({
  //   required String url,
  //   required dynamic error,
  // }) {
  //   final buffer = StringBuffer();
  //
  //   buffer.writeln("━━━━━━━━━━ API ERROR ━━━━━━━━━━");
  //   buffer.writeln("URL   : $url");
  //   buffer.writeln("ERROR : $error");
  //   buffer.writeln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //
  //   print(buffer.toString());
  // }