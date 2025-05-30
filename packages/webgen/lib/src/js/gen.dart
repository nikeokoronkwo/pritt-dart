import 'dart:js_interop';

// Options
extension type AuthOptions._(JSObject _) implements JSObject {
  external AuthOptions(
      {String name,
      String title,
      bool magicLink,
      bool passkey,
      OAuthOptions oauth,
      bool admin,
      bool orgs,
      bool sso,
      bool oidc,
      bool twoFactorAuth});
  external String get name;
  external String get title;
  external bool get magicLink;
  external bool get passkey;
  external OAuthOptions get oauth;
  external bool get admin;
  external bool get orgs;
  external bool get sso;
  external bool get oidc;
  external bool get twoFactorAuth;
}

extension type OAuthOptions._(JSObject _) implements JSObject {
  external OAuthOptions(
      {bool github, bool google, JSArray<GenericOAuthOptions>? generic});
  external bool get github;
  external bool get google;
  external JSArray<GenericOAuthOptions>? get generic;
}

extension type GenericOAuthOptions._(JSObject _) implements JSObject {
  external GenericOAuthOptions({
    String providerId,
    String clientId,
    String clientSecret,
    String discoveryUrl,
  });
  external String get providerId;
  external String get clientId;
  external String get clientSecret;
  external String get discoveryUrl;
}

// return types
extension type CodeReturnType._(JSObject _) implements JSObject {
  external CodeReturnType({String filename, String code, String? name});
  external String get filename;
  external String get code;
  external String? get name;
}

@JS()
external JSArray<CodeReturnType> generateAuthConfig(AuthOptions options);
