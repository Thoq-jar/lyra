# Rules

## Syntax & Formatting

- **Always use semicolons** - Complete every statement with a semicolon
- **Use trailing commas** - Add them in multiline objects, arrays, and function
  parameters
- **Prefer const over let** - Use `const` by default, `let` only when
  reassignment needed -- **Never use var** - This can cause undefined behaviour
- **Use template literals** - Prefer `\`Hello ${name}\`` over string
  concatenation

## Type Definitions

- **Be explicit with return types** - Always specify return types for functions
- **Use interface over type for object shapes** - Better extensibility and error
  messages
- **Avoid `any`** - Use `unknown` or proper type definitions instead
- **Use union types over enums** - `type Status = 'pending' | 'completed'` for
  simple cases

## Naming & Structure

- **PascalCase for types/interfaces** - `UserProfile`, `ApiResponse`
- **camelCase for variables/functions** - `userName`, `calculateTotal`
- **kebab-case** for filenames
- **UPPER_CASE for constants** - `MAX_RETRY_COUNT`, `API_BASE_URL`
- **Prefix interfaces with 'I' sparingly** - Only when needed to distinguish
  from classes

## Error Handling

- **Use Result/Either types** - Instead of throwing exceptions for expected
  errors
- **Strict null checks** - Enable `strictNullChecks` in tsconfig
- **Optional chaining** - Use `?.` and `??` operators for safe property access

## Imports & Exports

- **Use named imports** - `import { Component } from 'react'`
- **Group imports** - External libraries first, then internal modules
- **Use barrel exports** - Create `index.ts` files to re-export from directories
- **Avoid default exports** - Named exports provide better refactoring support

## Functions

- **Pure functions when possible** - No side effects, predictable outputs
- **Single responsibility** - Each function should do one thing well
- **Use type guards** - Create custom type predicates for runtime type checking
- **Prefer readonly arrays** - `readonly T[]` over `T[]` when mutation isn't
  needed
