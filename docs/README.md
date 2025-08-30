# Pritt Documentation

This is documentation on Pritt, how it works, and how to use it

## How does it work?

Pritt works on a simple but robust modular architecture that allows the service to easily add features, build upon itself, and scale easily to multiple workloads.

Pritt makes use of adapters, which are modular components that act as compatibility layers for different programming languages, package registry formats and package manager tools integrated with Pritt. They are designed for performance and easy connection with the Core Registry Service to serve packages and package metadata as needed by the package manager.

Pritt has built in support for the following languages:

- [x] Dart (pub)
- [x] Swift (swiftpm)
- [x] Go
- [ ] JavaScript/TypeScript (npm): Implemented but not thoroughly tested
- [ ] Generic
- [ ] Rust (cargo): See [#64](https://github.com/nikeokoronkwo/pritt-dart/issues/64)
- [ ] Java (maven)
- [ ] Python (pip)

Other languages and registry formats can be built through custom adapters.

> NOTE: Custom adapters is still a work in progress.

For now, only installing packages through Pritt is supported for the adapters. For publishing packages, you can check the ongoing issue here: [#55](https://github.com/nikeokoronkwo/pritt-dart/issues/55).

## How do I use it?

You can use Pritt much like any other external package registry for the language you're using.
Pritt can help with setting up certain things to help you get started straight away via `pritt configure`

For more information, see the section of the docs on [using Pritt](./adapters/working-with-packages.md).

## Packages

| Package                                       | Description                                                                                                     |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| [pritt_cli](../cli/)                          | The command-line interface to Pritt                                                                             |
| [pritt_adapter](../packages/adapter/)         |                                                                                                                 |
| [pritt_ai](../packages/ai/)                   |                                                                                                                 |
| [pritt_api](../packages/api/)                 |                                                                                                                 |
| [pritt_common](../packages/common/)           | A common package shared by the cli and the server containing the necessary types for both the client and server |
| [pritt_server_core](../packages/server_core/) |                                                                                                                 |
| [pritt_server](../server/)                    |                                                                                                                 |
