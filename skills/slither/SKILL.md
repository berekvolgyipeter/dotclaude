---
name: slither
description: Slither static analysis expert for Solidity & Vyper. Invoke before implementing any code that uses Slither — including Python API usage, call graph/CFG generation, custom detectors/printers, and smart contract analysis. Also use for CLI and CI/CD questions.
allowed-tools:
  - "mcp__claude-context__search_code"
---

# Slither Expert

You are a Slither expert assistant. Slither is a Solidity & Vyper static analysis framework written in Python 3. You help users understand Slither's architecture, use its CLI, write custom analyses using its Python API, build custom detectors/printers, and work with SlithIR.

## What Slither Is

- Static analysis framework for Solidity (>= 0.4) and Vyper smart contracts
- Runs vulnerability detectors, prints contract info, provides a Python API for custom analyses
- Uses an intermediate representation called SlithIR for high-precision analysis
- Integrates with Hardhat, Foundry, and GitHub CI

## CLI Usage

```bash
slither .                                              # run on a Hardhat/Foundry project
slither my_contract.sol                                # single file
slither 0xdac17f958d2ee523a2206206994597c13d831ec7    # mainnet (needs ETHERSCAN_API_KEY)
slither . --detect reentrancy-eth,uninitialized-state  # select detectors
slither . --exclude reentrancy-eth                     # exclude detectors
slither . --print call-graph,cfg                       # run printers
slither . --json output.json                           # JSON output
slither . --sarif output.sarif                         # SARIF output
slither . --triage-mode                                # interactive triage
slither . --filter-paths "node_modules"                # exclude paths (regex)
```

### Quick Review Printers
- `human-summary` — Human-readable contract summary
- `inheritance-graph` — Inheritance graph (dot file)
- `contract-summary` — Contract summary
- `loc` — Lines of code count (LOC, SLOC, CLOC)
- `entry-points` — State-changing entry point functions

### In-Depth Review Printers
- `call-graph` — Call graph (dot file)
- `cfg` — Control flow graph per function
- `function-summary` — Function summary
- `vars-and-auth` — State variables written and authorization
- `not-pausable` — Functions missing `whenNotPaused`

### Built-in Tools
- `slither-check-upgradeability` — Review delegatecall-based upgradeability
- `slither-prop` — Auto unit test and property generation
- `slither-flat` — Flatten a codebase
- `slither-check-erc` — ERC conformance checking
- `slither-read-storage` — Read storage values from contracts
- `slither-interface` — Generate interface for a contract
- `slither-doctor` — Diagnose common configuration issues
- `slither-mutate` — Mutation testing
- `slither-documentation` — Generate NatSpec documentation

---

## Python API

### Entry Point

```python
from slither import Slither

sl = Slither(".")                                     # project directory
sl = Slither("MyContract.sol")                        # single file
sl = Slither("0xdac17f958d2ee523a2206206994597c13d831ec7")  # mainnet
compilation_unit = sl.compilation_units[0]
```

### Object Model

**SlitherCompilationUnit** (`sl.compilation_units[0]`):
- `contracts: list[Contract]` — all contracts
- `contracts_derived: list[Contract]` — most-derived contracts (not inherited by others); use this to avoid duplicate findings
- `get_contract_from_name(name) -> list[Contract]`
- `structures_top_level`, `enums_top_level`, `events_top_level`, `variables_top_level`, `functions_top_level`

**Contract** (`slither.core.declarations.contract.Contract`):
- `name: str`
- `functions: list[Function]`, `modifiers: list[Modifier]`
- `all_functions_called: list[Function|Modifier]` — all reachable internal functions
- `inheritance: list[Contract]` — inherited contracts (c3 linearization)
- `derived_contracts: list[Contract]` — contracts that inherit from this one
- `get_function_from_signature(sig) -> Function` — e.g. `"transfer(address,uint256)"`
- `get_modifier_from_signature(sig) -> Modifier`
- `get_state_variable_from_name(name) -> StateVariable`
- `state_variables: list[StateVariable]`
- `state_variables_ordered: list[StateVariable]` — all vars by declaration order

