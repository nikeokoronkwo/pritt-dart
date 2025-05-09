/**
 * @copyright The Pritt Authors
 */
import { parseArgs } from "jsr:@std/cli/parse-args";
import { walk } from "jsr:@std/fs/walk";
import { join } from "jsr:@std/path/join";
import { dirname } from "jsr:@std/path/dirname";
import { basename } from "jsr:@std/path/basename";
import { relative } from "jsr:@std/path/relative";
import { copy } from "jsr:@std/fs/copy";
import { exists } from "jsr:@std/fs/exists";
import { blue, green } from "jsr:@std/fmt/colors";
import { TextLineStream } from "jsr:@std/streams/text-line-stream";
import { SEPARATOR } from "jsr:@std/path/constants";
import { checkIfCommandExists, runCommand, runCommandWithOutput } from "./utils.ts";

/** Used in the {@link generatePklGoTypes} */
function getName(path: string): string {
    return basename(dirname(path));
}

function getLockDep(name: string, denoJson?: string): string {
    const denoPath = denoJson ?? join(Deno.cwd(), 'deno.json');
    const json = JSON.parse(Deno.readTextFileSync(denoPath));
    return json.imports[name];
}

/** Checks whether the given dependencies for the program are available based on the arguments passed */
async function checkDependencies(options?: {
    strict?: boolean;
    cli?: boolean;
    openApi?: boolean;
    ignorePkl?: boolean;
    verbose?: boolean;
}) {
    const opts = {
        ignorePkl: false,
        strict: false,
        cli: true,
        openApi: true,
        verbose: false,
        ...options
    }
    // check if pkl is available
    if (!(await checkIfCommandExists('pkl')) || opts.ignorePkl) {
        console.error("%cError: PKL not found", "color: red");
        Deno.exit(1);
    }

    // PKL/GO: check if pkl-gen-go is available
    if (opts.cli && !(await checkIfCommandExists('pkl-gen-go'))) {
        if (opts.strict) {
            console.error("%cError: pkl-gen-go not found", "color: red");
            Deno.exit(1);
        } else {
            console.warn("%cCould not find pkl-gen-go", "color: orange");
            console.log("Installing pkl-gen-go...");

            // install pkl-gen-go
            if (!(await runCommand('go', ['install', 'github.com/apple/pkl-go/cmd/pkl-gen-go@latest'], { verbose: opts.verbose }))) {
                console.error("Error installing pkl-gen-go: Resolve the errors and try again");
                Deno.exit(1);
            }
        }
    }

    // OpenAPI SPEC: Check if jvm is available
    if (opts.openApi && !(await checkIfCommandExists('java'))) {
        console.error("%cError: Java Runtime not found", "color: red");
        Deno.exit(1);
    }
}

/**
 * Generate the PKL go types
 * @param schemaDir 
 * @param verbose 
 */
