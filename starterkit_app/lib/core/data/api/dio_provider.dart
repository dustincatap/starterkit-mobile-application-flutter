import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:starterkit_app/core/data/api/debug_logging_interceptor.dart';
import 'package:starterkit_app/core/data/api/internet_connection_interceptor.dart';
import 'package:starterkit_app/core/infrastructure/logging/logger.dart';
import 'package:starterkit_app/core/infrastructure/platform/connectivity_service.dart';

export 'package:dio/dio.dart';

const Headers jsonContentType = Headers(<String, dynamic>{'Content-Type': 'application/json'});

@injectable
class DioProvider {
  static const Duration _connectionTimeOut = Duration(seconds: 10);
  static const Duration _requestTimeOut = Duration(seconds: 30);
  static const Duration _sendTimeout = Duration(seconds: 10);

  final Logger _logger;
  final ConnectivityService _connectivityService;

  DioProvider(this._logger, this._connectivityService);

  Dio create<TApi>() {
    _logger.logFor<TApi>();

    final Dio dio =
        Dio(
            BaseOptions(
              connectTimeout: _connectionTimeOut,
              receiveTimeout: _requestTimeOut,
              sendTimeout: _sendTimeout,
            ),
          )
          ..interceptors.addAll(<Interceptor>[
            InternetConnectionInterceptor(_connectivityService),
            DebugLoggingInterceptor(_logger),
          ]);

    return dio;
  }
}
