import * as fs from "fs";
import * as path from "path";

const ROOT_DIR = process.cwd();
const OUTPUT_FILE = "db-output.sql";
const ROOT_INIT = "init.sql";
const visited = new Set<string>();

function readLines(filePath: string): string[] {
  if (!fs.existsSync(filePath)) {
    console.warn(`[WARN] Not found: ${filePath}`);
    return [];
  }
  return fs.readFileSync(filePath, "utf-8").split("\n").map((l) => l.trimEnd());
}

function sectionLabel(initPath: string): string {
  const rel = path.relative(ROOT_DIR, path.dirname(path.resolve(initPath)));
  return rel.replace(/[\\/]/g, " > ") || ".";
}

function processInit(initPath: string): string[] {
  const absPath = path.resolve(initPath);
  if (visited.has(absPath)) return [];
  visited.add(absPath);

  const output: string[] = [];
  for (const line of readLines(absPath)) {
    const match = line.match(/^\s*\\i\s+(.+)/);
    if (!match) {
      output.push(line);
      continue;
    }
    const ref = match[1].trim();
    const refPath = path.join(ROOT_DIR, ref);

    if (ref.endsWith("init.sql")) {
      const lbl = sectionLabel(refPath);
      const dashes = "-".repeat(Math.max(2, 54 - lbl.length));
      output.push(`\n-- [${lbl}] ${dashes}`);
      output.push(...processInit(refPath));
      output.push(`-- [/${lbl}]\n`);
    } else {
      output.push(...readLines(refPath));
    }
  }
  return output;
}

const now = new Date().toISOString().replace("T", " ").slice(0, 19);
const header = [
  "-- " + "=".repeat(58),
  `-- Generated: ${now}`,
  "-- DO NOT EDIT — run: npm run build",
  "-- " + "=".repeat(58),
  "",
];

if (fs.existsSync(OUTPUT_FILE)) fs.unlinkSync(OUTPUT_FILE);
const lines = processInit(ROOT_INIT);
fs.writeFileSync(OUTPUT_FILE, [...header, ...lines].join("\n") + "\n", "utf-8");
console.log(`Generated: ${OUTPUT_FILE}`);
