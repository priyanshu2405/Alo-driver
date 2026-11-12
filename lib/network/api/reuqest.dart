enum RequestType { get, post, put }

class ApiRequest<T> {
  RequestType type;
  String path;
  Map<String, dynamic>? data;
  Map<String, dynamic>? queryParameters;
  dynamic Function(dynamic response)? responseParser;
  Map<String, dynamic>? headers;
  bool useFormData;

  ApiRequest(
    this.type,
    this.path, {
    this.data,
    this.queryParameters,
    this.responseParser,
    this.useFormData = false,
    this.headers,
  });
}
