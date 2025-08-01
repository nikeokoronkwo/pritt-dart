# Pritt Documentation

This is documentation on Pritt

## How does it work?

Pritt works on a simple but robust modular architecture that allows the service to easily add features, build upon itself, and scale easily to multiple workloads.

Pritt makes use of adapters, which are modular components that act as compatibility layers for different programming languages and package managers integrated with Pritt. They are designed for performance and easy connection with the Core Registry Service to serve packages and package metadata as needed by the package manager.

An adapter registry is [in plans of development](#5), and contributions, especially concerning its architecture, are welcome.

## development

| Package                                    | Description                                                                                                     | Version                                                                                                |
|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| [pritt_cli](cli/)                          | The command-line interface to Pritt                                                                             | [![pub package](https://img.shields.io/pub/v/pritt_cli.svg)](https://pub.dev/packages/pritt_cli)       |
| [pritt_adapter](packages/adapter/)         |                                                                                                                 |                                                                                                        |
| [pritt_ai](packages/ai/)                   |                                                                                                                 |                                                                                                        |
| [pritt_api](packages/api/)                 |                                                                                                                 |                                                                                                        |
| [pritt_common](packages/common/)           | A common package shared by the cli and the server containing the necessary types for both the client and server | [![pub package](https://img.shields.io/pub/v/pritt_common.svg)](https://pub.dev/packages/pritt_common) |
| [pritt_server_core](packages/server_core/) |                                                                                                                 |                                                                                                        |
| [pritt_server](server/)                    |                                                                                                                 |                       