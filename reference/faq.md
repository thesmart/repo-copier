# FAQ

## Can Copier be applied over a preexisting project?

```bash
copier copy gh:owner/template ./my-existing-git-project
```

This is also how `copier update` works internally, and how
[multiple templates](./configuring.md#applying-multiple-templates-to-the-same-project) can be
applied to the same project.

---

## How do I create a computed value?

Combine `default` with `when: false`. The value is computed but never asked or stored in the
answers file:

```yaml
# copier.yml
copyright_year:
  type: int
  default: 2024

next_year:
  type: int
  default: "{{ copyright_year + 1 }}"
  when: false # computed, not asked, not stored
```

---

## How do I "lock" a computed value?

If you want a computed value stored at creation time and never updated again (e.g. `copyright_year`
that stays fixed even when the template is updated), explicitly include it in the answers file:

```yaml
# copier.yml
copyright_year:
  type: str
  default: "{{ copyright_year | default('%Y' | strftime) }}"
  when: false
```

```
# {{ _copier_conf.answers_file }}.jinja
# Changes here will be overwritten by Copier; NEVER EDIT MANUALLY
{{ dict(_copier_answers, copyright_year=copyright_year) | to_nice_yaml -}}
```

The pattern `{{ copyright_year | default('%Y' | strftime) }}` uses the stored value if it exists,
otherwise computes it from the current year. On subsequent updates, `copyright_year` is already in
the answers file so the stored value is used.

---

## How do I alter the context before rendering?

Use the `ContextHook` extension from `copier-templates-extensions`. It lets you add/modify/remove
variables before templates are rendered.

```yaml
# copier.yml
_jinja_extensions:
  - copier_templates_extensions.TemplateExtensionLoader
  - extensions/context.py:ContextUpdater
```

```python
# extensions/context.py
from copier_templates_extensions import ContextHook

class ContextUpdater(ContextHook):
    def hook(self, context):
        flavor = context["flavor"]
        return {
            "isDocker": flavor == "docker",
            "isK8s": flavor == "kubernetes",
            "hasContainers": flavor in {"docker", "kubernetes"},
        }
```

The returned dict is merged into the context before each file is rendered. To update in-place (and
delete keys), set `update = False` on the class and modify `context` directly.

This requires `--trust` since it uses a Jinja extension.

---

## Why does Copier consume a lot of resources?

Shallow clones can cause high CPU/memory. Use a fully-cloned repository:

```bash
git clone --no-shallow https://github.com/owner/template
```

---

## Why doesn't the template include my dirty (uncommitted) changes?

Copier uses the latest Git tag, not `HEAD`. To include uncommitted changes:

```bash
copier copy --vcs-ref HEAD ./my-local-template ./dest
```

---

## How do I pass credentials to Git?

Don't embed credentials in the template URL — they end up in the answers file.

**Preferred:** SSH key authentication:

```bash
copier copy git@github.com:owner/private-template.git ./dest
```

**Alternative:** Git credential helpers:

```bash
git config --global credential.helper store   # or cache
```
