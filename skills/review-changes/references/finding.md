## Finding Shape

Every finding has one shape, so a reader can sort and act on it at a glance:

```
### #<n> <CRITICAL|HIGH|MEDIUM|LOW> | <bug|judgement call> | <path>:<line> — <one line>
**Why:** <impact>
**Fix:** <suggested fix>
```

Number findings from 1, worst first, with paths relative to the change set's root. A failing check that points at no
line, such as a failing `make test`, names the command in place of `<path>:<line>` (`make test — <first failing
check>`). Separate findings with a horizontal rule (`---`).

**Severity** — how much harm it does if left:

- **CRITICAL** — crashes, security holes, data loss.
- **HIGH** — incorrect behavior a user or caller will hit.
- **MEDIUM** — no immediate failure, but it should change: a failure hidden from the caller, a stale doc, a rule broken.
- **LOW** — minor; small readability or maintenance cost.

**Kind** — whether the code is wrong or a matter of taste:

- **bug** — the code does the wrong thing, breaks a stated rule, or will fail; a reader who disagrees is mistaken.
- **judgement call** — a sign the code may want restructuring (a code smell, a design concern); a reasonable developer
  may keep it.

A finding says what is wrong and how bad it is, not whether to fix it: that depends on the change's goal and scope,
which the reviewer does not see.

Examples — a bug, then a judgement call:

```
### #1 HIGH | bug | src/sync.py:42 — `except Exception: pass` hides upload failures
**Why:** A failed upload reports success, so the caller never retries and the file is lost.
**Fix:** Catch only `TimeoutError`, log it, and re-raise after the retry limit.

---

### #2 LOW | judgement call | src/sync.py:88 — `sync_all` parses, uploads and reports in one 120-line function
**Why:** The three steps can't be tested apart, so a change to reporting means re-testing the upload path.
**Fix:** Split out `parse_manifest` and `report_results`, leaving `sync_all` to call them in order.
```
