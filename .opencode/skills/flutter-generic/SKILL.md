---
name: flutter-generic
description: Base Flutter development conventions - project structure, naming, code style, and best practices for any Flutter project. Use when users say "new project", "nuevo proyecto", "interface", "feature".
---

# Flutter Generic Development Conventions

## Project Structure

Prefer **feature-first** organization: group all code for a feature together rather than splitting by type.

```
lib/
  main.dart                 # Entry point, bootstrap
  app.dart                  # MaterialApp/MaterialApp.router widget

  core/                     # Truly shared code
    theme/                  # App theme definitions
    constants/              # App-wide constants
    extensions/             # Dart extension methods
    utils/                  # Utility/helper classes
    widgets/                # Reusable widgets
    router/                 # Route definitions
    network/                # API client, interceptors (if applicable)
    local/                  # Local DB helpers (if applicable)

  features/
    <feature>/
      presentation/
        pages/              # Screen/page widgets
        widgets/            # Feature-specific reusable widgets
        providers/          # State managers / controllers
      data/
        repositories/       # Repository implementations
        models/             # Data transfer objects / serialization
        datasources/        # Remote/local data sources
      domain/               # (Optional - for Clean Architecture)
        entities/           # Business entities
        repositories/       # Abstract repository interfaces
        usecases/           # Business logic use cases

  shared/                   # Widgets used across features
    widgets/
    constants/
```

## Dart Code Conventions

### Null Safety & Immutability

- All variables should be `final` unless mutation is explicitly required
- All class fields should be `final` (use `copyWith` for mutation instead of setters)
- Use `late final` only for dependency injection / initialization guarantees
- Prefer `const` constructors for all widgets and data classes when possible
- Use `??` and `?.` over conditional `if (x != null)`
- Avoid `!` (bang operator) — prefer explicit handling with `?` or pattern matching

### Naming Conventions

| Concept               | Convention                                    | Example                                 |
| --------------------- | --------------------------------------------- | --------------------------------------- |
| Files                 | `snake_case`                                  | `user_profile_page.dart`                |
| Classes               | `PascalCase`                                  | `UserProfilePage`                       |
| Methods/Functions     | `camelCase`                                   | `loadUserData()`                        |
| Variables             | `camelCase`                                   | `userName`, `isLoading`                 |
| Private members       | `_camelCase`                                  | `_loadData()`, `_counter`               |
| Constants             | `camelCase` (Dart style)                      | `defaultPadding`, `maxRetries`          |
| Enums                 | `PascalCase` for type, `camelCase` for values | `enum Status { loading, success }`      |
| Extensions            | `PascalCase` starting with `_X` pattern       | `extension ContextX on BuildContext`    |
| Controllers/Notifiers | `PascalCase` ending with descriptive role     | `UserProfileController`, `AuthNotifier` |
| State classes         | `PascalCase` ending in `State`                | `LoginState`, `DashboardState`          |

### File Organization (within a file)

1. Package imports (alphabetical)
2. Blank line
3. Project imports (alphabetical)
4. Blank line
5. Class/Code definition

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myapp/core/constants/app_colors.dart';
import 'package:myapp/features/auth/presentation/widgets/login_form.dart';

class LoginPage extends ConsumerStatefulWidget { ... }
```

### Widget Conventions

- Every widget gets its own file, named after the widget class in `snake_case`
- Prefer `StatelessWidget` over `StatefulWidget` whenever possible
- Use `ConsumerWidget` / `ConsumerStatefulWidget` with Riverpod 2.x or newer (or equivalent modern reactive state management) for reactive state
- Extract widgets into small, focused components (max ~80 lines per widget)
- Constructor parameters should be named and `required` unless optional
- Use `super.key` consistently in all widget constructors
- Build method should be organized: state reads → build result

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(provider);

  return Scaffold(
    appBar: AppBar(title: const Text('Title')),
    body: Center(child: Text(state.message)),
  );
}
```

## String & i18n Conventions

- Never hardcode display strings inside widgets
- Extract all user-facing strings into a localization system (easy_localization, flutter_localizations, etc.)
- Use `.tr()` or equivalent method call — no string literals visible to users
- String keys should be `camelCase` in JSON/YAML files
- Error messages, hints, and labels must all be localized

## Theme & Styling Conventions

- Use `Theme.of(context)` exclusively — never hardcode colors/fonts in widgets
- Define all visual constants (spacing, radius, elevation) in theme, not inline
- Prefer `TextTheme` styles over manual `TextStyle` in widgets
- Use a Design Token system: define semantic colors (not literal) before referencing in theme
- Support light and dark mode via `ThemeData` / `ColorScheme`
- Custom theme properties extend via `ThemeExtension<T>`

