import { StartedPostgreSqlContainer } from "@testcontainers/postgresql";
import { StartedTestContainer } from "testcontainers";


export {};

declare global {
  var postgresContainer: StartedPostgreSqlContainer
  var fileSystemContainer: StartedTestContainer
  var webContainer: StartedTestContainer
  var serverContainer: StartedTestContainer
}