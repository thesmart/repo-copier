# User Settings

## Settings File Location

| Platform | Path                                                                             |
| -------- | -------------------------------------------------------------------------------- |
| Linux    | `$XDG_CONFIG_HOME/copier/settings.yml` (usually `~/.config/copier/settings.yml`) |
| macOS    | `~/Library/Application Support/copier/settings.yml`                              |
| Windows  | `%USERPROFILE%\AppData\Local\copier\settings.yml`                                |

Override the location with the `COPIER_SETTINGS_PATH` environment variable.

## User Defaults

Define default answers for question variables. These replace the `default` value of any question
with a matching name across all templates.

```yaml
# ~/.config/copier/settings.yml
defaults:
  user_name: "Jane Doe"
  user_email: jane@example.com
  github_user: janedoe
```

### Well-Known Variables

Template authors are encouraged to use these standard names so user settings work consistently
across templates:

| Variable      | Type  | Description            |
| ------------- | ----- | ---------------------- |
| `user_name`   | `str` | User's full name       |
| `user_email`  | `str` | User's email address   |
| `github_user` | `str` | User's GitHub username |
| `gitlab_user` | `str` | User's GitLab username |

## Trusted Locations

Mark template repositories or prefixes as permanently trusted (equivalent to always passing
`--trust`):

```yaml
# ~/.config/copier/settings.yml
trust:
  - https://github.com/my-org/
  - https://github.com/my-org/specific-template.git
  - ~/my-local-templates/
```

Matching rules:

- Paths ending with `/` match as **prefixes** — all templates starting with that path are trusted
- Paths not ending with `/` are matched **exactly**

> Trusted templates can execute arbitrary code via tasks, migrations, and Jinja extensions. Only
> trust sources you control or have reviewed.
