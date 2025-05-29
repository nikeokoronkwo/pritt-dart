import { test } from "vitest";
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { generateAuthConfig } from "../lib/src/js/gen/auth";

const specDir = "./test/specs";

test("", async () => {
  generateAuthConfig({
    name: 'test',
    title: 'Test Site',
      magicLink: true,
      passkey: true,
      oauth: {
        github: true,
        google: true
      },
      admin: true,
      orgs: true,
      oidc: false,
      sso: false,
      twoFactorAuth: false
  });
});
