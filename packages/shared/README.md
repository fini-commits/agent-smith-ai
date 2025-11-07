# Shared Types & Schemas

This package will contain shared TypeScript and Python schemas for cross-service communication.

## Future Structure

```
packages/shared/
├── python/
│   ├── schemas.py        # Pydantic models
│   └── __init__.py
└── typescript/
    ├── types.ts          # TypeScript interfaces
    └── index.ts
```

## Usage

### Python (FastAPI)
```python
from shared.schemas import Action, Step, Run
```

### TypeScript (Next.js)
```typescript
import { Action, Step, Run } from '@agent-smith/shared'
```
