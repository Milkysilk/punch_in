import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:punch_in/common/global.dart';


class HttpRequest {
  static BaseOptions baseOptions = BaseOptions(
    baseUrl: Global.baseUrl,
    connectTimeout: Global.timeout,
  );
  static final dio = Dio(baseOptions);

  static Future request(
    String url, {
    String method = 'get',
    Map<String, dynamic> params,
    dynamic data,
    String contentType,
  }) async {

    dio.interceptors.add(CookieManager(Global.cookieJar));

    Options options = Options(
      method: method,
      contentType: contentType,
      followRedirects: true,
      validateStatus: (statusCode) {
        return statusCode < 500;
      }
    );
    try {
      final response = await dio.request(url, queryParameters: params, data: data, options: options);
      return response;
    } on DioError catch(err) {
        throw err;
    }
  }
}