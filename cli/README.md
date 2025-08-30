# The Pritt CLI

The Pritt Command Line Interface is one of the main ways to communicate with Pritt from your system (other than the web application).
It makes using pritt much easier, including for publishing packages, installing them into your projects, getting information about packages and pritt, and more.

## Installing The CLI

Check [cli/install.md](/docs/cli/install.md) for more information on installing pritt on multiple platforms

## Development

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

## CLI Usage

The pritt CLI comes with many useful commands for making use of pritt.
To get started using the CLI, you will need to log into the Pritt Instance

```shell
pritt login
pritt login --url http://localhost:8080/ # Logs onto the instance at http://localhost:8080/
pritt login --url http://localhost:8080/ --client-url http://localhost:3000/ # Logs onto the instance at http://localhost:8080/ and uses the website at http://localhost:3000/ for authentication
```

By default, user configuration and instance details are stored on the user system to allow usage between sessions.

You can get info about the current user via `pritt info`.

The Pritt CLI makes use of the API registry and web frontend.
You can either configure the mapping of such names on `/etc/hosts` or override the default URLs via the `PRITT_API_URL` and `PRITT_URL` respectively

```shell
PRITT_API_URL=http://localhost:8080/ pritt login # Logs onto the instance at http://localhost:8080/
```

### Installing Packages

Pritt currently does not have support for doing package management, and leaves such to the language tools to work with. For more on that, check the [documentation](/docs).

If you have a package that does not come with a package management tool, you can either leverage Pritt's API, or download them via `pritt unpack`.

```shell
pritt unpack pkg # Unpacks latest version of pkg in pritt
pritt unpack pkg@ver # Unpacks pkg at version ver
```

Only authorized users can publish given packages, which can be specified in the author and contributor fields of your `pritt.yaml` or project configuration file.

### Publishing Packages

Pritt publishes packages via the `pritt publish` command. This makes an initial request to the API and uploads the code

Pritt does well to respect files ignored by your VCS, as well as any files specified in a `.prittignore` located in the given directory.
Pritt is also able to parse configuration files, either directly or via some processing, through the use of client-side adapters.
The adapters deduce the type of your project based on the language configuration file at the root of the project, as well as other features.

> Client-Side adapters constitute the client part of Pritt adapters used mainly to help in publishing pritt packages.
> They are not required for working with a language if a `pritt.yaml` file is present with enough information.
>
> While builtin pritt develops these parts separately, when creating a custom adapter, you create them alongside server-side adapters (the main "adapters").

To publish a package, simply run the following at the root of the package:

```shell
pritt publish
```

If you haven't logged into pritt before, there will be a prompt to log into pritt from the command line.
If you are using a separate instance of pritt other than the main one at Pritt's website, this would not work, and you will need to log in before running `publish`, or override the api url.

Pritt usually associates a given package to a given language to help with configuration, package manager handling, and search in the Pritt Registry, which you can override such with the `-l` or `--language` flag.
This also means that in the presence of multiple configuration files there will be precedence. In order to specify a particular config file to use then use the `--project-config` flag

```shell
pritt publish --project-config jsr.json
```

> This does mean that pritt currently does not have support for multi-language projects, which should change as plans are made for development of such support. For more, you can check the following issue: [#56](https://github.com/nikeokoronkwo/pritt-dart/issues/56).

### Package Config

Pritt supports config for packages via a `pritt.yaml` file for most of its operations concerning local packages.

```bash
pritt publish -c pritt-alt.yaml # Publish given a pritt-alt.yaml
```

For more information, check the [`pritt.yaml` config reference](/docs/config.md).

---

For more of the commands that the Pritt CLI can do, you can run `pritt help`.
