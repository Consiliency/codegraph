# Claude Code Integration Guide

## Overview
This file helps Claude Code understand and work effectively with the CodeGraph project.

## Quick Start for Claude

### First Time Setup
```bash
# Check prerequisites
./scripts/pre-push-check.sh

# Install dependencies
./scripts/setup-new-machine.sh

# Start development
./scripts/start-dev.sh
```

### Daily Development
```bash
# Start your day
./scripts/sync-repos.sh
./scripts/start-dev.sh

# Check system health
curl http://localhost:4000/health
curl http://localhost:8000/health
```

## Code Generation Templates

### New GraphQL Query
When asked to add a GraphQL query, use this pattern:
```typescript
// In codegraph-api/src/graphql/resolvers/
export const newQueryResolver = {
  Query: {
    yourQuery: async (_, args, context) => {
      // Validate input
      // Call service
      // Return typed result
    }
  }
};
```

### New Python Service
When creating a Python service:
```python
# In codegraph-analysis/src/codegraph_analysis/services/
from typing import List, Optional
import structlog

logger = structlog.get_logger(__name__)

class YourService:
    def __init__(self, dependencies):
        self.deps = dependencies
    
    async def your_method(self, param: str) -> List[dict]:
        """Document what this does."""
        logger.info("your_method called", param=param)
        # Implementation
        return results
```

## Testing Patterns

### API Testing
```typescript
// In codegraph-api/tests/
describe("YourFeature", () => {
  it("should do something", async () => {
    const result = await request(app)
      .post("/graphql")
      .send({ query: "your query" });
    expect(result.body.data).toBeDefined();
  });
});
```

### Python Testing
```python
# In codegraph-analysis/tests/
import pytest
from codegraph_analysis.services import YourService

@pytest.mark.asyncio
async def test_your_feature():
    service = YourService()
    result = await service.your_method("test")
    assert result is not None
```

## Debugging Workflows

### When Something Breaks
1. Check logs: `docker-compose logs -f service_name`
2. Verify services: `docker ps`
3. Test endpoints: `curl http://localhost:PORT/health`
4. Check database: Access Memgraph console or Qdrant dashboard

### Common Fixes
- **Import errors**: Regenerate protos with `cd codegraph-proto && ./scripts/generate.sh`
- **Connection errors**: Restart Docker services
- **Type errors**: Run TypeScript compiler or mypy

## Performance Optimization

When asked to optimize:
1. Profile first: Use logging to find bottlenecks
2. Check database queries: Look for N+1 problems
3. Consider caching: Redis is available
4. Batch operations: Especially for embeddings

## Security Checklist

Before implementing any feature:
- [ ] Input validation
- [ ] Authentication check (if needed)
- [ ] SQL injection prevention (parameterized queries)
- [ ] No secrets in code
- [ ] Error messages dont leak internals

## Integration Points

### Adding New Languages
1. Update Tree-sitter grammar in codegraph-core
2. Add language enum in proto files
3. Update parser service
4. Add tests

### Adding New Relationships
1. Define edge type in graph schema
2. Update graph service
3. Add traversal logic
4. Update documentation

## Claude-Specific Commands

When Claude needs to:
- **See project structure**: `find . -type f -name "*.ts" -o -name "*.py" | grep -E "(src|tests)" | sort`
- **Find implementations**: `grep -r "function_name" codegraph-*/src/`
- **Check dependencies**: `cd codegraph-api && npm list` or `cd codegraph-analysis && poetry show`
- **Run specific service**: Use the terminal to start individual services

## Remember
- You have full terminal access
- You can read and write files
- You can run tests and debug
- Always validate changes before committing
- Follow the existing patterns in the codebase
