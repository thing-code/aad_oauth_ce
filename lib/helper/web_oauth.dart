/// Microsoft identity platform authentication library (web implementation).
///
/// Calls into the `aadOauth` JavaScript object defined in
/// `assets/msalv2.js` (loaded via `web/index.html`) using the static
/// `dart:js_interop` API. This file is only compiled for web through the
/// conditional import in `core_oauth.dart`, so it has no effect on
/// Android/iOS builds.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:azure_oauth/helper/core_oauth.dart';
import 'package:azure_oauth/model/config.dart';
import 'package:azure_oauth/model/failure.dart';
import 'package:azure_oauth/model/msalconfig.dart';
import 'package:azure_oauth/model/token.dart';
import 'package:dartz/dartz.dart';

@JS('aadOauth.init')
external void jsInit(MsalConfig config);

@JS('aadOauth.login')
external void jsLogin(
  JSBoolean refreshIfAvailable,
  JSBoolean useRedirect,
  JSFunction onSuccess,
  JSFunction onError,
);

@JS('aadOauth.logout')
external void jsLogout(
  JSFunction onSuccess,
  JSFunction onError,
  JSBoolean showPopup,
);

@JS('aadOauth.getAccessToken')
external JSPromise<JSAny?> jsGetAccessToken();

@JS('aadOauth.getIdToken')
external JSPromise<JSAny?> jsGetIdToken();

@JS('aadOauth.hasCachedAccountInformation')
external JSBoolean jsHasCachedAccountInformation();

@JS('aadOauth.refreshToken')
external void jsRefreshToken(
  JSFunction onSuccess,
  JSFunction onError,
);

class WebOAuth extends CoreOAuth {
  final Config config;
  WebOAuth(this.config) {
    jsInit(MsalConfig.construct(
        tenant: config.tenant,
        policy: config.policy,
        clientId: config.clientId,
        responseType: config.responseType,
        redirectUri: config.redirectUri,
        scope: config.scope,
        responseMode: config.responseMode,
        state: config.state,
        prompt: config.prompt,
        codeChallenge: config.codeChallenge,
        codeChallengeMethod: config.codeChallengeMethod,
        nonce: config.nonce,
        tokenIdentifier: config.tokenIdentifier,
        clientSecret: config.clientSecret,
        resource: config.resource,
        isB2C: config.isB2C,
        customAuthorizationUrl: config.customAuthorizationUrl,
        customTokenUrl: config.customTokenUrl,
        loginHint: config.loginHint,
        domainHint: config.domainHint,
        codeVerifier: config.codeVerifier,
        authorizationUrl: config.authorizationUrl,
        tokenUrl: config.tokenUrl,
        cacheLocation: config.cacheLocation.value,
        customParameters: jsonEncode(config.customParameters),
        postLogoutRedirectUri: config.postLogoutRedirectUri));
  }

  @override
  Future<String?> getAccessToken() async {
    final result = await jsGetAccessToken().toDart;
    return (result as JSString?)?.toDart;
  }

  @override
  Future<String?> getIdToken() async {
    final result = await jsGetIdToken().toDart;
    return (result as JSString?)?.toDart;
  }

  @override
  Future<bool> get hasCachedAccountInformation async =>
      jsHasCachedAccountInformation().toDart;

  @override
  Future<Either<Failure, Token>> login(
      {bool refreshIfAvailable = false}) async {
    final completer = Completer<Either<Failure, Token>>();

    jsLogin(
      refreshIfAvailable.toJS,
      config.webUseRedirect.toJS,
      ((JSAny? value) {
        final accessToken = (value as JSString?)?.toDart;
        completer.complete(Right(Token(accessToken: accessToken)));
      }).toJS,
      ((JSAny? error) {
        completer.complete(Left(AadOauthFailure(
          errorType: ErrorType.accessDeniedOrAuthenticationCanceled,
          message:
              'Access denied or authentication canceled. Error: ${_describeJsError(error)}',
        )));
      }).toJS,
    );

    return completer.future;
  }

  @override
  Future<Either<Failure, Token>> refreshToken() {
    final completer = Completer<Either<Failure, Token>>();

    jsRefreshToken(
      ((JSAny? value) {
        final accessToken = (value as JSString?)?.toDart;
        completer.complete(Right(Token(accessToken: accessToken)));
      }).toJS,
      ((JSAny? error) {
        completer.complete(Left(AadOauthFailure(
          errorType: ErrorType.accessDeniedOrAuthenticationCanceled,
          message:
              'Access denied or authentication canceled. Error: ${_describeJsError(error)}',
        )));
      }).toJS,
    );

    return completer.future;
  }

  @override
  Future<String?> getRefreshToken() async => throw UnsupportedFailure(
      errorType: ErrorType.unsupported,
      message:
          'Refresh token is not exposed on web; it is managed internally by MSAL.');

  @override
  Future<void> logout({bool showPopup = true, bool clearCookies = true}) async {
    final completer = Completer<void>();

    jsLogout(
      ((JSAny? _) {
        completer.complete();
      }).toJS,
      ((JSAny? error) {
        completer.completeError(_describeJsError(error));
      }).toJS,
      showPopup.toJS,
    );

    return completer.future;
  }
}

/// Best-effort conversion of a JS callback error into a readable message.
///
/// Uses [JSAny.isA] (instead of `is`) so the checks stay consistent
/// between the JS and WASM compilers.
String _describeJsError(JSAny? error) {
  if (error == null) return 'unknown error';
  if (error.isA<JSString>()) return (error as JSString).toDart;
  if (error.isA<JSNumber>()) return (error as JSNumber).toDartDouble.toString();
  if (error.isA<JSBoolean>()) return (error as JSBoolean).toDart.toString();
  if (error.isA<JSObject>()) {
    final message = (error as JSObject).getProperty('message'.toJS);
    if (message != null && message.isA<JSString>()) {
      return (message as JSString).toDart;
    }
  }
  return error.toString();
}

CoreOAuth getOAuthConfig(Config config) => WebOAuth(config);
