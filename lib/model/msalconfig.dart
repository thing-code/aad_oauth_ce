import 'dart:js_interop';

/// Interop with JS, we need to convert Config to a JS object or it comes
/// through as empty when passed to JS.
///
/// Parameters according to official Microsoft Documentation:
/// - Azure AD https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow
/// - Azure AD B2C: https://docs.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow
///
/// DartDocs of parameters are mostly from those pages.
///
/// Declared as an [extension type] of [JSObject] so the Dart compiler
/// emits a plain JavaScript object literal understood by `assets/msalv2.js`.
@JS()
extension type MsalConfig(JSObject _) implements JSObject {
  /// Azure AD OAuth Configuration. Look at individual fields for description.
  external factory MsalConfig.construct({
    /// The tenant value in the path of the request can be used to control who
    /// can sign into the application. Or name of your Azure AD B2C tenant.
    String? tenant,

    /// __AAD B2C only__: The user flow to be run.
    String? policy,

    /// The Application (client) ID assigned to your app.
    String? clientId,

    /// Must include code for the authorization code flow.
    String? responseType,

    /// The redirect uri of your app.
    String? redirectUri,

    /// A space-separated list of scopes that you want the user to consent to.
    String? scope,

    /// Specifies the method used to send the resulting token back to your app.
    String? responseMode,

    /// A value included in the request that will also be returned in the
    /// token response.
    String? state,

    /// Indicates the type of user interaction that is required.
    String? prompt,

    /// Used to secure authorization code grants via Proof Key for Code
    /// Exchange (PKCE).
    String? codeChallenge,

    /// The method used to encode the code_verifier.
    String? codeChallengeMethod,

    /// __AAD B2C only__: A nonce is a strategy used to mitigate token replay
    /// attacks.
    String? nonce,

    /// __AAD B2C only__: Identifies access tokens, to allow multiple
    /// concurrent sessions.
    String? tokenIdentifier,

    /// The client secret generated for your app in the app registration
    /// portal.
    String? clientSecret,

    /// Resource.
    String? resource,

    /// Using Azure AD B2C instead of standard Azure AD.
    bool? isB2C,

    /// Override of the authorization URL, can be used to enable ADFS
    /// authentication.
    String? customAuthorizationUrl,

    /// Override of the token URL, can be used to enable ADFS authentication.
    String? customTokenUrl,

    /// Can be used to pre-fill the username/email address field of the
    /// sign-in page.
    String? loginHint,

    /// If included, it will skip the email-based discovery process.
    String? domainHint,

    /// The same code_verifier that was used to obtain the authorization_code.
    String? codeVerifier,

    /// Azure AD authorization URL.
    String? authorizationUrl,

    /// Azure AD token URL.
    String? tokenUrl,

    /// Cache location used when authenticating with a web client.
    String? cacheLocation,

    /// Support for custom url parameters for dynamic UI support.
    String? customParameters,

    /// Where to redirect after logout.
    String? postLogoutRedirectUri,
  });

  /// Azure AD authorization URL.
  external String? get authorizationUrl;

  /// Azure AD token URL.
  external String? get tokenUrl;
}
