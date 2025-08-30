# Pritt

Pritt is a simple, lightweight, and powerful package registry!

It works on an adapter technology, allowing for composability and support for multiple registry formats contained in a single server, with support for your own custom package management tools.

> NOTE: This is an experimental project. Use with caution. If you encounter any bugs or issues running the service, you can make an issue for it and I'd be happy to help you work it out.

## Requirements

Pritt requires the following services to successfully run:

- Dart (3.8 or above)
- PostgreSQL: Database layer
- Any S3 Compatible Bucket Service: Storage layer

If you are working on pritt alongside support for custom adapters, you will also need to have the [pritt custom adapter runner](https://github.com/nikeokoronkwo/pritt-runner) up and running.

If you are working on pritt alongside the web frontend, you will need `node` installed on your machine to start the web frontend.

> NOTE: The custom adapter runner and the web frontend are still a work-in-progress. Web frontend development usually happens internally, but you can check the custom adapter runner project for more on that.

## Getting Started

In order to get pritt, you will need to clone this workspace, and get the dependencies

```bash
git clone https://github.com/nikeokoronkwo/pritt-dart.git
cd pritt-dart
dart pub get # Get Dart dependencies
pnpm i # Get PNPM dependencies
```

## Using Pritt

For documentation on how pritt works, and using it as a package registry, see the [docs](/docs).

For documentation on developing with pritt, continue.

### Starting a Development Service

You can make use of the `docker-compose.yml` at the root of the project to quickly get started with a dockerized development version of the service.

#### Manual Setup

Make sure the required services (postgres, an S3 compatible bucket, optionally the runner if possible)

Set up your `.env` with the following:

```env
# Runner
PRITT_RUNNER_URL=<runner-url>

# S3 Details
S3_SECRET_KEY=<secret-key>
S3_ACCESS_KEY=<access-key>
S3_URL=<s3-url>
# Optional: Region
S3_REGION=<s3-region>

# You can either set the DB details separately
DATABASE_NAME=
DATABASE_USERNAME=
DATABASE_PASSWORD=
DATABASE_HOST=
DATABASE_PORT=
# ...or pass the url
DATABASE_URL=<db-url>
```

Before getting `pritt` running, push the migrations available at `./server/sql`.

Run the development server at:

```bash
pnpm server
```

You can also pass these variables as env vars and run the dart bin entrypoint directly, however, the `tool/denv.dart` script does this for you.

By default, it runs the default server **with custom adapter support enabled** in a single port. The pritt server has support for other modes, including multi-server mode, registry proxy support, etc. For more information, you can check the help command at the server entrypoint

```bash
cd server
dart bin/server.dart --help # Show help information
```

### Starting the Frontend Service

The frontend service will need to be built before you can get started.

To build the frontend website:

```bash
cd web
pnpm gen:web
```

This adds any necessary CSS, completes templates, and populates the other contents of the website, with output at `web-ref`.

Before starting the website, ensure that all necessary services are up and functional. The registry (api) endpoint and the db endpoint are needed, so you may need to populate the `.env` file of `web-ref`:

```env
DATABASE_URL=<db-url>
NUXT_PUBLIC_API_URL=<registry-api-url>
```

You can then run the web app generated at `web-ref`:

```bash
cd web-ref
pnpm i
pnpm db:push # link db updates like auth tables to the database
pnpm dev
```

The web generator uses a [template file](/web/template.yaml) to configure options for generating the website, depending on features needed for it (like OAuth, Passkey, SAML, theming, etc). The website generator can be found at [`tool/webgen`](/tool/openapigen).

### Schema Development

The schema for Pritt is developed using [Apple Pkl](https://pkl-lang.org). You will need it if you want to work with the schema, or generate the OpenAPI document associated with it.
In order to get the OpenAPI document, run

```bash
pkl eval config/main.pkl --project-dir config -f yaml -o config/out/openapi.yaml # YAML
pkl eval config/main.pkl --project-dir config -f json -o config/out/openapi.json # JSON
```

> In the future, pending development at [the pkl community repo](https://github.com/pkl-community/pkl-dart/), integration of Pkl into Dart may eventually follow, but such is still in thoughts.

The common pritt package contains definitions for the client used by the CLI, as well as types for the API used by both the CLI and the API service. These definitions and types are generated from the OpenAPI document rendered by `pkl`.

To regenerate these types, run:

```bash
pnpm gen:common
```

You may encounter errors on the initial runs of `dart run build_runner build --delete-conflicting-outputs`. In such case, you can run that again at the root of the project.

The generator package lives at [`tool/openapigen`](/tool/openapigen). The main script is compiled to JS and linked with the main JS file containing the JS dependencies needed for generating the code.

> NOTE: Plans are to be made to migrate the openapi generator to a separate repository for development. It would be better maintained there, and allow for complete development and support for other use-cases, including possibly a Dart-only API (removing the dependency on JS subsequently).

### CI

CI is (partly) managed using [`mono_repo`](https://github.com/google/mono_repo.dart).
To regenerate the CI made/managed by `mono_repo` for the Dart packages, get `mono_repo` installed and run:

```bash
mono_repo generate
```

### Deployment

Pritt is deployed via Terraform, to allow for easily configurable deployments for different needs, purposes, and features.
Development is ongoing on terraform integration, and you can check the progress on the [Terraform IaC PR](https://github.com/nikeokoronkwo/pritt-dart/pull/61).

## CLI

Pritt also has a CLI tool for working with Pritt via the command-line. The CLI is contained at [`/cli`](/cli).
Run the CLI via:

```bash
pnpm cli <args>
```

Build the CLI via:

```
dart compile exe cli/bin/pritt.dart -o pritt
```

In order to begin using pritt, you will need to log into Pritt:

```bash
pritt login
```

You can set the registry URL, as well as the registry web URL via the `PRITT_API_URL` and `PRITT_URL` environment variables respectively

```bash
PRITT_API_URL=http://localhost:8080/ pritt login
```

For more information on the cli, see the [README at `/cli`](/cli/README.md).
