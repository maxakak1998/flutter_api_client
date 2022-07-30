import 'package:dio/dio.dart';
import 'package:super_generic_api_client/api_services/decoder.dart';

import 'api_response.dart';

///R = Raw type you get from response ( Ex: Using DIO is Response object)
///E = Formatted response type ( Ex: Common data format you want to get is Map<String,dynamic>
abstract class BaseAPIResponseDataTransformer<R, E, D> {
  static const String rootAPIDataFormat = "data";
  static const String rootAPIStatusFormat = "status";
  static const String rootAPIStatusMessageFormat = "status_message";
  static final List<int> succeedStatuses = [200, 201, 202, 203, 204];

  E transform(R response, D? genericObject);
}

class BasicDioTransformer extends BaseAPIResponseDataTransformer<Response,
    Map<String, dynamic>, dynamic> {
  @override
  Map<String, dynamic> transform(Response response, genericObject) {
    return {
      BaseAPIResponseDataTransformer.rootAPIDataFormat: response.data,
      BaseAPIResponseDataTransformer.rootAPIStatusFormat: response.statusCode,
      BaseAPIResponseDataTransformer.rootAPIStatusMessageFormat:
          response.statusMessage
    };
  }
}

class APIResponseDataTransformer<T> extends BaseAPIResponseDataTransformer<
    Response, BaseAPIResponseWrapper<Response, T>, T> {
  @override
  BaseAPIResponseWrapper<Response, T> transform(
      Response response, T? genericObject) {
    final Map<String, dynamic> object =
        BasicDioTransformer().transform(response, genericObject);
    dynamic data = object[BaseAPIResponseDataTransformer.rootAPIDataFormat];
    if (data is Map) {
      data = data["args"];
    }
    final int? status =
        object[BaseAPIResponseDataTransformer.rootAPIStatusFormat];
    final statusMessage =
        object[BaseAPIResponseDataTransformer.rootAPIStatusMessageFormat];
    final succeed =
        BaseAPIResponseDataTransformer.succeedStatuses.contains(status);
    T? _object;
    if (genericObject is Decoder) {
      _object = genericObject.decode(data);
    } else {
      _object = data;
    }

    if (!succeed) {
      throw ErrorResponse<T>(
          decodedData: _object,
          status: status,
          statusMessage: statusMessage,
          dataTransformer: this,
          response: response);
    }

    return APIResponse<T>(
        decodedData: _object,
        status: status,
        statusMessage: statusMessage,
        dataTransformer: this,
        response: response,
        hasError: !succeed);
  }
}

class APIListResponseDataTransformer<T> extends BaseAPIResponseDataTransformer<
    Response, BaseAPIResponseWrapper<Response, T>, T> {
  @override
  BaseAPIResponseWrapper<Response, T> transform(
      Response response, T? genericObject) {
    final Map<String, dynamic> object =
        BasicDioTransformer().transform(response, genericObject);
    final data = object[BaseAPIResponseDataTransformer.rootAPIDataFormat];
    final int? status =
        object[BaseAPIResponseDataTransformer.rootAPIStatusFormat];
    final statusMessage =
        object[BaseAPIResponseDataTransformer.rootAPIStatusMessageFormat];
    final succeed =
        BaseAPIResponseDataTransformer.succeedStatuses.contains(status);
    List<T> decodedList = [];
    final rawList = data["json"];
    if (rawList is List) {
      if (genericObject is Decoder) {
        for (final e in rawList) {
          decodedList.add(genericObject.decode(e));
        }
      } else {
        decodedList = rawList.cast<T>();
      }
    }
    if (!succeed) {
      throw ErrorResponse<T>(
          decodedData: genericObject,
          status: status,
          statusMessage: statusMessage,
          dataTransformer: this,
          response: response);
    }
    return APIListResponse(
        decodedList: decodedList,
        decodedData: genericObject,
        status: status,
        statusMessage: statusMessage,
        dataTransformer: this,
        response: response,
        hasError: !succeed);
  }
}
