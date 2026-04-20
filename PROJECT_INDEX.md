# GG TAXI - Project Index & Navigation

Welcome to **GG TAXI** - A production-ready Flutter ride-hailing application!

This file serves as your navigation hub. Start here to understand the project structure and find what you need.

---

## 🚀 Getting Started (5 minutes)

**First time?** Read this first:
1. [SETUP_COMPLETE.md](SETUP_COMPLETE.md) - Project initialization summary
2. [README.md](README.md) - Quick start + feature overview

Then run:
```bash
flutter pub get
dart run build_runner build -d
flutter run
```

---

## 📚 Documentation by Role

### 👨‍💻 For Developers

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Project overview + quick start |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 6 ADRs explaining design decisions |
| [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Complete UI component library |
| [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) | Quick lookup for common tasks |
| [.github/copilot-instructions.md](.github/copilot-instructions.md) | Coding conventions |

### 🎨 For Designers

- [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) - Colors, typography, spacing, components
- [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md#-design-constants) - Design constants for reference

### 📊 For Project Managers

- [README.md](README.md#-features--roadmap) - Feature list + roadmap
- [SETUP_COMPLETE.md](SETUP_COMPLETE.md#-project-roadmap) - Phase breakdown + timeline
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Technical decisions

---

## 🏗️ Project Structure

```
gg/                              # Project root
├── lib/                          # Source code
│   ├── main.dart                 # Entry point (updated!)
│   ├── config/                   # App/environment/API configuration
│   ├── core/
│   │   ├── di/                   # Dependency injection
│   │   ├── domain/               # Base entities & types
│   │   ├── providers/            # App-level Riverpod
│   │   ├── routing/              # GoRouter configuration
│   │   └── theme/                # Design system (#FE8C00)
│   ├── screens/                  # App screens (basic UI folder)
│   │   ├── auth/
│   │   ├── booking/
│   │   ├── home/
│   │   ├── onboarding/
│   │   ├── payments/
│   │   ├── profile/
│   │   ├── ride/
│   ├── shared/
│   │   └── widgets/
│   └── features/
│       ├── auth/                 # ✅ Ready for UI
│       │   ├── domain/
│       │   ├── data/             # Mock data source
│       │   └── presentation/     # (screens to build)
│       ├── booking/              # ✅ Entities ready
│       ├── ride/                 # ✅ Entities + Fare calculation
│       ├── payments/             # 📋 Structure ready
│       └── profile/              # 📋 Structure ready
│
├── test/                         # Tests
│   └── features/
│       └── ride/
│           └── domain/use_cases/  # ✅ 11 passing tests
│
├── docs/
│   ├── ARCHITECTURE.md            # 6 ADRs
│   ├── DESIGN_SYSTEM.md           # UI component library
│   └── QUICK_REFERENCE.md         # Developer quick lookup
│
├── pubspec.yaml                  # ✅ All deps configured
├── analysis_options.yaml         # Lint rules
├── README.md                     # Project overview
├── SETUP_COMPLETE.md             # This project setup
└── PROJECT_INDEX.md              # You are here
```

---

## 🧩 Architecture Pattern

**Clean Architecture + Feature-First**

Each feature is self-contained:
```
feature_name/
├── domain/          # Pure business logic (no Flutter)
│   ├── entities/    # Data models
│   ├── repositories/# Interfaces
│   └── use_cases/   # Business logic
├── data/            # Implementations
│   ├── models/      # DTOs + JSON
│   ├── repositories/# Concrete impls
│   └── data_sources/# Mocks/APIs
└── presentation/    # UI Layer
    ├── providers/   # Riverpod state
    ├── screens/     # Full-page widgets
    └── widgets/     # Reusable components
```

✅ **Reduces merge conflicts**  
✅ **Enables team autonomy**  
✅ **Clear separation of concerns**  
✅ **Easy to test**  

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md#adr-001-feature-first-clean-architecture) for detailed rationale.

---

## 🛠️ Tech Stack at a Glance

| Layer | Technology | Why? |
|-------|-----------|------|
| **State Management** | Riverpod 2.x | Compile-safe, testable, modern |
| **Routing** | GoRouter | Declarative, deep-linking |
| **Networking** | Dio + Retrofit | Type-safe APIs |
| **DI** | GetIt + Injectable | Service locator |
| **Maps** | google_maps_flutter | Route visualization |
| **Storage** | Hive + SharedPrefs | Offline-first data |
| **Testing** | flutter_test, mockito | Unit + widget tests |

See [.github/copilot-instructions.md](.github/copilot-instructions.md#-technical-stack--conventions) for full details.

---

## 📋 What's Implemented

### ✅ Complete
- [x] **Core Infrastructure**: Theme, routing, DI setup
- [x] **Config Module**: App config + env + API config
- [x] **Auth Feature**: User entity + mock data source
- [x] **Booking Feature**: Location, RideCategory entities
- [x] **Ride Feature**: Ride entity + FareCalculator use case
- [x] **Mock Implementations**: All features have mock data
- [x] **Unit Tests**: 11 tests for FareCalculator (✅ passing)
- [x] **Documentation**: 5 comprehensive guides

### 🚧 In Progress
- [x] **UI Screens**: Basic route screens moved to lib/screens/
- [ ] **Riverpod Providers**: Auth, Booking, RideTracking state
- [ ] **Widget Tests**: For each screen component

### 📋 Planned
- [ ] **Real API Integration**: Swap mock repos with Dio/Retrofit
- [ ] **Firebase Auth**: Phone verification
- [ ] **Real-time Features**: Firestore Streams for tracking
- [ ] **Payment Integration**: Stripe/PayU integration
- [ ] **Performance**: Build flavors (dev/staging/prod)

---

## 🚀 Quick Commands

### Setup
```bash
flutter pub get                    # Install dependencies
dart run build_runner build -d     # Generate code once
dart run build_runner watch -d     # Watch mode (recommended)
```

### Development
```bash
flutter run                        # Run debug build
flutter run -v                     # Verbose output
```

### Quality
```bash
dart format lib/ test/              # Format code
dart fix --apply                   # Apply fixes
flutter analyze                    # Check issues
flutter test                       # Run tests
flutter test --coverage            # With coverage
```

### Build
```bash
flutter build apk --release        # Android
flutter build appbundle --release  # Android (Play Store)
flutter build ios --release        # iOS
```

---

## 🎯 Development Workflow

### Day 1: Setup (Done!)
- ✅ Dependencies configured
- ✅ Core infrastructure in place
- ✅ Feature scaffolding complete
- ✅ Mock implementations ready

### Day 2-3: Build Auth UI
1. Create LoginScreen, OTPScreen, ProfileSetupScreen
2. Add Riverpod providers for auth state
3. Test with mock data source

### Day 4-5: Build Booking UI
1. Create HomeScreen with map
2. Build SearchLocationScreen
3. Build RideCategorySelection
4. Test with mock fare calculator

### Day 6+: Integrate & Polish
1. Replace mocks with real APIs
2. Add real-time tracking
3. Payment integration
4. Performance optimization

See [README.md#-features--roadmap](README.md#-features--roadmap) for full roadmap.

---

## 🎨 Design System Essentials

**Primary Color**: #FE8C00 (Vibrant Orange)
- Use for all CTAs, highlights, active states

**Typography**: Roboto/SF Pro
- Headlines: 700 weight
- Body: 400 weight
- Labels: 500 weight

**Spacing**: 4px base unit
- 16px page padding
- 12px item gaps
- 24px section gaps

**Border Radius**: 12-16dp standard

✅ All components pre-built in [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart)

See [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) for complete reference.

---

## 🧪 Testing Strategy

### Unit Tests
- Pure business logic in domain/ layer
- No Flutter dependencies
- Run fast (~100ms each)

### Widget Tests
- UI components and screens
- Interactions (taps, scrolls)
- Async behavior

### Integration Tests
- Full user flows
- Real-like scenarios
- Slower but comprehensive

**Current**: 11 unit tests ✅ (FareCalculator)  
**Next**: Widget tests for screens  
**Run**: `flutter test`

See [test/features/ride/domain/use_cases/fare_calculator_test.dart](test/features/ride/domain/use_cases/fare_calculator_test.dart) for examples.

---

## 🔍 File Navigation

### Key Files
- **Entry Point**: [lib/main.dart](lib/main.dart)
- **Theme**: [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart)
- **Routing**: [lib/core/routing/app_router.dart](lib/core/routing/app_router.dart)
- **DI**: [lib/core/di/service_locator.dart](lib/core/di/service_locator.dart)

### Feature Examples
- **Auth**: [lib/features/auth/](lib/features/auth/)
- **Booking**: [lib/features/booking/](lib/features/booking/)
- **Ride**: [lib/features/ride/](lib/features/ride/)

### Documentation
- **Architecture**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **Design System**: [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)
- **Quick Reference**: [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)

### Tests
- **Example Tests**: [test/features/ride/domain/use_cases/](test/features/ride/domain/use_cases/)

---

## ❓ FAQ

### **Q: Where do I start coding?**
A: Start with screens in `presentation/screens/`. Check [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md#i-need-to) for patterns.

### **Q: How do I add a new feature?**
A: Follow [docs/QUICK_REFERENCE.md#create-a-new-feature](docs/QUICK_REFERENCE.md#create-a-new-feature).

### **Q: Why is build_runner required?**
A: For Riverpod code generation. Run `dart run build_runner watch -d`.

### **Q: Can I use a different state management?**
A: Yes, but follow Riverpod patterns. See [docs/ARCHITECTURE.md#adr-002-riverpod-for-state-management](docs/ARCHITECTURE.md#adr-002-riverpod-for-state-management).

### **Q: How do I test my code?**
A: Look at [test/features/ride/domain/use_cases/fare_calculator_test.dart](test/features/ride/domain/use_cases/fare_calculator_test.dart) for examples.

### **Q: When do we replace mocks with real APIs?**
A: After UI is built and working with mocks. See [README.md#-mock-vs-real-implementation](README.md#-mock-vs-real-implementation).

---

## 📞 Getting Help

1. **Architecture questions**: Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
2. **Design questions**: Check [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)
3. **Code patterns**: See [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)
4. **Conventions**: Review [.github/copilot-instructions.md](.github/copilot-instructions.md)
5. **Examples**: Look at existing features (auth/, ride/, etc.)

---

## 🎓 Learning Path

1. **Day 1**: Read [README.md](README.md) + [SETUP_COMPLETE.md](SETUP_COMPLETE.md)
2. **Day 2**: Understand [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
3. **Day 3**: Study [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)
4. **Day 4**: Explore existing features (auth/, ride/)
5. **Day 5**: Start coding screens using [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)

---

## ✅ Pre-Launch Checklist

Before releasing to production:
- [ ] All screens built and polished
- [ ] Real API integration complete
- [ ] Firebase Auth working
- [ ] Real-time tracking functional
- [ ] Payment integration tested
- [ ] Offline-first implemented
- [ ] 90%+ test coverage
- [ ] Performance profiled
- [ ] Access control verified
- [ ] Analytics integrated

---

## 🏆 Success Criteria

**Phase 1 (Foundation)** ✅ COMPLETE
- Architecture in place
- Mock implementations ready
- Documentation comprehensive

**Phase 2 (UI)** 🚧 IN PROGRESS
- All screens built
- All flows tested
- Design system applied

**Phase 3 (Integration)** 📋 PLANNED
- Real APIs connected
- Real-time features working
- Production ready

---

## 📄 License

This project is proprietary. All rights reserved by GG_TAXI.

---

## 🙋 Questions?

Each document has specific content. Start with what you need:

| I want to... | Read this |
|--------------|-----------|
| Get started quickly | [README.md](README.md) |
| Understand architecture | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Build UI screens | [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) |
| Design components | [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) |
| Follow conventions | [.github/copilot-instructions.md](.github/copilot-instructions.md) |

---

**Last Updated**: April 10, 2026  
**Project Status**: ✅ Ready for Feature Development  
**Next Phase**: UI Implementation

Happy coding! 🚀
