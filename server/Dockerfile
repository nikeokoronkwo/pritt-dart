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

# ENVS
# either
# ENV DATABASE_URL
# or
# ENV DATABASE_NAME
# ENV DATABASE_USERNAME
# ENV DATABASE_PASSWORD
# ENV DATABASE_PORT
# ENV DATABASE_HOST

# Other ENVS
# ENV S3_SECRET_KEY
# ENV S3_ACCESS_KEY
# ENV S3_LOCAL_PORT (if local)
# ENV PRITT_RUNNER_URL

# RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server


# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/server/bin/server /server/bin

# Start server.
EXPOSE 8080
CMD ["/server/bin"]
