

import 'package:alo_ride_driver_app/network/exception.dart';

abstract class DataEvent<T> {
  const DataEvent();
}

class Loading<T> extends DataEvent<T> {
  final bool isLoading;

  Loading([this.isLoading = false]);

  @override
  String toString() => 'LoadingEvent{isLoading: $isLoading}';
}

class Success<T> extends DataEvent<T> {
  final T data;
  final  int? statusCode;
  Success(this.data,{this.statusCode});

  @override
  String toString() => 'SuccessEvent{data: $data, statusCode: $statusCode}';

}

class Failure<T> extends DataEvent<T> {
  final ApiException  exception;
  Failure(this.exception);

  @override
  String toString() => 'FailureEvent{exception: $exception}';
}
