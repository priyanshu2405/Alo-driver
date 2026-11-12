import 'dart:async';

import 'package:alo_ride_driver_app/core/base/pagination_controller.dart';
import 'package:alo_ride_driver_app/data/helpers/connectivity_helper.dart';
import 'package:alo_ride_driver_app/data/pref/app_pref.dart';
import 'package:alo_ride_driver_app/network/event.dart';
import 'package:alo_ride_driver_app/network/exception.dart';
import 'package:alo_ride_driver_app/screen/login/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


/*typedef OnSuccess<T> = void Function(T data);
typedef OnFailure = void Function(String message);
typedef OnLoading = void Function(bool isLoading);*/

abstract class BaseController extends GetxController with PaginationController {
  /*BaseController() {
    onInit;
  }
  @override
  @protected
  @mustCallSuper
  void onInit() {
  super.onInit();
  }*/

 // final RxBool isLoading = false.obs;


  //@protected
  //@mustCallSuper

  
  int _loaderCount = 0;

  final ConnectivityHelper _connectivityHelper = ConnectivityHelper();
  StreamSubscription? _subscription;

  @override
  void onClose() {
    _subscription?.cancel();
    _dismissAllLoaders();

    super.onClose();
  }

  void processData<T>(
    Stream<DataEvent<T>> stream, {
    bool handleLoading = true,
    required void Function(T data)? onSuccess,
    void Function()? onLoading,
    void Function(ApiException message)? onFailure,
  }) {
    _subscription?.cancel();
    if (!_connectivityHelper.hasInternet) {
      //final message = "No internet connection.";
      //  _showError(InternetConnectionException(message:"No internet connection." ));
      onFailure?.call(
        InternetConnectionException(message: "No internet connection."),
      );
      return;
    }

    _subscription = stream.listen(
      (event) {
        if (event is Loading<T>) {
          if (handleLoading) _showLoader();
          onLoading?.call();
        } else if (event is Success<T>) {
          if (handleLoading) _dismissLoader();
          onSuccess?.call(event.data);
        } else if (event is Failure<T>) {
          if (handleLoading) _dismissLoader();
          if (event.exception is UnauthorizedException) {
            onUnauthorized();
          }
          if (onFailure != null) {
            onFailure(event.exception);
          } /* else {
          _showError(event.exception);
        }*/
        }
      },
      onError: (error) {
        if (handleLoading) _dismissLoader();
        final message = error;
        print("message:: ${message}");
        if (onFailure != null) {
          //print("abcd: ${message}");
          onFailure(error);
          // _showError(message);
        } /*else {
        _showError(message);
      }*/
      },
    );
  }

  void _showLoader() {
    if (_loaderCount == 0 && !Get.isDialogOpen!) {
      Get.dialog(
        Center(child: CircularProgressIndicator(
          color: Get.theme.colorScheme.primary,
        )),
        barrierDismissible: false,
      );
    }
    _loaderCount++;
    print("DISMISS: $_loaderCount");
  }

  void _dismissLoader() {
    _loaderCount = (_loaderCount - 1).clamp(0, 1000);
    if (_loaderCount == 0 && Get.isDialogOpen == true) {
      Get.back(); // Close dialog
    }

    if (_loaderCount == 0 && Get.isDialogOpen == true) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.isDialogOpen == true) Get.back();
      });
    }
  }

  void _dismissAllLoaders() {
    _loaderCount = 0;
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }

  /*void _showError(ApiException message) {
    _dismissAllLoaders();


    Get.snackbar(
      "Error",
      message.message ?? "",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }*/

  void onUnauthorized() {
    //AuthRepository.instance.logout();
    _dismissAllLoaders();
   if(Get.currentRoute != "/LoginView") {
     Get.offAll(() => LoginScreen());
   }
   AppPref.instance.clear();
    /* showErrorMessage(
      content: "Session Expired",
      title: "Error",
      context: context,
    );*/
    /*  Get.snackbar(
      "Session Expired",
      "Please log in again.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFFFF3B30),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );*/
  }
}

/*  String _handleException(ApiException exception) {
    if (exception is ApiResponseException) {
      switch (exception.statusCode) {
        case 400:
        case 403:
        case 404:
        case 422:
        case 500:
          return exception.message ?? "Please Check Your InterNet Connection";
        case 401:
          return "Unauthorized access.";
        default:
          return "Unexpected error occurred.";
      }
    } else if (exception is InternetConnectionException) {
      return "No internet connection.";
    }
    return exception.toString();
  }*/
/* final RxBool isLoading = false.obs;

  void processData<T>(
    Stream<DataEvent<T>> stream, {
    Function()? onLoading,
    Function(String message)? onFailure,
    Function(T data)? onSuccess,
  }) {
    stream.listen((event) {
      if (event is Loading<T>) {
        onLoading?.call();
      } else if (event is Success<T>) {
        onSuccess?.call(event.data);
      } else if (event is Failure<T>) {
        onFailure?.call(event.message);
      }
    });
  }*/
