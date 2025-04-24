import 'package:flutter/foundation.dart';

abstract class Result<S, E> {
  const Result();

  /// 성공 결과 생성
  factory Result.success(S value) = Success<S, E>;

  /// 실패 결과 생성
  factory Result.failure(E error) = Failure<S, E>;

  /// 성공 여부
  bool get isSuccess;

  /// 실패 여부
  bool get isFailure;

  /// 값 접근 (성공인 경우)
  S? getOrNull();

  /// 기본값으로 대체 (실패인 경우)
  S getOrDefault(S defaultValue);

  /// 값 변환
  Result<T, E> map<T>(T Function(S) transform);

  /// 값 변환 (다른 Result 반환)
  Result<T, E> flatMap<T>(Result<T, E> Function(S) transform);

  /// 결과에 따른 분기 처리
  T fold<T>(T Function(S) onSuccess, T Function(E) onFailure);

  /// 결과에 따른 사이드 이펙트 실행
  Result<S, E> onSuccess(void Function(S) action);

  /// 결과에 따른 사이드 이펙트 실행
  Result<S, E> onFailure(void Function(E) action);

  /// 에러 변환
  Result<S, F> mapError<F>(F Function(E) transform);
}

/// 성공 결과
class Success<S, E> extends Result<S, E> {
  final S value;

  const Success(this.value);

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  S? getOrNull() => value;

  @override
  S getOrDefault(S defaultValue) => value;

  @override
  Result<T, E> map<T>(T Function(S) transform) {
    return Success<T, E>(transform(value));
  }

  @override
  Result<T, E> flatMap<T>(Result<T, E> Function(S) transform) {
    return transform(value);
  }

  @override
  T fold<T>(T Function(S) onSuccess, T Function(E) onFailure) {
    return onSuccess(value);
  }

  @override
  Result<S, E> onSuccess(void Function(S) action) {
    action(value);
    return this;
  }

  @override
  Result<S, E> onFailure(void Function(E) action) => this;

  @override
  Result<S, F> mapError<F>(F Function(E) transform) {
    return Success<S, F>(value);
  }
}

/// 실패 결과
class Failure<S, E> extends Result<S, E> {
  final E error;

  const Failure(this.error);

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  S? getOrNull() => null;

  @override
  S getOrDefault(S defaultValue) => defaultValue;

  @override
  Result<T, E> map<T>(T Function(S) transform) {
    return Failure<T, E>(error);
  }

  @override
  Result<T, E> flatMap<T>(Result<T, E> Function(S) transform) {
    return Failure<T, E>(error);
  }

  @override
  T fold<T>(T Function(S) onSuccess, T Function(E) onFailure) {
    return onFailure(error);
  }

  @override
  Result<S, E> onSuccess(void Function(S) action) => this;

  @override
  Result<S, E> onFailure(void Function(E) action) {
    action(error);
    return this;
  }

  @override
  Result<S, F> mapError<F>(F Function(E) transform) {
    return Failure<S, F>(transform(error));
  }
}

/// Result 확장 - 비동기 처리
extension FutureResultExtension<S, E> on Future<Result<S, E>> {
  Future<Result<T, E>> map<T>(T Function(S) transform) async {
    final result = await this;
    return result.map(transform);
  }

  Future<Result<T, E>> flatMap<T>(Future<Result<T, E>> Function(S) transform) async {
    final result = await this;
    return result.fold(
          (value) async => await transform(value),
          (error) async => Result.failure(error),
    );
  }
}

/// Result 확장 - 스트림 처리
extension StreamResultExtension<S, E> on Stream<Result<S, E>> {
  Stream<Result<T, E>> mapResult<T>(T Function(S) transform) {
    return map((result) => result.map(transform));
  }

  Stream<T> foldResult<T>(T Function(S) onSuccess, T Function(E) onFailure) {
    return map((result) => result.fold(onSuccess, onFailure));
  }
}

/// Result 확장 - 로그 처리
extension InspectResult<S, E> on Result<S, E> {
  Result<S, E> inspect(String tag) {
    return onSuccess((s) => debugPrint("[$tag] Success: $s"))
        .onFailure((e) => debugPrint("[$tag] Failure: $e"));
  }
}