```dart
// Good
Text('title', style: Theme.of(context).textTheme.titleLarge)
Container(padding: EdgeInsets.all(Theme.of(context).paddingTheme.medium))

// Avoid
Text('title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
Container(padding: EdgeInsets.all(16))
```

## Responsive Design Approach

- Use the device's `MediaQuery` for layout breakpoints and safe areas
- Prefer `LayoutBuilder`, `MediaQuery`, or `OrientationBuilder` over fixed sizes
- Use percentage-based spacing (fractions of screen) rather than absolute pixels
- Avoid `SizedBox` with fixed pixel values for layout spacing
- Consider using `FractionallySizedBox`, `Flex`, `Expanded` for responsive layouts
- Test layout on multiple screen sizes (phone, tablet, landscape)

## Error Handling

### Domain Level

```dart
class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}
```

### Pattern

- Wrap repository/data operations in try-catch
- Throw typed exceptions (subclass `Exception`) — never `Error`
- Catch specific exceptions, then `rethrow` typed ones
- In UI layer: catch typed exceptions and display user-friendly messages
- Never display raw exception strings to users

## State Management Guidelines

- Separate **state** (data + status) from **business logic** (mutations + side effects)
- State classes must be **immutable** — all fields `final`, mutation via `copyWith`
- Use a `Status` enum pattern for async operations:
  ```dart
  enum LoadStatus { initial, loading, success, failure }
  ```
- State should contain `status`, `errorMessage`, and `data` fields
- Business logic lives in controller/notifier classes, never in widgets
- Side effects (API calls, DB writes) happen in controllers, not in `build()`

```dart
class ProfileState {
  final LoadStatus status;
  final String? errorMessage;
  final UserEntity? user;

  const ProfileState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.user,
  });

  ProfileState copyWith({ ... }) => ProfileState(...);

  bool get isLoading => status == LoadStatus.loading;
}
```

## Performance Guidelines

- Avoid `Reactive` widgets rebuilding unnecessarily — scope state reads tightly
- Use `const` constructors wherever possible
- Avoid `BuildContext` captures in async gaps — check `context.mounted`
- Extract long lists into `ListView.builder`, never `Column` + `forEach`
- Prefer `Image` with cache width/height, avoid unbounded image sizes
- Use `RepaintBoundary` around complex animations
- Lazy-load pages/sections that are not immediately visible

## Architecture Preferences

- **Separation of concerns**: UI layer never directly accesses data layer
- **Single Responsibility**: Each class has one reason to change
- **Dependency Inversion**: High-level modules don't depend on low-level modules; both depend on abstractions
- **Repository pattern**: Data access is abstracted behind repository interfaces
- **Unidirectional data flow**: User action → Controller → State → UI rebuild
- **Testability**: Business logic is extractable from UI framework

## Import Conventions

```dart
// STYLE: Group imports in this order, separated by blank lines

// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages (alphabetical)
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Internal packages (alphabetical by package name, then path)
import 'package:myapp/core/constants.dart';
import 'package:myapp/features/auth/presentation/pages/login_page.dart';

// 5. Relative imports (only within same feature, avoid crossing features)
import '../widgets/profile_card.dart';
```

## General Don'ts

- ❌ Don't use `print()` for debugging — use `debugPrint()` or a logger
- ❌ Don't ignore return values from futures — `await` or `unawaited()` explicitly
- ❌ Don't use `dynamic` — prefer `Object?` with type checking
- ❌ Don't use `part` or `part of` directives — prefer separate files
- ❌ Don't use global/static mutable state — use DI + state management
- ❌ Don't access `context` after an `async` gap without checking `mounted`
- ❌ Don't leave commented-out code in committed files
- ❌ Don't use `BuildContext` across async gaps

## 🎨 Design System & UI Guidelines

```
.design/ # Design assets and references at the project root
  DESIGN.md # Colors, typography, and app design guidelines
  screenshots/ # Target UI interface captures
```

### 🛠️ Agent Execution Rules:

1. **Design Source of Truth:** Always read `.design/DESIGN.md` before styling any component. Extract the color palettes and typography rules defined there.
2. **Theming Implementation:** Use the data from `DESIGN.md` to configure the `app_theme`. You must implement robust configurations for both **Light and Dark themes**.
3. **UI Replication:** When tasked with building screens, analyze the images inside `.design/screenshots/`. Deduce the layout structure, visual hierarchy, and component distribution from these captures to build the interfaces accurately.
