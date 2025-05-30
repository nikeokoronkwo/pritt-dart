// ./schema.ts

import * as base from "./schema/schema";

import * as relations from "./schema/relations";

// Export everything as a merged schema object
export const schema = {
  ...base,

  ...relations,
};
