# Claude Code — Global User Config

## Sub-agents

Delegate to sub-agents any work that is token-heavy but where only the final result matters — not the intermediate steps. The goal is to keep the main context lean.

The sub-agent does the heavy lifting and returns a tight summary. Never let token-expensive work pollute the main context when you won't need most of it.

Examples: searching for a file (return the path), running tests (return pass/fail + relevant failures), researching on the web (return useful findings + relevant links).
