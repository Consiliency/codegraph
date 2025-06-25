#!/bin/bash
# setup-codegraph-core.sh

REPO_NAME="codegraph-core"
GITHUB_ORG="Consiliency"

# Create and enter directory
mkdir -p $REPO_NAME && cd $REPO_NAME

# Initialize git
git init

# Create directory structure
mkdir -p {src/{ast,graph,storage,bindings},include/codegraph,tests,benchmarks,docs,cmake,scripts,.github/workflows}

# Create .gitignore
cat > .gitignore << 'EOF'
# Build directories
build/
out/
cmake-build-*/

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# Compiled files
*.o
*.so
*.dylib
*.dll
*.a
*.lib
*.exe

# Dependencies
vcpkg_installed/
conan/
.conan/

# Testing
Testing/
test-results/
*.gcov
*.gcda
*.gcno
coverage/

# Documentation
docs/_build/
docs/html/
doxygen/

# OS files
.DS_Store
Thumbs.db

# Python bindings
*.pyc
__pycache__/
*.egg-info/
dist/
wheels/
EOF

# Create CMakeLists.txt
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)
project(codegraph-core VERSION 0.1.0 LANGUAGES CXX)

# C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Options
option(BUILD_TESTS "Build tests" ON)
option(BUILD_BENCHMARKS "Build benchmarks" OFF)
option(BUILD_PYTHON_BINDINGS "Build Python bindings" ON)
option(ENABLE_COVERAGE "Enable coverage reporting" OFF)

# Find packages
find_package(Threads REQUIRED)
find_package(Protobuf REQUIRED)

# Add subdirectories
add_subdirectory(src)
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
if(BUILD_BENCHMARKS)
    add_subdirectory(benchmarks)
endif()

# Installation
include(GNUInstallDirs)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
EOF

# Create main library CMakeLists.txt
cat > src/CMakeLists.txt << 'EOF'
# Core library
add_library(codegraph-core
    ast/parser.cpp
    ast/canonicalizer.cpp
    graph/graph_manager.cpp
    graph/traversal.cpp
    storage/content_store.cpp
    storage/blake3_hasher.cpp
)

target_include_directories(codegraph-core
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(codegraph-core
    PUBLIC
        Threads::Threads
        protobuf::libprotobuf
)

# Python bindings
if(BUILD_PYTHON_BINDINGS)
    add_subdirectory(bindings)
endif()
EOF

# Create initial header file
cat > include/codegraph/core.h << 'EOF'
#pragma once

#include <string>
#include <vector>
#include <memory>

namespace codegraph {

class Core {
public:
    Core();
    ~Core();
    
    std::string version() const;
};

} // namespace codegraph
EOF

# Create initial source file
cat > src/ast/parser.cpp << 'EOF'
#include "codegraph/core.h"

namespace codegraph {

Core::Core() = default;
Core::~Core() = default;

std::string Core::version() const {
    return "0.1.0";
}

} // namespace codegraph
EOF

# Create README.md
cat > README.md << 'EOF'
# CodeGraph Core

High-performance C++ engine for CodeGraph/USA providing AST parsing, graph algorithms, and content-addressable storage.

## Features

- **AST Parsing**: Tree-sitter based parsing for multiple languages
- **Graph Operations**: High-performance graph algorithms
- **Content Storage**: BLAKE3-based content-addressable storage
- **Python Bindings**: Native Python integration via pybind11

## Requirements

- C++20 compiler (GCC 11+, Clang 13+, MSVC 2022+)
- CMake 3.20+
- Python 3.8+ (for bindings)

## Building

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

## Testing

```bash
cd build
ctest --output-on-failure
```

## License

Apache License 2.0
EOF

# Create GitHub Actions workflow
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        compiler: [gcc, clang]
        exclude:
          - os: macos-latest
            compiler: gcc

    steps:
    - uses: actions/checkout@v3
      with:
        submodules: recursive

    - name: Install dependencies
      run: |
        if [ "$RUNNER_OS" == "Linux" ]; then
          sudo apt-get update
          sudo apt-get install -y cmake ninja-build
        elif [ "$RUNNER_OS" == "macOS" ]; then
          brew install cmake ninja
        fi

    - name: Configure
      run: |
        cmake -B build -G Ninja \
          -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_TESTS=ON \
          -DBUILD_BENCHMARKS=ON

    - name: Build
      run: cmake --build build

    - name: Test
      run: cd build && ctest --output-on-failure
EOF

# Create placeholder files
touch src/ast/canonicalizer.cpp
touch src/graph/graph_manager.cpp
touch src/graph/traversal.cpp
touch src/storage/content_store.cpp
touch src/storage/blake3_hasher.cpp

# Initial commit and push
git add .
git commit -m "feat: initial C++ project structure for codegraph-core"
git branch -M main
git remote add origin "https://github.com/$GITHUB_ORG/$REPO_NAME.git"
git push -u origin main

echo "✅ $REPO_NAME setup complete!"