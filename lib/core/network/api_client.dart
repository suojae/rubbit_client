import 'package:dio/dio.dart';
import 'package:rubbit_client/core/network/api_exception.dart';
import 'package:rubbit_client/core/type/result.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// GET 요청
  Future<Result<T, ApiException>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
      return Result.success(response.data as T);
    } on DioException catch (e) {
      return Result.failure(_mapDioErrorToApiException(e));
    } catch (e) {
      return Result.failure(
        ApiException(code: 'unknown', message: e.toString()),
      );
    }
  }

  /// POST 요청
  Future<Result<T, ApiException>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return Result.success(response.data as T);
    } on DioException catch (e) {
      return Result.failure(_mapDioErrorToApiException(e));
    } catch (e) {
      return Result.failure(
        ApiException(code: 'unknown', message: e.toString()),
      );
    }
  }

  ApiException _mapDioErrorToApiException(DioException e) {
    return ApiException(code: 'dio_error', message: e.message ?? '알 수 없는 오류');
  }
}
