# CodeGraph Quick Reference

## Daily Commands

    # Start everything
    ./scripts/start-dev.sh

    # Sync latest changes
    ./scripts/sync-repos.sh

    # Run tests
    ./scripts/test-all.sh

    # Check before pushing
    ./scripts/pre-push-check.sh

## Service URLs
- Dashboard: http://localhost:4000/dashboard/
- GraphQL: http://localhost:4000/graphql
- API Health: http://localhost:4000/health
- Analysis API: http://localhost:8000/docs
- Memgraph: http://localhost:3000
- Qdrant: http://localhost:6333/dashboard

## Common Tasks

### Add semantic search for new code

In codegraph-analysis:

    from codegraph_analysis.services.embeddings import EmbeddingService
    await embedding_service.create_embedding(code_text, metadata)

### Query the graph

In codegraph-api:

    const result = await memgraphService.query(`
      MATCH (f:Function)-[:CALLS]->(g:Function)
      WHERE f.name = $name
      RETURN g
    `, { name: 'myFunction' });

### Search by similarity

In codegraph-api:

    const similar = await qdrantService.search({
      vector: embedding,
      limit: 10,
      filter: { language: 'python' }
    });

## Debugging

### View logs

    # All logs
    docker-compose logs -f

    # Specific service
    docker-compose logs -f analysis

### Reset everything

    cd codegraph-deploy
    docker-compose down -v
    cd ..
    ./scripts/start-dev.sh

### Check service health

    curl http://localhost:4000/health
    curl http://localhost:8000/health

## Architecture Overview

    Browser → TypeScript API → Python Analysis
                 ↓                    ↓
             Memgraph            Qdrant
             (Graph DB)      (Vector DB)

## Git Workflow

    # Create feature branch
    git checkout -b feature/my-feature

    # Make changes and commit
    git add .
    git commit -m "feat: add awesome feature"

    # Push to origin
    git push origin feature/my-feature

    # Create PR on GitHub
