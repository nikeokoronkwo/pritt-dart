# Adapters

Adapters are at the core of Pritt and are used for making pritt compatible with multiple programming environments

Adapters are used as a compatibility layer between package managers and pritt.

When a package manager requests a package from pritt, it hits an adapter endpoint which is used to handle the package request . Depending on what package manager makes the request, the desired adapter is selected and used to handle the given request. By nature pritt can handle multiple requests, and so this means that multiple adapters can be spawned at once for handling multiple projects.

Adapters are present for all supported programming languages for Pritt.

## Custom Adapters

Custom adapters can be used to integrate either custom package managers or package managers for languages not directly supported on Pritt.

<!-- (Future iterations will allow overriding abilities) -->

Custom adapters are stored on the **adapter registry**, which is a registry that stores information about the adapters and makes them accessible to Pritt. The adapter registry can spawn multiple adapters from the registry, maintaining the core features of adapters.

The server contains endpoints for adding such adapters, which are directly interfaced by the command-line interface.

## Adapter API

<!-- There is an API for creating adapters using Python. Check out the [`pritt_adapter` python package](../api/adapter) for more information. -->
