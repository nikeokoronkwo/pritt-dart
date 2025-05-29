import { relations } from "drizzle-orm/relations";
import {
  users,
  packages,
  packageContributors,
  packageVersions,
} from "./schema";

export const packagesRelations = relations(packages, ({ one, many }) => ({
  user: one(users, {
    fields: [packages.authorId],
    references: [users.id],
  }),
  packageContributors: many(packageContributors),
  packageVersions: many(packageVersions),
}));

export const usersRelations = relations(users, ({ many }) => ({
  packages: many(packages),
  packageContributors: many(packageContributors),
}));

export const packageContributorsRelations = relations(
  packageContributors,
  ({ one }) => ({
    package: one(packages, {
      fields: [packageContributors.packageId],
      references: [packages.id],
    }),
    user: one(users, {
      fields: [packageContributors.contributorId],
      references: [users.id],
    }),
  }),
);

export const packageVersionsRelations = relations(
  packageVersions,
  ({ one }) => ({
    package: one(packages, {
      fields: [packageVersions.packageId],
      references: [packages.id],
    }),
  }),
);
