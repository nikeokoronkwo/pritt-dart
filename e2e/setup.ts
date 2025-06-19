// setup.js

import { PostgreSqlContainer } from '@testcontainers/postgresql';
import { GenericContainer, PullPolicy } from 'testcontainers';
import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand, ListObjectsV2Command } from '@aws-sdk/client-s3';
import { Client } from 'pg';
import { setupPostgresContainer } from './utils/pg';

export async function setup() {
  globalThis.fileSystemContainer = await new GenericContainer(
    'quay.io/minio/minio',
  )
    .withEnvironment({
      MINIO_ROOT_USER: process.env.MINIO_USERNAME!,
      MINIO_ROOT_PASSWORD: process.env.MINIO_PASSWORD!
    })
    .withExposedPorts(9000, 9001)
    .start();

  // S3 bucket with credentials
  globalThis.fsInstance = new S3Client({
    endpoint: `http://${globalThis.fileSystemContainer.getHost()}:${globalThis.fileSystemContainer.getMappedPort(9000)}`,
    region: 'us-east-1',
    credentials: {
      accessKeyId: process.env.S3_ACCESS_KEY!,
      secretAccessKey: process.env.S3_SECRET_KEY!,
    },
    forcePathStyle: true,
  })

  globalThis.postgresContainer = await new PostgreSqlContainer(
    'postgres:17',
  )
  .withName(process.env.DATABASE_NAME!)
  .withUsername(process.env.DATABASE_USERNAME!)
  .withPassword(process.env.DATABASE_PASSWORD!)
  .withExposedPorts(parseInt(process.env.DATABASE_PORT!))
  .start();

  globalThis.dbInstance = new Client({
    connectionString: postgresContainer.getConnectionUri()
  })


  await setupPostgresContainer(globalThis.dbInstance);

  globalThis.serverContainer = await new GenericContainer('pritt-server')
    .withPullPolicy(PullPolicy.defaultPolicy())
    .withEnvironment({
      PORT: process.env.API_URL ? new URL(process.env.API_URL).port : '8080',
      DATABASE_NAME: process.env.DATABASE_NAME ?? globalThis.postgresContainer.getName(),
      DATABASE_USERNAME: process.env.DATABASE_USERNAME ?? globalThis.postgresContainer.getUsername(),
      DATABASE_PASSWORD: process.env.DATABASE_PASSWORD ?? globalThis.postgresContainer.getPassword(),
      DATABASE_PORT: process.env.DATABASE_PORT ?? globalThis.postgresContainer.getMappedPort(5432).toString(),
      DATABASE_HOST: process.env.DATABASE_HOST ?? globalThis.postgresContainer.getHost(),
      S3_SECRET_KEY: process.env.S3_SECRET_KEY!,
      S3_ACCESS_KEY: process.env.S3_ACCESS_KEY!,
      S3_URL: process.env.S3_URL!,
      PRITT_RUNNER_URL: process.env.PRITT_RUNNER_URL!,
    })
    .withExposedPorts(8080)
    .start();

  globalThis.webContainer = await new GenericContainer('pritt-web')
    .withPullPolicy(PullPolicy.defaultPolicy())
    .withEnvironment({
      NUXT_PUBLIC_API_URL: process.env.API_URL!,
      DATABASE_NAME: process.env.DATABASE_NAME ?? globalThis.postgresContainer.getName(),
      DATABASE_USERNAME: process.env.DATABASE_USERNAME ?? globalThis.postgresContainer.getUsername(),
      DATABASE_PASSWORD: process.env.DATABASE_PASSWORD ?? globalThis.postgresContainer.getPassword(),
      DATABASE_PORT: process.env.DATABASE_PORT ?? globalThis.postgresContainer.getMappedPort(5432).toString(),
      DATABASE_HOST: process.env.DATABASE_HOST ?? globalThis.postgresContainer.getHost(),
    })
    .withExposedPorts(3000)
    .start();

  console.log('Containers started successfully');
}

export async function teardown() {
  await globalThis.fileSystemContainer.stop();
  await globalThis.postgresContainer.stop();
  await globalThis.webContainer.stop();
  await globalThis.serverContainer.stop();
  await globalThis.dbInstance.end();
  globalThis.fsInstance.destroy();
}
