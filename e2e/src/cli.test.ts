/**
 *
 * The E2E for CLI Testing should:
 * - invoke the pritt cli from cli/ in the current working directory
 * - run a suite of necessary commands
 *
 * 1. Basic help
 * 2. Login Workflow
 * 3. Publishing Workflow (logged out)
 * 4. Publishing Workflow (logged in)
 */

import { test, expect, describe, assert } from 'vitest';
import { invokeCLI } from '../utils/cli';
import { join } from 'node:path';
import { readFile } from 'node:fs/promises';
import { parse, stringify } from '@std/yaml';

function assertHelpDescription(text: string, global: boolean = false) {
  const lines = text.split('\n');
  assert(
    lines.find((l) => l.includes('Usage:')) !== undefined,
    'Should contain usage description',
  );
  assert(
    lines.find((l) => l.includes('-h, --help')) !== undefined,
    'Should contain help option',
  );

  if (global)
    assert(
      lines.find((l) => l.includes('Global options:')) !== undefined,
      'Global help should have options',
    );
  if (global)
    assert(
      lines.find((l) => l.includes('Available commands:')) !== undefined,
      'Global help should have command overview',
    );
}

describe('Command-Line E2E Testing', async () => {
  test.concurrent('[CALL <empty>]: should return help text complete', () => {
    const baseCall = invokeCLI([]);

    expect(baseCall.code).eq(0);
    expect(baseCall.stderr).string('');

    assertHelpDescription(baseCall.stdout, true);
  });

  test.concurrent('[CALL --help]: should return help text complete', () => {
    const baseCall = invokeCLI(['--help']);

    expect(baseCall.code).eq(0);
    expect(baseCall.stderr).string('');

    assertHelpDescription(baseCall.stdout, true);
  });

  test.concurrent('[CALL help]: should return help text complete', () => {
    const baseCall = invokeCLI(['help']);

    expect(baseCall.code).eq(0);
    expect(baseCall.stderr).string('');

    assertHelpDescription(baseCall.stdout, true);
  });

  test(
    "[CALL <empty>,'--help','help']: Equal output",
    { timeout: 10000 },
    () => {
      const baseCall = invokeCLI([]);
      const helpCall = invokeCLI(['--help']);
      const helpCommandCall = invokeCLI(['help']);

      expect(baseCall.stdout).eq(helpCall.stdout);
      expect(baseCall.stdout).eq(helpCommandCall.stdout);
      expect(helpCommandCall.stdout).eq(helpCall.stdout);
    },
  );

  describe('[WF]: Publish Workflow', () => {
    const dir = 'pkgs';
    const pkgA = 'dart-a';
    const pkgAName = 'a';
    const pkgB = 'dart-b';
    const pkgBName = 'b';
    const pkgAPath = join(dir, pkgA);

    test.skip('Get Current Package Info', async () => {
      const baseCall = invokeCLI([
        'package',
        'current',
        'pkgs/dart-a',
        '--json',
        'stdout',
      ]);

      expect(baseCall.code).eq(0);
      expect(baseCall.stderr).string('');

      const info = JSON.parse(baseCall.stdout);
      const pkgPubspec: Record<string, any> = parse(
        await readFile(join(pkgAPath, 'pubspec.yaml'), 'utf8'),
      ) as Record<string, any>;

      expect(info).toBeDefined();
      expect(info.name).toBe(pkgPubspec.name);
      expect(info.version).toBe(pkgPubspec.version);
      expect(info.description).toBe(pkgPubspec.description);
      expect(info.published).toBe(false);
    });

    test('Publish Package A', () => {
      const baseCall = invokeCLI([
        'package',
        'publish',
        pkgAPath,
        '--url',
        `${globalThis.serverContainer.getHost()}:${globalThis.serverContainer.getMappedPort(8080)}`,
        '--client-url',
        `${globalThis.webContainer.getHost()}:${globalThis.webContainer.getMappedPort(3000)}`,
      ]);

      expect(baseCall.code).eq(0);
    });

    test.todo('Get Packages Published by User');
    test.todo('Get Package Info after Publishing A');
    test.todo('Install Package A into Package B');
    test.todo('Unpack Package A elsewhere');
  });

  describe.todo('[WF]: Login Workflow', () => {
    test.todo('Login to Pritt');
    test.todo('Get Current User information');
    test.todo('Get Information about Packages');
    test.todo('Get Information about Adapters');
  });
});
