-- gitignore-library standalone / one-shot entry point.
--
-- Parents wanting to consume this library should depend on it with
-- `library: true` and call `require("gitignore").run(context, opts)`
-- — see the README. This script runs when the archetype is invoked
-- directly (`archetect render gitignore-library .`) or via plain
-- `catalog.render("gitignore", ctx)` without `library: true`.

local context = Context.new()
require("lib").run(context)
return context
