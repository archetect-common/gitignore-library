-- gitignore-library main module.
--
-- Composes a `.gitignore` file from a curated list of per-category
-- fragments shipped under `includes/`. Callers pick categories via
-- opts, pre-set context, or an interactive multi-select.
--
-- Consumers that mount this archetype with `library: true` under the
-- catalog key `gitignore` reach this module via `require("gitignore")`.
-- The archetype's own shim script reaches it via `require("lib")`.
--
-- Usage from a parent archetype (most common):
--
--     local gitignore = require("gitignore")
--     gitignore.run(context, {
--         destination = context:get("project-name"),
--         ignores     = { "Rust", "IDEA", "Claude" },
--     })
--
-- Standalone — drops a `.gitignore` into the destination root:
--
--     archetect render .../gitignore-library.git#v1 .
--
-- The three-phase API (`prompt` + `finalize` + `run`) mirrors
-- scm-library / license-library for consistency.

local M = {}

-- The set of ignore categories this library ships fragments for.
-- Adding a new category is a two-step edit: drop a fragment under
-- `includes/<category>.atl` and add the name here.
M.categories = {
    "Claude",
    "Rust",
    "Java",
    "JavaScript",
    "Python",
    "IDEA",
    "Eclipse",
    "VSCode",
    "Emacs",
    "Vim",
    "ReactJS",
    "NextJS",
    "macOS",
}

-- Gather the ignore categories. Prefers (in order): `opts.ignores`
-- passed by the caller → `ignores` already in context → interactive
-- prompt. Pure context, no side effects.
function M.prompt(context, opts)
    opts = opts or {}

    if opts.ignores then
        context:set("ignores", opts.ignores)
    end

    if not context:get("ignores") then
        local default = opts.default or { "Claude", "IDEA", "VSCode", "Vim", "macOS" }
        context:prompt_multiselect("Ignore Categories:", "ignores", M.categories, {
            help = "Select the categories whose gitignore fragments you want in the generated file.",
            default = default,
        })
    end

    return context
end

-- Render the `.gitignore` file. `opts.destination` is a subdirectory
-- under `Location.Destination`; omit to render at the destination
-- root. Parent archetypes typically pass their project directory:
-- `{ destination = context:get("project-name") }`.
function M.finalize(context, opts)
    opts = opts or {}

    local dest = ".gitignore"
    if opts.destination and opts.destination ~= "" then
        dest = opts.destination .. "/.gitignore"
    end

    file.render(archetype.include_path(".gitignore.atl"), context, { destination = dest })
    return context
end

-- Convenience: prompt + finalize. Used by the standalone shim and by
-- parents that don't need to insert work between the two phases.
function M.run(context, opts)
    M.prompt(context, opts)
    M.finalize(context, opts)
    return context
end

return M
