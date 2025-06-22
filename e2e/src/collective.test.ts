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

describe.todo('Collective E2E Testing', () => {
  beforeAll(async () => {});

  test.todo('[WF]: Login Workflow');
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
