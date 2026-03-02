---
paths:
  - "src/**/*.py"
  - "scripts/**/*.py"
---

# Debugging Guidelines

Reference for ipdb, memory-profiler, line-profiler, and rich for interactive debugging and profiling.

## 🔍 Debugging Tools

### ipdb

Interactive debugger with IPython features (tab completion, syntax highlighting).

```python
import ipdb

ipdb.set_trace()  # Pause execution here
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

Beautiful terminal output with colors, tables, and formatting.

```python
from rich import print
print("[bold red]Error:[/] Something failed")
```
