---
name: py-debug
description: Python debugging expert. Use when the user needs to debug, profile, or trace Python code — e.g. "how do I debug this", "find the memory leak", "why is this slow", "add a breakpoint", "profile this function".
---

# Python Debugging

Not sure what's wrong? Start with `ipdb` — step through the code and observe. Once you can characterize the problem (slow, leaking memory, crashing), switch to the matching profiler.

| Problem | Tool |
|---------|------|
| Need to step through execution interactively | `ipdb` |
| Which function is slow? (whole-program overview) | `cProfile` (stdlib) |
| Identifying slow lines in a function | `line-profiler` |
| Profile a running process without code changes | `py-spy` |
| Investigating memory growth or leaks | `memory-profiler` |
| Hard to read debug output (nested dicts, long lists, tracebacks) | `rich` |

## Behavioral Rules

- **Suggest only one tool per problem** — don't list all options and ask the user to choose
- **Explain the fit in one sentence** before showing usage — e.g. "Since you want line-by-line timing, `line-profiler` is the right tool here."
- **Prefer `ipdb` as the default** for general debugging; only reach for profilers when the problem is clearly performance- or memory-related
- **For performance, start broad then zoom in** — use `cProfile` to find the slow function, then `line-profiler` to find the slow line
- **Use `py-spy` when you can't modify the code** — running process, production, or quick triage
- **Place `set_trace()` just before the suspect line**, not at the top of the function
- **Never add profiling decorators** to production code paths — always remind the user to remove them before deploying

## Tool Reference

### ipdb

Interactive debugger with IPython features (tab completion, syntax highlighting).

```python
import ipdb

ipdb.set_trace()  # Pause execution here
```

Post-mortem debugging — drop into the debugger at the point of an unhandled exception:

```python
try:
    risky_operation()
except Exception:
    import ipdb; ipdb.post_mortem()
```

> **Tip:** `breakpoint()` (Python 3.7+) is equivalent to `import pdb; pdb.set_trace()`. Set `PYTHONBREAKPOINT=ipdb.set_trace` to make it launch ipdb instead.

### cProfile (stdlib)

Function-level CPU profiler — use to find which functions are slow before drilling into lines with `line-profiler`.

```bash
python -m cProfile -s cumtime script.py | head -20
```

```python
import cProfile, pstats

profiler = cProfile.Profile()
profiler.enable()
main()
profiler.disable()

stats = pstats.Stats(profiler)
stats.sort_stats("cumulative")
stats.print_stats(10)  # Top 10 functions
```

### py-spy

Sampling profiler that attaches to running processes — no code changes needed. Use for production profiling or when you can't modify the source.

```bash
# Profile a script
py-spy record -o profile.svg -- python script.py

# Attach to a running process
py-spy top --pid 12345

# Generate flamegraph from running process
py-spy record -o profile.svg --pid 12345
```

### memory-profiler

Line-by-line memory usage profiling to find memory leaks.

```python
from memory_profiler import profile

@profile
def my_func():
    data = [1] * 10**6  # Shows memory per line
```

### line-profiler

Line-by-line execution time profiling to identify bottlenecks.

```python
from line_profiler import profile

@profile
def slow_func():
    total = sum(range(10**6))  # Shows time per line
```

### rich

Use `rich` to replace ad-hoc `print` debugging when output is hard to read — nested dicts, long lists, exceptions with stack traces. It's not a debugger; use it when the problem is *visibility* of data, not stepping through logic.

```python
from rich import print
print(some_nested_dict)  # Pretty-printed with syntax highlighting
```

For better tracebacks across the whole program:

```python
from rich.traceback import install
install(show_locals=True)  # All exceptions now show local variables
```
