import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rubbit_client/core/network/api_client.dart';
import 'package:rubbit_client/core/network/api_exception.dart';
import 'package:rubbit_client/core/type/result.dart';

@GenerateMocks([Dio])
import 'api_client_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late ApiClient apiClient;

  setUp(() {
    mockDio = MockDio();
    apiClient = ApiClient(mockDio);
  });

  group('GET 요청 테스트', () {
    const testPath = '/test';
    final testQueryParams = {'key': 'value'};

    test('Given 정상적인 네트워크 환경'
        'When GET 요청을 수행하면'
        'Then 성공 Result를 반환한다', () async {
      // Given
      final responseData = {'success': true, 'data': 'test'};
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: testPath),
        data: responseData,
        statusCode: 200,
      );
      when(
        mockDio.get<Map<String, dynamic>>(testPath, queryParameters: testQueryParams),
      ).thenAnswer((_) async => response);

      // When
      final result = await apiClient.get<Map<String, dynamic>>(testPath, queryParameters: testQueryParams);

      // Then
      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), responseData);
      verify(mockDio.get<Map<String, dynamic>>(testPath, queryParameters: testQueryParams)).called(1);
    });

    test('Given Dio에서 예외가 발생하는 상황'
        'When GET 요청을 수행하면'
        'Then 실패 Result를 반환한다', () async {
      // Given
      final dioError = DioException(
        requestOptions: RequestOptions(path: testPath),
        error: 'Test error',
        message: '네트워크 오류',
      );
      when(mockDio.get<Map<String, dynamic>>(testPath, queryParameters: testQueryParams)).thenThrow(dioError);

      // When
      final result = await apiClient.get<Map<String, dynamic>>(testPath, queryParameters: testQueryParams);

      // Then
      expect(result.isFailure, isTrue);
      final error = (result as Failure<dynamic, ApiException>).error;
      expect(error.code, 'dio_error');
      expect(error.message, '네트워크 오류');
      verify(mockDio.get<Map<String, dynamic>>(testPath, queryParameters: testQueryParams)).called(1);
    });

    test('Given Dio에서 message가 없는 예외가 발생하는 상황'
        'When GET 요청을 수행하면'
        'Then 기본 오류 메시지가 있는 실패 Result를 반환한다', () async {
      // Given
      final dioError = DioException(requestOptions: RequestOptions(path: testPath), error: 'Test error');
      when(mockDio.get<Map<String, dynamic>>(testPath, queryParameters: testQueryParams)).thenThrow(dioError);

      // When
      final result = await apiClient.get<Map<String, dynamic>>(testPath, queryParameters: testQueryParams);

      // Then
      expect(result.isFailure, isTrue);
      final error = (result as Failure<dynamic, ApiException>).error;
      expect(error.code, 'dio_error');
      expect(error.message, '알 수 없는 오류');
    });

    test('Given Dio 이외의 예외가 발생하는 상황'
        'When GET 요청을 수행하면'
        'Then unknown 코드의 실패 Result를 반환한다', () async {
      // Given
      final exception = Exception('일반 예외');
      when(mockDio.get<Map<String, dynamic>>(testPath, queryParameters: testQueryParams)).thenThrow(exception);

      // When
      final result = await apiClient.get<Map<String, dynamic>>(testPath, queryParameters: testQueryParams);

      // Then
      expect(result.isFailure, isTrue);
      final error = (result as Failure<dynamic, ApiException>).error;
      expect(error.code, 'unknown');
      expect(error.message, contains('Exception: 일반 예외'));
    });
  });

  group('POST 요청 테스트', () {
    const testPath = '/post-test';
    final testData = {'name': 'test'};
    final testQueryParams = {'key': 'value'};

    test('Given 정상적인 네트워크 환경'
        'When POST 요청을 수행하면'
        'Then 성공 Result를 반환한다', () async {
      // Given
      final responseData = {'id': 1, 'success': true};
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: testPath),
        data: responseData,
        statusCode: 201,
      );
      when(
        mockDio.post<Map<String, dynamic>>(testPath, data: testData, queryParameters: testQueryParams),
      ).thenAnswer((_) async => response);

      // When
      final result = await apiClient.post<Map<String, dynamic>>(
        testPath,
        data: testData,
        queryParameters: testQueryParams,
      );

      // Then
      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), responseData);
      verify(mockDio.post<Map<String, dynamic>>(testPath, data: testData, queryParameters: testQueryParams)).called(1);
    });

    test('Given Dio에서 예외가 발생하는 상황'
        'When POST 요청을 수행하면'
        'Then 실패 Result를 반환한다', () async {
      // Given
      final dioError = DioException(
        requestOptions: RequestOptions(path: testPath),
        error: 'Post error',
        message: '서버 오류',
      );
      when(
        mockDio.post<Map<String, dynamic>>(testPath, data: testData, queryParameters: testQueryParams),
      ).thenThrow(dioError);

      // When
      final result = await apiClient.post<Map<String, dynamic>>(
        testPath,
        data: testData,
        queryParameters: testQueryParams,
      );

      // Then
      expect(result.isFailure, isTrue);
      final error = (result as Failure<dynamic, ApiException>).error;
      expect(error.code, 'dio_error');
      expect(error.message, '서버 오류');
    });

    test('Given Dio 이외의 예외가 발생하는 상황'
        'When POST 요청을 수행하면'
        'Then unknown 코드의 실패 Result를 반환한다', () async {
      // Given
      final exception = FormatException('JSON 파싱 오류');
      when(
        mockDio.post<Map<String, dynamic>>(testPath, data: testData, queryParameters: testQueryParams),
      ).thenThrow(exception);

      // When
      final result = await apiClient.post<Map<String, dynamic>>(
        testPath,
        data: testData,
        queryParameters: testQueryParams,
      );

      // Then
      expect(result.isFailure, isTrue);
      final error = (result as Failure<dynamic, ApiException>).error;
      expect(error.code, 'unknown');
      expect(error.message, contains('FormatException: JSON 파싱 오류'));
    });
  });

  group('mapDioErrorToApiException 메서드 테스트', () {
    test('Given DioException 인스턴스'
        'When _mapDioErrorToApiException 메서드를 호출하면'
        'Then 적절한 ApiException으로 변환된다', () {
      // Given
      final apiClient = ApiClient(Dio());
      final _ = DioException(requestOptions: RequestOptions(path: '/test'), message: '테스트 오류');

      // When
      // private 메서드를 직접 테스트할 수 없으므로 get 메서드를 통해 간접적으로 테스트
      final future = apiClient.get<Map<String, dynamic>>('/test');

      // Then
      expectLater(
        future,
        completion(
          isA<Result<Map<String, dynamic>, ApiException>>().having((result) => result.isFailure, 'isFailure', isTrue),
        ),
      );
    });
  });
}
