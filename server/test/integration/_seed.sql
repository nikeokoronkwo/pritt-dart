-- Enable uuid extension if needed (already in your schema)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users
INSERT INTO users (id, name, email, access_token, access_token_expires_at)
VALUES 
  ('user-1', 'Alice Smith', 'alice@example.com', 'token_alice', now() + interval '30 days'),
  ('user-2', 'Bob Johnson', 'bob@example.com', 'token_bob', now() + interval '30 days');

-- Packages
INSERT INTO packages (id, name, version, author_id, language, archive)
VALUES
  ('pkg-1', 'math-utils', '1.0.0', 'user-1', 'python', 'math-utils-1.0.0.tar.gz'),
  ('pkg-3', 'math-core', '1.0.1', 'user-1', 'python', 'math-core-1.0.1.tar.gz'),
  ('pkg-2', 'web-core', '0.9.1', 'user-2', 'typescript', 'web-core-0.9.1.tar.gz');

-- Package Versions
INSERT INTO package_versions (
  package_id, version, version_type, readme, config, config_name, info, env, metadata,
  archive, hash, signatures, integrity, deprecated, yanked
) VALUES
  (
    'pkg-1',
    '1.0.0',
    'major',
    'Math utilities for number crunching.',
    '{"setting": "value"}',
    'config.yml',
    '{"description": "Initial release"}',
    '{"NODE_ENV": "production"}',
    '{"tags": ["math", "utils"]}',
    'math-utils-1.0.0.tar.gz',
    'abc123hash',
    '[{
      "publicKeyId": "alice-key-1",
      "signature": "abcd1234sig",
      "created": "2025-01-01T00:00:00Z"
    }]'::jsonb,
    'sha256-xyz123',
    FALSE,
    FALSE
  ),
  (
    'pkg-2',
    '0.9.1',
    'beta',
    'Web core for frontend scaffolding.',
    '{"featureFlags": true}',
    'web.config.json',
    '{"description": "Beta version"}',
    '{"API_URL": "https://api.example.com"}',
    '{"tags": ["web", "frontend"]}',
    'web-core-0.9.1.tar.gz',
    'def456hash',
    '[{
      "publicKeyId": "bob-key-2",
      "signature": "efgh5678sig",
      "created": "2025-02-01T00:00:00Z"
    }]'::jsonb,
    'sha256-xyz456',
    FALSE,
    FALSE
  );

-- Package Contributors
INSERT INTO package_contributors (package_id, contributor_id, privileges)
VALUES
  ('pkg-1', 'user-1', ARRAY['read', 'write', 'publish']::privilege[]),
  ('pkg-1', 'user-2', ARRAY['read']::privilege[]),
  ('pkg-2', 'user-2', ARRAY['ultimate']::privilege[]);

