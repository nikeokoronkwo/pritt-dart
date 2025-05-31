import { relations } from "drizzle-orm/relations";
import { users, packages, organizations, authorizationSessions, organizationMembers, packageContributors, packageVersions } from "./schema";

export const packagesRelations = relations(packages, ({one, many}) => ({
	user: one(users, {
		fields: [packages.authorId],
		references: [users.id]
	}),
	organization: one(organizations, {
		fields: [packages.scope],
		references: [organizations.name]
	}),
	packageContributors: many(packageContributors),
	packageVersions: many(packageVersions),
}));

export const usersRelations = relations(users, ({many}) => ({
	packages: many(packages),
	authorizationSessions: many(authorizationSessions),
	organizationMembers: many(organizationMembers),
	packageContributors: many(packageContributors),
}));

export const organizationsRelations = relations(organizations, ({many}) => ({
	packages: many(packages),
	organizationMembers: many(organizationMembers),
}));

export const authorizationSessionsRelations = relations(authorizationSessions, ({one}) => ({
	user: one(users, {
		fields: [authorizationSessions.userId],
		references: [users.id]
	}),
}));

export const organizationMembersRelations = relations(organizationMembers, ({one}) => ({
	organization: one(organizations, {
		fields: [organizationMembers.organizationId],
		references: [organizations.id]
	}),
	user: one(users, {
		fields: [organizationMembers.userId],
		references: [users.id]
	}),
}));

export const packageContributorsRelations = relations(packageContributors, ({one}) => ({
	package: one(packages, {
		fields: [packageContributors.packageId],
		references: [packages.id]
	}),
	user: one(users, {
		fields: [packageContributors.contributorId],
		references: [users.id]
	}),
}));

export const packageVersionsRelations = relations(packageVersions, ({one}) => ({
	package: one(packages, {
		fields: [packageVersions.packageId],
		references: [packages.id]
	}),
}));