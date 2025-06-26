import { spawnSync } from 'node:child_process';
import { realpath } from 'node:fs/promises';
import { dirname, normalize, join } from 'node:path';

export function run(
  cmd: string,
  args: string[],
  options?: {
    cwd?: string;
    pipe?: boolean;
  },
): {
  stdout: string;
  stderr: string;
  code: number;
} {
  const result = spawnSync(cmd, args, {
    cwd: options?.cwd,
    encoding: 'utf8',
    stdio: (options?.pipe ?? true) ? 'pipe' : 'ignore',
  });
  return {
    ...result,
    code: result.status ?? 0,
  };
}

export function invokeCLI(args: string[]) {
  const cliPath = join('..', 'cli', 'bin', 'pritt.dart');
  return run('dart', [cliPath, ...args], { pipe: true });
  // console.log(await realpath(cliCwd));
}
