import { LinearIssue } from "./types";

const LINEAR_GQL = "https://api.linear.app/graphql";

async function gql<T>(apiKey: string, query: string, variables: Record<string, any>): Promise<T> {
  const key = apiKey || process.env.LINEAR_API_KEY || process.env.LINEAR_TOKEN || "";
  if (!key) throw new Error("Missing Linear API key (set orchestrator/config.json linear.apiKey or env LINEAR_API_KEY)");
  const res = await fetch(LINEAR_GQL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: key,
    },
    body: JSON.stringify({ query, variables }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Linear API error: ${res.status} ${text}`);
  }
  const json = (await res.json()) as any;
  if (json.errors) throw new Error("Linear GraphQL errors: " + JSON.stringify(json.errors));
  return json.data as T;
}

export async function fetchIssuesByProjectAndCycle(apiKey: string, projectName: string, cycleName: string, first = 100): Promise<LinearIssue[]> {
  const query = `#graphql
    query Issues($projectName: String!, $cycleName: String!, $first: Int!) {
      issues(
        filter: {
          project: { name: { eq: $projectName } }
          cycle: { name: { eq: $cycleName } }
        }
        first: $first
      ) {
        nodes {
          id
          identifier
          title
          description
          labels { nodes { name } }
          relations: relationships { nodes { type relatedIssue { identifier } } }
        }
      }
    }
  `;
  type Resp = { issues: { nodes: Array<{ id: string; identifier: string; title: string; description?: string; labels: { nodes: { name: string }[] }; relations?: { nodes: { type: string; relatedIssue?: { identifier: string } }[] } }> } };
  const data = await gql<Resp>(apiKey, query, { projectName, cycleName, first });
  return data.issues.nodes.map(n => ({
    id: n.id,
    identifier: n.identifier,
    title: n.title,
    description: n.description,
    labels: (n.labels?.nodes || []).map(l => l.name.toLowerCase()),
    blockedBy: (n.relations?.nodes || []).filter(r => r.type === "blocks" && r.relatedIssue?.identifier).map(r => r.relatedIssue!.identifier!),
  }));
}

export async function listTeams(apiKey: string): Promise<Array<{ id: string; name: string; key?: string }>> {
  const q = `#graphql
    query { teams(first: 50) { nodes { id name key } } }
  `;
  type R = { teams: { nodes: Array<{ id: string; name: string; key?: string }> } };
  const data = await gql<R>(apiKey, q, {});
  return data.teams.nodes;
}

export async function createProject(apiKey: string, name: string, description: string | undefined, teamId?: string): Promise<{ id: string; name: string }> {
  // Try with teamId
  const m1 = `#graphql
    mutation($input: ProjectCreateInput!) {
      projectCreate(input: $input) { project { id name } }
    }
  `;
  type R = { projectCreate: { project: { id: string; name: string } } };
  try {
    const data = await gql<R>(apiKey, m1, { input: { name, description, teamId } });
    return data.projectCreate.project;
  } catch (e) {
    // Retry without teamId if unsupported
    const data = await gql<R>(apiKey, m1, { input: { name, description } });
    return data.projectCreate.project;
  }
}

export async function getOrCreateLabel(apiKey: string, name: string, teamId?: string): Promise<string> {
  const q = `#graphql
    query($name: String!) { issueLabels(filter: { name: { eq: $name } }, first: 1) { nodes { id name } } }
  `;
  type R = { issueLabels: { nodes: Array<{ id: string; name: string }> } };
  const found = await gql<R>(apiKey, q, { name });
  if (found.issueLabels.nodes[0]) return found.issueLabels.nodes[0].id;
  const m = `#graphql
    mutation($input: IssueLabelCreateInput!) { issueLabelCreate(input: $input) { issueLabel { id } } }
  `;
  type R2 = { issueLabelCreate: { issueLabel: { id: string } } };
  const data = await gql<R2>(apiKey, m, { input: { name, teamId } });
  return data.issueLabelCreate.issueLabel.id;
}

export async function createIssue(apiKey: string, params: { teamId: string; projectId?: string; title: string; description?: string; parentId?: string; labelIds?: string[] }): Promise<{ id: string; identifier: string }> {
  const m = `#graphql
    mutation($input: IssueCreateInput!) { issueCreate(input: $input) { issue { id identifier } } }
  `;
  type R = { issueCreate: { issue: { id: string; identifier: string } } };
  const data = await gql<R>(apiKey, m, { input: params });
  return data.issueCreate.issue.id ? data.issueCreate.issue : { id: "", identifier: "" };
}

export async function getTeamStartedStateId(apiKey: string, teamId: string): Promise<string | null> {
  const q = `#graphql
    query($id: String!) { team(id: $id) { states(first: 50) { nodes { id name type } } } }
  `;
  type R = { team: { states: { nodes: Array<{ id: string; name: string; type: string }> } } | null };
  const data = await gql<R>(apiKey, q, { id: teamId });
  const states = data.team?.states?.nodes || [];
  const started = states.find(s => s.type?.toLowerCase() === "started") || states.find(s => /in\s*progress/i.test(s.name));
  return started?.id || null;
}

export async function getTeamStateIdByName(apiKey: string, teamId: string, namePattern: string): Promise<string | null> {
  const q = `#graphql
    query($id: String!) { team(id: $id) { states(first: 50) { nodes { id name type } } } }
  `;
  type R = { team: { states: { nodes: Array<{ id: string; name: string; type: string }> } } | null };
  const data = await gql<R>(apiKey, q, { id: teamId });
  const states = data.team?.states?.nodes || [];
  const re = new RegExp(namePattern, "i");
  const match = states.find(s => re.test(s.name));
  return match?.id || null;
}

export async function setIssueState(apiKey: string, identifier: string, stateId: string): Promise<boolean> {
  const issueId = await getIssueId(apiKey, identifier);
  const m = `#graphql
    mutation($id: String!, $stateId: String!) { issueUpdate(id: $id, input: { stateId: $stateId }) { success } }
  `;
  type R = { issueUpdate: { success: boolean } };
  const data = await gql<R>(apiKey, m, { id: issueId, stateId });
  return data.issueUpdate.success;
}

export async function commentOnIssue(apiKey: string, identifier: string, body: string) {
  // Linear mutation commonly uses issueId not identifier; resolve ID first
  const issueId = await getIssueId(apiKey, identifier);
  const m = `#graphql
    mutation AddComment($issueId: String!, $body: String!) {
      commentCreate(input: { issueId: $issueId, body: $body }) { success }
    }
  `;
  type Resp = { commentCreate: { success: boolean } };
  const data = await gql<Resp>(apiKey, m, { issueId, body });
  return data.commentCreate.success;
}

async function getIssueId(apiKey: string, identifier: string): Promise<string> {
  const q = `#graphql
    query Q($identifier: String!) { issue(identifier: $identifier) { id } }
  `;
  type R = { issue: { id: string } | null };
  const data = await gql<R>(apiKey, q, { identifier });
  if (!data.issue) throw new Error(`Issue ${identifier} not found`);
  return data.issue.id;
}

export async function fetchIssuesByProject(apiKey: string, projectName: string, first = 200): Promise<LinearIssue[]> {
  const q = `#graphql
    query($projectName: String!, $first: Int!) {
      issues(filter: { project: { name: { eq: $projectName } } }, first: $first) {
        nodes { id identifier title description labels { nodes { name } } }
      }
    }
  `;
  type R = { issues: { nodes: Array<{ id: string; identifier: string; title: string; description?: string; labels: { nodes: { name: string }[] } }> } };
  const data = await gql<R>(apiKey, q, { projectName, first });
  return data.issues.nodes.map(n => ({
    id: n.id,
    identifier: n.identifier,
    title: n.title,
    description: n.description,
    labels: (n.labels?.nodes || []).map(l => l.name.toLowerCase()),
    blockedBy: [],
  }));
}

export async function findProjectByName(apiKey: string, projectName: string): Promise<{ id: string; name: string } | null> {
  const q = `#graphql
    query($name: String!) { projects(filter: { name: { eq: $name } }, first: 1) { nodes { id name } } }
  `;
  type R = { projects: { nodes: Array<{ id: string; name: string }> } };
  const data = await gql<R>(apiKey, q, { name: projectName });
  return data.projects.nodes[0] || null;
}

export async function getProjectTeam(apiKey: string, projectId: string): Promise<{ id: string; name: string } | null> {
  const q = `#graphql
    query($id: String!) { project(id: $id) { team { id name } } }
  `;
  type R = { project: { team: { id: string; name: string } } | null };
  const data = await gql<R>(apiKey, q, { id: projectId });
  return data.project?.team || null;
}

export async function findCycleByName(apiKey: string, cycleName: string): Promise<{ id: string; name: string } | null> {
  const q = `#graphql
    query($name: String!) { cycles(filter: { name: { eq: $name } }, first: 1) { nodes { id name } } }
  `;
  type R = { cycles: { nodes: Array<{ id: string; name: string }> } };
  const data = await gql<R>(apiKey, q, { name: cycleName });
  return data.cycles.nodes[0] || null;
}
