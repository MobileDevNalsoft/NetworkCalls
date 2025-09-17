import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:network_calls/src/api_response_model.dart';
import 'package:network_calls/src/logging_interceptor.dart';

class NetworkCalls extends HttpOverrides {
  final String baseUrl;
  final int connectTimeout;
  final int receiveTimeout;
  final int maxRedirects;
  final String? username;
  final String? password;
  final String? contentType;
  final Map<String, dynamic>? headers;

  Dio dio;
  LoggingInterceptor loggingInterceptor = LoggingInterceptor();

  NetworkCalls(
    this.baseUrl,
    this.dio, {
    this.username,
    this.password,
    this.contentType,
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
      {Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress,
      Map<String, dynamic>? methodHeaders}) async {
    try {
      Response response = await dio.get(
        uri,
        queryParameters: queryParameters,
        options: Options(
            headers: headers ??
                methodHeaders ??
                {
                  'Authorization':
                      'Basic ${base64.encode(utf8.encode('$username:$password'))}',
                      'Accept': 'application/json',
                      'Content-Type': contentType
                }),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse.withSuccess(response);
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
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
        options: Options(
            headers: headers ??
                methodHeaders ??
                {
                  'Authorization':
                      'Basic ${base64.encode(utf8.encode('$username:$password'))}',
                      'Accept': 'application/json',
                      'Content-Type': contentType
                }),
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
        options: Options(
            headers: headers ??
                methodHeaders ??
                {
                  'Authorization':
                      'Basic ${base64.encode(utf8.encode('$username:$password'))}',
                      'Accept': 'application/json',
                      'Content-Type': contentType
                }),
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

  Future<ApiResponse> delete(String uri,
      {data,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      Map<String, dynamic>? methodHeaders}) async {
    try {
      Response response = await dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(
            headers: headers ??
                methodHeaders ??
                {
                  'Authorization':
                      'Basic ${base64.encode(utf8.encode('$username:$password'))}',
                      'Accept': 'application/json',
                      'Content-Type': contentType
                }),
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
