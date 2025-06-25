# CodeGraph/USA

Transform how AI understands code through graph-native semantic intelligence.

## 🚀 Quick Start

```bash
# Clone this repository
git clone https://github.com/Consiliency/codegraph
cd codegraph

# Start the development environment
./scripts/start-dev.sh

# Run the demo
./scripts/demo.sh
```

## 📋 System Requirements

- Docker 20.10+
- Docker Compose 2.0+
- Node.js 18+
- Python 3.11+
- 16GB RAM recommended
- 20GB free disk space

## 🏗️ Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Browser   │────▶│ TypeScript  │────▶│   Python    │
│ (Dashboard) │     │   API       │     │  Analysis   │
└─────────────┘     └─────────────┘     └─────────────┘
                            │                    │
                            ▼                    ▼
                    ┌─────────────┐     ┌─────────────┐
                    │  Memgraph   │     │   Qdrant    │
                    │   (Graph)   │     │  (Vectors)  │
                    └─────────────┘     └─────────────┘
```

## 📁 Repository Structure

- `codegraph-core`: High-performance C++ engine (Tree-sitter, BLAKE3)
- `codegraph-api`: TypeScript GraphQL/REST API server
- `codegraph-analysis`: Python ML workflows and analysis
- `codegraph-proto`: Protocol Buffer definitions
- `codegraph-deploy`: Docker compose and infrastructure

## 🚦 Getting Started

1. **Clone and setup**:
   ```bash
   git clone https://github.com/Consiliency/codegraph
   cd codegraph
   cp .env.example .env
   # Edit .env and add your OpenAI API key
   ```

2. **Start services**:
   ```bash
   ./scripts/start-dev.sh
   ```

3. **Access the system**:
   - Dashboard: http://localhost:4000/dashboard/
   - GraphQL: http://localhost:4000/graphql
   - Memgraph: http://localhost:3000

## 📊 Current Capabilities

- ✅ Multi-language AST parsing (Python, JavaScript, TypeScript)
- ✅ Graph-based code representation
- ✅ Semantic search with OpenAI embeddings
- ✅ Real-time monitoring dashboard
- ✅ Protocol buffer communication
- ✅ 70% LLM token reduction (projected)

## 🛠️ Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## 📜 License

Apache License 2.0