async function generatePklGoTypes(schemaDir: string, verbose?: boolean, additionalFiles: string[] = []) {
    
    const srcDir = join(schemaDir, 'src');

    const _pklPkgParts = ['github.com', 'pritt', 'cli'];
    const pklPkgName = _pklPkgParts.join(SEPARATOR);

    const pklDirectives = [];
    for await (const entry of walk(srcDir, {
        includeDirs: false,
        includeSymlinks: false,
    })) {
        if (entry.name !== 'schema.pkl') continue;
        
        const cmd = await runCommand('pkl-gen-go', [
            entry.path, 
            '--generator-settings', './schema/utils/generator-tools.pkl', 
            '--project-dir', 'schema',
            '--output-path', join(cliDir, 'types')
        ], { verbose });

        if (!cmd) {
            console.error("%cError: Abort", "color: red");
            Deno.exit(1);
        }

        const name = getName(entry.path);
        const outDir = join(cliDir, 'types', ..._pklPkgParts, name);

        for await (const item of walk(outDir, {
            includeDirs: false,
            includeSymlinks: false,
        })) {
            if (item.name === 'init.pkl.go') {
                // we need to parse some stuff
                let f = await Deno.open(item.path);
                const readable = f.readable
                    .pipeThrough(new TextDecoderStream()) 
                    .pipeThrough(new TextLineStream()); 

                let nextTake = false;
                
                for await (const data of readable) {
                    if (data.startsWith('}')) nextTake = false;
                    if (nextTake) {
                        pklDirectives.push(data);
                        continue;
                    }
                    if (data.includes('func init()')) nextTake = true;
                }
            } else {
                // copy to types dir
                let contents = (await Deno.readTextFile(item.path))
                // change pkg type
                contents = contents.replace(RegExp(/package [A-Za-z]+/g), 'package types').replace(_pklPkgParts.join('/'), _pklPkgParts.slice(1).join('/'));

                // change load and load from path functions
                /** @todo TODO: Remove functions */
                contents = contents.replaceAll('func Load', `func (${name[0].toLowerCase()} *${contents.includes(`type ${name} interface`) ? `${name}Impl` : name}) Load`);
                contents = contents.replaceAll('= Load', `= ${name[0].toLowerCase()}.Load`);

                await Deno.writeTextFile(join(cliDir, 'types', item.name.replace('.pkl.go', '.go')), contents);
            }
        }

        await Deno.remove(outDir, { recursive: true });
    }

    // console
    const initFile = `
package pkl

import (
    "github.com/apple/pkl-go/pkl"
    
    //lint:ignore ST1001 Autogenerated
    . "${_pklPkgParts.slice(1).join('/')}/types"
)

func init() {
${pklDirectives.join('\n')}
}`;

    if (!(await exists(join(cliDir, 'lib', 'pkl')))) await Deno.mkdir(join(cliDir, 'lib', 'pkl'));
    await Deno.writeTextFile(join(cliDir, 'lib', 'pkl', 'pkl.go'), initFile);

    // copy remaining
    for await (const item of walk(join(cliDir, 'types', ..._pklPkgParts), {
        includeDirs: false,
        includeSymlinks: false,
    })) {
        console.log(blue('Moving'), item.path, blue('to'), join(cliDir, basename(dirname(item.path))));
        if (!(await exists(join(cliDir, basename(dirname(item.path)))))) await Deno.mkdir(join(cliDir, basename(dirname(item.path))));
        await copy(item.path, join(cliDir, basename(dirname(item.path)), item.name.replace('.pkl.go', '.go')), { overwrite: true });
    }

    await Deno.remove(join(cliDir, 'types', _pklPkgParts[0]), { recursive: true });
}

const cliDir = './cli';
const schemaDir = './config';

const flags = parseArgs(Deno.args, {
    boolean: ['strict', 'verbose', 'go-gen', 'openapi'],
    string: ['pkl-path'],
    collect: ['go-gen-files'],
    default: {
        strict: false,
        verbose: false,
        "go-gen": true,
        openapi: true,
        "go-gen-files": []
    },
    negatable: ['strict', 'go-gen', 'openapi']
});

// check dependencies
console.log(green("Checking for dependencies..."));

// check for dependencies
await checkDependencies({
    strict: flags.strict,
    ignorePkl: flags["pkl-path"] !== undefined && flags["pkl-path"] !== "",
    verbose: flags.verbose,
    cli: flags["go-gen"],
    openApi: flags.openapi
});

// 1. The Pkl-Go Types
if (flags["go-gen"]) {
console.log(green("Generating pkl go types"))

// Generate for each type in SRC
await generatePklGoTypes(schemaDir, flags.verbose, flags["go-gen-files"] as string[] ?? [])
}

// 2. The OpenAPI Spec
if (flags.openapi) {
console.info("OpenAPI Spec")

// Generate the openapi spec
console.log(green("Generating OpenAPI Spec"))
const res = await runCommandWithOutput(flags["pkl-path"] ?? 'pkl', ['eval', 'main.pkl'], {cwd: schemaDir, verbose: flags.verbose});
if (!(await exists(join(schemaDir, 'out')))) await Deno.mkdir(join(schemaDir, 'out'));
await Deno.writeTextFile(join(schemaDir, 'out', 'openapi.json'), res);

// Generate TS bindings for the spec
/** @todo TODO: Unimplemented */

// Generate the Rust library for the given spec
console.log(green("Building Rust Library"))
const lockedVer = getLockDep("@openapitools/openapi-generator-cli");
await runCommand(Deno.execPath(), [
    "run", 
    "-A", 
    lockedVer, 
    "generate", 
    "-g", "dart", 
    "-i", "config/out/openapi.json", 
    "-c", "config/openapitools.json", 
    "-o", "packages/openapi-backend"
]);
}