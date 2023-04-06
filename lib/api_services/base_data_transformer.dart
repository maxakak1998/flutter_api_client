import 'package:dio/dio.dart';
import 'package:super_generic_api_client/api_services/decoder.dart';

import 'api_response.dart';

///R = Raw type you get from response ( Ex: Using DIO is Response object)
///E = Formatted response type ( Ex: Common data format you want to get is Map<String,dynamic>
abstract class BaseAPIResponseDataTransformer<R, E, D> {
  String rootKey;
  List<int> succeedStatuses;

  E transform(R response, D? genericObject);

  bool isSucceed(int? statusCode);

  BaseAPIResponseDataTransformer(this.rootKey,
      {this.succeedStatuses = const [200, 201, 202, 203, 204]});
}

// class BasicDioTransformer extends BaseAPIResponseDataTransformer<Response,
//     Map<String, dynamic>, dynamic> {
//   @override
//   Map<String, dynamic> transform(Response response, genericObject) {
//     return {
//       BaseAPIResponseDataTransformer.rootAPIDataFormat: response.data,
//       BaseAPIResponseDataTransformer.rootAPIStatusFormat: response.statusCode,
//       BaseAPIResponseDataTransformer.rootAPIStatusMessageFormat:
//           response.statusMessage
//     };
//   }
// }

class APIResponseDataTransformer<T> extends BaseAPIResponseDataTransformer<
    Response, BaseAPIResponseWrapper<Response, T>, T> {
  APIResponseDataTransformer({String rootName = "args"}) : super(rootName);

  @override
  BaseAPIResponseWrapper<Response, T> transform(
      Response response, T? genericObject) {
    dynamic data = response.data;
    if (data is Map) {
      data = data[rootKey];
    }

    T? _object;
    if (genericObject is Decoder) {
      _object = genericObject.decode(data);
    } else {
      _object = data;
    }
    if (!isSucceed(response.statusCode)) {
      throw ErrorResponse<T>(
          decodedData: _object, dataTransformer: this, response: response);
    }

    return APIResponse<T>(
        decodedData: _object,
        dataTransformer: this,
        response: response,
        hasError: false);
  }

  @override
  bool isSucceed(int? statusCode) => succeedStatuses.contains(statusCode);
}

class APIListResponseDataTransformer<T> extends BaseAPIResponseDataTransformer<
    Response, BaseAPIResponseWrapper<Response, T>, T> {
  APIListResponseDataTransformer({String rootKey = "json"}) : super(rootKey);

  @override
  BaseAPIResponseWrapper<Response, T> transform(
      Response response, T? genericObject) {
    final data = response.data;

    List<T> decodedList = [];
    final rawList = data[rootKey];
    if (rawList is List) {
      if (genericObject is Decoder) {
        for (final e in rawList) {
          decodedList.add(genericObject.decode(e));
        }
      } else {
        decodedList = rawList.cast<T>();
      }
    }
    if (!isSucceed(response.statusCode)) {
      throw ErrorResponse<T>(
          decodedData: genericObject,
          dataTransformer: this,
          response: response);
    }
    return APIListResponse(
        decodedList: decodedList,
        decodedData: genericObject,
        dataTransformer: this,
        response: response,
        hasError: false);
  }

  @override
  bool isSucceed(int? statusCode) => succeedStatuses.contains(statusCode);
}
