# The Pritt CLI

The Pritt Command Line Interface is one of the main ways to communicate with Pritt from your system (other than the web application).
It makes using pritt much easier, including for publishing packages, installing them into your projects, getting information about packages and pritt, and more.

## Installing

Check [cli/install.md](./cli/install.md) for more information on installing pritt on multiple platforms

## Using the CLI

The pritt cli comes with many useful commands for making use of pritt. To get started with pritt, it is suggested to log in to pritt.

```bash
pritt login
```

If you are logging into a separate or local instance of pritt, you will need to specify the url of this instance.

```bash
pritt login -u http://localhost:8080/
```

Given a package you may have developed, you can publish the package using the publish command at the root of the project directory

```bash
pritt publish
```

The pritt CLI deduces the type of your project based on the language configuration file at the root of the project, as well as other features.
This also means that in the presence of multiple configuration files it will take precedence. In order to specify a particular config file to use then use the `--project-config` flag

```bash
pritt publish --project-config jsr.json
```

Pritt also takes in a [`pritt.yaml` file](./cli/config.md) for configuring other information about the package, made use by pritt.

```bash
pritt publish -c pritt-alt.yaml
```

If you haven't logged into pritt before, there will be a prompt to log into pritt from the command line.
If you are using a separate instance of pritt other than the main one at Pritt's website, this would not work, and you will need to log in before running `publish`.

In order to install your newly published package into your project, you can run the install command.

```bash
pritt install locale # Assuming the name of your package is "locale"
```

This will first of all check the logged in pritt instance, if specified, before checking the main pritt registry. To specify a registry to install from use the "url" option

```bash
pritt install -u http://localhost:8080/ locale
```

> Pritt is a global registry, so it is possible for more than one package to have the same package name (e.g a package named "locale" for Go and JS) but they must be for different programming languages

Pritt will throw an error if the package cannot be found, or is not compatible for the given project (e.g installing a JS package for a Go project).

> INFO: There are plans for development of translators, which will allow one use a package in one language in another language.

To install a package for development (e.g to work on the project if authorized, or to check out the code for the given package), you can unpack the package into your directory.

```bash
pritt unpack locale
```

Only authorized users can publish given packages, which can be specified in the author and contributor fields of your `pritt.yaml` or project configuration file.

## More information

You can check for information on a specific command using the help flag

```bash
pritt --help
```

There is a useful man page on the pritt cli, which you can use to check for more info on all commands available, and how you can use them.

```bash
man pritt
```

You can also check the website for the full documentation.
