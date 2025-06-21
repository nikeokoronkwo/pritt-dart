// setup.js

import { PostgreSqlContainer } from '@testcontainers/postgresql';
import { GenericContainer, PullPolicy } from 'testcontainers';
import { S3Client } from '@aws-sdk/client-s3';
import { Client } from 'pg';
import { setupPostgresContainer } from './utils/pg';
import { afterAll, beforeAll } from 'vitest';
import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';

beforeAll(async () => {
  console.log(
    Object.keys(process.env).filter(e => e.startsWith('DATABASE')), 
    import.meta.env, process.cwd(), import.meta.url);
  try {
    globalThis.fileSystemContainer = await new GenericContainer(
      'quay.io/minio/minio',
    )
      .withEnvironment({
        MINIO_ROOT_USER: process.env.MINIO_USERNAME!,
        MINIO_ROOT_PASSWORD: process.env.MINIO_PASSWORD!
      })
      .withExposedPorts(9000, 9001)
      .withCommand(['server', '/data', '--console-address', ':9001'])
      .withReuse()
      .start();

    console.log('File system container started successfully');

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

    console.log('S3 client initialized successfully');

    // globalThis.postgresContainer = await new PostgreSqlContainer(
    //   'postgres:17',
    // )
    // .withDatabase(process.env.DATABASE_NAME!)
    // .withUsername(process.env.DATABASE_USERNAME!)
    // .withPassword(process.env.DATABASE_PASSWORD!)
    // .withExposedPorts(parseInt(process.env.DATABASE_PORT!))
    // .start();

    // console.log('PostgreSQL container started successfully');

    // globalThis.dbInstance = new Client({
    //   connectionString: postgresContainer.getConnectionUri()
    // })

    // await setupPostgresContainer(globalThis.dbInstance);

    // console.log('PostgreSQL client initialized successfully');

    // const serverDockerContainer = await GenericContainer.fromDockerfile('..', 'server/Dockerfile')
    //   .withPullPolicy(PullPolicy.defaultPolicy())
    //   .build();

    // console.log('Server Docker container built successfully');

    // globalThis.serverContainer = await serverDockerContainer
    //   .withEnvironment({
    //     PORT: process.env.API_URL ? new URL(process.env.API_URL).port : '8080',
    //     DATABASE_NAME: process.env.DATABASE_NAME ?? globalThis.postgresContainer.getName(),
    //     DATABASE_USERNAME: process.env.DATABASE_USERNAME ?? globalThis.postgresContainer.getUsername(),
    //     DATABASE_PASSWORD: process.env.DATABASE_PASSWORD ?? globalThis.postgresContainer.getPassword(),
    //     DATABASE_PORT: process.env.DATABASE_PORT ?? globalThis.postgresContainer.getMappedPort(5432).toString(),
    //     DATABASE_HOST: process.env.DATABASE_HOST ?? globalThis.postgresContainer.getHost(),
    //     S3_SECRET_KEY: process.env.S3_SECRET_KEY!,
    //     S3_ACCESS_KEY: process.env.S3_ACCESS_KEY!,
    //     S3_URL: process.env.S3_URL!,
    //     PRITT_RUNNER_URL: process.env.PRITT_RUNNER_URL!,
    //   })
    //   .withExposedPorts(8080)
    //   .withReuse()
    //   .start();

    // console.log('Server container started successfully');

    // set up web
    if (!existsSync('../web-ref')) spawnSync('pnpm', ['gen:web'], {
      cwd: '..',
      encoding: 'utf8',
    });

    const webDockerContainer = await GenericContainer.fromDockerfile('../web-ref')
      .withPullPolicy(PullPolicy.defaultPolicy())
      .withCache(true)
      .build();

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
      .withReuse()
      .start();

    console.log('Web container started successfully');

    console.log('Containers started successfully');
  } catch (err) {
    console.error('Error during container setup:', err);
    // Try to print logs for each container if available
    const containers = [
      globalThis.fileSystemContainer,
      globalThis.postgresContainer,
      globalThis.serverContainer,
      globalThis.webContainer
    ];
    for (const c of containers) {
      if (c && typeof c.logs === 'function') {
        try {
          const logs = await c.logs();
          console.error(`Logs for container ${c.getName ? c.getName() : ''}:\n`, logs);
        } catch (logErr) {
          console.error('Could not fetch logs for a container:', logErr);
        }
      }
    }
    throw err;
  }
}, 100000);

afterAll(async () => {
  await globalThis.fileSystemContainer.stop();
  await globalThis.postgresContainer.stop();
  await globalThis.webContainer.stop();
  await globalThis.serverContainer.stop();
  await globalThis.dbInstance.end();
  globalThis.fsInstance.destroy();
});