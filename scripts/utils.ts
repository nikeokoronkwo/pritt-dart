export async function checkIfCommandExists(name: string) {
  const cmd = new Deno.Command(Deno.build.os === 'windows' ? `Get-Command` : `which`, { args: [name] });
  return (await cmd.output()).success;
}
export async function runCommand(name: string, args: string[] = [], options: { verbose?: boolean; cwd?: string; } = { verbose: false }) {
  const cmd = new Deno.Command(name, !options.verbose ? { args, cwd: options.cwd } : { args, stdin: 'piped', stdout: 'piped', stderr: 'piped', cwd: options.cwd });
  if (options.verbose) {
    const child = cmd.spawn();

    child.stdout.pipeTo(Deno.stdout.writable);
    child.stderr.pipeTo(Deno.stderr.writable);

    const status = await child.status;
    return status.success;
  } else {
    const { success, stderr } = await cmd.output();
    if (!success) console.error(`%c${new TextDecoder().decode(stderr)}`, "color: red");
    return success;
  }
}

export async function runCommandWithOutput(name: string, args: string[] = [], options: { verbose?: boolean; cwd?: string; } = { verbose: false }): Promise<string> {
  const cmd = new Deno.Command(name, !options.verbose ? { args, cwd: options.cwd } : { args, stdin: 'piped', stdout: 'piped', stderr: 'piped', cwd: options.cwd });
  if (options.verbose) {
    const child = cmd.spawn();

    const updates: string[] = [];
    
    const writableStream = new WritableStream<string>({
      write(chunk) {
        updates.push(chunk);
      }
    });

    child.stdout.pipeThrough(new TextDecoderStream()).pipeTo(writableStream);
    child.stderr.pipeTo(Deno.stderr.writable);

    return updates.join('');
  } else {
    const { success, stderr, stdout, code } = await cmd.output();
    if (!success) {
      console.error(`%c${new TextDecoder().decode(stderr)}`, "color: red");
      Deno.exit(code);
    }
    return (new TextDecoder()).decode(stdout);
  }
}