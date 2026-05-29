# Branch Review Workflow

Review local branches for code quality, correctness, redundancy, and conformance to project patterns.

## Arguments

- `$ARGUMENTS` - Branch name to review. If omitted, reviews the current branch against main/master.

---

## Step 1: Determine Branch to Review

- **If a branch name is provided as an argument:** Use that branch.
- **If no branch name is provided:** Use the current branch.

```bash
BRANCH_NAME=${1:-$(git rev-parse --abbrev-ref HEAD)}
echo "Reviewing branch: $BRANCH_NAME"
```

---

## Step 2: Setup and Validation

### 2a. Determine the base branch:

Check which base branch exists:

```bash
if git show-ref --verify --quiet refs/heads/main; then
  BASE_BRANCH="main"
elif git show-ref --verify --quiet refs/heads/master; then
  BASE_BRANCH="master"
else
  echo "Error: Neither main nor master branch found"
  exit 1
fi
echo "Comparing against: $BASE_BRANCH"
```

### 2b. Ensure we're on the review branch:

```bash
git checkout $BRANCH_NAME
git pull origin $BRANCH_NAME
```

### 2c. Fetch latest base branch:

```bash
git fetch origin $BASE_BRANCH
```

### 2d. Get the list of changed files:

```bash
git diff origin/$BASE_BRANCH...$BRANCH_NAME --name-only
```

Store the count and list for the report.

---

## Step 3: Load Project Patterns

Read the project's coding standards and patterns:

### 3a. Check for CLAUDE.md:

Read `CLAUDE.md` or `claude.md` from the repository root if they exist.

### 3b. Check for agent.md:

Read `agent.md` or `AGENT.md` from the repository root if they exist.

Read `docs/ai/product-overview.md`.

### 3c. Extract key patterns:

- Code style and conventions
- Component/service patterns
- File organization standards
- Naming conventions
- Error handling patterns
- Testing requirements

---

## Step 4: Analyze the Code Changes

### 4a. Get the full diff:

```bash
git diff origin/$BASE_BRANCH...$BRANCH_NAME
```

### 4b. Get detailed file statistics:

```bash
git diff origin/$BASE_BRANCH...$BRANCH_NAME --stat
```

### 4c. For each changed file, read the full context if needed:

When reviewing changes, Claude can read the entire file or related files to understand the full context:

```bash
cat path/to/changed/file.cs
```

### 4d. Analyze each changed file:

**Correctness:**

- Does the code do what it claims to do?
- Are there logic errors or edge cases not handled?
- Are there potential runtime errors (null checks, exception handling)?
- For C#: Are nullable reference contexts properly handled?
- For Vue: Are reactive properties properly declared?

**Redundancy:**

- Is there duplicate code that could be refactored?
- Are there existing utilities/helpers that could be reused?
- Are there unnecessary imports or dead code?
- Could existing patterns/components be leveraged?

**Pattern Conformance:**

- Does the code follow the project's established patterns from agent.md/CLAUDE.md?
- Is the file in the correct location per project structure?
- Are naming conventions followed (PascalCase for C#, kebab-case for Vue)?
- Is the code style consistent with the codebase?
- Are the correct services/controllers being used?

**C#-Specific Checks:**

- Are using statements organized correctly?
- Are exceptions properly typed and handled?
- Are interfaces used where appropriate?
- Is dependency injection used correctly?
- Are LINQ queries efficient?
- Are resources properly disposed (IDisposable, using statements)?

**Vue-Specific Checks:**

- Are components properly structured (setup, template, style)?
- Are props and emits properly typed?
- Is reactivity handled correctly (ref, reactive, computed)?
- Are lifecycle hooks used appropriately?
- Is the composition API or options API used consistently?
- Are watchers used appropriately vs computed properties?

**MVC-Specific Checks:**

- Are controllers thin (logic in services)?
- Are views properly bound to models?
- Are routes configured correctly?
- Is model validation implemented?
- Are action results appropriate for the response type?

**Additional Checks:**

- Performance: Are there obvious performance concerns (N+1 queries, inefficient loops)?
- Error handling: Are errors properly caught and handled?
- Types: Are types properly defined and used?
- Testing: Are there tests for new functionality?

---

## Step 5: Generate Review Report

### Summary

- **Branch:** `<branch-name>`
- **Base:** `<base-branch>`
- **Files Changed:** `<count>`
- **Lines:** +`<additions>` / -`<deletions>`

### Code Review Findings

**Correctness Issues:**

- List any bugs, logic errors, or missing edge cases
- Reference specific files and line numbers
- Provide code snippets where helpful

**Redundancy Issues:**

- List duplicate code or missed reuse opportunities
- Suggest existing utilities that could be used
- Show where similar patterns already exist in the codebase

**Pattern Violations:**

- List deviations from project patterns
- Reference the specific pattern from agent.md/CLAUDE.md
- Explain the expected pattern

**Security Concerns:**

- List any potential security issues
- Explain the risk and suggest remediation

**Performance Concerns:**

- List any inefficient code patterns
- Suggest optimizations

**Best Practice Suggestions:**

- List recommended improvements (not blockers)
- Provide examples of better approaches

### Verdict

**RECOMMEND CHANGES** if:

- Critical security issues found
- Major correctness issues found
- Significant pattern violations that affect maintainability

**APPROVE WITH SUGGESTIONS** if:

- Code is functionally correct
- Minor improvements recommended but not required

**APPROVE** if:

- Code is high quality with no concerns

---

## Step 6: Present Report to User

Display the complete review report and ask for confirmation on next steps:

```
Review complete. Would you like me to:
1. Save this report to a file
2. Review specific files in more detail
3. Check for additional context from related files
4. Explain any finding in more detail
5. Nothing more (review complete)
```

---

## Step 7: Cleanup

Return to the original branch if needed:

```bash
git checkout $BASE_BRANCH
```
