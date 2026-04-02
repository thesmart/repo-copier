---
name: repo-copier
description: "Use this skill when the user is working with the `copier` CLI tool specifically — generating a project from a copier template (`copier copy`), updating a copier-managed project (`copier update`), authoring a copier template (i.e. a Git repo with `copier.yml`), or configuring `copier.yml`. Also trigger for questions about `.copier-answers.yml`, `_tasks`, `_exclude`, or other copier-specific settings. Do NOT trigger for general Jinja2 templating, Flask/Django/Ansible templates, or other tools that happen to use Jinja."
license: PolyForm Internal Use License 1.0.0
compatibility: Designed for Claude Code (and compatible)
metadata:
  author: github.com/thesmart
  version: "1.0.2"
---

Copier is a CLI tool for rendering project templates and keeping generated projects in sync with
those templates over time. Templates are Git repos; generated projects record their answers in
`.copier-answers.yml` to enable future updates.

## Reference Files

Read these on demand — don't load all of them upfront:

| File                                                                 | When to read                                                   |
| -------------------------------------------------------------------- | -------------------------------------------------------------- |
| [reference/creating.md](./reference/creating.md)                     | Authoring templates: file handling, variables, yield loops     |
| [reference/configuring.md](./reference/configuring.md)               | `copier.yml` questions, conditional files, tasks, answers file |
| [reference/settings-reference.md](./reference/settings-reference.md) | Full list of all `_` settings with CLI flags and defaults      |
| [reference/generating.md](./reference/generating.md)                 | `copier copy` options, version selection, flags                |
| [reference/updating.md](./reference/updating.md)                     | `copier update`, conflict handling, check-update               |
| [reference/user-settings.md](./reference/user-settings.md)           | Global user defaults, trusted repos                            |
| [reference/faq.md](./reference/faq.md)                               | Computed values, context hooks, credentials, dirty changes     |

---

## Core Operations

### Generate a project from a template

```bash
copier copy <template> <destination>
```

Template sources:

```bash
copier copy ./my-local-template ./my-project
copier copy gh:owner/repo ./my-project        # GitHub shorthand
copier copy gl:owner/repo ./my-project        # GitLab shorthand
copier copy git+https://github.com/owner/repo.git ./my-project
```

Common flags:

```bash
copier copy -d project_name="Acme API" gh:org/template ./dest   # pre-answer a question
copier copy --defaults gh:org/template ./dest                    # use all defaults, no prompts
copier copy --vcs-ref v2.0.0 gh:org/template ./dest             # pin to a specific version
copier copy --vcs-ref HEAD ./local-template ./dest              # include uncommitted changes
copier copy --trust gh:org/template ./dest                      # required for templates with tasks/migrations/extensions
copier copy --pretend gh:org/template ./dest                    # dry run
```

> Use `--trust` (or `--UNSAFE`) whenever a template defines `_tasks`, `_migrations`, or
> `_jinja_extensions`. Without it, copier exits with code 4.

### Update a project

```bash
cd my-project
copier update
```

Prerequisites for a clean update:

1. Project has a `.copier-answers.yml` (created at `copier copy` time)
2. Template has Git tags (copier picks the latest PEP 440 tag)
3. Project has a clean `git status`

Common update flags:

```bash
copier update --defaults                          # reuse all previous answers silently
copier update --defaults --data author="New Name" # override one answer
copier update --vcs-ref v3.0.0                    # update to a specific version
copier update --vcs-ref=:current:                 # re-answer questions without changing version
copier update --skip-answered                     # skip questions that already have answers
copier update --conflict rej                      # write .rej files instead of inline markers
```

Check if an update is available:

```bash
copier check-update
copier check-update --output-format json   # machine-readable
```

Abort an update that went wrong:

```bash
git reset && git checkout . && git clean -d -i
```

### Check for updates

```bash
copier check-update                            # human-readable
copier check-update --output-format json       # {"update_available": true, ...}
copier check-update --quiet                    # exit 0 = up to date, exit 2 = update available
```

---

## Creating a Template

A template is a directory (usually the root of a Git repo) containing `copier.yml` and template
files.

### Minimal structure

