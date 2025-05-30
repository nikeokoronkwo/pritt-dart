import { drizzle } from "drizzle-orm/d1";
export { sql, eq, and, or } from "drizzle-orm";

import * as schema from "./schema";

export { schema };

export const db = drizzle(process.env.DATABASE_URL!, { schema });

export function useDrizzle() {
  return db;
}
