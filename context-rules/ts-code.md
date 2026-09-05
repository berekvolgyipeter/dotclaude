# TypeScript Developer Rules

## Core Development Philosophy

- **KISS**: Choose the simplest solution that works. Reach for a union or a plain object type before a conditional, mapped, or recursive type. Before implementing, confirm the request is explicit and use tools to verify rather than guessing.
- **YAGNI**: Build only what is explicitly requested — no speculative generics, no type parameters with a single call site, no abstraction layers awaiting a second implementation. Stop when the requirement is met.
- **DRY**: Implement logic once; upper layers pass parameters through, not re-implement. Derive types from a single source (`z.infer`, `typeof`, indexed access) rather than declaring the same shape twice.
- **Fail Fast**: Surface failures at the point they occur, never later. Validate at the top of the function and return early.
- **Be Explicit About Mutation**: If a function mutates a caller-owned argument (array, object, `Map`, `Set`) as part of its contract, make it obvious — through the name (`appendTo*`, `updateIn*`, `populate*`), a clear parameter name (`out`, `buffer`, `accumulator`), or a brief JSDoc note. Do **not** defensively spread or `structuredClone` inputs just to avoid mutation — trust the caller and prefer returning new values only when it's natural (e.g. pure transforms). In-place operations on locally constructed objects are always fine.
- **Dependency Inversion**: Depend on abstractions for service/module dependencies — accept a narrow interface as a parameter, don't import a concrete module for its side effects. Not for configuration (see Configuration Extraction below).

---

## Code Structure & Modularity

- **Max file length: 500 lines** — split into modules when approaching this limit
- **Max function length: 50 lines**
- **Max class length: 200 lines**
- **Max cyclomatic complexity: 3** — flatten deep nesting with early returns, guard clauses, or extracted helpers
- **Max function parameters: 4** — if a function needs more, apply one of these in order of preference:
  1. **Introduce an options object** — group related parameters into a single named type
  2. **Promote to class state or a closure** — if the same args recur across methods, make them constructor parameters
  3. **Decompose the function** — if parameters belong to distinct concerns, split into smaller functions

```ts
// ❌ BAD — too many parameters, call site is unreadable
function publishDocument(doc: Doc, threshold: number, retries: number, timeout: number, mode: string, dryRun: boolean): void {}

// ✅ GOOD — grouped into a named options type
type PublishOptions = {
  readonly threshold: number;
  readonly retries: number;
  readonly timeout: number;
  readonly mode: PublishMode;
  readonly dryRun: boolean;
};

function publishDocument(doc: Doc, options: PublishOptions): void {}
```

- Organize code into clearly separated modules grouped by feature or responsibility

- **Single Level of Abstraction per function** — every statement should operate at the same abstraction level. Extract low-level steps into private methods so the parent reads as a clean sequence of same-level operations.

```ts
// ❌ BAD — mixed abstraction levels
async fulfillOrder(order: Order): Promise<Receipt> {
  let items: Item[];
  try {
    items = await Promise.all(order.itemIds.map((id) => fetchItem(id)));
  } catch (error) {
    logger.warn({ error }, "Failed to fetch items");
    return { status: "failed" };
  }

  const total = items.reduce((sum, item) => sum + item.price, 0);
  if (total > this.limit) return { status: "overLimit" };

  return this.paymentGateway.charge(order.account, total);
}

// ✅ GOOD — each step at the same level
async fulfillOrder(order: Order): Promise<Receipt> {
  const items = await this.fetchItems(order);
  if (items === null) return { status: "failed" };

  return this.chargeAccount(order, items);
}
```

---

## Style & Conventions

### File-level Symbol Ordering

**Do not interleave types, constants, classes, and functions** — group into contiguous sections:
1. Types / interfaces
2. Constants
3. Classes
4. Functions

Within each section, exported symbols come before private helpers — a reader must see what the module offers before how it works.

### TypeScript Style

