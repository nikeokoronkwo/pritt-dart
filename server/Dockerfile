# Use latest stable channel SDK.
FROM dart:stable AS build

WORKDIR /

# Resolve app dependencies.
COPY tool /app/tool

COPY ./pubspec.yaml /app/
COPY common/pubspec.yaml /app/common/
COPY cli/pubspec.yaml /app/cli/
COPY server/pubspec.* /app/server/

WORKDIR /app

RUN dart pub get

COPY . .

WORKDIR /app/server
RUN dart pub get --offline

# ENVS
# either
# ARG DATABASE_URL
# or
ARG DATABASE_NAME
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD_FILE
ARG DATABASE_PORT
ARG DATABASE_HOST

# Other ENVS
ARG S3_SECRET_KEY_FILE
ARG S3_ACCESS_KEY_FILE
ARG S3_URL
ARG PRITT_RUNNER_URL

# RUN dart pub get
RUN --mount=type=secret,id=aws-key-id,env=AWS_ACCESS_KEY_ID \
    --mount=type=secret,id=aws-secret-key,env=AWS_SECRET_ACCESS_KEY \
    --mount=type=secret,id=aws-session-token,env=AWS_SESSION_TOKEN \ \
  dart compile exe bin/server.dart -o bin/server


# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/server/bin/server /server/bin

# Start server.
EXPOSE 8080
CMD ["/server/bin"]
