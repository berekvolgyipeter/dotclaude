# dotclaude

## Prerequisites

### Makefile

A Makefile shall be created in each project which has the following 3 commands: `lint`, `test`, `tree`.

### claude-context

[template.mcp.json](template.mcp.json) sets up the claude-context MCP server which needs:
- an OPENAI_API_KEY set in project root `.env`
- a locally running instance of Milvus vector db
    - check out [this repo](https://github.com/berekvolgyipeter/milvus) to run Milvus via Docker Compose
