# Build Stage 1

FROM node:23-alpine AS build
WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm i --frozen-lockfile

# Copy the entire project
COPY . ./

# Push DB Changes
RUN pnpm run db:push

# Build the project
RUN pnpm run build

# Build Stage 2

FROM node:slim
WORKDIR /app

# Only `.output` folder is needed from the build stage
COPY --from=build /app/.output/ ./

# Change the port and host
# TODO: Set env
ENV PORT=3000
ENV HOST=0.0.0.0

EXPOSE 80

CMD ["node", "/app/server/index.mjs"]
