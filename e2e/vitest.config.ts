import { defineConfig } from 'vitest/config';
import { loadEnv } from 'vite';

export default defineConfig(({ mode }) => ({
  test: {
    setupFiles: './setup.ts',
    env: loadEnv(mode, process.cwd(), ''),
  },
}));
