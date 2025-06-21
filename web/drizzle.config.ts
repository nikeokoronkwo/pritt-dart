import "dotenv/config";
import { defineConfig } from "drizzle-kit";

interface DatabaseParts {
  user?: string;
  password?: string;
  host: string;
  port?: number;
  database: string;
  ssl?: boolean;
  options?: { [key: string]: string | number | boolean };
}

function assemblePostgresUrl(parts: DatabaseParts): string {
  let url = "postgresql://";

  if (parts.user) {
    url += encodeURIComponent(parts.user);
    if (parts.password) {
      url += `:${encodeURIComponent(parts.password)}`;
    }
    url += "@";
  }

  url += parts.host;

  if (parts.port) {
    url += `:${parts.port}`;
  }

  url += `/${encodeURIComponent(parts.database)}`;

  const queryParams: string[] = [];

  if (parts.ssl === true) {
    queryParams.push("sslmode=require");
  } else if (parts.ssl === false) {
    queryParams.push("sslmode=disable");
  }

  if (parts.options) {
    for (const key in parts.options) {
      if (Object.prototype.hasOwnProperty.call(parts.options, key)) {
        queryParams.push(
          `${encodeURIComponent(key)}=${encodeURIComponent(String(parts.options[key]))}`,
        );
      }
    }
  }

  if (queryParams.length > 0) {
    url += `?${queryParams.join("&")}`;
  }

  return url;
}

export default defineConfig({
  out: "./server/db/schema",
  schema: ["./server/db/schema.ts", "./server/db/schema/**/*.ts"],
  dialect: "postgresql",
  dbCredentials: {
    url: assemblePostgresUrl({
      host: process.env.DATABASE_HOST!,
      port: parseInt(process.env.DATABASE_PORT!),
      user: process.env.DATABASE_USERNAME!,
      password: process.env.DATABASE_PASSWORD!,
      database: process.env.DATABASE_NAME!,
    }),
  },
});
