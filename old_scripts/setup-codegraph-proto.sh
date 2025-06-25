#!/bin/bash
# setup-codegraph-proto.sh

REPO_NAME="codegraph-proto"
GITHUB_ORG="Consiliency"

# Create and enter directory
mkdir -p $REPO_NAME && cd $REPO_NAME

# Initialize git
git init

# Create directory structure
mkdir -p {proto/{ast,graph,storage,api},generated/{python,typescript,cpp},docs,scripts,.github/workflows}

# Create .gitignore
cat > .gitignore << 'EOF'
# Generated files (committed separately)
generated/*/

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Temporary
*.tmp
*.swp
EOF

# Create README.md
cat > README.md << 'EOF'
# CodeGraph Proto

Protocol Buffer definitions and generated code for CodeGraph/USA services.

## Structure

```
proto/
├── ast/          # AST-related definitions
├── graph/        # Graph structure definitions
├── storage/      # Storage layer definitions
└── api/          # API service definitions

generated/
├── python/       # Generated Python code
├── typescript/   # Generated TypeScript code
└── cpp/          # Generated C++ code
```

## Building

```bash
# Generate all language bindings
./scripts/generate.sh

# Generate specific language
./scripts/generate.sh python
./scripts/generate.sh typescript
./scripts/generate.sh cpp
```

## Usage

### Python
```python
from codegraph_proto.ast import ast_pb2
from codegraph_proto.graph import graph_pb2
```

### TypeScript
```typescript
import { ASTNode } from '@codegraph/proto/ast';
import { GraphNode } from '@codegraph/proto/graph';
```

### C++
```cpp
#include "codegraph/proto/ast/ast.pb.h"
#include "codegraph/proto/graph/graph.pb.h"
```

## Contributing

1. Modify proto files in `proto/` directory
2. Run `./scripts/generate.sh` to regenerate bindings
3. Commit both proto files and generated code
4. Create PR with clear description of changes

## License

Apache License 2.0
EOF

# Create main proto definitions
cat > proto/ast/ast.proto << 'EOF'
syntax = "proto3";

package codegraph.ast;

option go_package = "github.com/Consiliency/codegraph-proto/go/ast";
option java_package = "com.consiliency.codegraph.proto.ast";

// Represents an AST node
message ASTNode {
  string id = 1;                    // Unique identifier
  string type = 2;                  // Node type (e.g., "function", "class")
  string language = 3;              // Programming language
  bytes blake3_hash = 4;            // BLAKE3 hash of canonicalized node
  
  // Node metadata
  NodeMetadata metadata = 5;
  
  // Child nodes
  repeated ASTNode children = 6;
  
  // Source location
  SourceLocation location = 7;
}

message NodeMetadata {
  string name = 1;                  // Node name (e.g., function name)
  map<string, string> attributes = 2; // Additional attributes
  int64 timestamp = 3;              // Creation timestamp
}

message SourceLocation {
  string file_path = 1;
  int32 start_line = 2;
  int32 start_column = 3;
  int32 end_line = 4;
  int32 end_column = 5;
}

// Request to parse code
message ParseRequest {
  string code = 1;
  string language = 2;
  string file_path = 3;
}

// Response from parser
message ParseResponse {
  ASTNode root = 1;
  repeated ParseError errors = 2;
}

message ParseError {
  string message = 1;
  SourceLocation location = 2;
  string severity = 3;  // "error", "warning", "info"
}
EOF

cat > proto/graph/graph.proto << 'EOF'
syntax = "proto3";

package codegraph.graph;

import "ast/ast.proto";

option go_package = "github.com/Consiliency/codegraph-proto/go/graph";
option java_package = "com.consiliency.codegraph.proto.graph";

// Graph node types
enum NodeType {
  NODE_TYPE_UNSPECIFIED = 0;
  NODE_TYPE_CONTRACT = 1;      // Interface/API definition
  NODE_TYPE_IMPLEMENTATION = 2; // Concrete implementation
  NODE_TYPE_CHUNK = 3;         // Code chunk
  NODE_TYPE_FILE = 4;          // Source file
  NODE_TYPE_MODULE = 5;        // Module/package
}

// Graph edge types
enum EdgeType {
  EDGE_TYPE_UNSPECIFIED = 0;
  EDGE_TYPE_HAS_IMPLEMENTATION = 1;
  EDGE_TYPE_IMPLEMENTS_CONTRACT = 2;
  EDGE_TYPE_CALLS = 3;
  EDGE_TYPE_REFERENCES = 4;
  EDGE_TYPE_DEPENDS_ON = 5;
  EDGE_TYPE_CONTAINS = 6;
  EDGE_TYPE_SUPERSEDED_BY = 7;
}

// Graph node
message GraphNode {
  string id = 1;                    // Unique identifier
  NodeType type = 2;                // Node type
  bytes blake3_hash = 3;            // Content hash
  
  // Semantic embedding
  SemanticEmbedding embedding = 4;
  
  // Node properties
  map<string, string> properties = 5;
  
  // Associated AST node (if applicable)
  codegraph.ast.ASTNode ast_node = 6;
  
  // Timestamps
  int64 created_at = 7;
  int64 updated_at = 8;
}

// Semantic embedding
message SemanticEmbedding {
  string model_version = 1;         // Model used to generate embedding
  repeated float vector = 2;        // Embedding vector
  uint64 semantic_handle = 3;       // 64-bit semantic handle
  float confidence = 4;             // Confidence score
}

// Graph edge
message GraphEdge {
  string id = 1;                    // Unique identifier
  string source_id = 2;             // Source node ID
  string target_id = 3;             // Target node ID
  EdgeType type = 4;                // Edge type
  
  // Edge properties
  map<string, string> properties = 5;
  
  // Weight/score
  float weight = 6;
}

// Graph query request
message GraphQueryRequest {
  oneof query {
    string node_id = 1;             // Query by node ID
    SemanticQuery semantic = 2;     // Semantic search
    TraversalQuery traversal = 3;   // Graph traversal
  }
  
  int32 max_results = 4;
  int32 max_depth = 5;
}

message SemanticQuery {
  string text = 1;                  // Query text
  repeated float vector = 2;        // Or direct vector
  float min_similarity = 3;         // Minimum similarity threshold
}

message TraversalQuery {
  string start_node_id = 1;
  repeated EdgeType edge_types = 2;
  string direction = 3;             // "in", "out", "both"
}

// Graph query response
message GraphQueryResponse {
  repeated GraphNode nodes = 1;
  repeated GraphEdge edges = 2;
  QueryMetrics metrics = 3;
}

message QueryMetrics {
  int32 total_results = 1;
  int64 query_time_ms = 2;
  int32 nodes_visited = 3;
}
EOF

cat > proto/storage/storage.proto << 'EOF'
syntax = "proto3";

package codegraph.storage;

option go_package = "github.com/Consiliency/codegraph-proto/go/storage";
option java_package = "com.consiliency.codegraph.proto.storage";

// Content storage entry
message StorageEntry {
  bytes blake3_hash = 1;            // Content hash (key)
  bytes content = 2;                // Raw content
  string content_type = 3;          // MIME type
  int64 size = 4;                   // Content size in bytes
  int64 created_at = 5;             // Creation timestamp
  map<string, string> metadata = 6; // Additional metadata
}

// Storage request
message StoreRequest {
  bytes content = 1;
  string content_type = 2;
  map<string, string> metadata = 3;
}

// Storage response
message StoreResponse {
  bytes blake3_hash = 1;
  bool already_existed = 2;
}

// Retrieval request
message RetrieveRequest {
  bytes blake3_hash = 1;
}

// Retrieval response
message RetrieveResponse {
  StorageEntry entry = 1;
  bool found = 2;
}

// Batch operations
message BatchStoreRequest {
  repeated StoreRequest requests = 1;
}

message BatchStoreResponse {
  repeated StoreResponse responses = 1;
}

message BatchRetrieveRequest {
  repeated bytes blake3_hashes = 1;
}

message BatchRetrieveResponse {
  repeated RetrieveResponse responses = 1;
}
EOF

cat > proto/api/service.proto << 'EOF'
syntax = "proto3";

package codegraph.api;

import "ast/ast.proto";
import "graph/graph.proto";
import "storage/storage.proto";

option go_package = "github.com/Consiliency/codegraph-proto/go/api";
option java_package = "com.consiliency.codegraph.proto.api";

// Main CodeGraph service
service CodeGraphService {
  // AST operations
  rpc ParseCode(codegraph.ast.ParseRequest) returns (codegraph.ast.ParseResponse);
  
  // Graph operations
  rpc QueryGraph(codegraph.graph.GraphQueryRequest) returns (codegraph.graph.GraphQueryResponse);
  rpc AddNode(codegraph.graph.GraphNode) returns (AddNodeResponse);
  rpc AddEdge(codegraph.graph.GraphEdge) returns (AddEdgeResponse);
  
  // Storage operations
  rpc Store(codegraph.storage.StoreRequest) returns (codegraph.storage.StoreResponse);
  rpc Retrieve(codegraph.storage.RetrieveRequest) returns (codegraph.storage.RetrieveResponse);
  
  // Analysis operations
  rpc AnalyzeRepository(AnalyzeRepositoryRequest) returns (stream AnalyzeRepositoryResponse);
}

message AddNodeResponse {
  string node_id = 1;
  bool created = 2;  // false if already existed
}

message AddEdgeResponse {
  string edge_id = 1;
  bool created = 2;
}

message AnalyzeRepositoryRequest {
  string repository_path = 1;
  repeated string languages = 2;    // Languages to analyze
  AnalysisOptions options = 3;
}

message AnalysisOptions {
  bool skip_tests = 1;
  bool include_dependencies = 2;
  int32 max_file_size = 3;
  repeated string exclude_patterns = 4;
}

message AnalyzeRepositoryResponse {
  oneof update {
    AnalysisProgress progress = 1;
    AnalysisResult result = 2;
    AnalysisError error = 3;
  }
}

message AnalysisProgress {
  int32 files_processed = 1;
  int32 total_files = 2;
  string current_file = 3;
  float percentage = 4;
}

message AnalysisResult {
  int32 total_files = 1;
  int32 total_nodes = 2;
  int32 total_edges = 3;
  map<string, int32> nodes_by_type = 4;
  map<string, int32> edges_by_type = 5;
  int64 analysis_time_ms = 6;
}

message AnalysisError {
  string message = 1;
  string file = 2;
  string details = 3;
}
EOF

# Create generation script
cat > scripts/generate.sh << 'EOF'
#!/bin/bash

# Generate protocol buffer bindings for all languages

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
PROTO_DIR="$PROJECT_ROOT/proto"
GENERATED_DIR="$PROJECT_ROOT/generated"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
log() {
    echo -e "${GREEN}[GENERATE]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check for required tools
check_requirements() {
    if ! command -v protoc &> /dev/null; then
        error "protoc is not installed. Please install protocol buffers compiler."
        exit 1
    fi
    
    log "Using protoc version: $(protoc --version)"
}

# Generate Python bindings
generate_python() {
    log "Generating Python bindings..."
    
    mkdir -p "$GENERATED_DIR/python/codegraph_proto"
    
    # Generate Python files
    protoc \
        --proto_path="$PROTO_DIR" \
        --python_out="$GENERATED_DIR/python/codegraph_proto" \
        --pyi_out="$GENERATED_DIR/python/codegraph_proto" \
        --grpc_python_out="$GENERATED_DIR/python/codegraph_proto" \
        "$PROTO_DIR"/**/*.proto
    
    # Create __init__.py files
    find "$GENERATED_DIR/python/codegraph_proto" -type d -exec touch {}/__init__.py \;
    
    # Create setup.py for the generated package
    cat > "$GENERATED_DIR/python/setup.py" << 'SETUP'
