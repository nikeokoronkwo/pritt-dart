CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Prelim types
CREATE TYPE privilege AS ENUM ('read', 'write', 'publish', 'ultimate');
CREATE TYPE version_control_system AS ENUM ('git', 'svn', 'fossil', 'mercurial', 'other');

CREATE TYPE version_kind AS ENUM ('major', 'experimental', 'beta', 'next', 'rc', 'canary', 'other');
CREATE TYPE plugin_archive_type AS ENUM ('single', 'multi');

CREATE TYPE access_token_type AS ENUM ('device', 'personal', 'extended', 'pipeline');

CREATE TYPE task_status AS ENUM ('pending', 'success', 'fail', 'expired', 'error', 'idle', 'queue');

CREATE TYPE plugin_source_type AS ENUM ('hosted', 'vcs', 'local', 'other');

-- Validates Signatures passed to the `signature` field in the `package_versions` table
CREATE OR REPLACE FUNCTION validate_signatures()
RETURNS trigger AS $$
DECLARE
    item jsonb;
BEGIN
    -- Loop through each item in the array
    FOR item IN SELECT * FROM jsonb_array_elements(NEW.signatures)
    LOOP
        -- Check that all required keys exist and are of the right type
        IF NOT (
            item ? 'publicKeyId' AND
            jsonb_typeof(item->'publicKeyId') = 'string' AND
            item ? 'signature' AND
            jsonb_typeof(item->'signature') = 'string' AND
            item ? 'created' AND
            jsonb_typeof(item->'created') = 'string'  -- ISO8601, optionally check format
        ) THEN
            RAISE EXCEPTION 'Invalid signature format in JSON array: %', item;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- The actual types

CREATE TABLE users (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    avatar_url TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE organizations (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Join table for users and organizations
CREATE TABLE organization_members (
    organization_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    privileges privilege ARRAY NOT NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (organization_id) REFERENCES organizations (id),
    FOREIGN KEY (user_id) REFERENCES users (id),
    PRIMARY KEY (organization_id, user_id)
);

CREATE TABLE access_tokens (
    id UUID PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    hash TEXT UNIQUE NOT NULL,
    token_type access_token_type NOT NULL,
    description TEXT,
    device_id TEXT,
    expires_at TIMESTAMPTZ NOT NULL,
    last_used_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now(),
    device_info JSONB
);

CREATE TABLE packages (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    version TEXT UNIQUE NOT NULL,
    scoped BOOLEAN NOT NULL DEFAULT FALSE,
    description TEXT,
    author_id TEXT NOT NULL,
    scope TEXT,
    language TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    vcs version_control_system NOT NULL DEFAULT 'git',
    vcs_url TEXT,
    archive TEXT NOT NULL,
    license TEXT,
    CONSTRAINT valid_name CHECK (name ~ '^[a-zA-Z0-9][a-zA-Z0-9_.-]*$'),
    CONSTRAINT valid_scope CHECK (scope ~ '^[a-zA-Z0-9][a-zA-Z0-9_.-]*$'),
    CONSTRAINT scoped_means_scope CHECK (scoped = TRUE AND scope IS NOT NULL OR scoped = FALSE AND scope IS NULL),
    FOREIGN KEY (author_id) REFERENCES users (id),
    FOREIGN KEY (scope) REFERENCES organizations (name)
);

-- Ensure that the combination of name and scope is unique
-- This allows for scoped packages (e.g., @scope/package) and non-scoped packages (e.g., package)
ALTER TABLE packages
ADD CONSTRAINT unique_name_scope
UNIQUE (name, scope);

CREATE TABLE package_contributors (
    package_id TEXT NOT NULL,
    contributor_id TEXT NOT NULL,
    privileges privilege ARRAY NOT NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (package_id, contributor_id),
    FOREIGN KEY (package_id) REFERENCES packages (id),
    FOREIGN KEY (contributor_id) REFERENCES users (id)
);


CREATE TABLE package_versions (
    package_id TEXT NOT NULL,
    version TEXT NOT NULL,
    version_type version_kind NOT NULL DEFAULT 'major',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    readme TEXT,
    config TEXT,
    config_name TEXT,
    info JSONB NOT NULL DEFAULT '{}',
    env JSON NOT NULL DEFAULT '{}',
    metadata JSONB NOT NULL DEFAULT '{}',
    archive TEXT NOT NULL,
    hash TEXT NOT NULL,
    signatures JSONB NOT NULL,
    integrity TEXT NOT NULL,
    deprecated BOOLEAN NOT NULL DEFAULT FALSE,
    deprecated_message TEXT,
    yanked BOOLEAN NOT NULL DEFAULT FALSE,

    PRIMARY KEY (package_id, version),
    FOREIGN KEY (package_id) REFERENCES packages (id)
);

-- package_versions trigger upon update of signatures
CREATE TRIGGER validate_signatures_trigger
AFTER INSERT OR UPDATE OF signatures
ON package_versions
FOR EACH ROW
EXECUTE FUNCTION validate_signatures();

CREATE TABLE plugins (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT UNIQUE NOT NULL,
    "language" TEXT UNIQUE NOT NULL,
    description TEXT,
    archive TEXT NOT NULL,
    archive_type plugin_archive_type NOT NULL DEFAULT 'single',
    source_type plugin_source_type NOT NULL DEFAULT 'other',
    url TEXT,
    vcs version_control_system,
    -- TODO: More properties (author, ...)
    CONSTRAINT valid_name CHECK (name ~ '^[a-zA-Z0-9][a-zA-Z0-9_.-]*$'),
    CONSTRAINT url_source_type_check CHECK (source_type NOT IN ('vcs', 'hosted') OR url IS NOT NULL),
    CONSTRAINT vcs_source_type_check CHECK (source_type != 'vcs' OR vcs IS NOT NULL)
);

CREATE TABLE authorization_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    session_id TEXT UNIQUE NOT NULL,
    user_id TEXT,
    status task_status NOT NULL DEFAULT 'pending',
    authorized_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL,
    device_id TEXT NOT NULL,
    code VARCHAR UNIQUE NOT NULL,
    access_token TEXT,

    -- TODO: CRON to clean up
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
);

-- TODO: Use index
CREATE INDEX idx_login_sessions_expiry ON authorization_sessions (expires_at);

CREATE TABLE package_publishing_tasks (
    id UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4(),
    status task_status NOT NULL DEFAULT 'pending',
    user_id TEXT NOT NULL REFERENCES users (id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    scope TEXT,
    version TEXT NOT NULL,
    new BOOLEAN NOT NULL,
    language TEXT NOT NULL,
    config TEXT NOT NULL,
    config_map JSONB NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}',
    env JSON NOT NULL DEFAULT '{}',
    vcs version_control_system NOT NULL DEFAULT 'other',
    vcs_url TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL
);
