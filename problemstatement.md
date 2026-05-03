# Problem Generation Rules

This document outlines best practices for generating problem descriptions for AI coding agents.

## 1. Focus on Behavioral Requirements
Describe *what* the feature should do, not *how* to implement it.
- **Good**: "The enterprise slug must be derived automatically from the client's existing state."
- **Bad**: "Parse the URL hostname in `__init__` and store it in `self._enterprise`."

## 2. Explicit Interface Definitions
Clearly name the modules, classes, and methods that need to be created or modified. Ambiguity in naming leads to inconsistent implementations.
- Specify exact module paths (e.g., `github3.audit_log`).
- List exact class names (e.g., `AuditLogEvent`, `AuditLogActor`).
- Define method signatures where constraints exist (e.g., "must not accept an `enterprise` positional parameter").

## 3. Specify Data Formats and Types
Be precise about input and output data types, especially for dates, times, and numeric units.
- State original data formats (e.g., "milliseconds since UNIX epoch").
- Define expected object types (e.g., "timezone-aware UTC `datetime` object").

## 4. Handle Missing Data Explicitly
Define the behavior for missing or optional fields in API responses only when the behavior is non-obvious or differs from codebase convention.
- **Example**: "Fields missing in the API response should safely default to `None`."

## 5. Address Nested Deserialization
If an API field contains a nested structure that maps to another model, state this requirement explicitly.
- **Example**: "The `actor` field must be deserialized into an `AuditLogActor` instance."

## 6. Maintain Conciseness (The "Obvious" Rule)
Remove any information that is redundant or discoverable from the codebase.
- Do not enumerate fields exhaustively if a general rule applies.
- Do not describe standard library behaviors or common codebase conventions.
- Do not mention inheritance from base classes, decorator usage, or test structure -- these are discoverable by reading existing code.
- Do not mention HTTP methods, status codes, or return-type wiring unless the behavior deviates from the codebase norm.

## 7. No Test References
The problem description must never reference tests, test files, fixtures, or assertions. The implementor should be able to write correct code from the behavioral spec alone; tests validate, they don't specify.

## 8. Assume Codebase Familiarity
The implementor will read the codebase. Do not re-explain patterns, conventions, or architectural decisions that are evident from existing modules. Only call out where the new feature *deviates* from established patterns.

## 9. Omit Standard Model Fields
Do not enumerate a model's fields unless the field has a non-obvious type, transformation, or nullable behavior that deviates from a direct JSON mapping. The implementor will derive field names from the API response or existing fixtures.
- **Omit**: listing every field of a model when they are all plain JSON-to-attribute mappings.
- **Keep**: calling out fields like `deleted_at` (nullable) or `metadata` (stored as a raw dict rather than a nested model) only when the handling is non-obvious.

## 10. Keep Signatures Minimal
In method signatures, include only parameters that carry non-obvious behavioral constraints. Omit:
- Standard pagination/etag parameters (`number`, `etag`) -- these are conventional for all iterators.
- Auth requirements -- these follow from whether the operation is a write or reads private data; only state auth explicitly when the rule is unusual (e.g., a read that still requires auth).
- Pattern names (e.g., "use the short/full class split pattern") -- the implementor will recognize the pattern from the codebase.
- **Good**: `packages(package_type, visibility=None)` -- `visibility` is domain-specific and non-obvious.
- **Bad**: `packages(package_type, visibility=None, number=-1, etag=None, ...)` -- pagination defaults are mechanical and universal.

## 11. Routing Logic IS the Spec
When a feature's purpose is to route requests differently based on parameters, the routing table must be in the description -- it is the behavioral contract, not an implementation detail. When "auto-detect" routing makes an API call to determine the route, specify the detection query and the discriminating field -- this is observable behavior, not an internal detail.
- **Keep**: what each parameter value produces (which endpoint is called) and, for auto-detect, which API call determines the route and what field is checked.
- **Omit**: internal Python mechanisms used to implement the routing decision.

## 12. Specify Model Methods for New Resource Types
For a new model class, explicitly list non-trivial instance methods (`delete()`, `restore()`, iterator methods) that are part of the public interface. These are not derivable from field mappings alone. Omit method bodies, HTTP verb details, and URL construction -- those follow codebase convention.

## 13. State Explicit Re-Export Requirements
If classes from a new module must be accessible from the top-level package namespace, state this explicitly. It is not discoverable from the codebase unless a direct precedent exists for that specific module.

## 14. Specify Non-Obvious Method Payloads
State the request body for mutating operations when it deviates from the obvious (e.g., a POST with no body). Omit payload details only when the codebase convention makes them unambiguous (e.g., a DELETE with no body is standard).
- **Keep**: "restore() sends a POST with no body" -- the endpoint implies a payload would be natural; the absence is surprising.
- **Omit**: "delete() sends a DELETE request" -- body-less DELETE is universal convention.

## 15. State Signature Parity Explicitly When It Is Non-Obvious
If a subclass method must have the same parameters as the parent or a sibling, state this explicitly when it could reasonably be omitted. Do not assume the implementor will infer parity from context.
- **Example**: "User `packages()` accepts `visibility=None`" -- without this, an implementor may omit the parameter since users are less commonly filtered by visibility in GitHub's API.
- **Omit**: parameters that are identical to the parent and obviously required (e.g., `package_type` on every packages method).

## 16. Lead With the Behavioral Outcome, Not the Mechanism
Even when a requirement involves a necessary observable technical detail (e.g., an API call made during auto-detection), state the behavioral contract first and the technical detail as supporting context -- never as an imperative procedure.
- **Good**: "routes to the org endpoint if the owner is an organization, with the type determined from `GET /users/{owner}` (`type` field)" -- the contract leads; the API call explains how to verify it.
- **Bad**: "queries `GET /users/{owner}` and routes to the org endpoint if the response `type` is `'Organization'`" -- reads as a step-by-step instruction rather than a behavioral requirement.

## 17. Use Declarative Language, Not Imperative Instructions
Write problem descriptions as statements of fact about the system, not as commands to the implementor. Imperative phrasing ("Add X", "Create Y", "Re-export Z") frames the description as a to-do list; declarative phrasing ("X lives in module Y", "All classes are re-exported from Z") frames it as a specification of what is true.
- **Good**: "`ShortWorkflow`, `Workflow`, and `RunnerGroup` live in `src/github3/actions/workflows.py`. All classes are re-exported from `src/github3/actions/__init__.py`."
- **Bad**: "Add `ShortWorkflow`, `Workflow`, and `RunnerGroup` to a new `src/github3/actions/workflows.py` module. Re-export all classes from `src/github3/actions/__init__.py`."
- **Good**: "`_Repository` gains a `workflow(workflow_id_or_filename)` method that returns a `Workflow`."
- **Bad**: "Add a `workflow(workflow_id_or_filename)` method to `_Repository` that returns a `Workflow`."