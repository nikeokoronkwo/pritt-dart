/**
 * The collective test should work with both the CLI and Web and be able to complete a workflow
 * for 
 */

import { test, expect, describe, beforeAll, afterAll } from "vitest"
import { Client } from "pg";
import { PostgreSqlContainer, StartedPostgreSqlContainer } from "@testcontainers/postgresql"
import { GenericContainer, StartedTestContainer } from "testcontainers"

describe.todo('Collective E2E Testing', () => {

  let dbService;

  beforeAll(async () => {
    
  });

  afterAll(async () => {
    await postgresContainer.stop();
    await webContainer.stop();
  });
});