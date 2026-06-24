# AGENTS.md

Guidance for AI coding agents working in this repository.

## Roku API reference

Treat the official Roku developer docs (`rokudev/dev-doc`) as the source of truth for Roku APIs
(SceneGraph node fields, BrightScript components, value enums, OS-version availability) rather
than relying on model training knowledge, which is often stale or wrong for Roku.

See the `roku-api-reference` skill in [`.agents/skills/`](.agents/skills/roku-api-reference/SKILL.md)
for how to clone/refresh the docs cache and where to look. Agents that support the
`.agents/skills/` convention load it automatically when relevant.
