import { drizzle } from "drizzle-orm/d1";
export { sql, eq, and, or } from "drizzle-orm";

import * as schema from "./schema";

export const tables = schema;

export const db = drizzle({
  connection: {
    connectionString: process.env.DATABASE_URL!,
    ssl: true,
  },
});

export function useDrizzle() {
  return db;
}
