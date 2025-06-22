import { test } from 'vitest';
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import {
  generateAuthConfig,
  mlc,
  nodeMailerCode,
} from '../lib/src/js/gen/auth';

const specDir = './test/specs';

test('', async () => {
  console.log(
    generateAuthConfig({
      name: 'test',
      title: 'Test Site',
      magicLink: true,
      passkey: true,
      oauth: {
        github: true,
        google: true,
      },
      admin: true,
      orgs: true,
      oidc: false,
      sso: false,
      twoFactorAuth: false,
    }),
  );

  console.log(nodeMailerCode);
});
