import { OrchestratorConfig, SpecialistKind } from "./types";

export function routeSpecialist(labels: string[], cfg: OrchestratorConfig): SpecialistKind {
  const lower = labels.map(l => l.toLowerCase());
  for (const rule of cfg.routing.rules) {
    if (rule.labels.some(l => lower.includes(l))) return rule.droid;
  }
  return cfg.routing.fallback;
}