from setuptools import setup, find_packages

setup(
    name="codegraph-proto",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "protobuf>=4.25.0",
        "grpcio>=1.60.0",
    ],
)
SETUP
    
    log "Python bindings generated successfully"
}

# Generate TypeScript bindings
generate_typescript() {
    log "Generating TypeScript bindings..."
    
    mkdir -p "$GENERATED_DIR/typescript/src"
    
    # Check for protoc-gen-ts
    if ! command -v protoc-gen-ts &> /dev/null; then
        warning "protoc-gen-ts not found. Installing..."
        npm install -g @protobuf-ts/plugin
    fi
    
    # Generate TypeScript files
    protoc \
        --proto_path="$PROTO_DIR" \
        --plugin="protoc-gen-ts=$(which protoc-gen-ts)" \
        --ts_out="$GENERATED_DIR/typescript/src" \
        --ts_opt=target=node,json_types=true \
        "$PROTO_DIR"/**/*.proto
    
    # Create package.json
    cat > "$GENERATED_DIR/typescript/package.json" << 'PACKAGE'
{
  "name": "@codegraph/proto",
  "version": "0.1.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "prepublishOnly": "npm run build"
  },
  "dependencies": {
    "@grpc/grpc-js": "^1.9.0",
    "@protobuf-ts/runtime": "^2.9.0",
    "@protobuf-ts/runtime-rpc": "^2.9.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0"
  }
}
PACKAGE

    # Create tsconfig.json
    cat > "$GENERATED_DIR/typescript/tsconfig.json" << 'TSCONFIG'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
