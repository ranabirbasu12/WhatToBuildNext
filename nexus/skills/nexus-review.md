 # Nexus Review — Cross-Agent Review Skill

## Overview

Every piece of work in Nexus gets reviewed by the OTHER agent. Claude reviews Codex's work. Codex reviews Claude's work. This skill defines how.

## Why Cross-Review

- Single-agent review has blind spots — the same model that wrote the code won't catch its own systematic errors
- Claude excels at architectural coherence and big-picture issues
- Codex excels at systematic bug hunting and edge case detection
- Disagreements surface insights that neither agent would find alone

## Review Workflows

### Claude Reviews Codex's Work

After Codex completes a task:

1. **Read the diff**: `git diff` or `git diff HEAD~1` to see exactly what changed
2. **Check architectural coherence**: Does this fit the overall design? Does it follow patterns used elsewhere?
3. **Check conventions**: Does it follow `nexus/context/conventions.md`?
4. **Run tests independently**: Never trust that Codex ran them
5. **Look for**:
   - Architectural drift (doing things differently from the rest of the codebase)
   - Missing error handling at system boundaries
   - Security issues (injection, auth bypass, data exposure)
   - Over-engineering or unnecessary complexity
   - Missing tests for edge cases

**Verdict format:**
```
REVIEW: [APPROVED | CHANGES_REQUESTED]
Files reviewed: [list]
Strengths: [what's good]
Issues: [if any, with file:line references]
Recommendation: [what to fix or "ready to merge"]
```

### Codex Reviews Claude's Work

After Claude completes a task, dispatch a review:

```bash
./nexus/scripts/nexus-dispatch.sh \
  --mode reviewer \
  --task-id TXXX-review \
  --prompt "Review the changes in the last commit (git diff HEAD~1). Focus on:
1. Bugs and logic errors
2. Edge cases not handled
3. Security vulnerabilities
4. Test coverage gaps
5. Convention violations (see CONVENTIONS section above)

For each issue found, provide:
- Severity: critical / important / minor
- File and line number
- What's wrong
- Suggested fix

If no issues found, say APPROVED." \
  --dir /path/to/project
```

### Disagreement Resolution

When Claude and Codex disagree:

1. **Document both perspectives clearly**
2. **Present to human with your recommendation**:
   > "Codex suggests [X] because [reasons]. I think [Y] because [reasons]. I recommend [your pick] because [why]. What do you think?"
3. **Log the decision** in knowledge base regardless of outcome

```bash
./nexus/scripts/nexus-knowledge.sh add \
  --type decision \
  --fact "Chose X over Y for [reason]" \
  --rec "Use X pattern for similar situations" \
  --tags "architecture,review" \
  --source human
```

## Review Checklist

For any code review (by either agent), check:

- [ ] Does it do what the task asked for? (spec compliance)
- [ ] Are there tests? Do they cover the happy path AND edge cases?
- [ ] Does it follow project conventions?
- [ ] Are there security concerns?
- [ ] Is it simple? Could it be simpler?
- [ ] Does it handle errors at system boundaries?
- [ ] Will it break anything else? (integration concerns)

## Logging Reviews

After every review:
```bash
./nexus/scripts/nexus-board.sh update \
  --id T001 \
  --reviewed-by claude \
  --review-status approved \
  --note "Review: clean implementation, good test coverage, no issues"
```

Or if changes needed:
```bash
./nexus/scripts/nexus-board.sh update \
  --id T001 \
  --reviewed-by claude \
  --review-status changes_requested \
  --note "Review: missing null check in auth middleware line 42, no test for expired tokens"
```

## Post-Review Reflection

After every review (by either agent), extract learnings:

```bash
# If review found issues
./nexus/scripts/nexus-reflect.sh extract \
  --task-id T001 \
  --outcome retry \
  --fact "Review found: [specific issue]" \
  --rec "Check for [issue type] before submitting" \
  --type gotcha \
  --tags "review,quality"

# If review was clean
./nexus/scripts/nexus-reflect.sh extract \
  --task-id T001 \
  --outcome success \
  --fact "Clean review — [what went right]" \
  --rec "Continue using [approach]" \
  --type pattern \
  --tags "review,quality"
```

This is how Nexus learns from reviews over time.
