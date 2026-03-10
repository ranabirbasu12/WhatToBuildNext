# src/

Source code goes here. Organize by whatever makes sense for the idea:

## Common Structures

### For a CLI tool:
```
src/
├── index.ts          # Entry point
├── cli.ts            # CLI argument parsing
├── commands/         # One file per command
├── lib/              # Core logic (no CLI dependency)
└── utils/            # Shared helpers
```

### For a web app:
```
src/
├── app/              # Routes / pages
├── components/       # Reusable UI components
├── lib/              # Core business logic
├── hooks/            # Custom React/framework hooks
├── api/              # API route handlers
├── types/            # TypeScript types
└── utils/            # Shared helpers
```

### For a library:
```
src/
├── index.ts          # Public API (exports)
├── core/             # Core implementation
├── adapters/         # Integration adapters
└── types.ts          # Public types
```

### For a plugin / extension:
```
src/
├── manifest.json     # Plugin manifest
├── skills/           # Agent skills
├── commands/         # Slash commands
├── hooks/            # Event hooks
└── lib/              # Core logic
```

## Guidelines

- Keep the public API surface small
- Separate core logic from I/O (CLI, HTTP, etc.)
- Types in dedicated files when they're shared
- One responsibility per file
