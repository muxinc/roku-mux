---
name: roku-api-reference
description: Authoritative reference for Roku SDK APIs and associated developer documentation. Use whenever working with Roku APIs — e.g. SceneGraph node fields (Video, Audio, Task), BrightScript components/ifaces, or verifying a field's name/type/values/availability — instead of relying on training knowledge, which is often stale or wrong for Roku.
---

# Roku API Reference

Treat the official Roku developer documentation (`rokudev/dev-doc`) as the **source of truth**
for Roku APIs. Roku's SceneGraph field names, value enums, and OS-version availability are easy
to get subtly wrong from memory — always confirm against these docs before asserting a fact or
wiring up a field.

## Local copy

The docs are kept as a shallow clone in a shared machine cache:

```
~/.cache/roku-dev-doc
```

Ensure it exists and is current before reading:

```bash
DOCS="$HOME/.cache/roku-dev-doc"
if [ -d "$DOCS/.git" ]; then
  git -C "$DOCS" fetch --depth 1 origin HEAD >/dev/null 2>&1 \
    && git -C "$DOCS" reset --hard FETCH_HEAD >/dev/null 2>&1 || true
else
  mkdir -p "$(dirname "$DOCS")"
  git clone --depth 1 https://github.com/rokudev/dev-doc.git "$DOCS"
fi
```

## Where to look

Reference docs live under `docs/REFERENCES/`:

- `docs/REFERENCES/references-overview.md` — start here for a map of what's documented.
- `docs/REFERENCES/scenegraph/` — SceneGraph nodes. Media playback fields are in
  `docs/REFERENCES/scenegraph/media-playback-nodes/` (`video.md`, `audio.md`).
- `docs/REFERENCES/brightscript/` — BrightScript reference, split into `components/`,
  `interfaces/`, `events/`, and `language/`.
- `docs/REFERENCES/deprecated-apis.md` — deprecations.
