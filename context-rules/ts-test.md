# TypeScript Testing Rules

## Core Principle

Tests verify observable behavior through public interfaces, never implementation details. A good test reads like a specification of what the unit does and survives any internal refactor that preserves behavior. Assert on return values, thrown errors, emitted events, and rendered output — the things a real caller can observe. Never assert call counts or call order as the point of a test, never reach into private members, and never verify through a side channel instead of through the interface under test. If a test breaks when you rename a private method or reorder internal calls without changing behavior, it is testing the wrong thing.

## Testing Best Practices

**Runner** — Default to Vitest. Use the built-in `node:test` + `node:assert/strict` only for zero-dependency library/CLI packages that must avoid a test toolchain; use Jest only when joining an existing Jest codebase. On Jest or `node:test`, apply every rule below as written — module mocking, spies, fake timers and parametrization exist in all three, only the API names differ. Import test globals explicitly (`import { describe, it, expect, vi } from "vitest"`) — Vitest disables `globals` by default; only rely on ambient globals when the project sets `globals: true`.

**Mocking boundary** — Mock only at the edges you do not own: external HTTP APIs, databases, the network, the filesystem, the system clock, and randomness. Never mock your own modules to test your own code — needing `vi.mock("./my-service")` to test another of your files is the surest sign of a brittle test that couples to internal structure. Prefer dependency injection or real collaborators over module mocks. Reserve module mocking (`vi.mock` / `jest.mock` / `t.mock.module`) for third-party packages and true boundaries. Mock HTTP boundaries at the network layer with MSW (`msw`), not by stubbing your fetch/axios client module: `setupServer` from `msw/node` with `http` + `HttpResponse`, started in setup with `server.listen({ onUnhandledRequest: "error" })`, `server.resetHandlers()` after each test, `server.close()` after all.

> Note: MSW is not bundled with the test runner — add `msw` to dev dependencies and tell the user to install it.

**Module mocking hoisting** — `vi.mock` and `jest.mock` are hoisted above all imports. A factory that references a top-level variable throws a ReferenceError (temporal dead zone). Declare such values inside `vi.hoisted(() => ...)`. Under native ESM, Jest requires `jest.unstable_mockModule` paired with dynamic `import()`; `node:test` requires `t.mock.module` followed by a dynamic import of the subject. Prefer `vi.spyOn(obj, "method")` when you only need to replace one member of a real module.

**AAA** — Structure every test as Arrange, Act, Assert, separated by blank lines. No assertions during the arrange phase; one clearly identifiable act.

**One behavior per test** — Each test exercises exactly one behavior and reads as a single specification statement. Give it a descriptive name stating the behavior and condition (`returns 404 when the user does not exist`), not the method name. Keep `describe` nesting shallow — at most two levels.

**Test error paths** — Assert failure modes explicitly. For async rejections use `await expect(fn()).rejects.toThrow(Message)` — always `await` it, or the test passes falsely. Test cancellation paths by passing an `AbortSignal` and asserting the operation rejects/stops when aborted. Never wrap `expect` in `if`/`try`/`catch` (that hides false passes); use `expect.assertions(n)` when a test must prove an assertion in a callback actually ran.

**Parametrize** — Collapse cases that differ only in data into one `test.each` / `it.each` table instead of copy-pasted tests. Keep distinct behaviors as distinct tests.

```ts
// ❌ BAD — duplicated bodies
it("3 sides is triangle", () => expect(name(3)).toBe("triangle"));
it("4 sides is quad", () => expect(name(4)).toBe("quadrilateral"));
// ✅ GOOD
it.each([
  [3, "triangle"],
  [4, "quadrilateral"],
])("names a %i-sided polygon %s", (sides, expected) => {
  expect(name(sides)).toBe(expected);
});
```

**Test against specification** — Derive expected values from the spec, computed independently of the code under test. Do not mirror the implementation's own logic in the assertion; if the test re-runs the production algorithm to compute its expectation, it proves nothing.

**Test thoroughly** — Cover the meaningful scenarios (happy path, boundaries, empty, error), and within each assert the whole expected result, not one member of it. Assert the complete object/array, not a single field.

```ts
// ❌ BAD — passes even if other fields are wrong
expect(user.name).toBe("Ada");
// ✅ GOOD — asserts the whole observable result
expect(user).toEqual({ id: 1, name: "Ada", role: "admin" });
```