- `my-template/` — template root directory
- `my-template/copier.yml` — questions + settings
- `my-template/{{ _copier_conf.answers_file }}.jinja` — always include for update support
- `my-template/{{ project_name }}/` — project root folder (templated name)
- `my-template/{{ project_name }}/{{ module_name }}.py.jinja` — rendered Python module

**Always include the answers file template** — without it, `copier update` won't work:

```
# {{ _copier_conf.answers_file }}.jinja
# Changes here will be overwritten by Copier; NEVER EDIT MANUALLY
{{ _copier_answers|to_nice_yaml -}}
```

### File rendering rules

- Files ending in `.jinja` → rendered by Jinja2, output without the `.jinja` suffix
- All other files → copied as-is
- File and directory names can contain `{{ jinja_expressions }}` — they're evaluated to produce the
  actual name
- If both `README.md` and `README.md.jinja` exist, the `.jinja` version wins

### `copier.yml` quick reference

Simple format:

```yaml
project_name: my-project # string question, default provided
port: 8080 # int detected automatically
```

Full format (any key can use these fields):

```yaml
project_name:
  type: str # bool | float | int | json | path | str | yaml
  help: What is your project name?
  default: my-project
  placeholder: acme-service
  validator: >-
    {% if not (project_name | regex_search('^[a-z][a-z0-9\-]+$')) %} Must be lowercase letters,
    digits, or dashes. {% endif %}

use_docker:
  type: bool
  default: yes

python_versions:
  type: str
  multiselect: true
  choices: ["3.11", "3.12", "3.13"]
  default: '["3.12"]'

license:
  type: str
  when: "{{ not proprietary }}" # skip question when condition is false
```

**Computed values** (never asked, not stored in answers):

```yaml
next_year:
  type: int
  default: "{{ current_year + 1 }}"
  when: false
```

### Common settings in `copier.yml`

```yaml
_tasks:
  - "git init"
  - command: "pip install -e ."
    when: "{{ _copier_operation == 'copy' }}"

_exclude:
  - "*.pyc"
  - "__pycache__"

_skip_if_exists:
  - .env
  - secrets.yml

_min_copier_version: "9.0.0"

_message_after_copy: |
  Project "{{ project_name }}" created!
  Next: cd {{ _copier_conf.dst_path }} && make install
```

> `_exclude` in `copier.yml` **replaces** the default list. CLI `--exclude` **extends** it. Tasks
> require `--trust` from the user running `copier copy`/`copier update`.

### Global template variables

Always available in Jinja templates:

| Variable                    | Description                                                |
| --------------------------- | ---------------------------------------------------------- |
| `_copier_answers`           | All answers (minus secrets) — use in answers file template |
| `_copier_conf.answers_file` | Path for the answers file                                  |
| `_copier_conf.dst_path`     | Destination directory                                      |
| `_copier_conf.src_path`     | Template source directory                                  |
| `_copier_conf.os`           | `"linux"`, `"macos"`, `"windows"`, or `None`               |
| `_copier_operation`         | `"copy"` or `"update"`                                     |
| `_copier_phase`             | `"prompt"`, `"render"`, `"tasks"`, or `"migrate"`          |
| `_folder_name`              | Name of the project root directory                         |
| `_copier_python`            | Python interpreter running Copier (useful in `_tasks`)     |

---

## Common Pitfalls

- **Don't edit `.copier-answers.yml` manually** — use `copier update --defaults --data key=value`
  instead
- **Template not found / template uses old version** — copier uses the latest Git tag by default;
  use `--vcs-ref HEAD` to test local uncommitted changes
- **`copier update` fails** — if the old template used a removed Jinja extension, fall back to
  `copier recopy` (bypasses the diff algorithm; you'll need to manually recover customizations from
  `git diff`)
- **Credentials in URLs** — don't put credentials in the template URL (they end up in
  `.copier-answers.yml`); use SSH or a credential helper instead
- **High CPU/memory** — caused by shallow clones; fix with `git clone --no-shallow`

---

## Applying Multiple Templates to One Project

Use a different answers file per template:

```bash
copier copy -a .copier-answers.main.yml gh:org/main-template .
copier copy -a .copier-answers.ci.yml gh:org/ci-template .

# Update each independently
copier update -a .copier-answers.main.yml
copier update -a .copier-answers.ci.yml
```

Each template's `copier.yml` should set `_answers_file` to match:

```yaml
_answers_file: .copier-answers.ci.yml
```
