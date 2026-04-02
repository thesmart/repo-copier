# Settings Reference

All settings go in `copier.yml` prefixed with `_` (e.g. `_tasks`). Some are CLI-only or API-only as
noted.

For commonly used settings with examples, see
[configuring.md](./configuring.md#most-used-settings).

---

## `answers_file`

- **Format:** `str`
- **CLI:** `-a`, `--answers-file`
- **Default:** `.copier-answers.yml`
- **In copier.yml:** Yes

Path (relative to project root) where answers are recorded. Required for update support.

```yaml
_answers_file: .copier-answers.my-template.yml
```

---

## `cleanup_on_error`

- **Format:** `bool`
- **CLI:** `-C`, `--no-cleanup` (disables it; only in `copier copy`)
- **Default:** `True`
- **In copier.yml:** No

When `True`, deletes the destination folder if an error occurs during generation. Has no effect on
`copier update` (destination already exists).

---

## `conflict`

- **Format:** `Literal["rej", "inline"]`
- **CLI:** `-o`, `--conflict` (only in `copier update`)
- **Default:** `inline`
- **In copier.yml:** No

How unresolvable diff hunks are written during updates:

- `inline` — conflict markers in the file (like `git merge`)
- `rej` — separate `.rej` files for each conflicted file

---

## `context_lines`

- **Format:** `int`
- **CLI:** `-c`, `--context-lines` (only in `copier update`)
- **Default:** `1`
- **In copier.yml:** No

Lines of context used when comparing template evolution vs project evolution during updates. More
lines = more accurate but more conflicts. Git uses 3 by default.

---

## `data`

- **Format:** `dict | List[str=str]`
- **CLI:** `-d`, `--data`
- **Default:** N/A
- **In copier.yml:** No (use questions with defaults instead)

Pre-answer questions via CLI/API:

```bash
copier copy -d project_name="My Project" -d author="Alice" template/ dest/
copier copy -fd 'user_name=Manuel'   # -f also sets --force
```

For multiselect questions, pass a YAML list:

```bash
copier copy -d 'python_versions=["3.11", "3.12"]' template/ dest/
```

---

## `data_file`

- **Format:** `str` (path to YAML file)
- **CLI:** `--data-file`
- **Default:** N/A
- **In copier.yml:** No (CLI only)

Alternative to `--data`. Pass a YAML file of answers:

```bash
copier copy --data-file answers.yml template/ dest/
```

`--data` flags always take precedence over `--data-file`.

---

## `defaults`

- **Format:** `bool`
- **CLI:** `--defaults`
- **Default:** `False`
- **In copier.yml:** No

Use default answers without prompting. Questions without defaults must be pre-answered via `--data`
or an error is raised.

```bash
copier update --defaults
copier update --defaults --data key=new_value
```

---

## `envops`

- **Format:** `dict`
- **CLI:** N/A
- **Default:** `{"keep_trailing_newline": true}`
- **In copier.yml:** Yes

Jinja2 environment options. Copier preserves trailing newlines by default. To change block/variable
delimiters:

```yaml
_envops:
  block_start_string: "[%"
  block_end_string: "%]"
  variable_start_string: "[["
  variable_end_string: "]]"
  keep_trailing_newline: true
```

---

## `exclude`

- **Format:** `List[str]`
- **CLI:** `-x`, `--exclude`
- **Default:**
  `["copier.yaml", "copier.yml", "~*", "*.py[co]", "__pycache__", ".git", ".DS_Store", ".svn"]`
- **In copier.yml:** Yes (replaces defaults)

Gitignore-style patterns for files/folders to never copy. Each pattern can be templated.

```yaml
_exclude:
  - "*.txt"
  - "!important.txt" # negation: don't exclude this one
  - "{% if _copier_operation == 'update' %}src/*_example.py{% endif %}"
```

> In `copier.yml`: **replaces** defaults. Via CLI: **extends** the `copier.yml` list.

When `_subdirectory` is a real subdirectory, the default becomes `[]`.

---

## `external_data`

- **Format:** `dict[str, str]`
- **CLI:** N/A
- **Default:** `{}`
- **In copier.yml:** Yes

Load data from existing YAML files in the project. Keys become namespaces under `_external_data`.

```yaml
_external_data:
  parent_tpl: .copier-answers.yml # static path
  secrets: .secrets.yaml # optional; returns {} if missing
  config: "{{ config_file }}" # dynamic path (must be answerable first)
```

Access in templates: `{{ _external_data.parent_tpl.some_key }}`

Reading from outside the project root requires `--trust`.

---

## `force`

- **Format:** `bool`
- **CLI:** `-f`, `--force` (not in `copier update`)
- **Default:** `False`
- **In copier.yml:** No

Overwrite existing files without asking AND use defaults without prompting (combines
`--overwrite` + `--defaults`).

---

## `jinja_extensions`

- **Format:** `List[str]`
- **CLI:** N/A
- **Default:** `[]`
- **In copier.yml:** Yes

Additional Jinja2 extensions. The `jinja2_ansible_filters` extension is always loaded. Users must
install listed extensions alongside Copier.

```yaml
_jinja_extensions:
  - jinja2_time.TimeExtension
  - jinja_markdown.MarkdownExtension
  - copier_templates_extensions.TemplateExtensionLoader
```

Install extensions with Copier:

```bash
pipx inject copier jinja2-time
uv tool install --with jinja2-time copier
```

> Requires `--trust` from the template consumer.

---

## `message_before_copy` / `message_after_copy`

- **Format:** `str`
- **CLI:** N/A
- **Default:** `""`
- **In copier.yml:** Yes

Messages printed before/after generating a project. Supports Jinja rendering.

```yaml
_message_before_copy: |
  Thanks for using our template. Answer a few questions to get started.

_message_after_copy: |
  Your project "{{ project_name }}" is ready!
  Next: cd {{ _copier_conf.dst_path }} && make install
```

---

## `message_before_update` / `message_after_update`

Same as above but for `copier update` runs.

```yaml
_message_after_update: |
  Updated "{{ project_name }}"! Resolve any conflicts, then commit.
```

---

## `migrations`

- **Format:** `List[str | List[str] | dict]`
- **CLI:** N/A
- **Default:** `[]`
- **In copier.yml:** Yes

Commands run during updates (not on initial copy). Useful for data migrations between template
versions.

```yaml
_migrations:
  - version: v2.0.0
    command: python migrate_to_v2.py
    when: "{{ _stage == 'before' }}"
  - invoke -r {{ _copier_conf.src_path }} -c migrations migrate $STAGE $VERSION_FROM $VERSION_TO
```

Available environment variables: `$STAGE` (`before`/`after`), `$VERSION_FROM`, `$VERSION_TO`,
`$VERSION_CURRENT`.

Runs only when `new_version >= declared_version > old_version`. Requires `--trust`.

---

## `min_copier_version`

- **Format:** `str` (PEP 440)
- **CLI:** N/A
- **Default:** N/A
- **In copier.yml:** Yes

Minimum Copier version required. Aborts generation if not met.

```yaml
_min_copier_version: "9.0.0"
```

---

## `overwrite`

- **Format:** `bool`
- **CLI:** `--overwrite` (not in `copier update`)
- **Default:** `False`
- **In copier.yml:** No

Overwrite existing files without asking (without also setting `--defaults`).

Required when using the Python API for updates.

---

## `preserve_symlinks`

- **Format:** `bool`
- **CLI:** N/A
- **Default:** `False`
- **In copier.yml:** Yes

Keep symlinks as symlinks. When `False`, symlinks are replaced with the file they point to. When
`True` and the symlink ends with `.jinja`, the target path is Jinja-rendered.

---

## `pretend`

- **Format:** `bool`
- **CLI:** `-n`, `--pretend`
- **Default:** `False`
- **In copier.yml:** No

Dry run — go through all steps but write nothing.

---

## `quiet`

- **Format:** `bool`
- **CLI:** `-q`, `--quiet`
- **Default:** `False`
- **In copier.yml:** No

Suppress all status output (including `message_after_copy`).

---

## `secret_questions`

- **Format:** `List[str]`
- **CLI:** N/A
- **Default:** `[]`
- **In copier.yml:** Yes

Mark questions as secret via a list (alternative to `secret: true` in each question):

```yaml
_secret_questions:
  - password
  - api_key

password: ""
api_key: ""
```

---

## `skip_answered`

- **Format:** `bool`
- **CLI:** `-A`, `--skip-answered` (only in `copier update`)
- **Default:** `False`
- **In copier.yml:** No

During updates, skip questions that already have answers. Keeps the recorded answer without
re-prompting.

---

## `skip_if_exists`

- **Format:** `List[str]`
- **CLI:** `-s`, `--skip`
- **Default:** `[]`
- **In copier.yml:** Yes

Gitignore-style patterns for files to skip if they already exist. They are still created on first
copy (and recreated during updates if deleted).

```yaml
_skip_if_exists:
  - .env
  - .secret_password.yml
```

---

## `skip_tasks`

- **Format:** `bool`
- **CLI:** `-T`, `--skip-tasks`
- **Default:** `False`
- **In copier.yml:** No

Skip `_tasks` execution. Does not skip `_migrations`. Requires `--trust` to have any effect (since
tasks need trust anyway).

---

## `subdirectory`

- **Format:** `str`
- **CLI:** N/A
- **Default:** N/A (use template root)
- **In copier.yml:** Yes

Use a subdirectory of the template repo as the actual template root. Allows separating template
metadata from template content.

```yaml
_subdirectory: template
```

Dynamic (useful for choosing between template variants):

```yaml
_subdirectory: "{{ framework }}"
framework:
  type: str
  choices: [django, fastapi]
```

> Recommendation: 1 template = 1 Git repository. `_subdirectory` is for separating metadata, not
> hosting multiple templates.

---

## `tasks`

- **Format:** `List[str | List[str] | dict]`
- **CLI:** N/A
- **Default:** `[]`
- **In copier.yml:** Yes

Commands run after generating or updating a project. Run in order, each in its own subprocess with
`$STAGE=task`.

```yaml
_tasks:
  - "git init"
  - [pip, install, -e, .]
  - command: "git init"
    when: "{{ _copier_operation == 'copy' }}"
  - command: rm README.md
    working_directory: "{{ _copier_conf.dst_path }}/subdir"
```

> Requires `--trust` from consumer.

---

## `templates_suffix`

- **Format:** `str`
- **CLI:** N/A
- **Default:** `.jinja`
- **In copier.yml:** Yes

File suffix that triggers Jinja rendering. Set to `""` to render every file.

```yaml
_templates_suffix: ".tmpl"
_templates_suffix: ""   # render all files
```

---

## `unsafe`

- **Format:** `bool`
- **CLI:** `--UNSAFE`, `--trust`
- **Default:** `False`
- **In copier.yml:** No (consumer sets it)

Allow templates that use `_tasks`, `_migrations`, or `_jinja_extensions`. Without this, Copier
aborts with exit code 4.

```bash
copier copy --trust gh:owner/template ./dest
```

Set trusted repos globally:
[user-settings.md#trusted-locations](./user-settings.md#trusted-locations).

---

## `use_prereleases`

- **Format:** `bool`
- **CLI:** `-g`, `--prereleases`
- **Default:** `False`
- **In copier.yml:** No

Include prerelease tags (e.g. `v2.0.0a1`) when selecting the template version to use.

---

## `vcs_ref`

- **Format:** `str | VcsRef`
- **CLI:** `-r`, `--vcs-ref`
- **Default:** latest release tag (PEP 440 sorted)
- **In copier.yml:** No

Override which Git ref to use when copying or updating:

```bash
copier copy --vcs-ref master gh:owner/template ./dest
copier copy --vcs-ref HEAD ./local-template ./dest    # include dirty changes
copier update --vcs-ref=:current:                     # re-answer without changing version
```

The special value `:current:` keeps the current template version while re-answering questions.
