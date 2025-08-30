# The Pritt Configuration File

Pritt packages can be configured using a `pritt.yaml` file. This is useful for:

- clarifying things like package names (scoped or unscoped): A package registry format may not support direct scoping/unscoping, and it may be useful to specify correctly.
- adding indexes for contributors, for instance.

Most of the options are optional if a project configuration file is present, which can suffice if possible. If not, then the options from the given file will be required.
Given both files, the `pritt.yaml` file will take precedence.

## Schema

- `name`: The name of the package (either as `pkg` or `@scope/pkg`)
- `version`: The current version of the package, as a [semver version](https://semver.org)
- `private`: Whether this package is private or not.
- `contributors`: Either specify a list of contributors by name or create an `AUTHORS` file at the root of the project

## Example Config

```yaml
name: pritt # The name of the given package
homepage: pritt.dev # The homepage of the given package (optional)
url: https://github.com/nikeokoronkwo/pritt # The url where the source code of the package is hosted (optional)
author: nikeokoronkwo # specify the username of the author of the given package (optional - inferred from logged in user)

# specify contributors for the project. They have the ability to unpack packages from the registry and then
contributors:
  - Brigght
```

## Some Notes

1. You cannot change publicity of a package in future versions unless you explicitly set it to `false` in the site.
