import * as fs from "fs";
import * as path from "path";
import { Client } from "pg";

const ROOT_DIR = process.cwd();
const MIGRATIONS_DIR = path.join(ROOT_DIR, "migrations");

function loadEnv(): Record<string, string> {
  const envPath = path.join(ROOT_DIR, ".env");
  if (!fs.existsSync(envPath)) {
    console.error(".env not found. Copy .env.example and fill in your credentials.");
    process.exit(1);
  }
  const env: Record<string, string> = {};
  for (const line of fs.readFileSync(envPath, "utf-8").split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eq = trimmed.indexOf("=");
    if (eq === -1) continue;
    env[trimmed.slice(0, eq).trim()] = trimmed.slice(eq + 1).trim();
  }
  return env;
}

async function ensureMigrationsTable(client: Client): Promise<void> {
  await client.query(`
    CREATE TABLE IF NOT EXISTS _migrations (
      migration   VARCHAR(255) PRIMARY KEY,
      applied_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
    )
  `);
}

async function appliedMigrations(client: Client): Promise<Set<string>> {
  const result = await client.query<{ migration: string }>(
    "SELECT migration FROM _migrations ORDER BY migration"
  );
  return new Set(result.rows.map((r) => r.migration));
}

function pendingMigrations(applied: Set<string>): string[] {
  if (!fs.existsSync(MIGRATIONS_DIR)) return [];
  return fs
    .readdirSync(MIGRATIONS_DIR)
    .filter((name) => {
      const dir = path.join(MIGRATIONS_DIR, name);
      return (
        fs.statSync(dir).isDirectory() &&
        !applied.has(name) &&
        fs.existsSync(path.join(dir, "up.sql"))
      );
    })
    .sort();
}

async function main(): Promise<void> {
  const env = loadEnv();
  const client = new Client({
    host: env.DB_HOST ?? "localhost",
    port: Number(env.DB_PORT ?? 5432),
    database: env.DB_NAME,
    user: env.DB_USER,
    password: env.DB_PASSWORD,
  });

  await client.connect();
  await ensureMigrationsTable(client);

  const applied = await appliedMigrations(client);
  const pending = pendingMigrations(applied);

  if (pending.length === 0) {
    console.log("Nothing to migrate.");
    await client.end();
    return;
  }

  for (const name of pending) {
    const upPath = path.join(MIGRATIONS_DIR, name, "up.sql");
    const sql = fs.readFileSync(upPath, "utf-8");
    console.log(`Applying: ${name}`);
    await client.query("BEGIN");
    try {
      await client.query(sql);
      await client.query("INSERT INTO _migrations (migration) VALUES ($1)", [name]);
      await client.query("COMMIT");
      console.log(`  ✓ Done`);
    } catch (err) {
      await client.query("ROLLBACK");
      console.error(`  ✗ Failed — rolled back`);
      console.error(err);
      await client.end();
      process.exit(1);
    }
  }

  console.log(`\nApplied ${pending.length} migration(s).`);
  await client.end();
}

main();
