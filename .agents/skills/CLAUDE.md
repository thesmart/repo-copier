# External Skills

These skills are external to this project.

**NEVER** waste tokens reading the contents of `.agents/skills/**`

## Managing Skill Dependencies

Run from the project root:

```console
npx skills add <package> --skill <skills> -y # add or replace a skill
npx skills update --all -y                   # update all skills to latest
npx skills experimental_install              # restore from skills-lock.json
```
