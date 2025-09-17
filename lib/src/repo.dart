import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NetworkCalls extends HttpOverrides {
  final String baseUrl;
  final int connectTimeout;
  final int receiveTimeout;
  final int maxRedirects;
  final String? username;
  final String? password;
  final Map<String, dynamic>? headers;

  Dio dio;
  LoggingInterceptor loggingInterceptor = LoggingInterceptor();

  NetworkCalls(
    this.baseUrl,
    this.dio, {
    this.username,
    this.password,
    this.connectTimeout = 5,
    this.receiveTimeout = 5,
    this.maxRedirects = 5,
    this.headers,
  }) {
    dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = Duration(seconds: connectTimeout)
      ..options.receiveTimeout = Duration(seconds: receiveTimeout)
      ..options.maxRedirects = maxRedirects
      ..httpClientAdapter
      ..options.headers = headers ?? {};
    dio.interceptors.add(loggingInterceptor);
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  Future<ApiResponse> get(String uri,
      {Map<String, dynamic>? queryParameters, CancelToken? cancelToken, ProgressCallback? onReceiveProgress, Map<String, dynamic>? methodHeaders, String? bearerToken}) async {
    try {
      final allHeaders = <String, dynamic>{};
      if (headers != null) allHeaders.addAll(headers!);
      if (methodHeaders != null) allHeaders.addAll(methodHeaders!);
      if (bearerToken != null) {
        allHeaders['Authorization'] = 'Bearer $bearerToken';
      } else if (username != null && password != null) {
        allHeaders['Authorization'] = 'Basic ${base64.encode(utf8.encode('$username:$password'))}';
      }
      Response response = await dio.get(
        uri,
        queryParameters: queryParameters,
        options: Options(headers: allHeaders),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(e);
    }
  }

  Future<ApiResponse> post(String uri,
      {data,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress,
      Map<String, dynamic>? methodHeaders}) async {
    try {
      Response response = await dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers ?? methodHeaders ?? {'Authorization': 'Basic ${base64.encode(utf8.encode('$username:$password'))}'}),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse.withSuccess(response);
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      return ApiResponse.withError(e);
    }
  }

  Future<ApiResponse> put(String uri,
      {data,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress,
      Map<String, dynamic>? methodHeaders}) async {
    try {
      Response response = await dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers ?? methodHeaders ?? {'Authorization': 'Basic ${base64.encode(utf8.encode('$username:$password'))}'}),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse.withSuccess(response);
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      return ApiResponse.withError(e);
    }
  }

  Future<ApiResponse> delete(String uri, {data, Map<String, dynamic>? queryParameters, CancelToken? cancelToken, Map<String, dynamic>? methodHeaders}) async {
    try {
      Response response = await dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers ?? methodHeaders ?? {'Authorization': 'Basic ${base64.encode(utf8.encode('$username:$password'))}'}),
        cancelToken: cancelToken,
      );
      return ApiResponse.withSuccess(response);
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      return ApiResponse.withError(e);
    }
  }
}

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print("--> ${options.method} ${options.path}");
    print("Headers: ${options.headers.toString()}");
    print("<-- END HTTP");

    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    print("<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}");

    String responseAsString = response.data.toString();

    if (responseAsString.length > maxCharactersPerLine) {
      int iterations = (responseAsString.length / maxCharactersPerLine).floor();
      for (int i = 0; i <= iterations; i++) {
        int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
        if (endingIndex > responseAsString.length) {
          endingIndex = responseAsString.length;
        }
        // print(
        //     responseAsString.substring(i * maxCharactersPerLine, endingIndex));
      }
    } else {
      print('Got Data');
    }
    print("<-- END HTTP");
    return super.onResponse(response, handler);
  }

  @override
  // ignore: deprecated_member_use
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    print("ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");
    return super.onError(err, handler);
  }
}
