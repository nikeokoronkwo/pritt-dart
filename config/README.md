# Pritt Schema

This is the [apple pkl](https://pkl-lang.org/) schemas used for the development of the Pritt OpenAPI spec and Schemas shared across the [server](./server), [cli](./cli) and web interfaces.

## Development

> NOTE: Make sure to read the following guidelines and work with the schema code based on the following conventions, as the scripts work based on these conventions.

The key files here are the following:

1. `main.pkl`: This is the entrypoint for the OpenAPI specification. This file is evaluated to produce the OpenAPI spec for the server in YAML or JSON
2. `src/`: This folder contains all the major types for both the OpenAPI specification and the types used in the CLI. They specify schemas/models for both implementations and also have example implementations of the modules for the OpenAPI spec and testing.
   To make a new schema module, create a file with the format `src/<name>/schema.pkl`, and define it as a module. Other implementations (e.g for a 200 OK response or 404 Bad response) are placed in the folder (e.g `src/<name>/200.pkl`).
3. `lib/`: This folder contains utilities like functions and classes used/shared in modules. These should all include an `@go.Package` header with the name being `"github.com/pritt/cli/utils"`, which helps combine all library classes and functions into a single folder in the CLI.
4. `utils/generator-tools.pkl`: This file is used by [`pkl-go-gen`](https://pkl-lang.org/go/current/codegen.html).

### Dependencies

In order to generate the Pritt OpenAPI JSON/YAML, as well as the type bindings for the CLI, you will need to have [pkl](https://pkl-lang.org/) installed, as well as have your environment [set up for pkl and go](https://pkl-lang.org/go/current/codegen.html).

In order to generate the OpenAPI implementations for the Server (Rust) and Web (TypeScript), you will need the [OpenAPI Generator CLI](https://openapi-generator.tech/) installed as well. The current project makes use of the generator CLI via the NPM package wrapper, so only the dependencies to the generator cli (JVM) are required. If it doesn't find the JVM installed, it will fallback to looking for the generator cli itself on the host system.

### Setting Up

There are a few dependencies needed for working on this. To check if they are installed, you can run the following command

```bash
deno task schema --no-go-gen --no-openapi
```

In order to generate the schemas, you can run the following command

```bash
deno task schema
deno task schema --no-go-gen # Do not generate CLI types
deno task schema --no-openapi # Do not generate OpenAPI spec and Libraries
```

### Contributing

All contributions concerning APIs and other configurations should be made to the pkl files defined in the `schema/` directory only, as any other files and code are auto-generated.
