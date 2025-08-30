# The Pritt CLI

## Getting Started
You will need to have the registry up and running for most operations, as well as the web frontend

> While the web frontend is a WIP, it is usable for login via email for CLI login.

The CLI can be directly run via
```shell
dart bin/pritt.dart
```

To view help information and others, you can run:
```shell
dart bin/pritt.dart --help
```

To build the CLI, run:
```shell
dart compile exe bin/pritt.dart -o pritt
pritt --help # Test it out!

```

The Pritt CLI makes use of the API registry and web frontend. You can either configure the mapping of such names on `/etc/hosts` or override the default URLs via the `PRITT_API_URL` and `PRITT_URL` respectively

```shell
PRITT_API_URL=http://localhost:8080/ pritt login # Logs onto the instance at http://localhost:8080/
```

## CLI Usage
To get started using the CLI, you will need to log into the Pritt Instance
```shell
pritt login 
pritt login --url http://localhost:8080/ # Logs onto the instance at http://localhost:8080/
pritt login --url http://localhost:8080/ --client-url http://localhost:3000/ # Logs onto the instance at http://localhost:8080/ and uses the website at http://localhost:3000/ for authentication
```

By default, user configuration and instance details are stored on the user system to allow usage between sessions.

You can get info about the current user via `pritt info`.

### Installing Packages
Pritt currently does not have support for doing package management, and leaves such to the language tools to work with. For more on that, check the [documentation](/docs).


