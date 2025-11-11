export type ApprovalsMode = "auto" | "require_manual" | "disallow_push";

export interface OrchestratorConfig {
  linear: { project: string; sprint: string; updateComments: boolean; apiKey?: string; teamId?: string; projectId?: string };
  concurrency: number;
  approvals: { prs: ApprovalsMode };
  workspace: { baseDir: string; branchPattern: string; useWorktrees?: boolean; mode?: "worktree" | "clone" | "branch" };
  guardrails: { dryRun: boolean; secretScan: boolean; testsRequired: boolean; maxJobMinutes: number };
  merge?: { autoMerge: boolean; strategy: "squash" | "merge" | "rebase"; requireChecks: boolean; reviewStateName?: string; doneStateName?: string };
  routing: { rules: Array<{ labels: string[]; droid: SpecialistKind }>; fallback: SpecialistKind };
  specialists?: Array<{ name: SpecialistKind; enabled: boolean }>;
  profile?: Record<string, unknown>;
}

export interface ProjectPlan {
  name: string;
  description?: string;
  epics: EpicPlan[];
}

export interface EpicPlan {
  title: string;
  description?: string;
  labels?: string[];
  tasks: TaskPlan[];
}

export interface TaskPlan {
  title: string;
  description?: string;
  labels?: string[];
  acceptance?: string[];
}

export type SpecialistKind =
  | "codegen"
  | "test"
  | "infra"
  | "refactor"
  | "integration"
  | "generalist";

export interface TaskSpec {
  id: string; // Linear issue ID
  key: string; // e.g., PROJ-123
  title: string;
  description?: string;
  labels: string[];
  acceptance?: string[];
  deps: string[]; // issue keys that block this task
  repoDir: string; // cwd for work
  branch: string;
  specialist: SpecialistKind;
}

export interface LinearIssue {
  id: string;
  identifier: string; // PROJ-123
  title: string;
  description?: string;
  labels: string[];
  blockedBy: string[]; // identifiers
}
