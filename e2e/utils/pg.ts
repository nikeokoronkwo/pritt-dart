import { Client } from 'pg';
import { readdir, readFile } from 'node:fs/promises';

export async function setupPostgresContainer(pgClient: Client) {
  const sqlAssets = '../assets/sql';
  const sqlFiles = await readdir(sqlAssets, {
    withFileTypes: true,
    encoding: 'utf8',
  });

  for (const file of sqlFiles) {
    if (file.isFile() && file.name.endsWith('.sql')) {
      const sqlContent = await readFile(`${sqlAssets}/${file.name}`, 'utf8');
      await pgClient.query(sqlContent);
    }
  }
}
