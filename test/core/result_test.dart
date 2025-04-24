import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rubbit_client/core/type/result.dart';

void main() {
  group('Success – 기본 동작', () {
    test('Given Success 인스턴스'
        'When isSuccess & isFailure 조회'
        'Then true/false가 올바르게 반환된다.', () {
      // Given
      final result = Result.success(1);

      // When
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('Given Success 인스턴스'
        'When getOrNull() 호출'
        'Then 내부 값을 반환한다.', () {
      const value = 10;
      final result = Result.success(value);

      expect(result.getOrNull(), value);
    });

    test('Given Success 인스턴스'
        'When getOrDefault() 호출'
        'Then defaultValue를 무시하고 내부 값을 반환한다.', () {
      final result = Result.success('A');
      expect(result.getOrDefault('B'), 'A');
    });

    test('Given Success 인스턴스'
        'When map() 호출'
        'Then 변환된 Success를 돌려준다.', () {
      final result = Result.success(2).map((v) => v * 3);
      expect(result, isA<Success<int, dynamic>>());
      expect((result as Success).value, 6);
    });

    test('Given Success 인스턴스'
        'When flatMap() 호출'
        'Then transform 결과(Result)를 그대로 돌려준다.', () {
      final result = Result.success(5).flatMap((v) => Result.success('v=$v'));
      expect(result.getOrNull(), 'v=5');
    });

    test('Given Success 인스턴스'
        'When fold() 호출'
        'Then onSuccess가 실행되고 반환값을 돌려준다.', () {
      final folded = Result.success(7).fold((v) => v * 2, (_) => 0);
      expect(folded, 14);
    });

    test('Given Success 인스턴스'
        'When onSuccess() 호출'
        'Then 콜백이 실행되고 자기 자신을 반환한다.', () {
      int sideEffect = 0;
      final original = Result.success(3);
      final returned = original.onSuccess((v) => sideEffect = v);

      expect(sideEffect, 3);
      expect(identical(original, returned), isTrue);
    });

    test('Given Success 인스턴스'
        'When mapError() 호출'
        'Then 타입만 바뀐 Success를 그대로 돌려준다.', () {
      final result = Result.success(1).mapError<String>((e) => 'error');
      expect(result, isA<Success<int, String>>());
      expect(result.getOrNull(), 1);
    });
  });

  group('Failure – 기본 동작', () {
    test('Given Failure 인스턴스'
        'When isSuccess & isFailure 조회'
        'Then false/true가 올바르게 반환된다.', () {
      final result = Result.failure('err');
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
    });

    test('Given Failure 인스턴스'
        'When getOrNull() 호출'
        'Then null을 반환한다.', () {
      final result = Result.failure('oops');
      expect(result.getOrNull(), isNull);
    });

    test('Given Failure 인스턴스'
        'When getOrDefault() 호출'
        'Then 기본값을 반환한다.', () {
      final result = Result.failure('oops');
      expect(result.getOrDefault(99), 99);
    });

    test('Given Failure 인스턴스'
        'When map() 호출'
        'Then 동일 오류를 가진 Failure를 돌려준다.', () {
      final result = Result.failure('e').map((v) => v.toString());
      expect(result, isA<Failure<dynamic, String>>());
      expect((result as Failure).error, 'e');
    });

    test('Given Failure 인스턴스'
        'When flatMap() 호출'
        'Then 동일 오류를 가진 Failure를 돌려준다.', () {
      final result = Result.failure('e').flatMap((_) => Result.success('unused'));
      expect(result.isFailure, isTrue);
    });

    test('Given Failure 인스턴스'
        'When fold() 호출'
        'Then onFailure가 실행되고 반환값을 돌려준다.', () {
      final folded = Result.failure('boom').fold((_) => 1, (e) => e.length);
      expect(folded, 4); // 'boom'.length
    });

    test('Given Failure 인스턴스'
        'When onFailure() 호출'
        'Then 콜백이 실행되고 자기 자신을 반환한다.', () {
      String? captured;
      final original = Result.failure('fail');
      final returned = original.onFailure((e) => captured = e);

      expect(captured, 'fail');
      expect(identical(original, returned), isTrue);
    });

    test('Given Failure 인스턴스'
        'When mapError() 호출'
        'Then 오류가 변환된 Failure를 돌려준다.', () {
      final result = Result<int, String>.failure('e').mapError<int>((e) => e.length);
      expect(result, isA<Failure<int, int>>());
      expect((result as Failure).error, 1);
    });
  });

  group('FutureResultExtension', () {
    test('Given Future<Success>'
        'When map() 호출'
        'Then 값이 변환된 Success가 반환된다.', () async {
      final future = Future.value(Result.success(2));
      final result = await future.map((v) => v * 4);

      expect(result.getOrNull(), 8);
    });

    test('Given Future<Success>'
        'When flatMap() 호출'
        'Then transform Future<Result>가 반환된다.', () async {
      final future = Future.value(Result.success('ok'));
      final result = await future.flatMap((v) => Future.value(Result.success('$v👍')));

      expect(result.getOrNull(), 'ok👍');
    });

    test('Given Future<Failure>'
        'When flatMap() 호출'
        'Then 원본 오류가 그대로 전달된다.', () async {
      final future = Future.value(Result.failure('bad'));
      final result = await future.flatMap((_) => Future.value(Result.success(1)));

      expect(result.isFailure, isTrue);
      expect((result as Failure).error, 'bad');
    });
  });

  group('StreamResultExtension', () {
    test('Given Stream<Success>'
        'When mapResult() 호출'
        'Then 각 값이 변환된 Success 스트림을 반환한다.', () async {
      final stream = Stream.fromIterable([Result.success(1), Result.success(2)]).mapResult((v) => v * 10);

      final values = await stream.map((r) => r.getOrNull()).toList();
      expect(values, [10, 20]);
    });

    test('Given Stream<Failure>'
        'When foldResult() 호출'
        'Then onFailure 결과가 방출된다.', () async {
      final stream = Stream.fromIterable([
        Result<String, String>.failure('e1'),
        Result<String, String>.failure('e2'),
      ]).foldResult((_) => 'success', (e) => 'fail:$e');

      expect(await stream.toList(), ['fail:e1', 'fail:e2']);
    });
  });
}
