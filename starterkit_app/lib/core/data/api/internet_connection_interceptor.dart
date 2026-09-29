// coverage:ignore-file

import 'package:dio/dio.dart';
import 'package:starterkit_app/core/infrastructure/platform/connectivity_service.dart';

class InternetConnectionInterceptor extends Interceptor {
  final ConnectivityService _connectivityService;

  InternetConnectionInterceptor(this._connectivityService);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      handler.reject(DioException.connectionError(requestOptions: options, reason: 'No internet connection'));
      return;
    }

    return super.onRequest(options, handler);
  }
}
