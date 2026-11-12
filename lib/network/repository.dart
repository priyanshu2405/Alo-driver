import 'package:alo_ride_driver_app/network/api/reuqest.dart';
import 'package:alo_ride_driver_app/network/api_client.dart';
import 'package:alo_ride_driver_app/network/event.dart';
import 'package:alo_ride_driver_app/network/exception.dart';
import 'package:alo_ride_driver_app/network/utils/log_mixin.dart';
import 'package:dio/dio.dart';
import 'dart:io' as io;


class BaseRepository  with LogMixin{
  Dio dio = ApiClient().client;

  BaseRepository(/*{required this.dio}*/);

  Stream<DataEvent<T>> processApi<T>(ApiRequest<T> request) async* {
  //  LoadingDialog.show();
    yield Loading();

    try {
      Response response;

      dynamic payload = request.useFormData
          ? FormData.fromMap(request.data ?? {})
          : request.data;
   /*   if(kDebugMode) {
        log("➡️ URL    : ${dio.options.baseUrl}${request.path}");
        log("➡️ METHOD : ${request.type.name.toUpperCase()}");
        log("➡️ HEADER : ${dio.options.headers}");
        log("➡️ QUERY  : ${request.queryParameters}");
        log("➡️ REQUEST   : $payload");
      }*/
      switch (request.type) {
        case RequestType.get:
          response = await dio.get(
            request.path,
            queryParameters: request.queryParameters,
            data: payload,
            options: Options(
              headers: {
                ...dio.options.headers,
                if (request.headers != null) ...dio.options.headers,
              },

            ),
          );
          break;
        case RequestType.post:
          response = await dio.post(
            request.path,
            data: payload,
            queryParameters: request.queryParameters,
          );
          break;
        case RequestType.put:
          response = await dio.put(
            request.path,
            data: payload,
            queryParameters: request.queryParameters,
          );
          break;
      }

      final parsed = request.responseParser?.call(response.data) ?? response.data;
   /*   if(kDebugMode) {
        log("⬅️ STATUS : ${response.statusCode}");
        log("⬅️ RESPONSE   : $parsed");
      }*/
      yield Success<T>(parsed);
     // LoadingDialog.hide();
    }
    catch (error, stacktrace) {
      /*if (kDebugMode) {
        log("⬅️ ERROR: $error");
        log("⬅️ STACK: $stacktrace");
      }*/

      ApiException exception;

      if (error is DioException) {
        if (error.error is io.SocketException || error.type == DioExceptionType.connectionError) {
          exception = InternetConnectionException(message: "Please Check Your Internet Connection");
        } else {
          exception = handleDioException(error) ?? UnknownException(message: error.message);
        }
      } else if (error is io.SocketException || error is io.HttpException) {
        exception = InternetConnectionException(message: "Please Check Your Internet Connection");
      } else if (error is ApiException) {
        exception = error;
      } else {
        exception = UnknownException(message: error.toString());
      }

      yield Failure<T>(exception);
    }

    /*catch (error, stacktrace) {
      if(kDebugMode) {
        log("⬅️ DATA   : $error");
      }
      switch (error) {
        case DioException():
          if (error.error is TokenExpiredException) {
            processApi(request);
          } else if (error.error is io.SocketException ||
              error.error is io.HttpException) {
            print("internetexception--> ${error.message}");
            InternetConnectionException(
                message: "Please Check Your Internet connection");
          } else {
            var apiException = handleDioException(error);
            print("unAuthorized");
            if (apiException != null) throw apiException;
          }
          break;
        case io.SocketException() || io.HttpException():
          InternetConnectionException(
              message: "Please Check Your Internet connection");
        default:
          printError(error);
          printError(stacktrace);
      }
      rethrow;
    }*/finally {
    //  LoadingDialog.hide();
    }
  }


  ApiException? handleDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const InternetConnectionException(message: "Please Check Your Internet Connection");
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.badResponse:
        if (dioException.response?.statusCode == io.HttpStatus.unauthorized) {
          final statusCode = dioException.response?.statusCode;
          final data = dioException.response?.data;

          if (statusCode == io.HttpStatus.unauthorized) {
            return UnauthorizedException(
              message: data is Map ? data['message'] ?? "Unauthorized" : "Unauthorized",
            );
          }
        } else if (dioException.response?.data != null) {
          return _handleResponseError(dioException);
        }
        break;
      case DioExceptionType.unknown:
        throw dioException;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.badCertificate:
        break;
      case DioExceptionType.connectionError:
        break;
    }
    return null;
  }



  ApiResponseException _handleResponseError(DioException dioException) {
    String? message;
    String? result;
    List<Map<String, dynamic>>? errors;
    final responseData = dioException.response?.data;

    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] is String) message = responseData['message'];

      if (responseData['error'] is List) {
        errors = (responseData['error'] as List).map((dynamic item) {
          if (item is Map<String, dynamic>) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();
      }
      // if (responseData['result'] is String) result = responseData['result'];
    }
   /* if(kDebugMode) {
      log("⬅️ DATA   : $responseData");
    } */   return ApiResponseException(statusCode: dioException.response?.statusCode ?? -1, message: message, /*data: MessageModel(error:responseData['message'] ?? "")*/);
  }
}
