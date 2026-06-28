---
paths: ["**/**.ts, **/**.tsx"]
---


# TypeScript Code Review Rules

## Type Safety Checks

1. **No `any` types** without justification
   - Acceptable: Migration from JS, third-party lib with no types
   - Must include comment explaining why

2. **Null/undefined handling**
   - Use optional chaining: `obj?.prop`
   - Use nullish coalescing: `value ?? default`
   - Explicitly check for null/undefined before use

3. **Type assertions**
   - Prefer type guards over `as` assertions
   - Use `unknown` instead of `any` for truly dynamic data

## Common Issues

- Missing return type annotations on functions
- Unused imports or variables
- Console.log statements in production code
- Magic numbers (use named constants)