# Creating a Template

A template is a directory — usually the root of a Git repository.

## How Files Are Handled

- Files ending in `.jinja` are **rendered by Jinja2** and copied without the suffix.
- All other files are **copied as-is** without any processing.
- If both `README.md` and `README.md.jinja` exist, the non-jinja version is **ignored**.

- `my_copier_template/README.md` — ignored — .jinja version takes precedence
- `my_copier_template/README.md.jinja` — rendered → README.md in output
- `my_copier_template/CONTRIBUTING.md` — copied as-is

The template suffix (`.jinja`) can be customized via
[`_templates_suffix`](./settings-reference.md#templates_suffix).

## Templated File and Directory Names

File and directory names can themselves contain Jinja expressions. The expression is evaluated and
the result becomes the actual name:

- `{{project_name}}/`
- `{{project_name}}/{{module_name}}.py.jinja`

## Template Helpers

In addition to standard Jinja2, Copier includes all filters from **jinja2-ansible-filters**,
including:

- `to_nice_yaml` — serialize a value as pretty-printed YAML
- `to_nice_json` — serialize as pretty-printed JSON
- `ans_random` — random value
- `hash('sha512')` — hash a value
- `regex_search(pattern)` — regex match

## Global Variables

These variables are always available in Jinja templates:

### `_copier_answers`

The current answers dict, modified for safe use in the answers file:

- Does not contain secret answers
- Contains special keys `_commit` and `_src_path`
- Used in the answers file template: `{{ _copier_answers|to_nice_yaml }}`

### `_copier_conf`

Configuration and runtime info about the current Copier execution. Key attributes:

| Attribute      | Type          | Description                                               |
| -------------- | ------------- | --------------------------------------------------------- |
| `answers_file` | `PurePath`    | Path for the answers file (relative to project root)      |
| `src_path`     | `PurePath`    | Absolute path to the cloned template on disk              |
| `dst_path`     | `PurePath`    | Destination path where the project is rendered            |
| `sep`          | `str`         | OS-specific directory separator                           |
| `os`           | `str \| None` | Detected OS: `"linux"`, `"macos"`, `"windows"`, or `None` |
| `vcs_ref`      | `str \| None` | VCS tag/commit of the template                            |
| `vcs_ref_hash` | `str \| None` | VCS commit hash of the template                           |
| `data`         | `dict`        | All answers including secrets                             |
| `conflict`     | `str`         | `"inline"` or `"rej"`                                     |
| `overwrite`    | `bool`        | Whether files are overwritten without asking              |
| `pretend`      | `bool`        | Whether this is a dry run                                 |

> `_copier_conf` can be serialized: `{{ _copier_conf|to_json }}` Warning: `_copier_conf.data` may
> contain secret answers.

### `_copier_python`

Absolute path to the Python interpreter running Copier. Useful in tasks:

```yaml
_tasks:
  - ["{{ _copier_python }}", "setup.py"]
```

### `_external_data`

A dict of data loaded from external YAML files. Keys and paths are defined by
[`_external_data`](./settings-reference.md#external_data) in `copier.yml`.

### `_folder_name`

The name of the project root directory.

### `_copier_phase`

The current execution phase: `"prompt"`, `"tasks"`, `"migrate"`, or `"render"`.

## Context-Dependent Variables

### `_copier_operation`

The current operation: `"copy"` or `"update"`.

Available in: `_exclude` patterns and `_tasks`.

```yaml
_tasks:
  - command: ["{{ _copier_python }}", "init.py"]
    when: "{{ _copier_operation == 'copy' }}"
```

## Loop Over Lists to Generate Files

Use the `yield` tag in file/directory names to generate multiple files from a list:

- `commands/`
- `commands/{% yield cmd from commands %}{{ cmd.name }}{% endyield %}/`
- `commands/{% yield cmd from commands %}{{ cmd.name }}{% endyield %}/__init__.py`
- `commands/{% yield cmd from commands %}{{ cmd.name }}{% endyield %}/{% yield subcmd from cmd.subcommands %}{{ subcmd }}{% endyield %}.py.jinja`

`copier.yml`:

```yaml
commands:
  type: yaml
  multiselect: true
  choices:
    init:
      value: &init
        name: init
        subcommands: [config, database]
    run:
      value: &run
        name: run
        subcommands: [server, worker]
  default: [*init, *run]
```

The looped variable (`cmd`, `subcmd`) is available inside the generated files.
