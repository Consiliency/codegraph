# Contributing to CodeGraph

## Development Setup

1. Fork and clone the repository
2. Follow the Quick Start guide in README.md
3. Create a feature branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Run tests: `./scripts/test-all.sh`
6. Submit a pull request

## Code Style

- **TypeScript**: ESLint + Prettier
- **Python**: Black + Ruff
- **C++**: clang-format

## Commit Convention

Follow Conventional Commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `test:` Tests
- `refactor:` Code refactoring

## Testing

Each service has its own test suite:

    # API tests
    cd codegraph-api && npm test

    # Analysis tests  
    cd codegraph-analysis && poetry run pytest

    # Core tests
    cd codegraph-core && make test

## Pull Request Process

1. Update documentation
2. Add tests for new features
3. Ensure all tests pass
4. Update CHANGELOG.md
5. Request review from maintainers
