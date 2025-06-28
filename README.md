# Pritt

Pritt is a simple, fast and powerful **multi-language registry** for code and
packages in multiple languages.

- Multi-language - a new paradigm: No need to have all your packages in various
  places. With pritt you can now have all your packages seamlessly integrated in
  one place, with seamless compatibility with all your favourite programming
  language package managers.
- Simple yet Configurable: Publishing is as simple as a command. Can be
  configured to run commands before building, after installing, and more.
- Fast and Lightweight: Pritt is designed to be as light as possible, while
  still being able to scale well. Different parts can scale for different
  demands.

To learn more, check out the [docs](./docs).

## Development
Pritt requires Dart (at least 3.6) to build the server and CLI. 

The CLI can be built with:
```bash
cd cli
dart compile exe bin/pritt.dart
```

The Server requires a few more dependencies:
- PostgreSQL
- An S3 Compatible Storage: We use MinIO for development

Start PostgreSQL 

## Building
Pritt can be built as a Docker image. 

### Compose Setup
```bash
docker compose up
```