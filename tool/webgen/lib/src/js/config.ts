import { z } from 'zod';

export const configSchema = z.object({
  // The name of the project
  name: z.string().min(1, 'Project name cannot be empty'),
  // The version of the project
  version: z.string().optional(),
  // The description of the project
  description: z.string().optional(),

  style: z.union([
    z.enum(['default']),
    z.object({
      colours: z.object({
        primary: z.string(),
        secondary: z.string().optional(),
        accent: z.string(),
      }),
      font: z.union([
        z.enum(['default', 'serif']),
        z.object({
          family: z.string(),
          size: z.number().optional(),
          weight: z.string().optional(),
        }),
      ]),
    }),
  ]),

  icon: z.string(),

  logo: z.string(),

  assets: z.array(z.string()).optional(),

  'terms-of-use': z.string().optional(),
  'privacy-policy': z.string().optional(),

  'cookie-policy': z.string().optional(),

  meta: z.object({}),
});
