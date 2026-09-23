import 'package:azure_oauth/helper/choose_oauth.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:azure_oauth/helper/mobile_oauth.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'package:azure_oauth/helper/web_oauth.dart';
import 'package:azure_oauth/model/config.dart';
import 'package:azure_oauth/model/failure.dart';
import 'package:azure_oauth/model/token.dart';
import 'package:dartz/dartz.dart';

class CoreOAuth {
  CoreOAuth();

  Future<Either<Failure, Token>> login(
          {bool refreshIfAvailable = false}) async =>
      throw UnsupportedFailure(
          errorType: ErrorType.unsupported, message: 'Unsupported login');

  Future<Either<Failure, Token>> refreshToken() async =>
      throw UnsupportedFailure(
          errorType: ErrorType.unsupported,
          message: 'Unsupported silentlyLogin');

  Future<void> logout(
          {bool showPopup = true, bool clearCookies = true}) async =>
      throw UnsupportedFailure(
          errorType: ErrorType.unsupported, message: 'Unsupported logout');

  Future<bool> get hasCachedAccountInformation async => false;

  Future<String?> getAccessToken() async => throw UnsupportedFailure(
      errorType: ErrorType.unsupported, message: 'Unsupported getAccessToken');

  Future<String?> getRefreshToken() async => throw UnsupportedFailure(
      errorType: ErrorType.unsupported, message: 'Unsupported getRefreshToken');

  Future<String?> getIdToken() async => throw UnsupportedFailure(
      errorType: ErrorType.unsupported, message: 'Unsupported getIdToken');

  factory CoreOAuth.fromConfig(Config config) =>
      config.isStub ? MockCoreOAuth() : getOAuthConfig(config);
}

/// Mock class for testing.
class MockCoreOAuth extends CoreOAuth {
  final String mockAccessToken = 'ACCESS_TOKEN';
  final String mockRefreshToken = 'REFRESH_TOKEN';
  final String mockIdToken = 'ID_TOKEN';

  @override
  Future<Either<Failure, Token>> login(
          {bool refreshIfAvailable = false}) async =>
      Right(Token(accessToken: mockAccessToken));

  @override
  Future<void> logout(
      {bool showPopup = true, bool clearCookies = true}) async {}

  @override
  Future<bool> get hasCachedAccountInformation async => true;

  @override
  Future<String?> getAccessToken() async => mockAccessToken;

  @override
  Future<String?> getRefreshToken() async => mockRefreshToken;

  @override
  Future<String?> getIdToken() async => mockIdToken;
}
