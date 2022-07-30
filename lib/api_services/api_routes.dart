import 'package:dio/dio.dart';

abstract class APIRouteConfigurable<R1, R2, R3> {
  R3 apiType;
  bool authorize;
  String method, path;
  String? baseUrl;
  ResponseType responseType;

  APIRouteConfigurable(
      {required this.apiType,
      required this.authorize,
      required this.method,
      required this.path,
      this.baseUrl,
      required this.responseType});

  R1 getConfig(R2 baseOption);
}

enum APIType {
  testGet,
  testPut,
  testPost,
  testDelete,
  testError,
}

class APIRoute
    extends APIRouteConfigurable<RequestOptions, BaseOptions, APIType> {
  static const String authorizeKey = "Authorize";

  APIRoute({
    required APIType apiType,
    bool authorize = true,
    String method = APIMethod.get,
    String? baseUrl,
    String path="",
    ResponseType responseType = ResponseType.json,
  }) : super(
            apiType: apiType,
            authorize: authorize,
            method: method,
            baseUrl: baseUrl,
            path: path,
            responseType: responseType);

  @override
  RequestOptions getConfig(BaseOptions baseOption) {
    switch (apiType) {
      case APIType.testGet:
        path = "/get";
        authorize = false;
        break;
      case APIType.testPut:
        path = "/put";
        method = APIMethod.put;
        authorize = false;
        break;
      case APIType.testPost:
        path = "/post";
        authorize = false;
        method = APIMethod.post;

        break;
      case APIType.testDelete:
        path = "/delete";
        authorize = false;
        method = APIMethod.delete;
        break;
      case APIType.testError:
        path="/status";
        method=APIMethod.get;

        break;
    }
    final options = Options(
            extra: {APIRoute.authorizeKey: authorize},
            responseType: responseType,
            method: method)
        .compose(
      baseOption,
      path,
    );
    if (baseUrl != null) {
      options.baseUrl = baseUrl!;
    }
    return options;
  }
}

class APIMethod {
  static const get = 'get';
  static const post = 'post';
  static const put = 'put';
  static const patch = 'patch';
  static const delete = 'delete';
}
