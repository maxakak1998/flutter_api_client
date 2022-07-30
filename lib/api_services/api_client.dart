import 'package:dio/dio.dart';

import 'api_response.dart';
import 'api_routes.dart';
import 'base_data_transformer.dart';
import 'decoder.dart';

abstract class BaseAPIClient {
  late BaseOptions options;
  late Dio instance;

  Future<T> request<T>(
      {required APIRouteConfigurable route,
      required GenericObject<T> create,
      Map<String, dynamic>? params,
      String? extraPath,
      FormData? formData,
      Map<String, dynamic>? header,
      dynamic body});
}

class APIClient extends BaseAPIClient {
  APIClient() {
    options = BaseOptions(
      validateStatus: (status)=>true,
      baseUrl: "http://httpbin.org",
      headers: {"Content-Type": "application/json"},
      responseType: ResponseType.json,
    );
    instance = Dio(options);
  }

  @override
  Future<T> request<T>(
      {required route,
      required GenericObject<T> create,
      Map<String, dynamic>? params,
      String? extraPath,
      FormData? formData,
      Map<String, dynamic>? header,
      dynamic body}) async {
    final RequestOptions? requestOptions = route.getConfig(options);
    if (requestOptions != null) {
      if (params != null) {
        requestOptions.queryParameters = params;
      }
      if (extraPath != null) requestOptions.path += extraPath;
      if (header != null) requestOptions.headers.addAll(header);
      if (body != null) {
        requestOptions.data = body;
      }
      if (formData != null) {
        if (requestOptions.data != null) {
          formData.fields.add(requestOptions.data);
        }
        requestOptions.data = formData;
      }

      try {
        Response response = await instance.fetch(requestOptions);

        T apiWrapper = create(response);


          ///using Wrapper
          if (apiWrapper is BaseAPIResponseWrapper) {
            apiWrapper = apiWrapper.decode() as T;

            if (apiWrapper is ErrorResponse) throw apiWrapper;
            return apiWrapper;
          }

          ///If you want to use another object type such as primitive type
          ///, but you need to ensure that the response type matches your expected type
          if (response.data is T) {
            return response.data;
          } else {
            throw ErrorResponse.defaultError(
                statusMessage:
                    "Can not match the $T type with ${response.data.runtimeType}");
          }


      } on DioError catch (e) {
        throw ErrorResponse(response: e.response);
      } on ErrorResponse catch(e)  {
        rethrow;
      } catch (e) {
        throw ErrorResponse.defaultError(statusMessage: e.toString());
      }
    } else {
      throw ErrorResponse.defaultError(
          statusMessage: "Missing request options");
    }
  }
}
