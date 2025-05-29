-- Current sql file was generated after introspecting the database
-- If you want to run this migration please uncomment this code before executing migrations
/*
CREATE TYPE "public"."plugin_archive_type" AS ENUM('single', 'multi');--> statement-breakpoint
CREATE TYPE "public"."privilege" AS ENUM('read', 'write', 'publish', 'ultimate');--> statement-breakpoint
CREATE TYPE "public"."version_control_system" AS ENUM('git', 'svn', 'fossil', 'mercurial', 'other');--> statement-breakpoint
CREATE TYPE "public"."version_kind" AS ENUM('major', 'experimental', 'beta', 'next', 'rc', 'canary', 'other');--> statement-breakpoint
CREATE TABLE "flyway_schema_history" (
	"installed_rank" integer PRIMARY KEY NOT NULL,
	"version" varchar(50),
	"description" varchar(200) NOT NULL,
	"type" varchar(20) NOT NULL,
	"script" varchar(1000) NOT NULL,
	"checksum" integer,
	"installed_by" varchar(100) NOT NULL,
	"installed_on" timestamp DEFAULT now() NOT NULL,
	"execution_time" integer NOT NULL,
	"success" boolean NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"email" text NOT NULL,
	"access_token" text NOT NULL,
	"access_token_expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "packages" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"version" text NOT NULL,
	"description" text,
	"author_id" text NOT NULL,
	"language" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"vcs" "version_control_system" DEFAULT 'git' NOT NULL,
	"archive" text NOT NULL,
	"license" text,
	CONSTRAINT "packages_name_key" UNIQUE("name"),
	CONSTRAINT "packages_version_key" UNIQUE("version")
);
--> statement-breakpoint
CREATE TABLE "package_contributors" (
	"package_id" text NOT NULL,
	"contributor_id" text NOT NULL,
	"privileges" "privilege"[] NOT NULL
);
--> statement-breakpoint
CREATE TABLE "plugins" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"language" text NOT NULL,
	"description" text,
	"archive" text NOT NULL,
	"archive_type" "plugin_archive_type" DEFAULT 'single' NOT NULL,
	CONSTRAINT "plugins_name_key" UNIQUE("name"),
	CONSTRAINT "plugins_language_key" UNIQUE("language")
);
--> statement-breakpoint
CREATE TABLE "package_versions" (
	"package_id" text NOT NULL,
	"version" text NOT NULL,
	"version_type" "version_kind" DEFAULT 'major' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"readme" text,
	"config" text,
	"config_name" text,
	"info" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"env" json DEFAULT '{}'::json NOT NULL,
	"metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"archive" text NOT NULL,
	"hash" text NOT NULL,
	"signatures" jsonb NOT NULL,
	"integrity" text NOT NULL,
	"deprecated" boolean DEFAULT false NOT NULL,
	"deprecated_message" text,
	"yanked" boolean DEFAULT false NOT NULL,
	CONSTRAINT "package_versions_pkey" PRIMARY KEY("package_id","version")
);
--> statement-breakpoint
ALTER TABLE "packages" ADD CONSTRAINT "packages_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "package_contributors" ADD CONSTRAINT "package_contributors_package_id_fkey" FOREIGN KEY ("package_id") REFERENCES "public"."packages"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "package_contributors" ADD CONSTRAINT "package_contributors_contributor_id_fkey" FOREIGN KEY ("contributor_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "package_versions" ADD CONSTRAINT "package_versions_package_id_fkey" FOREIGN KEY ("package_id") REFERENCES "public"."packages"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "flyway_schema_history_s_idx" ON "flyway_schema_history" USING btree ("success" bool_ops);
*/