**Independent test constants** — Never import a production constant to use as an expected value; hard-code the literal in the test. Importing the constant means a wrong change to it silently passes.

```ts
// ❌ BAD
import { MAX_RETRIES } from "../config";
expect(client.maxRetries).toBe(MAX_RETRIES);
// ✅ GOOD
expect(client.maxRetries).toBe(3);
```

**Mirror real calling patterns** — Construct the subject through the same public entry points production uses. Do not fabricate state with `as any`, casts, or partial object literals to reach a code path — if a real caller cannot produce that input, the test is fiction.

```ts
// ❌ BAD
const order = { items: [{ price: 5 }] } as any as Order;
// ✅ GOOD
const order = createOrder({ items: [lineItem({ price: 5 })] });
```

**Determinism** — Kill every source of nondeterminism. Freeze the clock with `vi.useFakeTimers()` + `vi.setSystemTime(new Date("2025-01-01T00:00:00Z"))` and restore with `vi.useRealTimers()`. Seed or stub randomness. Pin timezone and locale (`TZ=UTC`, fixed locale) in runner config. Never use real sleeps/`waitForTimeout`; advance fake timers or await a condition. For UI, use Testing Library async utilities (`findBy*`, `waitFor`) or Playwright web-first assertions (`await expect(locator).toBeVisible()`) which auto-retry — never hard sleeps.

**Env vars** — Declare test environment variables in the runner config file (`env` in `vitest.config.ts`), never inline in test files or shell wrappers. Override per test with `vi.stubEnv("KEY", "value")` and restore via `unstubEnvs: true` or `vi.unstubAllEnvs()`. All secrets must be dummy placeholders, never real credentials.

```ts
// vitest.config.ts
import { defineConfig } from "vitest/config";
export default defineConfig({
  test: {
    environment: "node",
    setupFiles: ["./test/setup.ts"],
    env: { TZ: "UTC", LANG: "en_US.UTF-8", API_TOKEN: "test-dummy-token" },
    clearMocks: true,
  },
});
```

> Note: DOM tests require an environment package not bundled with Vitest — add `jsdom` (or the faster `happy-dom`) to dev dependencies, set `environment: "jsdom"`, and tell the user to install it.

**DRY in tests** — Express shared setup as factory functions / builders that return fresh objects per call, or Vitest fixtures via `test.extend` — not as mutable module-level variables. Prefer a factory over `beforeEach` assignment when a value can simply be constructed; use `beforeEach` for genuine lifecycle (start server, reset DB). Keep each test isolated: no shared mutable state between tests. Use `satisfies` for typed fixtures so they stay type-checked without widening.

**Type safety in tests** — No `any` in test code. Type mocks with `vi.mocked(fn)` (or `jest.mocked`) rather than casting. Build fixtures with `satisfies MyType` so missing/extra fields are caught. Do type-level testing with `expectTypeOf` (built into Vitest) or `tsd` only for public generic APIs and declaration files where a type regression would break consumers — not for ordinary application code.

**Snapshots** — Use snapshots only for stable, human-reviewable serialized output (error messages, small DOM/ARIA trees, config objects). Prefer small inline snapshots (`toMatchInlineSnapshot`). Never snapshot entire pages, large JSON, or anything containing dynamic values (dates, IDs, hashes); assert those fields explicitly. A snapshot nobody reads in review is not a test.

## Test Organization

- **Unit** tests exercise one module in isolation (real collaborators or edge-only mocks); **integration** tests exercise several modules together against a real DB/service; **e2e** tests (Playwright) drive the full app through the UI.
- Colocate unit and module-level integration tests next to source as `foo.test.ts` / `foo.spec.ts`. Put e2e and broad cross-module tests in a top-level `e2e/` or `tests/` tree that does not mirror `src/` internals.
- Query UI by accessibility role/label (Testing Library `getByRole` first, `getByTestId` last resort); drive interactions with `user-event`. Never query by CSS class or reach into component internals.
- In Playwright, use accessible locators over CSS selectors, rely on auto-waiting web-first assertions, and enable traces/retries in CI.
- Prioritize coverage on branching logic and error paths over raw line-percentage targets; a coverage number is a diagnostic, not a goal.
- Never use Enzyme or shallow rendering; render the real component tree.
