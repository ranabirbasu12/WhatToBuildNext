# WhatToBuildNext? — Idea Monorepo

## What Is This

A Turborepo monorepo for sparring on ideas. Each idea lives in `ideas/<name>` as its own package. Some get built, some stay as design docs, some die — all are artifacts worth keeping.

## Structure

```
ideas/          — one directory per idea (each is a workspace package)
docs/           — tutorials, comparisons, design docs
```

## Current Ideas

- `ideas/nexus` — Multi-agent orchestration system (v0.3, archived). Superseded by GSD + Metaswarm plugins but kept as a reference artifact.

## Turborepo

```bash
npx turbo build     # build all packages
npx turbo test      # test all packages
npx turbo dev       # dev mode
```

## Adding a New Idea

1. Create `ideas/<name>/`
2. Add a `package.json` with `"name": "@ideas/<name>"`
3. Build it out

## Docs

- `docs/gsd-tutorial.md` — GSD plugin tutorial
- `docs/metaswarm-tutorial.md` — Metaswarm plugin tutorial
- `docs/gsd-vs-metaswarm.md` — Comparison of both
- `docs/plans/` — Design docs (Nexus plugin design & implementation plans)
