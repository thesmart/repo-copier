# Configuring a Template

## Configuration Sources

Copier reads **settings** (template behavior) from these sources, in priority order:

1. Command line / API arguments
2. `copier.yml` — settings keys start with `_` (e.g. `_tasks`)

Copier obtains **answers** (question responses) from these sources, in priority order:

1. Command line / API `--data` arguments
2. Interactive user prompts
3. Previous answers from `.copier-answers.yml`
4. Default values in `copier.yml`

## The `copier.yml` File

Found at the template root. Two purposes:

1. Define questions to prompt the user
2. Configure template settings (prefixed with `_`)

### Questions — Simple Format

```yaml
project_name: My awesome project # string, default provided
number_of_eels: 1234 # int detected automatically
your_email: "" # string, empty default
```

### Questions — Advanced Format

When the value is a dict, you get full control:

```yaml
project_name:
  type: str # bool | float | int | json | path | str | yaml
  help: What is your project name?
  default: my-project
  placeholder: acme-service
  validator: >-
    {% if not (project_name | regex_search('^[a-z][a-z0-9\-]+$')) %} Must be lowercase letters,
    digits, or dashes. {% endif %}

love_copier:
  type: bool
  qmark: "❤️" # custom prompt icon (default: 🎤, or 🕵️ for secrets)
  help: Do you love Copier?
  default: yes

rocket_password:
  type: str
  secret: true # hidden input; not saved to answers file; requires default
  placeholder: my top secret password

any_yaml:
  type: yaml
  multiline: true # allow multi-line input

project_license:
  type: str
  choices:
    MIT: &mit_text |
      Full MIT license text here.
    Apache2: |
      Full Apache2 license text.
  default: *mit_text # default is the VALUE, not the key

close_to_work:
  choices:
    - [at home, I work at home] # [display_key, value]
    - [less than 10km, quite close]

copyright_holder:
  type: str
  default: "{{ project_creator }}"
  when: "{{ project_license != 'Public domain' }}" # skip question conditionally
```

#### Choice Types

**Static choices:**

```yaml
cloud:
  type: str
  choices: [AWS, Azure, GCP]
```

**Conditional choices** (validator disables a choice with an error message):

```yaml
iac:
  type: str
  choices:
    Terraform: tf
    Cloud Formation:
      value: cf
      validator: "{% if cloud != 'AWS' %}Requires AWS{% endif %}"
```

**Dynamic choices** (rendered from a Jinja template):

```yaml
dependency_manager:
  type: str
  choices: |
    {%- if language == "python" %}
    - poetry
    - pipenv
    {%- else %}
    - npm
    - yarn
    {%- endif %}
```

**Multiselect:**

```yaml
python_versions:
  type: str
  multiselect: true
  choices: ["3.10", "3.11", "3.12"]
  default: '["3.11", "3.12"]'
```

#### The `when` Key

- `false` — skip question, use default as computed value (not stored in answers)
- `"{{ expr }}"` — evaluated as boolean; if false, question is skipped

```yaml
# Computed value (never asked, never stored)
next_year:
  type: int
  default: "{{ copyright_year + 1 }}"
  when: false
```

#### The `UNSET` Variable

Render `{{ UNSET }}` as a default to force the user to answer when no default applies:

```yaml
database_url:
  type: str
  default: >-
    {%- if database_engine == 'postgres' -%} postgresql://localhost/dbname {%- else -%} {{ UNSET }}
    {%- endif -%}
```

### Prompt Templating Rules

Most question keys support Jinja templating inside values (not keys):

```yaml
email:
  type: str
  default: "{{ username }}@{{ organization }}.com" # ✓ valid
```

Limitations:

- You can only template inside the value string
- You cannot reference variables not yet declared (questions are processed top-to-bottom)
- YAML interprets bare `{{ }}` — wrap in quotes

### Include Other YAML Files

```yaml
---
!include shared-conf/common.*.yml # glob supported
---
!include common-questions/web-app.yml
---
_skip_if_exists:
  - .password.txt
custom_question: default answer
```

Merging rules:

- Same question name → later document wins
- `exclude`, `skip_if_exists`, `jinja_extensions`, `secret_questions` → concatenated
- All other settings → later document wins

## Conditional Files and Directories

Use Jinja in file/directory names:

- `your_template/`
- `your_template/copier.yml`
- `your_template/{% if use_precommit %}.pre-commit-config.yaml{% endif %}.jinja`
- `your_template/{% if ci == 'github' %}.github{% endif %}/`
- `your_template/{% if ci == 'github' %}.github{% endif %}/workflows/`
- `your_template/{% if ci == 'github' %}.github{% endif %}/workflows/ci.yml`

