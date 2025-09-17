# Azure Active Directory OAuth

[![pub package](https://img.shields.io/pub/v/aad_oauth_ce.svg)](https://pub.dartlang.org/packages/aad_oauth_ce)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![pub points](https://img.shields.io/pub/points/aad_oauth_ce?logo=dart)](https://pub.dev/packages/aad_oauth_ce/score)
[![Join the chat](https://badges.gitter.im/Earlybyte/aad_oauth.svg)](https://gitter.im/Earlybyte/aad_oauth?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A Flutter OAuth package for performing user authentication against Azure Active Directory OAuth2 v2.0 endpoint. Forked from [hitherejoe.FlutterOAuth](https://github.com/hitherejoe/FlutterOAuth).

Supported Flows:

- [Authorization code flow (including refresh token flow)](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow)
- [Authorization code flow B2C](https://docs.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow)
- [Authorization code flow ADFS](https://learn.microsoft.com/windows-server/identity/ad-fs/development/msal/adfs-msal-native-app-web-api)

## Usage

For using this library you have to create an azure app at the [Azure App registration portal](https://apps.dev.microsoft.com/). Use native app as platform type (with callback URL: <https://login.live.com/oauth20_desktop.srf>).

Your minSdkVersion must be >= 20 in `android/app/build.gradle` section `android / defaultConfig` to support webview_flutter. Version 19 may build but will likely fail at runtime.

If your app does not have the `android.permission.INTERNET` permission you must add it to the AndroidManifest
`<uses-permission android:name="android.permission.INTERNET"/>`

Afterwards you must create a navigatorKey and initialize the library as follow:

```dart
  final navigatorKey = GlobalKey<NavigatorState>();

  // ... 

  static final Config config = new Config(
    tenant: "YOUR_TENANT_ID",
    clientId: "YOUR_CLIENT_ID",
    scope: "openid profile offline_access",
    // redirectUri is Optional as a default is calculated based on app type/web location
    redirectUri: "your redirect url available in azure portal",
    navigatorKey: navigatorKey,
    webUseRedirect: true, // default is false - on web only, forces a redirect flow instead of popup auth
    //Optional parameter: Centered CircularProgressIndicator while rendering web page in WebView
    loader: Center(child: CircularProgressIndicator()),
    postLogoutRedirectUri: 'http://your_base_url/logout', //optional
  );

  final AadOAuth oauth = new AadOAuth(config);
```

This allows you to pass in an tenant ID, client ID, scope and redirect url.

The same `navigatorKey` must be provided to the top-level `MaterialApp`.

```dart
  // ...
  // Material App must be built with the same navigatorKey
  // to support navigation to the login route for interactive
  // authentication.
  // ...

    Widget build(BuildContext context) {
    return MaterialApp(
      // ...
      navigatorKey: navigatorKey,
      // ...
    );
  }
```

Then once you have an OAuth instance, you can call `login()` and afterwards `getAccessToken()` to retrieve an access token:

```dart
final result = await oauth.login();
result.fold(
  (failure) => showError(failure.toString()),
  (token) => showMessage('Logged in successfully, your access token: $token'),
);
String accessToken = await oauth.getAccessToken();
```

Tokens are stored in Keychain for iOS or Keystore for Android. To destroy the tokens you can call `logout()`:

```dart
await oauth.logout();
```

### Web Usage

For web you also have to add some lines to your `index.html` (see the `index.html` in the example applications):
```html
<head>
  <script type="text/javascript" src="https://alcdn.msauth.net/browser/2.13.1/js/msal-browser.min.js"
    integrity="sha384-2Vr9MyareT7qv+wLp1zBt78ZWB4aljfCTMUrml3/cxm0W81ahmDOC6uyNmmn0Vrc"
    crossorigin="anonymous"></script>
  <script src="assets/packages/aad_oauth_ce/assets/msalv2.js"></script>
</head>
```

Note that when using redirect flow on web, the `login()` call will not return if the user has not logged in yet because
the page is redirected and the app is destroyed until login is complete. Your application must take care of calling
`login()` again once reloaded to complete the login process within the flutter application - if login was successful,
this second call will be fast, and will not cause another redirection.

When using redirecting logins with the example application, you will need to click on the login button again following 
a successful login to see the token details. 

### B2C Usage

Setup your B2C directory - [Azure AD B2C Setup](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-tenant/).

Register an App on the previously created B2C directory - [Azure AD B2C App Register](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-register-applications?tabs=applications).

Use native app as plattform type (with callback URL: <https://login.live.com/oauth20_desktop.srf>).

Create your user flows - [Azure AD B2C User Flows](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows)

Add your Azure tenant ID, tenantName, client ID (ID of App), client Secret (Secret of App) and redirectUrl in the main.dart source-code:

```dart
  static final Config configB2Ca = new Config(
    tenant: "YOUR_TENANT_NAME",
    clientId: "YOUR_CLIENT_ID",
    scope: "YOUR_CLIENT_ID offline_access",
    // redirectUri: "https://login.live.com/oauth20_desktop.srf", // Note: this is the default for Mobile
    // clientSecret: "YOUR_CLIENT_SECRET", // Note: do not include secret in publicly available applications
    isB2C: true,
    policy: "YOUR_USER_FLOW___USER_FLOW_A",
    tokenIdentifier: "UNIQUE IDENTIFIER A",
    navigatorKey: navigatorKey,
  );
```

Afterwards you can login and get an access token for accessing other resources. You can also use multiple configs at the same time.

### ADFS Usage

> This library only suports ADFS authentication for Flutter mobile applications, not web builds.

Register an ADFS app = [Windows Server ADFS Application Setup](https://learn.microsoft.com/windows-server/identity/ad-fs/development/msal/adfs-msal-native-app-web-api#app-registration-in-ad-fs).

Use redirect URI: <https://login.live.com/oauth20_desktop.srf>.

Use a configuration like:

```dart
static final Config adfsAuthConfig = Config(
  customAuthorizationUrl:
      'https://adfs.your-domain.com/adfs/oauth2/authorize',
  customTokenUrl:
      'https://adfs.your-domain.com/adfs/oauth2/token',
  clientId: 'YOUR_CLIENT_ID',
  scope:
      'openid OTHER_SCOPES_YOU_NEED',
  navigatorKey: navigatorKey,
  loader: const SizedBox(),
);
```

## Migration from aad_oauth

If you're migrating from the `aad_oauth` package to `aad_oauth_ce`, follow these simple steps to maintain backward compatibility:

### Step 1: Update Dependencies

Update your `pubspec.yaml` file:

```yaml
dependencies:
  # Remove the old package
  # aad_oauth: "^1.0.1"
  
  # Add the new package
  aad_oauth_ce: "^1.1.0"
```

### Step 2: Update Import Statements

Replace all import statements in your Dart files:

```dart
// ❌ Old imports (replace these)
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/token.dart';
import 'package:aad_oauth/model/failure.dart';

// ✅ New imports (use these instead)
import 'package:aad_oauth_ce/aad_oauth.dart';
import 'package:aad_oauth_ce/model/config.dart';
import 'package:aad_oauth_ce/model/token.dart';
import 'package:aad_oauth_ce/model/failure.dart';
```

### Step 3: Update Web Assets (Web Applications Only)

If you're building a web application, update your `web/index.html` file:

```html
<head>
  <!-- ❌ Old script reference (replace this) -->
  <!-- <script src="assets/packages/aad_oauth/assets/msalv2.js"></script> -->
  
  <!-- ✅ New script reference (use this instead) -->
  <script src="assets/packages/aad_oauth_ce/assets/msalv2.js"></script>
</head>
```

### Step 4: Run Flutter Clean and Get Dependencies

```bash
flutter clean
flutter pub get
```

### What Stays the Same

✅ **All class names remain identical**: `AadOAuth`, `Config`, `Token`, etc.  
✅ **All method signatures are unchanged**: `login()`, `logout()`, `getAccessToken()`, etc.  
✅ **All configuration options work the same way**  
✅ **All functionality is preserved** - no breaking changes to the public API  

### Migration Example

Here's a complete before/after example:

**Before (aad_oauth):**
```dart
// pubspec.yaml
dependencies:
  aad_oauth: "^1.0.1"

// main.dart
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';

final AadOAuth oauth = AadOAuth(config);
```

**After (aad_oauth_ce):**
```dart
// pubspec.yaml
dependencies:
  aad_oauth_ce: "^1.1.0"

// main.dart  
import 'package:aad_oauth_ce/aad_oauth.dart';
import 'package:aad_oauth_ce/model/config.dart';

final AadOAuth oauth = AadOAuth(config); // Same code!
```

The migration is designed to be as seamless as possible - you only need to change package references and imports, not your actual implementation code!

## Installation

Add the following to your pubspec.yaml dependencies:

```yaml
dependencies:
  aad_oauth_ce: "^1.1.0"
```

## Contribution

Contributions can be submitted as pull requests and are highly welcomed. Changes will be bundled together into a release. You can find the next release date and past releases in the [CHANGELOG file](CHANGELOG.md).
