#!/bin/bash
# setup-codegraph-api.sh

REPO_NAME="codegraph-api"
GITHUB_ORG="Consiliency"

# Create and enter directory
mkdir -p $REPO_NAME && cd $REPO_NAME

# Initialize git
git init

# Initialize npm project
npm init -y

# Create directory structure
mkdir -p {src/{controllers,services,middleware,utils,types},tests,docs,.github/workflows}

# Install dependencies
npm install --save \
  express \
  @apollo/server \
  graphql \
  ws \
  cors \
  helmet \
  compression \
  dotenv \
  winston \
  joi \
  @grpc/grpc-js \
  @grpc/proto-loader

# Install dev dependencies
npm install --save-dev \
  @types/node \
  @types/express \
  @types/cors \
  @types/compression \
  @types/ws \
  typescript \
  ts-node \
  nodemon \
  jest \
  @types/jest \
  ts-jest \
  @typescript-eslint/parser \
  @typescript-eslint/eslint-plugin \
  eslint \
  prettier \
  husky \
  lint-staged \
  @swc/core \
  @swc/jest

# Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "allowJs": false,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Build output
dist/
build/
out/
*.tsbuildinfo

# Environment files
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Test coverage
coverage/
.nyc_output/

# Logs
logs/
*.log

# Temporary files
tmp/
temp/
EOF

# Create .eslintrc.json
cat > .eslintrc.json << 'EOF'
{
  "parser": "@typescript-eslint/parser",
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-type": "warn",
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "@typescript-eslint/no-floating-promises": "error",
    "@typescript-eslint/await-thenable": "error"
  },
  "ignorePatterns": ["dist/", "node_modules/", "*.js"]
}
EOF

# Create .prettierrc
cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "all",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "endOfLine": "lf"
}
EOF

# Create jest.config.js
cat > jest.config.js << 'EOF'
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  transform: {
    '^.+\\.ts$': ['@swc/jest'],
  },
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
};
EOF

# Create main application file
cat > src/index.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import { config } from 'dotenv';
import { logger } from './utils/logger';
import { typeDefs, resolvers } from './graphql';

config();

const app = express();
const httpServer = createServer(app);

// Middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

async function startServer() {
  const apolloServer = new ApolloServer({
    typeDefs,
    resolvers,
  });

  await apolloServer.start();

  app.use(
    '/graphql',
    expressMiddleware(apolloServer, {
      context: async ({ req }) => ({ token: req.headers.token }),
    })
  );

  const PORT = process.env.PORT || 3000;
  httpServer.listen(PORT, () => {
    logger.info(`Server running on http://localhost:${PORT}`);
    logger.info(`GraphQL endpoint: http://localhost:${PORT}/graphql`);
  });
}

startServer().catch((error) => {
  logger.error('Failed to start server:', error);
  process.exit(1);
});
EOF

# Create logger utility
mkdir -p src/utils
cat > src/utils/logger.ts << 'EOF'
import winston from 'winston';

export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      ),
    }),
  ],
});
EOF

# Create basic GraphQL schema
mkdir -p src/graphql
cat > src/graphql/index.ts << 'EOF'
import { gql } from 'graphql-tag';

export const typeDefs = gql`
  type Query {
    version: String!
    health: HealthStatus!
  }

  type HealthStatus {
    status: String!
    timestamp: String!
  }
`;

export const resolvers = {
  Query: {
    version: () => '0.1.0',
    health: () => ({
      status: 'ok',
      timestamp: new Date().toISOString(),
    }),
  },
};
EOF

# Update package.json scripts
npm pkg set scripts.build="tsc"
npm pkg set scripts.start="node dist/index.js"
npm pkg set scripts.dev="nodemon src/index.ts"
npm pkg set scripts.test="jest"
npm pkg set scripts.test:watch="jest --watch"
npm pkg set scripts.test:coverage="jest --coverage"
npm pkg set scripts.lint="eslint src --ext .ts"
npm pkg set scripts.format="prettier --write 'src/**/*.ts'"
npm pkg set scripts.typecheck="tsc --noEmit"

# Create README.md
cat > README.md << 'EOF'
# CodeGraph API

GraphQL and REST API server for CodeGraph/USA providing real-time code analysis capabilities.

## Features

- **GraphQL API**: Flexible query interface for code graph exploration
- **REST Endpoints**: Traditional REST API for simple operations
- **WebSocket Support**: Real-time updates and streaming
- **gRPC Integration**: High-performance communication with core engine

## Requirements

- Node.js 18+
- npm or yarn
- Docker (optional)

## Installation

```bash
npm install
```

## Development

```bash
npm run dev
```

## Building

```bash
npm run build
```

## Testing

```bash
npm test
```

## API Documentation

GraphQL playground available at `/graphql` in development mode.

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
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Lint
      run: npm run lint

    - name: Type check
      run: npm run typecheck

    - name: Test
      run: npm run test:coverage

    - name: Build
      run: npm run build

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      if: matrix.node-version == '20.x'
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/index.js"]
EOF

# Initial commit and push
git add .
git commit -m "feat: initial TypeScript API server structure"
git branch -M main
git remote add origin "https://github.com/$GITHUB_ORG/$REPO_NAME.git"
git push -u origin main

echo "✅ $REPO_NAME setup complete!"