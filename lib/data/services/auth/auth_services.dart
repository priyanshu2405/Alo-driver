import 'package:alo_ride_driver_app/data/pref/app_pref.dart';
import 'package:alo_ride_driver_app/models/model.dart';
import 'package:alo_ride_driver_app/network/api/reuqest.dart';
import 'package:alo_ride_driver_app/network/event.dart';
import 'package:alo_ride_driver_app/network/repository.dart';

class AuthRepository extends BaseRepository {
  AuthRepository(/*{required super.dio}*/);


  Stream<DataEvent<dynamic>> loginApi({
    required String countryCode,
    required String mobile,
  }) async* {
    final request = ApiRequest<dynamic>(RequestType.post, "/api/driver/send-otp")
      ..data = {
        "mobile": mobile,
        "country_code": countryCode,
      }
      ..useFormData = true
      ..responseParser = (value) => value;
    yield* processApi(request);
  }

  Stream<DataEvent<dynamic>> verifyOtp({
    required String mobile,
    required String otp,
    required String countryCode,
  }) async* {
    final request = ApiRequest<dynamic>(RequestType.post, "/api/verify-otp")
      ..data = {
        "mobile": "9876543210",
        "otp": "3793",
        "country_code" : countryCode
      }
      ..responseParser = (value) => value;
    yield* processApi(request);
  }

  Stream<DataEvent<dynamic>> resendOtp({
    required String email,
  }) async* {
    final request = ApiRequest<dynamic>(RequestType.post, "/api/resend-otp")
      ..data = {
        "email": email,
      }
      ..responseParser = (value) => value;
    yield* processApi(request);
  }


  // Stream<DataEvent<dynamic>> register({
  //   required String name,
  //   required String email,
  //   required String phoneNo,
  //   required String password,
  //   required String countryCode,
  //   required String confirmPassword,
  // }) async* {
  //   final request = ApiRequest<dynamic>(RequestType.post, "/api/register")
  //     ..data = {
  //       "email": email,
  //       "name": name,
  //       "phone_no": phoneNo,
  //       "password": password,
  //       "password_confirmation": confirmPassword,
  //       "country_code" : countryCode,
  //     }
  //     ..responseParser = (value) => value;
  //   yield* processApi(request);
  // }

  Stream<DataEvent<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async* {
    final request = ApiRequest<dynamic>(RequestType.post, "/api/change-password/${AppPref.instance.userId}")
      ..data = {
        "current_password": currentPassword,
        "new_password": newPassword,
        "new_password_confirmation": confirmPassword,
      }
      ..responseParser = (value) => value;
    yield* processApi(request);
  }

  Stream<DataEvent<dynamic>> forgotPassword({
    required String email,
  }) async* {
    final request = ApiRequest<dynamic>(RequestType.post, "/api/forgot-password")
      ..data = {
        "email": email,
      }
      ..responseParser = (value) => value;
    yield* processApi(request);
  }

  Stream<DataEvent<TermsAndCondition>> getTermAndCondition() async* {
    final request = ApiRequest<TermsAndCondition>(
        RequestType.post,
        "/api/tearms-condition"
    )..responseParser = (value) => TermsAndCondition.fromJson(value['data']);
    yield* processApi(request);
  }

  Stream<DataEvent<TermsAndCondition>> getPrivacyAndPolicy() async* {
    final request = ApiRequest<TermsAndCondition>(
        RequestType.post,
        "/api/private-policy"
    )..responseParser = (value) => TermsAndCondition.fromJson(value['data']);
    yield* processApi(request);
  }
}