# GitHub Copilot Instructions

## General Guidelines
- Use SwiftUI instead of UIKit for all examples.
- Follow MVVM architecture with clear separation between View, ViewModel, and Model layers.
- Use Combine for data flow and binding where applicable.
- Always include `@MainActor` on ViewModels interacting with the UI.
- Format code with 2-space indentation.
- Prefer concise, expressive variable names.

## Project-Specific Details
- This is a banking app.
- We support transfers, payments, and P2P transactions.
- Do not suggest third-party libraries; use native Apple frameworks only.
- Validation should be clean, reusable, and composable using protocols.

## Documentation Style
- Add doc comments (`///`) above each public method and type.
- When appropriate, explain business logic with inline comments.

## Naming Conventions
- Use camelCase for variables and methods.
- Use PascalCase for types (e.g., ViewModels, Views, Models).
- Suffix view models with `ViewModel`, views with `View`.

## Don’ts
- Do not generate print statements for debugging.
- Do not use forced unwrapping (`!`) unless absolutely necessary.
- Avoid `DispatchQueue.main.async` unless no other options are viable.