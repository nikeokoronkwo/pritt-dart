import { drizzle } from "drizzle-orm/d1";
export { sql, eq, and, or } from "drizzle-orm";

import * as s from "./schema";
import * as relations from "./relations"

export const schema = {
  ...s,
  ...relations
}


export const db = drizzle(process.env.DATABASE_URL!, { schema });

export function useDrizzle() {
  return db;
}
