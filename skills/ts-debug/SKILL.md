---
name: ts-debug
description: TypeScript/Node debugging expert. Use when the user needs to debug, profile, or trace TypeScript or Node.js code — e.g. "how do I debug this", "find the memory leak", "why is this slow", "add a breakpoint", "profile this function", "why won't the process exit".
---

# TypeScript Debugging

Not sure what's wrong? Start with the Node inspector — step through the code and observe. Once you can characterize the problem (slow, leaking memory, hanging), switch to the matching profiler.

| Problem | Tool |
|---------|------|
| Need to step through execution interactively | `node --inspect-brk` + Chrome DevTools or VS Code |
| Need to step through a failing test | `vitest --inspect-brk --no-file-parallelism` |
| Which function is slow, and where does the time go? | `node --cpu-prof`, read as a flame chart in DevTools |
| Investigating memory growth or leaks | `node --heap-prof`, then `v8.writeHeapSnapshot()` |
| Process won't exit or hangs after work is done | `process.getActiveResourcesInfo()`, escalating to `why-is-node-running` for the creation stacks |
| Hard to read debug output (nested objects, long arrays) | `console.dir(value, { depth: null })` |

Every Node flag above is stock — no build step, no loader, no dependency. `why-is-node-running` is the single gap worth a package: the built-in `process.getActiveResourcesInfo()` names the handle types holding the loop open but not where they were created. Run `scripts/setup.sh` to add it.

## Behavioral Rules

- **Lock the bug with a failing test once reproduced** — before patching incorrect behavior, capture the faulty behavior as a regression test (through the public interface where one exists), so the fix is verified and the bug can't silently regress; skip this for pure performance or memory investigations, where a test through the public interface is rarely the right artifact
- **Suggest only one tool per problem** — don't list all options and ask the user to choose
- **Explain the fit in one sentence** before showing usage — e.g. "Since the process hangs after the work finishes, `why-is-node-running` is the right tool here."
- **Prefer the inspector as the default** for general debugging; only reach for profilers when the problem is clearly performance- or memory-related
- **Reach for a built-in before a dependency** — adding a package to a project mid-investigation is a cost the user pays forever, so justify it
- **Run the TypeScript source, not the build** — stack frames and breakpoints land on the right lines with no source maps; only a compiled `node dist/…` run needs `--enable-source-maps`
- **Place the `debugger` statement just before the suspect line**, not at the top of the function
- **Debug tests in a single worker** — `--no-file-parallelism`, otherwise breakpoints land in a worker thread the debugger isn't attached to
- **Never leave instrumentation in production code paths** — `debugger` statements, `why-is-node-running` dumps, and heap-snapshot calls must be removed before deploying

## Running TypeScript directly

`node file.ts` erases type annotations in place and runs the result — no build step, no loader, no source maps. Because types are blanked rather than removed, every line number in a stack trace matches the source file exactly.

This runs unflagged on Node 22.18+ and 23.6+. Check `node --version` before recommending it: on anything older the same command needs `--experimental-strip-types`, and the whole table above assumes the source runs directly.

Type stripping only erases; it refuses TypeScript that has to *emit* runtime code:

```
SyntaxError [ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX]: TypeScript enum is not supported in strip-only mode
```

`enum` and `namespace` are the two that come up in practice. Rewriting them into erasable syntax (a `const` object, a plain module) is the durable fix — the escape hatch that used to cover them, `--experimental-transform-types`, was removed in Node 26. When rewriting isn't on the table, run the file through `tsx` instead.

Native execution also ignores `paths` in tsconfig — if a project maps import aliases, they won't resolve.

## Tool Reference

### Node inspector

Pauses on the first line and waits for a debugger to attach on port 9229. Open `chrome://inspect` in Chrome, or attach VS Code to the running process.

```bash
node --inspect-brk src/index.ts                      # TypeScript source
node --inspect-brk --enable-source-maps dist/index.js # compiled output
```

Set breakpoints in the DevTools/VS Code UI, or in code:

```ts
export function transfer(amount: number): void {
  debugger; // execution pauses here when an inspector is attached
  applyTransfer(amount);
}
```

VS Code attach configuration:

```json
{
  "name": "Attach to process",
  "type": "node",
  "request": "attach",
  "port": 9229,
  "skipFiles": ["<node_internals>/**", "${workspaceFolder}/node_modules/**"]
}
```

> **Tip:** `inspector.open(9229, undefined, true)` from `node:inspector` activates the inspector at runtime — use it when the interesting state only exists after startup.

### vitest --inspect-brk

Debug a failing test the same way, with tests forced onto the main thread so breakpoints are hit.

```bash
pnpm exec vitest --inspect-brk --no-file-parallelism tests/index.test.ts
```

### node --cpu-prof

CPU profiler. Writes a `.cpuprofile` to the working directory; load it in the Chrome DevTools **Performance** tab, which renders it both as a flame chart (where time goes across the call tree) and as a sortable function list (which single function is hot).

```bash
node --cpu-prof src/index.ts
# → CPU.<date>.<time>.<pid>.<tid>.<seq>.cpuprofile
```

Narrow the output with `--cpu-prof-dir` and `--cpu-prof-name`.

### node --heap-prof + heap snapshots

`--heap-prof` shows which allocation sites the memory came from; a heap snapshot shows what is still retained. Use the profile to find the allocator, the snapshot to find the retainer.

```bash
node --heap-prof src/index.ts
# → Heap.<date>.<time>.<pid>.<tid>.<seq>.heapprofile
```

```ts
import v8 from "node:v8";

v8.writeHeapSnapshot("./before.heapsnapshot");
await runWorkload();
v8.writeHeapSnapshot("./after.heapsnapshot");
```

Load both `.heapsnapshot` files in the Chrome DevTools **Memory** tab and compare them to see what survived.

### process.getActiveResourcesInfo (built-in)

The zero-dependency first look at a process that won't exit. Returns the *types* of the handles and requests keeping the event loop alive:

```ts
console.log(process.getActiveResourcesInfo()); // [ 'Timeout' ]
```

Often that's enough — a lone `'Timeout'` or `'TTYWrap'` points straight at the culprit. When the type alone doesn't identify which one, reach for the stacks.

### why-is-node-running

Dumps the open handles and requests *with the stack trace of where each was created* — the part `getActiveResourcesInfo()` can't give you.

```ts
import whyIsNodeRunning from "why-is-node-running";

setTimeout(() => whyIsNodeRunning(), 5000); // prints every active handle with its stack
```

Import it when the investigation starts and delete the import when it ends.

### console.dir

Use `console.dir` to replace ad-hoc `console.log` debugging when output is hard to read — nested objects collapsed to `[Object]`, truncated arrays. It's not a debugger; use it when the problem is *visibility* of data, not stepping through logic.

```ts
console.dir(someNestedValue, { depth: null, colors: true });
```
