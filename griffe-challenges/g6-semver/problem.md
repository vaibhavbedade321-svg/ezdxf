Add `recommend_bump(old, new, ignore=())` and `bump_between(package, old_path, new_path, ignore=(), **load_options)` to turn an API diff into a semantic-version recommendation.

Both are importable from `griffe`, along with `Bump`, `ChangeKind` and `BumpReport`. `recommend_bump` compares two loaded models and returns a `BumpReport`; `bump_between` loads the package from each search path, forwarding load options to both, then compares them.

Objects compare by exported path relative to the package name, not definition site, and each is compared under one exported path. Nested members of classes and submodules compare too, including inside a newly added or re-exported container. A name in `ignore` matches a whole first path segment and excludes that object entirely, breakage included.

A breaking change or a public object leaving the surface recommends `Bump.MAJOR`. An added public object, one gaining a compatible capability, or one newly carrying a decorator named `deprecated`, wherever defined, recommends `Bump.MINOR`. Anything else recommends `Bump.PATCH`.

A compatible gain is a signature that only added optional parameters or a variadic, or relaxed a required parameter to optional; a class that only added bases; or an object declaring its own return or type annotation it lacked. A parameter gaining, losing or changing an annotation never counts.

Every breakage is its own `BREAKING` entry, so dropping two parameters reports it twice. Deleting a public object or changing its kind is `BREAKING` under the exported path, never also a removal, and a breaking object is never also `EXPANDED` or `DEPRECATED`. `REMOVED` covers an object leaving the surface with no breakage, such as a name dropped from `__all__` while still defined.

Each change exposes a `kind` (`BREAKING`, `REMOVED`, `ADDED`, `EXPANDED` or `DEPRECATED`), a `path`, a non-empty `detail` and the `severity` it alone forces. `BumpReport` carries `bump`, the `breaking` list, and a `changes` list sorted by path then kind, plus `additions`, `removals`, `expansions` and `deprecations` path lists, `counts` mapping kind values to nonzero counts, `changes_of_kind(kind)`, and `changelog()` mapping each first path segment to its list of changes.

`render_text()` and `render_markdown()` name the level and list the changed paths; `explain()` and `str()` give the same one-line summary naming the level. `gated_by(level)`, taking a `Bump` member or its value, holds when the recommendation meets or exceeds it. `bump_version(version)` bumps a `major.minor.patch` version whose parts carry no leading zero, drops a `-` or `+` suffix, and raises `ValueError` on anything else. JSON-serializable `as_dict()` carries `bump`, `additions`, `removals`, `expansions`, `deprecations` and `counts`, plus `breaking` and `changes` lists of entries carrying kind, path and detail.

`griffe semver PACKAGE --old OLD --new NEW` prints the level with its changes, JSON with `--json`, Markdown with `--markdown`, or `--bump VERSION` bumped, exiting nonzero on a malformed version. `--fail-on LEVEL` exits nonzero exactly when `gated_by(LEVEL)` holds, in any output mode. Repeatable `--ignore NAME` shapes the comparison itself, so its recommendation drives both the bump and the gate. Other commands' loading options reach both loads. Enum members carry lowercase string values. `griffecli.main(argv)` returns the exit code.
