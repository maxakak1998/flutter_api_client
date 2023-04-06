import 'package:dio/dio.dart';

import 'base_data_transformer.dart';

abstract class BaseAPIResponseWrapper<R, E> {
  R? originalResponse;
  E? decodedData;

  bool hasError = false;
  BaseAPIResponseDataTransformer dataTransformer;

  BaseAPIResponseWrapper({this.decodedData,
    this.hasError = false,
    this.originalResponse,
    required this.dataTransformer});

  BaseAPIResponseWrapper<R, E> decode();
}

class APIResponse<T> extends BaseAPIResponseWrapper<Response, T> {
  APIResponse({
    required Response? response,
    T? decodedData,
    BaseAPIResponseDataTransformer? dataTransformer,
    int? status,
    String? statusMessage,
    bool hasError = false,
  }) : super(
      originalResponse: response,
      hasError: hasError,
      decodedData: decodedData,
      dataTransformer:
      dataTransformer ?? APIResponseDataTransformer<T>());

  @override
  APIResponse<T> decode() =>
      dataTransformer.transform(originalResponse, decodedData);
}

class APIListResponse<T> extends BaseAPIResponseWrapper<Response, T> {
  final List<T>? decodedList;

  APIListResponse({
    required Response? response,
    this.decodedList,
    T? decodedData,
    BaseAPIResponseDataTransformer? dataTransformer,
    bool hasError = false,
  }) : super(
      originalResponse: response,
      hasError: hasError,
      decodedData: decodedData,
      dataTransformer:
      dataTransformer ?? APIListResponseDataTransformer<T>());

  @override
  APIListResponse<T> decode() =>
      dataTransformer.transform(originalResponse, decodedData);
}

class ErrorResponse<T> extends BaseAPIResponseWrapper<Response, T> {
  APIErrorType errorType;

  ErrorResponse({
    this.errorType = APIErrorType.unknown,
    Response? response,
    T? decodedData,
    BaseAPIResponseDataTransformer? dataTransformer,
    int? status,
    String? statusMessage,
  }) : super(
      originalResponse: response,
      hasError: true,
      decodedData: decodedData,
      dataTransformer:
      dataTransformer ?? APIResponseDataTransformer<T>());

  ErrorResponse.defaultError({
    String? statusMessage,
    APIErrorType errorType = APIErrorType.unknown,
  }) : this(errorType: errorType, statusMessage: statusMessage);

  @override
  ErrorResponse<T> decode() =>
      dataTransformer.transform(originalResponse, decodedData);

  APIErrorType getErrorType(dynamic error) {
    if (error == "error.unauthorized") {
      return APIErrorType.unauthorized;
    }
    return APIErrorType.unknown;
  }
}

enum APIErrorType {
  unauthorized,
  unknown,
}
