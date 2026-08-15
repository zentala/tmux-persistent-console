**Purpose:** How to contribute to pTTY.

# Contributing to pTTY

Thanks for considering a contribution! pTTY is a small project; contributions are very welcome.

## Before You Start

1. Read [docs/SPEC.md](docs/SPEC.md) to understand what pTTY is and its scope
2. For larger changes, open an issue first to discuss

## How to Contribute

- **Bug reports:** Open an issue with reproduction steps, OS, tmux version, and terminal emulator
- **Feature requests:** Open an issue; check the spec first (some features intentionally out of scope)
- **Pull requests:**
  - Branch from `main`
  - Keep shell changes small and portable
  - Use conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`)
  - Run the local validation commands from [CLAUDE.md](CLAUDE.md) before pushing
  - Wait for CI green before requesting review

## Working with AI Tools

This repo is friendly to AI-assisted contributions. We use [CLAUDE.md](CLAUDE.md) to guide Claude Code and other agents. If you use an AI assistant, please:

- Have it read [CLAUDE.md](CLAUDE.md) and [docs/SPEC.md](docs/SPEC.md) before generating user-facing content
- Verify any positioning/marketing copy against the spec's scope section

## License

By contributing, you agree your contributions will be licensed under the MIT License.
