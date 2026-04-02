# Updating a Project

## Prerequisites

For a clean update, ensure:

1. The project has a valid `.copier-answers.yml` file
2. The template is versioned with Git tags
3. The project's Git status is clean (`git status` shows no changes)

## Basic Update

```bash
cd my-project
copier update
```

Copier reads available Git tags, compares using PEP 440, and checks out the latest one.

## Update Options

```bash
# Use all previous answers without re-prompting
copier update --defaults

# Override one answer, keep others
copier update --defaults --data author="New Name"

# Update answers only, don't change template version
copier update --vcs-ref=:current:

# Skip questions that already have answers
copier update --skip-answered

# Update to latest commit (not latest tag)
copier update --vcs-ref HEAD

# Update to a specific version
copier update --vcs-ref v2.0.0

# Update a project using a non-default answers file
copier update -a .copier-answers.pre-commit.yml
```

## Conflict Handling

When Copier can't automatically merge a diff hunk, it writes a conflict. Control the format with
`--conflict`:

```bash
copier update --conflict inline   # default: conflict markers in file
copier update --conflict rej      # separate .rej files per conflicted file
```

**Inline** (default) looks like:

```
<<<<<<< before updating
old content
=======
new content
>>>>>>> after updating
```

**Reject** creates `filename.rej` files with the unresolved diffs.

Review all conflicts manually before committing.

### Pre-commit Hooks to Prevent Committing Conflicts

For `--conflict inline`:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.3.0
    hooks:
      - id: check-merge-conflict
        args: [--assume-in-merge]
```

For `--conflict rej`:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: forbidden-files
        name: forbidden files
        entry: found .rej files; review and remove them before merging.
        language: fail
        files: "\\.rej$"
```

## Never Edit the Answers File Manually

Manual edits confuse Copier's diff algorithm — unsupported. To change one answer:

```bash
copier update --defaults --data updated_question="my new answer"
```

Or via a data file:

```bash
echo "updated_question: my new answer" > /tmp/data.yaml
copier update --defaults --data-file /tmp/data.yaml
```

## How the Update Algorithm Works

1. Regenerates a fresh project from the **current** template version
2. Computes diff: fresh → your current project (your customizations)
3. Applies pre-migrations, then re-prompts and generates from the **latest** template version
4. Re-applies the diff (your customizations) on top
5. Runs post-migrations

## Handling Deleted Files

Files deleted from your project are excluded from future updates. If you want a deleted file
re-added, run `copier recopy` and commit it; subsequent updates will respect it again.

Exception: files matched by `_skip_if_exists` are always re-created if missing during updates.

## Recovering from a Broken Update

If `copier update` fails (e.g. the old template used a removed Jinja extension), fall back to:

```bash
copier recopy ./my-project
```

This bypasses the diff algorithm and re-applies the template directly, keeping your answers. You'll
lose automatic merging of your customizations — use `git diff` to review and recover them manually.

## Aborting an Update

```bash
git reset           # discard merge conflict information
git checkout .      # restore modified tracked files
git clean -d -i     # interactively remove untracked files/folders
```

## Checking for Updates

```bash
# Human-readable output
copier check-update
# → "Project is up-to-date!" or "New template version available. Current: 1.0.0, latest: 2.0.0."

# Include prereleases
copier check-update --prereleases

# JSON output (for scripting)
copier check-update --output-format json
# → {"update_available": true, "current_version": "1.0.0", "latest_version": "2.0.0"}

# Quiet: exit code 0 = up to date, exit code 2 = update available
copier check-update --quiet
```