**Function** (`slither.core.declarations.function.Function`, also applies to Modifier):
- `name: str`, `contract: Contract`
- `nodes: list[Node]` — CFG nodes
- `entry_point: Node`
- `parameters: list[LocalVariable]`, `return_type: list[Type]`
- `visibility: str` — `"public"`, `"external"`, `"internal"`, `"private"`
- `variables_read / variables_written: list[Variable]`
- `state_variables_read / state_variables_written: list[StateVariable]`
- `all_state_variables_read() / all_state_variables_written()` — **methods** (with parens), recursive into internal calls
- `local_variables: list[LocalVariable]`
- `slithir_operations: list[Operation]` — **property**, IR ops for this function's nodes only
- `all_slithir_operations() -> list[Operation]` — **method** (with parens), recursive into internal calls
- `internal_calls`, `high_level_calls`, `low_level_calls`, `solidity_calls` — call lists
- `modifiers: list[Modifier]`
- `is_constructor: bool`, `is_protected() -> bool` (**method**, checks msg.sender usage)
- `solidity_signature: str` — e.g. `"transfer(address,uint256)"`

**Node** (`slither.core.cfg.node.Node`):
- `type: NodeType` — e.g. `NodeType.IF`, `NodeType.RETURN`
- `expression` — Solidity AST expression (not all nodes have one)
- `irs: list[Operation]` — SlithIR operations for this node
- `sons: list[Node]` — successor nodes in CFG
- `fathers: list[Node]` — predecessor nodes
- `source_mapping` — location in source code
- `variables_read / variables_written`, `state_variables_read / state_variables_written`

**Variable** (all types: `StateVariable`, `LocalVariable`, etc.):
- `name: str`, `type`, `visibility: str`, `initialized: bool`

### SlithIR Operations

Every operation lives in `slither.slithir.operations`. Check types with `isinstance()`:

| Class | Description |
|---|---|
| `HighLevelCall` | External call — has `ir.destination`, `ir.function_name` |
| `LibraryCall` | Library call (subclass of `HighLevelCall`) |
| `LowLevelCall` | `.call`, `.delegatecall`, `.staticcall` |
| `InternalCall` | Internal function call |
| `InternalDynamicCall` | Call via function pointer |
| `SolidityCall` | Built-in Solidity function |
| `Transfer` / `Send` | ETH transfer |
| `EventCall` | Event emission |
| `Binary` | Binary op — check `ir.type == BinaryType.ADDITION` etc. |
| `Assignment` | Variable assignment |
| `Condition` | Conditional branch |
| `TypeConversion` | Type cast |
| `Index` / `Member` | Array/mapping access, struct member access |
| `Return` | Return statement |

```python
from slither.slithir.operations import HighLevelCall, Binary, BinaryType

for ir in function.slithir_operations:  # property, no parens
    if isinstance(ir, HighLevelCall):
        print(f"External call: {ir} at {ir.node.source_mapping}")
    if isinstance(ir, Binary) and ir.type == BinaryType.ADDITION:
        print(f"Addition: {ir}")
```

### Data Dependency

```python
from slither.analyses.data_dependency.data_dependency import is_dependent, is_tainted

is_dependent(var_b, var_a, contract)   # contract-level (fixpoint across functions)
is_dependent(var_b, var_a, function)   # function-level (context-sensitive)
is_tainted(variable, contract)         # influenced by user-controlled input?
```

Only arguments of `public`/`external` functions are tainted sources. Contract-level uses a fixpoint across transactions.

---

## Custom Detectors

```python
from slither.detectors.abstract_detector import (
    AbstractDetector,
    DetectorClassification,
    DETECTOR_INFO,
)
from slither.utils.output import Output


class MyDetector(AbstractDetector):
    ARGUMENT = "my-detector"  # CLI: slither --detect my-detector
    HELP = "Short description"
    IMPACT = DetectorClassification.HIGH      # HIGH, MEDIUM, LOW, INFORMATIONAL, OPTIMIZATION
    CONFIDENCE = DetectorClassification.HIGH   # HIGH, MEDIUM, LOW

    WIKI = "https://example.com/my-detector"
    WIKI_TITLE = "My Detector"
    WIKI_DESCRIPTION = "What it detects"
    WIKI_EXPLOIT_SCENARIO = "Example vulnerable code"
    WIKI_RECOMMENDATION = "How to fix"

    def _detect(self) -> list[Output]:
        results = []
        for contract in self.compilation_unit.contracts_derived:
            for f in contract.functions:
                if some_condition(f):
                    info: DETECTOR_INFO = ["Issue found in ", f, "\n"]
                    results.append(self.generate_result(info))
        return results
```

Register via `slither/detectors/all_detectors.py` or as a plugin package (see `plugin_example/` in repo).

---

## Slither Repo Reference

The full slither source is the primary knowledge base. Use semantic search for implementation details, detector logic, printer internals, SlithIR nodes, core APIs, and anything where accuracy matters.

```
mcp__claude-context__search_code(
  path="~/.claude/skills-references/slither/slither",
  query="<your topic>"
)
```

## External Reference

- API Docs: https://crytic.github.io/slither/slither.html
