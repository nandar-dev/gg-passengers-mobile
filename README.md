# GG TAXI - Passenger Mobile Application

A production-ready Flutter mobile application for a ride-hailing service (similar to Bolt or Uber). This is the **passenger-side** application only—driver app and admin panel are out of scope.

## 🎯 Features

### Core Features
- ✅ **Authentication**: Phone-based login with OTP verification
- ✅ **Booking**: Find rides with price estimates for multiple car categories
- ✅ **Real-time Tracking**: Live driver location and ETA updates
- ✅ **Payments**: Multiple payment methods (Card, Cash, Wallet)
- ✅ **Ratings**: 5-star driver ratings and feedback
- ✅ **History**: Past rides with receipts and reorder option
- ✅ **Profile**: User profile with saved addresses and preferences

### Advanced Features
- 📍 **Interactive Map**: Google Maps integration with route visualization
- 🎨 **Smooth Animations**: Polished UI with carefully crafted transitions
- 🔒 **Safety Features**: SOS button and trip sharing
- 💬 **In-app Communication**: Call/Message driver
- 📱 **Deep Linking**: Share rides and links externally

## 🏗️ Architecture

This project follows **Clean Architecture** with a **Feature-First** organization pattern.

**Core Principle**: Each feature is independent and vertically organized with its own domain, data, and presentation layers.

See [.github/copilot-instructions.md](.github/copilot-instructions.md) for detailed architecture, folder structure, and technical stack.

## 📁 Screen Structure (Basic)

For faster UI iteration, all app screens are now grouped in a single simple location:

```
lib/screens/
├── splash_screen.dart
├── onboarding/
├── auth/
├── home/
├── booking/
├── ride/
├── payments/
└── profile/
lib/shared/widgets/
```

Routing imports screen widgets from `lib/screens/*` to keep `app_router.dart` focused only on route mapping.

## ⚙️ App Config

Application-level configuration is centralized in:

```
lib/config/
├── app_config.dart
├── app_environment.dart
├── api_config.dart
└── app_constants.dart
```

Use Dart defines to switch environments:

```bash
flutter run --dart-define=APP_ENV=dev
flutter run --dart-define=APP_ENV=staging
flutter run --dart-define=APP_ENV=prod
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK: ≥3.19
- Dart SDK: ≥3.11
- iOS deployment: ≥12.0
- Android deployment: ≥21

### Setup

```bash
# 1. Get dependencies
flutter pub get

# 2. Generate code (IMPORTANT)
dart run build_runner build -d

# 3. Run the app
flutter run

# For watch mode during development
dart run build_runner watch -d
```

## 💾 Current Status: Mock Mode

All API calls are mocked with simulated delays. To switch to real APIs:

1. Remove mock implementations from `data/data_sources/`
2. Create real Dio + Retrofit implementations
3. Update dependency injection in `core/di/service_locator.dart`
4. Add environment variables for API endpoints

## 🎨 Design System

- **Primary Color**: #FE8C00 (Vibrant Orange)
- **Base Unit**: 4px
- **Border Radius**: 12-16dp
- **Typography**: Roboto/SF Pro

See `lib/core/theme/app_theme.dart` for complete design tokens.

## 🧪 Testing

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Watch mode
dart run build_runner watch -d
```

## 📖 Key Concepts

See [.github/copilot-instructions.md](.github/copilot-instructions.md) for:
- Clean Architecture explanation
- Feature-first pattern rationale
- Riverpod state management guide
- Mock vs. Real implementation strategy
- ADRs (Architecture Decision Records)

## 🚢 Development Commands

```bash
# Format code
dart format lib/ test/

# Analyze for issues
flutter analyze

# Fix issues
dart fix --apply

# Run tests before committing
flutter test
```

## 📝 Features & Roadmap

### Phase 1: Core Features ✅
- [x] Auth (Phone + OTP)
- [x] Booking flow setup
- [x] Ride category entities
- [x] Fare calculation logic
- [x] Mock ride lifecycle

### Phase 2: UI Implementation 🚧
- [x] Onboarding screens
- [x] Auth screens (Login, Signup, OTP, Profile Setup)
- [ ] Home dashboard with map
- [ ] Location search & selection
- [ ] Ride booking flow

### Phase 3: Real-Time Features 📋
- [ ] Live driver tracking
- [ ] Real-time notifications
- [ ] In-app messaging
- [ ] SOS functionality

### Phase 4: Payments & History 📋
- [ ] Payment method management
- [ ] Ride history & receipts
- [ ] Driver rating system
- [ ] Wallet integration

---

**Last Updated**: April 2026  
**Maintainer**: GG_TAXI Development Team
