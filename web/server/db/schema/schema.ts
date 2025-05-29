import { pgTable, index, integer, varchar, timestamp, boolean, text, foreignKey, unique, primaryKey, jsonb, json, pgEnum } from "drizzle-orm/pg-core"
import { sql } from "drizzle-orm"

export const pluginArchiveType = pgEnum("plugin_archive_type", ['single', 'multi'])
export const privilege = pgEnum("privilege", ['read', 'write', 'publish', 'ultimate'])
export const versionControlSystem = pgEnum("version_control_system", ['git', 'svn', 'fossil', 'mercurial', 'other'])
export const versionKind = pgEnum("version_kind", ['major', 'experimental', 'beta', 'next', 'rc', 'canary', 'other'])


export const flywaySchemaHistory = pgTable("flyway_schema_history", {
	installedRank: integer("installed_rank").primaryKey().notNull(),
	version: varchar({ length: 50 }),
	description: varchar({ length: 200 }).notNull(),
	type: varchar({ length: 20 }).notNull(),
	script: varchar({ length: 1000 }).notNull(),
	checksum: integer(),
	installedBy: varchar("installed_by", { length: 100 }).notNull(),
	installedOn: timestamp("installed_on", { mode: 'string' }).defaultNow().notNull(),
	executionTime: integer("execution_time").notNull(),
	success: boolean().notNull(),
}, (table) => [
	index("flyway_schema_history_s_idx").using("btree", table.success.asc().nullsLast().op("bool_ops")),
]);

export const users = pgTable("users", {
	id: text().primaryKey().notNull(),
	name: text().notNull(),
	email: text().notNull(),
	accessToken: text("access_token").notNull(),
	accessTokenExpiresAt: timestamp("access_token_expires_at", { withTimezone: true, mode: 'string' }).notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
});

export const packages = pgTable("packages", {
	id: text().primaryKey().notNull(),
	name: text().notNull(),
	version: text().notNull(),
	description: text(),
	authorId: text("author_id").notNull(),
	language: text().notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	vcs: versionControlSystem().default('git').notNull(),
	archive: text().notNull(),
	license: text(),
}, (table) => [
	foreignKey({
			columns: [table.authorId],
			foreignColumns: [users.id],
			name: "packages_author_id_fkey"
		}),
	unique("packages_name_key").on(table.name),
	unique("packages_version_key").on(table.version),
]);

export const packageContributors = pgTable("package_contributors", {
	packageId: text("package_id").notNull(),
	contributorId: text("contributor_id").notNull(),
	privileges: privilege().array().notNull(),
}, (table) => [
	foreignKey({
			columns: [table.packageId],
			foreignColumns: [packages.id],
			name: "package_contributors_package_id_fkey"
		}),
	foreignKey({
			columns: [table.contributorId],
			foreignColumns: [users.id],
			name: "package_contributors_contributor_id_fkey"
		}),
]);

export const plugins = pgTable("plugins", {
	id: text().primaryKey().notNull(),
	name: text().notNull(),
	language: text().notNull(),
	description: text(),
	archive: text().notNull(),
	archiveType: pluginArchiveType("archive_type").default('single').notNull(),
}, (table) => [
	unique("plugins_name_key").on(table.name),
	unique("plugins_language_key").on(table.language),
]);

export const packageVersions = pgTable("package_versions", {
	packageId: text("package_id").notNull(),
	version: text().notNull(),
	versionType: versionKind("version_type").default('major').notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	readme: text(),
	config: text(),
	configName: text("config_name"),
	info: jsonb().default({}).notNull(),
	env: json().default({}).notNull(),
	metadata: jsonb().default({}).notNull(),
	archive: text().notNull(),
	hash: text().notNull(),
	signatures: jsonb().notNull(),
	integrity: text().notNull(),
	deprecated: boolean().default(false).notNull(),
	deprecatedMessage: text("deprecated_message"),
	yanked: boolean().default(false).notNull(),
}, (table) => [
	foreignKey({
			columns: [table.packageId],
			foreignColumns: [packages.id],
			name: "package_versions_package_id_fkey"
		}),
	primaryKey({ columns: [table.packageId, table.version], name: "package_versions_pkey"}),
]);
