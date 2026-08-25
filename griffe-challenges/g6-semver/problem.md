Add `recommend_bump(old, new, ignore=())` and `bump_between(package, old_path, new_path, ignore=(), **load_options)` to turn an API diff into a semantic-version recommendation.

Both are importable from `griffe`, with `Bump`, `ChangeKind` and `BumpReport`. `recommend_bump` compares two loaded models and returns a `BumpReport`. `bump_between` loads it from each search path, never the working directory unless asked, forwarding load options to both.

Objects compare by exported path relative to the package name, not definition site. Nested members compare too, including inside a new or re-exported container. A name in `ignore` matches a whole first path segment and excludes it, breakage included. `__all__` lists exactly what a module exports, even when empty.

A breaking change or a public object leaving the surface recommends `Bump.MAJOR`. An added public object, one gaining a compatible capability, or one newly carrying a `deprecated` decorator, wherever defined, recommends `Bump.MINOR`. Anything else recommends `Bump.PATCH`.

A compatible gain is a signature that only added optional parameters or a variadic, or relaxed a required one to optional; a class that only added bases; or an object declaring its own return or type annotation it lacked. A parameter gaining, losing or changing one never counts.

Every breakage is its own `BREAKING` entry: two dropped parameters report twice. Deleting a public object or changing its kind is `BREAKING` under its exported path, never also a removal; no breaking object is ever also `EXPANDED` or `DEPRECATED`. `REMOVED` covers a name leaving the surface with no breakage, such as one dropped from `__all__`.

Each change exposes a `kind` (`BREAKING`, `REMOVED`, `ADDED`, `EXPANDED` or `DEPRECATED`), a `path`, a non-empty `detail` and the `severity` it forces. `BumpReport` carries `bump`, the `breaking` list and a `changes` list sorted by path then kind, plus `additions`, `removals`, `expansions` and `deprecations` path lists, `counts` mapping kind values to nonzero counts, `changes_of_kind(kind)` and `changelog()` mapping each first path segment to its list of changes.

`render_text()` and `render_markdown()` name the level and the changed paths; `explain()` and `str()` give the same one-line summary naming it. `gated_by(level)`, taking a `Bump` member or its value, holds when the recommendation reaches or exceeds it. `bump_version(version)` bumps a `major.minor.patch` version whose parts carry no leading zero, drops a `-` or `+` suffix and raises `ValueError` on anything else. JSON-serializable `as_dict()` carries `bump`, `additions`, `removals`, `expansions`, `deprecations` and `counts`, plus `breaking` and `changes` lists of entries with kind, path and detail.

`griffe semver PACKAGE --old OLD --new NEW` prints the level with its changes, JSON with `--json`, Markdown with `--markdown`, or `--bump VERSION` bumped, exiting nonzero on a bad one. `--fail-on LEVEL` exits nonzero exactly when `gated_by(LEVEL)` holds, in any output mode. Repeatable `--ignore NAME` shapes the comparison, so its recommendation drives bump and gate. Other commands' load options reach both. Enum members carry lowercase string values. `griffecli.main(argv)` returns the exit code.