TSCONFIG
    
    log "TypeScript bindings generated successfully"
}

# Generate C++ bindings
generate_cpp() {
    log "Generating C++ bindings..."
    
    mkdir -p "$GENERATED_DIR/cpp/codegraph/proto"
    
    # Generate C++ files
    protoc \
        --proto_path="$PROTO_DIR" \
        --cpp_out="$GENERATED_DIR/cpp/codegraph/proto" \
        --grpc_cpp_out="$GENERATED_DIR/cpp/codegraph/proto" \
        "$PROTO_DIR"/**/*.proto
    
    # Create CMakeLists.txt
    cat > "$GENERATED_DIR/cpp/CMakeLists.txt" << 'CMAKE'
cmake_minimum_required(VERSION 3.20)
project(codegraph-proto)

set(CMAKE_CXX_STANDARD 20)

find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)

file(GLOB_RECURSE PROTO_SOURCES "codegraph/proto/*.cc")
file(GLOB_RECURSE PROTO_HEADERS "codegraph/proto/*.h")

add_library(codegraph-proto ${PROTO_SOURCES})
target_include_directories(codegraph-proto PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(codegraph-proto
    PUBLIC
        protobuf::libprotobuf
        gRPC::grpc++
)
CMAKE
    
    log "C++ bindings generated successfully"
}

