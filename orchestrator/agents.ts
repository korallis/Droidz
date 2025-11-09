import { promises as fs } from "fs";
import path from "path";

const CANDIDATES = [
  "AGENTS.md",
  "agents.md",
  path.join(".github", "AGENTS.md"),
  path.join("docs", "AGENTS.md"),
];

export async function loadAgentsGuide(root: string): Promise<{ text: string; path: string | null }> {
  for (const rel of CANDIDATES) {
    const p = path.join(root, rel);
    try {
      const txt = await fs.readFile(p, "utf-8");
      return { text: txt, path: p };
    } catch {}
  }
  return { text: "", path: null };
}

export function truncateGuide(text: string, maxChars = 6000): string {
  if (!text) return "";
  if (text.length <= maxChars) return text;
  return text.slice(0, maxChars) + "\n\n[...truncated...]";
}
