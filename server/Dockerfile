# Use latest stable channel SDK.
FROM dart:stable AS build

WORKDIR /

# Resolve app dependencies.
COPY tools /app/tools

COPY ./pubspec.yaml /app/
COPY common/pubspec.yaml /app/common/
COPY cli/pubspec.yaml /app/cli/
COPY server/pubspec.* /app/server/

WORKDIR /app

RUN dart pub get

COPY . .

WORKDIR /app/server
RUN dart pub get --offline

WORKDIR /app

# RUN dart pub get
RUN ./tool/denv.dart --cwd server -- dart compile exe bin/server.dart -o bin/server


# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/server/bin/server /server/bin

# Start server.
EXPOSE 8080
CMD ["/server/bin"]