# Main execution
main() {
    check_requirements
    
    # Parse arguments
    if [ $# -eq 0 ]; then
        # Generate all if no arguments
        generate_python
        generate_typescript
        generate_cpp
    else
        # Generate specific language
        case "$1" in
            python)
                generate_python
                ;;
            typescript|ts)
                generate_typescript
                ;;
            cpp|c++)
                generate_cpp
                ;;
            *)
                error "Unknown language: $1"
                echo "Usage: $0 [python|typescript|cpp]"
                exit 1
                ;;
        esac
    fi
    
    log "Generation complete!"
}

main "$@"
EOF

chmod +x scripts/generate.sh

# Create GitHub Actions workflow
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Protocol Buffers
      run: |
        sudo apt-get update
        sudo apt-get install -y protobuf-compiler protobuf-compiler-grpc
        protoc --version

    - name: Validate Proto Files
      run: |
        for proto in $(find proto -name "*.proto"); do
          echo "Validating $proto"
          protoc --proto_path=proto "$proto" --descriptor_set_out=/dev/null
        done

    - name: Check Breaking Changes
      uses: bufbuild/buf-breaking-action@v1
      with:
        input: proto
        against: 'https://github.com/${{ github.repository }}.git#branch=main'

  generate:
    runs-on: ubuntu-latest
    needs: validate

    steps:
    - uses: actions/checkout@v3

    - name: Setup Protocol Buffers
      run: |
        sudo apt-get update
        sudo apt-get install -y protobuf-compiler protobuf-compiler-grpc

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '20'

    - name: Install TypeScript plugin
      run: npm install -g @protobuf-ts/plugin

    - name: Generate Bindings
      run: ./scripts/generate.sh

    - name: Check Generated Files
      run: |
        if [ -z "$(ls -A generated/)" ]; then
          echo "No files generated!"
          exit 1
        fi
EOF

# Initial commit and push
git add .
git commit -m "feat: initial protocol buffer definitions"
git branch -M main
git remote add origin "https://github.com/$GITHUB_ORG/$REPO_NAME.git"
git push -u origin main

echo "✅ $REPO_NAME setup complete!"