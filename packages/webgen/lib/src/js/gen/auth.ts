import * as t from "@babel/types";
// @ts-ignore
import * as templ from "@babel/template";
import { generate } from "@babel/generator";
import { AuthOptions } from "./types";

const template = templ.default.default;

/**
 *
 * @param options
 * @returns An array of objects mapping code to designated file names
 *
 * Do not forget to run:
 * npx @better-auth/cli@latest generate
 * npx drizzle-kit generate # generate the migration file
 * npx drizzle-kit migrate
 */
export function generateAuthConfig(options: AuthOptions): {
  filename: string;
  code: string;
  name?: string;
}[] {
  // generate server
  const serverImports = generateAuthImports(options);
  const serverConfig = generateAuthExport(options, serverImports);

  const serverAst = t.program([...serverImports, serverConfig]);

  const { code: authFileCode } = generate(serverAst);

  const clientAst = generateAuthClient(options);

  const { code: authClientCode } = generate(clientAst);

  return [
    {
      filename: "server/utils/auth.ts",
      code: authFileCode,
      name: "auth",
    },
    {
      filename: "utils/client.ts",
      code: authClientCode,
    },
  ];
}

function generateAuthClient(options: AuthOptions): t.Program {
  const authClientPluginImportSpecifiers: (
    | t.ImportSpecifier
    | t.ImportDefaultSpecifier
    | t.ImportNamespaceSpecifier
  )[] = [];
  const authClientPlugins = [];
  if (options.magicLink) {
    /**
         * Magic Link Code:
         * 
         * On Sign Up, On Sign In: - 
         * ```ts
         * const { data, error } = await authClient.signIn.magicLink({
                email: "user@email.com",
                callbackURL: "/login/status", // redirect after successful login (handle query option) 
                // on success: /dashboard, on fail: /login/failed
           });
         * ```
         * 
         */
    authClientPluginImportSpecifiers.push(
      t.importSpecifier(
        t.identifier("magicLinkClient"),
        t.identifier("magicLinkClient"),
      ),
    );
    authClientPlugins.push(
      t.callExpression(t.identifier("magicLinkClient"), []),
    );
  }
  if (options.passkey) {
    /**
         * Passkey Code:
         * 
         * On First Complete Sign In: -
         * ```ts
         * const { data, error } = await authClient.passkey.addPasskey();
         * ```
         * 
         * On Sign In: -
         * ```ts
         * const data = await authClient.signIn.passkey();
         * ```
         * 
         * For autocomplete: 
         * <label for="name">Username:</label>
            <input type="text" name="name" autocomplete="username webauthn">
            <label for="password">Password:</label>
            <input type="password" name="password" autocomplete="current-password webauthn">
         * 
         * 
         * 
         */
    authClientPluginImportSpecifiers.push(
      t.importSpecifier(
        t.identifier("passkeyClient"),
        t.identifier("passkeyClient"),
      ),
    );
    authClientPlugins.push(t.callExpression(t.identifier("passkeyClient"), []));
  }
  if (options.admin) {
    /**
     *
     * On Init: Initialize a single user and put as super admin
     */
    authClientPluginImportSpecifiers.push(
      t.importSpecifier(
        t.identifier("adminClient"),
        t.identifier("adminClient"),
      ),
    );
    authClientPlugins.push(t.callExpression(t.identifier("adminClient"), []));
  }
  if (options.orgs) {
    /**
     *
     */
    authClientPluginImportSpecifiers.push(
      t.importSpecifier(
        t.identifier("organizationClient"),
        t.identifier("organizationClient"),
      ),
    );
    authClientPlugins.push(
      t.callExpression(t.identifier("organizationClient"), []),
    );
  }

  const authClientImports = [
    t.importDeclaration(
      [
        t.importSpecifier(
          t.identifier("createAuthClient"),
          t.identifier("createAuthClient"),
        ),
      ],
      t.stringLiteral("better-auth/vue"),
    ),
    t.importDeclaration(
      authClientPluginImportSpecifiers,
      t.stringLiteral("better-auth/client/plugins"),
    ),
  ];

  const authClientExport = t.exportNamedDeclaration(
    t.variableDeclaration("const", [
      t.variableDeclarator(
        t.identifier("authClient"),
        t.callExpression(t.identifier("createAuthClient"), [
          t.objectExpression([
            t.objectProperty(
              t.identifier("plugins"),
              t.arrayExpression(authClientPlugins),
            ),
          ]),
        ]),
      ),
    ]),
  );

  return t.program([...authClientImports, authClientExport]);
}

function generateAuthImports(options: AuthOptions): t.ImportDeclaration[] {
  // import { betterAuth } from "better-auth";
  const betterAuthSpecifiers = [
    t.importSpecifier(t.identifier("betterAuth"), t.identifier("betterAuth")),
  ];
  // import { drizzleAdapter } from "better-auth/adapters/drizzle";
  const betterAuthDrizzleAdapterSpecifiers = [
    t.importSpecifier(
      t.identifier("drizzleAdapter"),
      t.identifier("drizzleAdapter"),
    ),
  ];

  const otherImports = [];
  //
  const betterAuthPluginSpecifiers = [];
  if (options.magicLink)
    betterAuthPluginSpecifiers.push(
      t.importSpecifier(t.identifier("magicLink"), t.identifier("magicLink")),
    );
  if (options.passkey)
    otherImports.push(
      t.importDeclaration(
        [t.importSpecifier(t.identifier("passkey"), t.identifier("passkey"))],
        t.stringLiteral("better-auth/plugins/passkey"),
      ),
    );
  if (options.admin)
    betterAuthPluginSpecifiers.push(
      t.importSpecifier(t.identifier("admin"), t.identifier("admin")),
    );
  if (options.orgs)
    betterAuthPluginSpecifiers.push(
      t.importSpecifier(
        t.identifier("organization"),
        t.identifier("organization"),
      ),
    );

  return [
    // better auth
    t.importDeclaration(betterAuthSpecifiers, t.stringLiteral("better-auth")),
    // better auth drizzle adapter
    t.importDeclaration(
      betterAuthDrizzleAdapterSpecifiers,
      t.stringLiteral("better-auth/adapters/drizzle"),
    ),
    // db and schema
    t.importDeclaration(
      [
        t.importSpecifier(t.identifier("db"), t.identifier("db")),
        t.importSpecifier(t.identifier("schema"), t.identifier("schema")),
      ],
      t.stringLiteral("../db/index"),
    ),
    // plugins
    t.importDeclaration(
      betterAuthPluginSpecifiers,
      t.stringLiteral("better-auth/plugins"),
    ),
    ...otherImports,
  ];
}

