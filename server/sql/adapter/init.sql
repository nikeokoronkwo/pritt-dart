CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Prelim types
CREATE TYPE IF NOT EXISTS privileges AS ENUM ('read', 'write', 'publish', 'ultimate');


CREATE TABLE users (
    id UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    -- TODO: Should we use a hash instead?
    access_token TEXT NOT NULL,
    access_token_expires_at TIMESTAMPTZ NOT NULL,
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE packages (
    
);

CREATE TABLE package_versions (

);

CREATE TABLE package_contributors (
    package 
);


