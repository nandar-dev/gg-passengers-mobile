# GG_TAXI Workspace Instructions

## 🎯 Project Overview
**GG_TAXI** is a production-grade **passenger-side ride-hailing application** similar to Bolt or Uber.
- **Architecture**: Clean Architecture (Feature-first).
- **State Management**: Riverpod 2.x (using `@riverpod` annotations and `build_runner`).
- **Routing**: GoRouter (declarative routing with deep-linking).
- **Networking**: Dio + Retrofit for APIs.
- **Dependency Injection**: GetIt + Injectable for DI configuration.
- **Maps**: Google Maps Flutter + Polyline for route visualization.
- **Design System**: Custom Theme. **Primary Color: #FE8C00** (Vibrant Orange).
- **Strategy**: Mock-first implementation for all Data layers for rapid iteration.

## 🏗️ Enforcement: Clean Architecture (Feature-First)
Always organize code by feature. Each feature folder must strictly contain:

lib/features/feature_name/
├── domain/            # Business Logic (No Flutter dependencies)
│   ├── entities/      # Plain Dart objects
│   ├── repositories/  # Abstract repository interfaces
│   └── use_cases/     # Logic executors (one class per action)
├── data/              # Data Implementation
│   ├── models/        # Data Transfer Objects (DTOs) + JSON mapping
│   ├── repositories/  # Implementation of domain repositories
│   └── data_sources/  # Remote (Dio) and Local (Hive/Prefs) sources
└── presentation/      # UI Layer
    ├── providers/     # Riverpod providers/notifiers
    ├── screens/       # Full-page widgets
    └── widgets/       # Feature-specific reusable components

## 🛠️ Technical Stack & Conventions
- **State**: Use `AsyncValue` for all data-fetching states.
- **Theme**: Use `ThemeData` extensions for brand-specific colors (Brand Orange: #FE8C00).
- **Icons**: Material Icons + `flutter_svg` for custom assets.
- **DI**: Use `get_it` + `injectable` for repository and use case injection.
- **Async**: Prefer `Future<T>` or `Stream<T>` with proper error handling.

## 🧪 Mocking Strategy
- Prioritize `Mock` implementations in the `data/` layer. 
- Implement `MockRepository` classes with `Future.delayed` to simulate network latency.
- Structure code so real API integration requires only swapping implementation classes.

## 🚦 Quick Start & Commands

```bash
# Get dependencies
flutter pub get

# Generate code (Riverpod, Injectable, Retrofit, JSON serialization)
# One-time generation:
dart run build_runner build -d

# Or use watch mode during development:
dart run build_runner watch -d

# Quality check
flutter analyze
flutter test
```

## 📦 Current Project Structure

```
lib/
├── core/
│   ├── di/                    # Dependency Injection (GetIt + Injectable)
│   │   └── service_locator.dart
│   ├── domain/                # Shared domain models
│   │   └── entity.dart        # Base Entity & Result types
│   ├── providers/             # Shared Riverpod providers
│   ├── routing/               # GoRouter configuration
│   │   └── app_router.dart
│   └── theme/                 # Design System
│       └── app_theme.dart     # Primary: #FE8C00
├── features/
│   ├── auth/                  # Authentication & User Management
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart    # JSON serialization
│   │   │   └── data_sources/
│   │   │       └── mock_auth_data_source.dart
│   │   └── presentation/
│   │       ├── providers/              # Riverpod: Auth state
│   │       ├── screens/                # Login, OTP, ProfileSetup
│   │       └── widgets/
│   ├── booking/               # Location Search & Ride Booking
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── location.dart
│   │   │   │   └── ride_category.dart  # Economy, Comfort, XL
│   │   │   └── repositories/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── data_sources/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── ride/                  # Ride Lifecycle & Tracking
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── ride.dart          # Ride + Driver entities
│   │   │   ├── repositories/
│   │   │   └── use_cases/
│   │   │       └── fare_calculator.dart
│   │   ├── data/
│   │   │   └── data_sources/
│   │   │       └── mock_ride_repository.dart  # Simulates ride lifecycle
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── payments/              # Payment Methods & History
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   └── profile/               # User Profile & Settings
│       ├── domain/
│       ├── data/
│       └── presentation/
└── main.dart                   # App entry point + theme + routing
```