function generateAuthExport(
  options: AuthOptions,
  imports: t.ImportDeclaration[],
) {
  const authPlugins = [];

  if (options.magicLink) {
    authPlugins.push(
      t.callExpression(t.identifier("magicLink"), [
        t.objectExpression([
          t.objectProperty(
            t.identifier("sendMagicLink"),
            t.arrowFunctionExpression(
              [
                t.objectPattern([
                  t.objectProperty(
                    t.identifier("email"),
                    t.identifier("email"),
                    false,
                    true,
                  ),
                  t.objectProperty(
                    t.identifier("token"),
                    t.identifier("token"),
                    false,
                    true,
                  ),
                  t.objectProperty(
                    t.identifier("url"),
                    t.identifier("url"),
                    false,
                    true,
                  ),
                ]),
                t.identifier("request"),
              ],
              // magicLinkCode() as t.BlockStatement,
              t.blockStatement(magicLinkCode()),
              true,
            ),
          ),
        ]),
      ]),
    );
  }
  if (options.passkey) {
    authPlugins.push(
      t.callExpression(t.identifier("passkey"), [
        t.objectExpression([
          t.objectProperty(t.identifier("rpID"), t.stringLiteral(options.name)),
          t.objectProperty(
            t.identifier("rpName"),
            t.stringLiteral(options.title),
          ),
        ]),
      ]),
    );
  }
  if (options.admin) {
    authPlugins.push(
      t.callExpression(t.identifier("admin"), [
        // TODO: Admin User IDs -> adminUserIds: ["user_id_1", "user_id_2"]
      ]),
    );
  }
  if (options.orgs) {
    authPlugins.push(
      t.callExpression(t.identifier("organization"), [
        // TODO: Admin User IDs -> adminUserIds: ["user_id_1", "user_id_2"]
      ]),
    );
  }

  const betterAuthOpts = [];

  betterAuthOpts.push(
    t.objectProperty(
      t.identifier("socialProviders"),
      t.objectExpression([
        ...(options.oauth.github
          ? [
              t.objectProperty(
                t.identifier("github"),
                t.objectExpression([
                  t.objectProperty(
                    t.identifier("clientId"),
                    t.tsAsExpression(
                      t.memberExpression(
                        t.memberExpression(
                          t.identifier("process"), // process
                          t.identifier("env"), // process.env
                        ),
                        t.identifier("GITHUB_CLIENT_ID"),
                      ),
                      t.tsTypeReference(t.identifier("string")),
                    ),
                  ),
                  t.objectProperty(
                    t.identifier("clientSecret"),
                    t.tsAsExpression(
                      t.memberExpression(
                        t.memberExpression(
                          t.identifier("process"), // process
                          t.identifier("env"), // process.env
                        ),
                        t.identifier("GITHUB_CLIENT_SECRET"),
                      ),
                      t.tsTypeReference(t.identifier("string")),
                    ),
                  ),
                ]),
              ),
            ]
          : []),
        ...(options.oauth.google
          ? [
              t.objectProperty(
                t.identifier("google"),
                t.objectExpression([
                  t.objectProperty(
                    t.identifier("clientId"),
                    t.tsAsExpression(
                      t.memberExpression(
                        t.memberExpression(
                          t.identifier("process"), // process
                          t.identifier("env"), // process.env
                        ),
                        t.identifier("GOOGLE_CLIENT_ID"),
                      ),
                      t.tsTypeReference(t.identifier("string")),
                    ),
                  ),
                  t.objectProperty(
                    t.identifier("clientSecret"),
                    t.tsAsExpression(
                      t.memberExpression(
                        t.memberExpression(
                          t.identifier("process"), // process
                          t.identifier("env"), // process.env
                        ),
                        t.identifier("GOOGLE_CLIENT_SECRET"),
                      ),
                      t.tsTypeReference(t.identifier("string")),
                    ),
                  ),
                ]),
              ),
            ]
          : []),
      ]),
    ),
  );

  betterAuthOpts.push(
    t.objectProperty(
      t.identifier("database"),
      t.callExpression(t.identifier("drizzleAdapter"), [
        t.identifier("db"),
        t.objectExpression([
          t.objectProperty(t.identifier("provider"), t.stringLiteral("pg")),
          t.objectProperty(
            t.identifier("schema"),
            t.objectExpression([t.spreadElement(t.identifier("schema"))]),
          ),
        ]),
      ]),
    ),
    t.objectProperty(t.identifier("plugins"), t.arrayExpression(authPlugins)),
  );

  return t.exportNamedDeclaration(
    t.variableDeclaration("const", [
      t.variableDeclarator(
        t.identifier("auth"),
        t.callExpression(t.identifier("betterAuth"), [
          t.objectExpression(betterAuthOpts),
        ]),
      ),
    ]),
  );
}

const magicLinkCode = template(`
    // code...
    const o = 9;
    const f = 9;
`);
