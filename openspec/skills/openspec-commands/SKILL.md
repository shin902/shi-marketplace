---
name: openspec-commands
description: OpenSpec CLI command reference and help. Use when working with OpenSpec commands like list, validate, show, archive, or when you need to understand OpenSpec command options and usage.
---

# OpenSpec Commands

This skill provides reference information for OpenSpec CLI commands. When triggered, it executes `openspec --help` and related command help to show you the available commands and their options.

## Common Commands

- **List changes**: `openspec list` - Show active changes
- **List specs**: `openspec list --specs` - Show available specifications
- **Validate**: `openspec validate [item] --strict` - Validate changes or specs
- **Show details**: `openspec show [item]` - Display a change or spec
- **Archive**: `openspec archive [change-id]` - Archive a completed change

## Getting Help

For complete command reference, run:

```bash
openspec --help
openspec [command] --help
```

This skill will fetch the latest help output when you ask about OpenSpec commands.