> **Files**: `.jinja` suffix must appear **outside** the Jinja condition. **Directories**: must
> **not** end with `.jinja`. **Windows**: use single-quotes in directory names (double-quotes are
> invalid).

## Generating Directory Structures

```yaml
# copier.yml
package:
  type: str
  help: Package name (e.g. your_package.cli.main)
```

- `your_template/`
- `your_template/{{ package.replace('.', _copier_conf.sep) }}{{ _copier_conf.sep }}__main__.py.jinja`

## Importing Jinja Templates and Macros

```yaml
# copier.yml
_exclude:
  - includes/

slug:
  type: str
  default: "{% from 'includes/slugify.jinja' import slugify %}{{ slugify(name) }}"
```

Use `pathjoin()` for cross-platform paths in import/include statements:

```
{% include pathjoin('includes', 'name-slug.jinja') %}
{% from pathjoin('includes', 'slugify.jinja') import slugify %}
```

## Most-Used Settings

Settings go in `copier.yml` prefixed with `_`. Full reference:
[settings-reference.md](./settings-reference.md).

### `_tasks`

Commands to run after generating or updating the project:

```yaml
_tasks:
  - "git init"
  - "rm {{ name_of_the_project }}/README.md"
  - [invoke, "--search-root={{ _copier_conf.src_path }}", after-copy]
  - command: "git init"
    when: "{{ _copier_operation == 'copy' }}"
  - command: rm README.md
    when: "{{ _copier_conf.os in ['linux', 'macos'] }}"
```

> Tasks run with the same user permissions. Requires `--trust` flag from consumer.

### `_exclude`

Glob patterns for files/folders to never copy. Replaces the default list when defined in
`copier.yml`:

```yaml
_exclude:
  - "*.bar"
  - ".git"
  - "{% if _copier_operation == 'update' %}src/*_example.py{% endif %}"
```

Default excludes: `copier.yaml`, `copier.yml`, `~*`, `*.py[co]`, `__pycache__`, `.git`,
`.DS_Store`, `.svn`

> CLI `--exclude` **extends** the list from `copier.yml`. In `copier.yml`, it **replaces** the
> defaults.

### `_skip_if_exists`

Files to skip if they already exist (but always create on first copy):

```yaml
_skip_if_exists:
  - .secret_password.yml
  - .env
```

### `_answers_file`

Custom path for the answers file (default: `.copier-answers.yml`):

```yaml
_answers_file: .copier-answers.{{ _copier_conf.src_path | basename }}.yml
```

### `_subdirectory`

Use a subdirectory as the template root (useful for separating template metadata from template
content):

```yaml
_subdirectory: template
```

Or dynamically:

```yaml
_subdirectory: "{{ python_engine }}"
python_engine:
  type: str
  choices: [poetry, pipenv]
```

### `_min_copier_version`

Abort with an error if Copier is too old:

```yaml
_min_copier_version: "9.0.0"
```

### `_templates_suffix`

Default is `.jinja`. Change or clear it:

```yaml
_templates_suffix: "" # render every file as a template
```

### `_unsafe` / `--trust`

Templates using `_tasks`, `_migrations`, or `_jinja_extensions` require the consumer to pass
`--trust`:

```bash
copier copy --trust gh:owner/template ./destination
```

Not configurable in `copier.yml` (consumer sets it).

## The `.copier-answers.yml` File

Required for [update support](./updating.md). Your template must include a file named exactly
`{{ _copier_conf.answers_file }}.jinja` with this content:

```
# Changes here will be overwritten by Copier; NEVER EDIT MANUALLY
{{ _copier_answers|to_nice_yaml -}}
```

The resulting file in the project records which template version was used and all non-secret
answers.

> **Never edit `.copier-answers.yml` manually.** See
> [updating.md](./updating.md#never-edit-the-answers-file-manually).

## Applying Multiple Templates to the Same Project

Use a different `-a` (answers file) for each template:

```bash
git init
copier copy -a .copier-answers.main.yml gh:org/framework-template .
copier copy -a .copier-answers.pre-commit.yml gh:org/pre-commit-template .
copier copy -a .copier-answers.ci.yml gh:org/ci-template .
```

Later updates are handled per-template:

```bash
copier update -a .copier-answers.main.yml
copier update -a .copier-answers.pre-commit.yml
```

Each template's `copier.yml` should set `_answers_file` to a unique path:

```yaml
_answers_file: .copier-answers.pre-commit.yml
```
