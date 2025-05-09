# Pritt
Pritt is a simple, fast and powerful **multi-language registry** for code and packages in multiple languages.

- Multi-language - a new paradigm: No need to have all your packages in various places. With pritt you can now have all your packages seamlessly integrated in one place, with seamless compatibility with all your favourite programming language package managers.
- Simple yet Configurable: Publishing is as simple as a command. Can be configured to run commands before building, after installing, and more.
- Fast and Lightweight: Pritt is designed to be as light as possible, while still being able to scale well. Different parts can scale for different demands.

To learn more, check out the [docs](./docs). 

## Installing
Pritt can be installed as a docker image

## Building
In order to build pritt from source, and get a development version running your system, you will need to have 
- rust and cargo: for the API server
- Postgres: for the database
- Docker: to get the file storage running

## Deploying
Pritt has different deployment cases suited for different needs. For more information check out the [infra](./infra) directory.
