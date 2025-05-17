CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Prelim types
CREATE TYPE privilege AS ENUM ('read', 'write', 'publish', 'ultimate');
CREATE TYPE version_control_system AS ENUM ('git', 'svn', 'fossil', 'mercurial', 'other');

CREATE TYPE version_kind AS ENUM ('major', 'experimental', 'beta', 'next', 'rc', 'canary', 'other');

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
    -- TODO: Should we use a hash instead?
    access_token TEXT NOT NULL,
    access_token_expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE packages (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT UNIQUE NOT NULL,
    version TEXT UNIQUE NOT NULL,
    description TEXT,
    author_id TEXT NOT NULL,
    language TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    vcs version_control_system NOT NULL DEFAULT 'git',
    archive TEXT NOT NULL,
    FOREIGN KEY (author_id) REFERENCES users (id)
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


CREATE TABLE package_contributors (
    package_id TEXT NOT NULL,
    contributor_id TEXT NOT NULL,
    privileges privilege ARRAY NOT NULL,
    FOREIGN KEY (package_id) REFERENCES packages (id),
    FOREIGN KEY (contributor_id) REFERENCES users (id)
);


CREATE TABLE package_publishing_tasks (
    
);
