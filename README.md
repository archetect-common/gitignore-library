# gitignore-library

Composable `.gitignore` generator for Archetect. Ships per-category
fragments (languages, editors, frameworks) and renders a single
`.gitignore` file by concatenating the selected ones. Most often
consumed by parent archetypes; usable standalone to drop a
`.gitignore` into an existing project.

## Contract

| Key | Role |
|---|---|
| `ignores` | Input — list of category names. Pre-set via `opts.ignores`, context, or interactive prompt. |

The library produces no context outputs — its side effect is rendering
the `.gitignore` file at the requested destination.

## API

| Call | When to use it |
|---|---|
| `gitignore.prompt(context, opts?)` | Gather ignores — `opts.ignores` skips prompt entirely; `opts.default` overrides the pre-selected default while still prompting. No side effects. |
| `gitignore.finalize(context, opts?)` | Render `.gitignore`. `opts.destination` controls where (subdir under `Location.Destination`; default is root) |
| `gitignore.run(context, opts?)` | One-shot `prompt` + `finalize` |
| `gitignore.categories` | The list of supported category names (read-only) |

The three-phase API matches `scm-library` / `license-library` so
parents can mix and match — prompt early with the other libraries,
render content, finalize at the end.

## Categories

`Claude`, `Rust`, `Java`, `JavaScript`, `Python`, `IDEA`, `Eclipse`,
`VSCode`, `Emacs`, `Vim`, `ReactJS`, `NextJS`, `macOS`.

Each category has a corresponding `includes/<category>.atl` fragment.
Adding a new category is a two-step edit: drop a fragment file and
add the name to `M.categories` in `lib/init.lua`.

## Usage — parent archetype

```yaml
# parent archetype.yaml
catalog:
  gitignore:
    source: "https://github.com/archetect-common/gitignore-library.git#v1"
    library: true
```

```lua
-- parent archetype.lua
local gitignore = require("gitignore")

-- Single call: pick categories and render into the project dir.
gitignore.run(context, {
    destination = context:get("project-name"),
    ignores     = { "Rust", "IDEA", "Claude" },
})
```

Or split across phases for consistency with `scm.prompt` / `scm.finalize`:

```lua
local gitignore = require("gitignore")

-- Hard-code categories — skips the prompt entirely:
gitignore.prompt(context, { ignores = { "Rust", "IDEA", "Claude" } })
-- …content render in between…
gitignore.finalize(context, { destination = context:get("project-name") })
```

Override the pre-selected defaults while still letting the user confirm
or adjust them:

```lua
gitignore.prompt(context, {
    default = { "Claude", "IDEA", "VSCode", "Vim", "macOS" },
})
```

## Usage — `catalog.render()` one-shot

When phase separation isn't needed and you don't need to split prompt from file
writes, skip `library: true` and drive the library as a plain catalog entry:

```yaml
# parent archetype.yaml
catalog:
  gitignore:
    source: "https://github.com/archetect-common/gitignore-library.git#v1"
```

```lua
-- parent archetype.lua
-- Pre-set ignores to skip the interactive prompt entirely.
context:set("ignores", { "Rust", "IDEA", "Claude" })
catalog.render("gitignore", context, { destination = context:get("project-name") })
```

No `context:merge()` needed — gitignore produces no context outputs.
The catalog-level `destination` shifts where `.gitignore` is written.

## Usage — standalone

Drop a `.gitignore` into the current directory:

```sh
archetect render https://github.com/archetect-common/gitignore-library.git#v1 .
```

Non-interactive with explicit categories:

```sh
archetect render https://github.com/archetect-common/gitignore-library.git#v1 . \
    -a 'ignores=[Rust, IDEA, macOS]'
```

Non-interactive with defaults (`Claude + IDEA + VSCode + Vim + macOS`):

```sh
archetect render https://github.com/archetect-common/gitignore-library.git#v1 . -D
```

## Context keys

### Input

| Key | Values | Notes |
|---|---|---|
| `ignores` | List of category names | Default (when prompted): `[Claude, IDEA, VSCode, Vim, macOS]` |

### Output

No context keys. The library writes a single file and returns.

## Testing locally

```sh
archetect render --local \
    /Users/jimmie/personal/archetect-common/gitignore-library .
```

When a parent archetype is under development, `--local` also causes
its library dependencies to resolve to the local checkouts configured
via `archetect config` — including this one — so changes here take
effect immediately without cutting a new tag.

## Release versioning

This library comes wired with the
[`archetect-actions/repository-release`](https://github.com/archetect-actions/repository-release)
action. Trigger a `minor_release` via the GitHub Actions tab to cut
`v1.0` and an auto-updating `v1` floating tag.
