# Pritt Configuration
Package information can be configured using the `pritt.yaml` configuration file in the root of the desired project's directory.

Most of the options are optional if a project configuration file is present, which can suffice if possible. If not, then the options from the given file will be required. 
Given both files, the `pritt.yaml` file will take precedence.

## Example Config
```yaml
name: pritt # The name of the given package
homepage: pritt.dev # The homepage of the given package (optional)
url: https://github.com/nikeokoronkwo/pritt # The url where the source code of the package is hosted (optional)
author: nikeokoronkwo # specify the username of the author of the given package (optional - inferred from logged in user)

# specify contributors for the project. They have the ability to unpack packages from the registry and then 
contributors: 
  - Brigght

# Specify scripts to run with the `pritt script` command
scripts:
  format: cargo fmt # `pritt script format`

  # You can also mention multiple scripts in a script. They can be called individually separated with '.', or altogether
  # By default, scripts are run in order of how they are listed
  schema: # pritt script schema - runs all commands specified here
    generate: # `pritt script schema.generate` runs specific command
  

# Specify actions to be run before given commands in
# Any other values other than builtin values specified here will be ignored
# Use the `scripts` value to specify custom jobs
actions:
  publish:
    pre: make setup # Runs before package is published
    post: rm -rf ./target # Runs after package is published (e.g cleanup)
  install:
    post: cargo run # Runs after package is installed in user's project (e.g generate code/files)
```

## Tips to note
1. It is advised, based on the way pritt adapters work, not to specify name fields in both projects. A warning will be displayed on the pritt cli when trying to publish the given commands.

## Lints
Pritt makes use of lints when publishing a package to allow your `pritt.yaml` as well as your package itself to conform to standards. 
They are usually displayed as warnings when trying to publish

To ignore lints from the pritt command, you can specify the name when using the `--allow` flag, or you can use the `--allow-all` flag to allow all lints.
```bash
pritt publish --allow multi_name
pritt publish --allow-all
```

You can also specify lints to ignore or cause an error in the config
```yaml
lints:
  ignore:
    - multi_name # This lint will be ignored
  strict:
    # Lints here will cause an error if encountered
```

In the case you are running pritt in a CI job, or want to just see how the publish pipeline is like, you can use the `--dry-run` flag to make a dry run of the publish pipeline. 
You can use `--fail-if-warn` to exit with an error code when a lint warning occurs.
```bash
pritt publish --dry-run --fail-if-warn
```

## Upcoming
1. Order of scripts, and script dependencies: The ability to order your scripts run, and specify dependencies for scripts
