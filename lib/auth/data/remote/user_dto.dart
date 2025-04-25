import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final String? provider;

  /// 계정 생성 시간
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;

  const UserDto({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
    this.isEmailVerified = false,
    this.createdAt,
    this.provider,
  });

  /// Firebase User 객체로부터 DTO 생성
  factory UserDto.fromFirebaseUser(firebase_auth.User user) {
    return UserDto(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
      provider:
          user.providerData.isNotEmpty
              ? user.providerData.first.providerId
              : null,
    );
  }

  factory UserDto.empty() => const UserDto(id: '');

  /// JSON에서 객체 생성
  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  /// 객체에서 JSON 생성
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  /// DateTime을 JSON으로 변환 (ISO 8601 문자열)
  static String? _dateTimeToJson(DateTime? dateTime) =>
      dateTime?.toIso8601String();

  /// JSON에서 DateTime으로 변환
  static DateTime? _dateTimeFromJson(String? dateString) =>
      dateString != null ? DateTime.parse(dateString) : null;

  @override
  String toString() =>
      'UserDto(id: $id, email: $email, displayName: $displayName, isEmailVerified: $isEmailVerified, provider: $provider)';
}