- **Annotate every exported signature** — parameter types and return types on anything exported. Let inference handle locals and callbacks; do not annotate what the compiler already knows.
- **Use precise types** — avoid `any` and `object`; prefer unions (`ModelA | ModelB | null`). `unknown` at any boundary where the shape isn't guaranteed, narrowed before use. `any` is acceptable only at untyped third-party boundaries.
- **Never use `as` or `!` to silence the checker** — a type assertion or non-null assertion is permitted only where the type system genuinely cannot see what you can (DOM lookups, untyped libraries), and must sit next to a runtime check or a one-line comment stating why it holds. Prefer type guards and narrowing everywhere else.
- **Use `satisfies` to check a literal without widening it** — `as const satisfies Config` validates the shape and keeps the narrow literal types
- **Mark data `readonly`** — `readonly` on properties, `readonly T[]` on parameters you don't mutate. This is the contract, not decoration.
- **`type` by default; `interface` only** for shapes meant to be `extends`-ed or `implements`-ed by a class. Never rely on declaration merging in application code.
- **Prefer discriminated unions over optional-field bags** — a literal `kind`/`status` tag makes invalid states unrepresentable
- **Use `?.` and `??`, not truthiness checks** — `??` avoids the `0` / `""` / `false` bugs that `||` introduces
- **Use template literal types** for structured strings (routes, keys, prefixed IDs) rather than bare `string`
- **Use branded types** for identifiers that must not be interchangeable — `type UserId = string & { readonly brand: unique symbol }`
- **`async`/`await` only** — never `.then()` chains, never mixing the two in one function
- **`for...of` over `.forEach()`** when the body is async, breaks, or returns early
- **Named exports** — reserve `export default` for framework-required entry points

### Naming — The 5-Second Rule

**If you can't understand what a function, class, or variable does within 5 seconds of reading its name, the name is wrong.**

- **No vague names** — every name must reveal intent
- **No abbreviations** — `user-repository.ts` not `usr-repo.ts`
- **Name length proportional to scope** — `i` is acceptable in a 3-line loop; module-level names need full descriptive words
- **Functions**: use **verb + domain + detail** — describe the action being performed. If you need "and" to describe what a function does, split it
- **Classes**: name by **responsibility**, not data shape — what it *does*, not what it *holds*
- **Variables**: name by **meaning in context**, not type or structure. **Always include the noun** — never name a variable with only an adjective or past participle (`updated`, `filtered`, `parsed`, `mapped`). The name must answer "updated *what*?". Prefer the bare noun when the scope is clear (`orders`); only qualify it (`updatedOrders`) when the unqualified name is already taken or genuinely ambiguous in context
- **Booleans**: must use an intent-revealing prefix — `is`, `has`, `does`, `can`, `should`. Applies to variables, properties, and methods returning `boolean`
- **No Hungarian type prefixes or suffixes** — `User`, not `IUser`, `TUser`, or `UserType`. The type system already says it's a type.
- **Type parameters get real names when they carry meaning** — `T` is fine for a single opaque parameter; `<TPayload, TError>` beats `<T, U>` the moment there are two
- **One concept, one name everywhere** — pick a single term for a concept and use it consistently across every name that refers to it: variables, parameters, functions, properties, types, files. The same thing should not be `email` in one place and `mail` in another, or `fetch*` here and `get*` there. When you rename, propagate it to every occurrence in one pass so no synonym lingers.
- **No ambiguous names** — a name must resolve to exactly one thing in its context. When a bare term could refer to more than one entity — e.g. an `id`/`uuid`/`name` field that could be the object's own *or* a referenced entity's — qualify it with its owner (`ownerId`, `parentUuid`), and reserve the bare term for the thing's own identity.
- **Casing**: `camelCase` for values and functions, `PascalCase` for types, classes, and components, `UPPER_SNAKE_CASE` for module-level constants, `kebab-case.ts` for filenames

```ts
// ❌ BAD — vague, requires reading the body to understand
function process(data: unknown) {}
function handle(event: Event) {}
class Manager {}
type Info = { /* ... */ };
const temp = getResult();
const updated = updateOrders(orders);        // updated what? potatoes?
const parsed = parseDirectory(path);         // parsed what?

// ✅ GOOD — intent is obvious from the name alone
function validateUserEmail(email: string): boolean { /* ... */ }
function fetchActiveSubscriptions(userId: UserId): Promise<Subscription[]> { /* ... */ }
class PaymentGatewayClient {}
type OrderSummary = { /* ... */ };
const activeSubscriptionCount = countActiveSubscriptions(user);
const orders = updateOrders(rawOrders);              // bare noun when scope is clear
const updatedOrders = updateOrders(orders);          // qualify only when `orders` is taken
const files = parseDirectory(path);
```

### Types, Models and Schemas

- **Colocate single-use types with their consumer**; lift to a dedicated module (`types.ts`, `models/`) only once three or more modules share them. Never define shared domain types inline with business logic.
- **Name every non-trivial structural type** — no inline object literals with three or more properties in a signature, and no `Promise<[number, Array<{ id: string; count: number }>]>`. Declare it and reference it.
- **Validate at trust boundaries** — HTTP payloads, env vars, CLI args, file and DB reads, and anything from a third party must pass through a schema parser, never a cast. Use a Standard Schema library: Zod by default, Valibot when bundle size is the binding constraint.
- **Derive the type from the schema, never write both** — `type Order = z.infer<typeof orderSchema>`. Two hand-written declarations of the same shape will drift.
- **Plain types inside the boundary** — once data is parsed it is trusted; do not re-validate in internal functions

