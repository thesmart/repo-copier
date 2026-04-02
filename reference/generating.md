# Generating a Project

## Basic Usage

```bash
copier copy <template> <destination>
```

If `<destination>` doesn't exist, Copier creates it. If it exists, it must be writable.

## Template Sources

```bash
# Local path
copier copy ./my-template ./my-project

# GitHub shortcut
copier copy gh:owner/repo ./my-project

# GitLab shortcut
copier copy gl:owner/repo ./my-project

# Full Git URL (use when URL isn't auto-detected as Git)
copier copy git+https://github.com/owner/repo.git ./my-project
copier copy git@github.com:owner/repo.git ./my-project
```

## Passing Answers

Pre-answer questions to avoid interactive prompts:

```bash
# Single value
copier copy -d project_name="My Project" template/ dest/

# Multiple values
copier copy -d project_name="My Project" -d author="Alice" template/ dest/

# Force: use defaults + overwrite existing files
copier copy -fd project_name="My Project" template/ dest/

# From a YAML file
copier copy --data-file answers.yml template/ dest/

# Multiselect answer
copier copy -d 'python_versions=["3.11", "3.12"]' template/ dest/
```

## Selecting Template Version

By default Copier uses the **latest Git tag** (sorted by PEP 440).

```bash
# Use a specific tag
copier copy --vcs-ref v1.2.0 gh:owner/template ./dest

# Use the latest commit on a branch
copier copy --vcs-ref master gh:owner/template ./dest

# Use local dirty changes (HEAD including uncommitted modifications)
copier copy --vcs-ref HEAD ./local-template ./dest
```

## Trusted Templates

Templates using tasks, migrations, or Jinja extensions require explicit trust:

```bash
copier copy --trust gh:owner/template ./dest
# or equivalently
copier copy --UNSAFE gh:owner/template ./dest
```

To mark repos as permanently trusted, see
[user-settings.md#trusted-locations](./user-settings.md#trusted-locations).

## Other Useful Flags

| Flag                    | Description                             |
| ----------------------- | --------------------------------------- |
| `--defaults`            | Use default answers, no prompts         |
| `--overwrite`           | Overwrite existing files without asking |
| `--pretend` / `-n`      | Dry run — no files written              |
| `--quiet` / `-q`        | Suppress output                         |
| `--skip` / `-s`         | Additional skip-if-exists patterns      |
| `--exclude` / `-x`      | Additional exclude patterns             |
| `--answers-file` / `-a` | Custom answers file path                |
| `--no-cleanup` / `-C`   | Don't delete destination on error       |

## Applying to an Existing Project

```bash
copier copy gh:owner/template ./my-existing-git-project
```

## Regenerating a Project

`copier recopy` re-applies the template keeping answers but ignoring the update diff algorithm. Use
only to recover from a broken `update` — it discards project customizations.

```bash
copier recopy ./my-project
```
