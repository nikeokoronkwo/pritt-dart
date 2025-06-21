import { drizzle } from "drizzle-orm/node-postgres";
export { sql, eq, and, or } from "drizzle-orm";

import { schema } from "./schema";

export { schema };

export const db = drizzle(process.env.DATABASE_URL!, { schema });

export function useDrizzle() {
  return db;
}