### Unions and Constants

- **Never use `enum`** — it emits runtime code, does not erase, and its members are nominally typed in ways that surprise. Use a `const` object plus a derived union.
- **No magic strings or numbers** — every repeated literal becomes a named constant or a union member
- **Close every exhaustive `switch`** with a `default` branch that assigns the value to `never`, so adding a variant becomes a compile error rather than a silent fallthrough

```ts
// ❌ BAD — magic string, and nothing catches a new status
if (order.status === "pending") {}

// ✅ GOOD — const object + derived union + exhaustiveness
const OrderStatus = { Pending: "pending", Completed: "completed" } as const;
type OrderStatus = (typeof OrderStatus)[keyof typeof OrderStatus];

function describe(status: OrderStatus): string {
  switch (status) {
    case OrderStatus.Pending: return "Awaiting payment";
    case OrderStatus.Completed: return "Fulfilled";
    default: {
      const unhandled: never = status;
      throw new Error(`Unhandled status: ${String(unhandled)}`);
    }
  }
}
```

### Configuration Extraction

- **Extract magic values to a config module** — never hardcode in functions
- **App-layer functions** read config internally; **pure/utility functions** take parameters for testability:

```ts
// App-layer — reads config internally
async function dispatchPendingOrders(): Promise<void> {
  const threshold = config.orderThreshold;
}

// Pure/utility — takes parameters, no config dependency
function filterOrders(orders: readonly Order[], threshold: number): Order[] { /* ... */ }
```

### Comments

- **Default to no comments** — well-named identifiers and types document *what*. Only comment when the *why* is non-obvious (hidden constraint, subtle invariant, workaround for a specific bug)
- **Never restate the code** — if the comment paraphrases the next line, delete it
- **No task/PR context** — don't reference the current change, ticket, or callers; that belongs in commit messages
- **A comment doing heavy explaining is a symptom, not a fix** — if a constant, setting, or function needs a comment to explain what it means or how it behaves, the name, design, or docs are wrong; fix those instead of writing the paragraph
- **One line is almost always enough** — never write multi-paragraph comment blocks
- **JSDoc**: write one only when the contract is non-obvious from the signature. Single line unless behavior is genuinely complex. Never restate parameter types — the signature has them — and never echo the function name in prose.

### Imports

- Always at the top of the file, ordered: node builtins → third-party → local
- **Use `import type` for type-only imports** — keeps them erasable and makes the runtime cost of each import visible
- **Use path aliases across layers, relative paths between siblings** — `@/features/orders` across the tree, `./helper` within a folder. Never `../../..`.
- **No wildcard imports** (`import * as x`) except for libraries that ship a namespace as their only export
- **No barrel files** — importing from an `index.ts` re-export drags in unrelated modules, defeats tree-shaking, and hides cycles. Import from the defining module.
- **Break circular dependencies by extracting** the shared type or constant into a leaf module both sides import

---

## Error Handling

- Create domain-specific error hierarchies extending `Error` (`PaymentError` → `InsufficientFundsError`), and set `name` explicitly in the constructor so it survives minification
- **Throw only `Error` subclasses** — never strings, objects, or literals; only an `Error` carries a stack
- **Attach context as fields, not string interpolation** — `new PaymentError(message, { orderId })`, so handlers can branch on data instead of parsing prose
- **Preserve the original with `cause`** when re-throwing — `new SyncError("Sync failed", { cause: error })`
- **Treat the catch variable as `unknown`** — narrow with `instanceof` before touching `.message`. Catch specific error types, never a bare catch that swallows everything.
- **Do not use exceptions for control flow** — errors signal failure, not branching logic
- **Model expected, recoverable failures as return values** — a discriminated union (`{ ok: true, value } | { ok: false, error }`) puts the failure in the signature and forces the caller to handle it. `throw` for programmer errors and invariant violations; return a result union for failures the caller is expected to handle as normal control flow (external input validation, business-rule rejections).
- **No log-and-rethrow** — either handle the error or let it propagate, not both
- **Let errors bubble** unless the current layer can meaningfully recover
- **Never leave a floating promise** — `await` it, `void` it, or `.catch()` it. An unhandled rejection is a crash waiting for production.
- **`Promise.all` when every result is required** and one failure should abort the rest; **`Promise.allSettled`** only when partial success is a valid outcome you then inspect
- **Accept an optional `AbortSignal`** on anything long-running or network-bound, and propagate it to every call underneath
