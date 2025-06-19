// setup.js

import { PostgreSqlContainer } from "@testcontainers/postgresql";
import { GenericContainer, StartedTestContainer } from "testcontainers";



export async function setup() {
  globalThis.fileSystemContainer = await new GenericContainer("quay.io/minio/minio")
    .withExposedPorts(9000, 9001)
    .start();
  
  globalThis.postgresContainer = await new PostgreSqlContainer("postgres:17")
  .start();
  globalThis.webContainer = await new GenericContainer("")
        .withEnvironment({})
        .withExposedPorts(3000)
        .start()

  globalThis.serverContainer = await new GenericContainer("")
    .withEnvironment({})
    .withExposedPorts(8080)
    .start()

}

export async function teardown() {
  await globalThis.fileSystemContainer.stop();
  await globalThis.postgresContainer.stop();
  await globalThis.webContainer.stop();
  await globalThis.serverContainer.stop();
}
