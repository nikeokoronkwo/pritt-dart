import { S3Client } from '@aws-sdk/client-s3';
import { StartedPostgreSqlContainer } from '@testcontainers/postgresql';
import { StartedTestContainer } from 'testcontainers';
import { Client } from 'pg';

export {};

declare global {
  var postgresContainer: StartedPostgreSqlContainer;
  var fileSystemContainer: StartedTestContainer;
  var webContainer: StartedTestContainer;
  var serverContainer: StartedTestContainer;

  var fsInstance: S3Client;
  var dbInstance: Client;
}
