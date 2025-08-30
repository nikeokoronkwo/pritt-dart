/**
 * The collective test should work with both the CLI and Web and be able to complete a workflow
 * for
 */

import { test, expect, describe, beforeAll, afterAll } from 'vitest';
import { Client } from 'pg';
import {
  PostgreSqlContainer,
  StartedPostgreSqlContainer,
} from '@testcontainers/postgresql';
import { GenericContainer, StartedTestContainer } from 'testcontainers';
import { exec, spawn } from 'child_process';
import { promisify } from 'util';

describe('Collective E2E Testing', () => {
  beforeAll(async () => {});

  test('[WF]: Login Workflow', async () => {
    // get initial log in of CLI
    const cliProcess = spawn('pritt', ['login'], {
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    let stdout = '';
    let stderr = '';
    let resolved = false;

    // Helper to clean up
    function finish(err?: Error) {
      if (!resolved) {
        resolved = true;
        cliProcess.kill();
        if (err) throw err;
      }
    }

    // Listen for output and interact with CLI
    cliProcess.stdout.on('data', (data) => {
      const output = data.toString();
      stdout += output;
      // Example: respond to prompts
      if (output.includes('Username:')) {
        cliProcess.stdin.write('testuser\n');
      }
      if (output.includes('Password:')) {
        cliProcess.stdin.write('testpassword\n');
      }
      if (output.includes('Login successful')) {
        finish();
      }
    });

    cliProcess.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    // Timeout to avoid hanging
    const timeout = setTimeout(() => {
      finish(new Error('CLI process timed out'));
    }, 20000);

    await new Promise<void>((resolve, reject) => {
      cliProcess.on('close', (code) => {
        clearTimeout(timeout);
        if (!resolved) {
          resolved = true;
          if (code === 0) {
            resolve();
          } else {
            reject(
              new Error(
                `CLI process exited with code ${code}\nStderr: ${stderr}`,
              ),
            );
          }
        } else {
          resolve();
        }
      });
      cliProcess.on('error', (err) => {
        clearTimeout(timeout);
        finish(err);
        reject(err);
      });
    });

    // Process completed stdout will be available here for further assertions
    expect(stdout).toContain('Login successful');

    // Process completed stdout will be available here for further assertions
  });
  test.todo('[WF]: Login Workflow when logged in on browser already');
  test.todo('[WF]: Login Workflow with invalid credentials');
  test.todo('[WF]: Package Information Workflow');

  describe.todo('[WF]: Publish Workflow', () => {
    test.todo('Get Current Package Info');
    test.todo('Publish Package A');
    test.todo('Get Packages Published by User');
    test.todo('Get Package Info after Publishing A');
    test.todo('Install Package A into Package B');
    test.todo('Unpack Package A elsewhere');
    test.todo('Get Packages From Web');
    test.todo(
      'Validate Package Information from Web with published information',
    );
    test.todo('Validate Package Information from Web with CLI');
  });

  afterAll(async () => {});
});
