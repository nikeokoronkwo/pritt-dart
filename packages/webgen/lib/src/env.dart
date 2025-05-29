final defaultEnv = {
  'BETTER_AUTH_SECRET': '',
  'BETTER_AUTH_URL': '',
  'DATABASE_URL': ''
};

enum OAuthPlatforms {
  generic,
  google,
  github
}

Map<String, String> env(Map<String, String> envMap, {
  List<OAuthPlatforms> authPlatforms = const []
}) {
  final env = defaultEnv..addAll(envMap);
  for (final a in authPlatforms) {
    switch (a) {
      case OAuthPlatforms.github:
        env.putIfAbsent('GITHUB_CLIENT_ID', () => 'env:GITHUB_CLIENT_ID');
        env.putIfAbsent('GITHUB_CLIENT_SECRET', () => 'env:GITHUB_CLIENT_SECRET');
        break;
      case OAuthPlatforms.google:
        env.putIfAbsent('GOOGLE_CLIENT_ID', () => 'env:GOOGLE_CLIENT_ID');
        env.putIfAbsent('GOOGLE_CLIENT_SECRET', () => 'env:GOOGLE_CLIENT_SECRET');
        break;
      default:
    }
  }

  return env;
}