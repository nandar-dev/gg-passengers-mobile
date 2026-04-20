# Architecture Decision Records (ADRs)

This document records significant architectural decisions made in GG TAXI.

---

## ADR-001: Feature-First Clean Architecture

**Date**: April 2026  
**Status**: ✅ Accepted

### Context
We needed to structure a scalable ride-hailing application where multiple features (auth, booking, ride tracking, payments) would be developed concurrently by different team members.

### Problem
Traditional layer-based architecture (screens/, models/, services/) creates bottlenecks:
- All screens live in one folder → merge conflicts
- Shared logic in services → hard to remove features
- No clear ownership of features
- Feature impact is unclear

### Decision
Use **Feature-First Clean Architecture** where each feature is self-contained:

```
lib/features/feature_name/
├── domain/       # Pure business logic (no Flutter deps)
├── data/         # Implementation (APIs, databases)
└── presentation/ # UI layer (screens, widgets)
```

### Rationale
✅ **Reduced merge conflicts**: Each team owns one feature folder  
✅ **Feature autonomy**: Install/remove features independently  
✅ **Clear boundaries**: Domain layer is framework-agnostic  
✅ **Testability**: Easy to unit test domain logic  
✅ **Scalability**: Works for small (5 devs) to large (50+ devs) teams  

### Trade-offs
❌ Potential code duplication (mitigated by `core/` shared utilities)  
❌ Requires discipline to avoid feature dependencies  
❌ Steeper onboarding curve for new team members  

### Alternatives Considered
1. **Layer-First**: Rejected (creates bottlenecks)
2. **Module-Based (horizontal)**: Similar benefits but harder to navigate related code
3. **Hybrid (layers + features)**: Rejected (complexity without clear benefit)

### Implementation Guidelines
- Each feature owns its domain, data, and presentation
- `core/` contains only truly shared code (DI, theme, routing)
- Features may import from `core/` but not from other features
- Cross-feature communication via Riverpod providers or deep linking

### UI Folder Note (Current)
- For a simpler workflow, app route screens are currently grouped under `lib/screens/`.
- This keeps all full-page UI widgets in one place while domain/data logic stays in `lib/features/`.
- `lib/core/routing/app_router.dart` should only map routes to screen classes.

### Config Folder Note (Current)
- App and environment configuration lives in `lib/config/`.
- `app_config.dart` is initialized at startup and exposes current environment and API base configuration.
- Prefer using config values instead of hardcoding base URLs or app-level constants in features.

---

## ADR-002: Riverpod for State Management

**Date**: April 2026  
**Status**: ✅ Accepted

### Context
GG TAXI needs a state management solution that:
- Handles complex async data flows (API calls, real-time streams)
- Provides testability without verbose mocking
- Works well with code generation and type safety

### Problem
Popular options have trade-offs:
- **Provider**: Simple but value-based (not reactive)
- **BLoC**: Reactive but verbose boilerplate
- **GetX**: All-in-one but too opinionated
- **Cubit**: Good but requires manual dependency handling

### Decision
Adopt **Riverpod 2.x** as the primary state management solution.

### Rationale
✅ **Compile-time safe**: Errors caught during build  
✅ **Tree-shakeable**: Only used providers bundled  
✅ **Superior testing**: Can override providers for testing  
✅ **Generator support**: Works with build_runner  
✅ **Reactive**: Automatic dependency tracking  
✅ **Modern**: Async/await first-class support  

### Architecture Pattern
```dart
// Simple provider
final userProvider = FutureProvider<User>((ref) async {
  return fetchUser();
});

// With custom notifier
final rideBookingProvider = StateNotifierProvider<RideBookingNotifier, RideBooking>((ref) {
  return RideBookingNotifier(ref.watch(authProvider));
});

// Watching in UI
@override
Widget build(BuildContext context, WidgetRef ref) {
  final asyncUser = ref.watch(userProvider);
  return asyncUser.when(
    data: (user) => Text(user.name),
    loading: () => const CircularProgressIndicator(),
    error: (err, st) => Text('Error: $err'),
  );
}
```

### Trade-offs
❌ Steeper learning curve than Provider  
❌ Requires build_runner (slower initial compile)  
❌ Less documentation compared to BLoC  
❌ Still evolving API (but stable since v2.0)  

### Alternatives Considered
1. **Provider**: Rejected (not reactive enough)
2. **BLoC**: Rejected (too verbose)
3. **GetX**: Rejected (too opinionated, less testable)

### Migration Path
If Riverpod becomes problematic:
1. Extract business logic to domain/ (use_cases)
2. Replace Riverpod providers with alternative state management
3. UI layer remains mostly unchanged

---

## ADR-003: Mock-First Development Strategy

**Date**: April 2026  
**Status**: ✅ Accepted

### Context
GG TAXI needs to:
- Start building UI before backend is ready
- Test offline without network dependency
- Iterate quickly on requirements
- Minimize developer friction during early stages

### Problem
Traditional approach (wait for API, then build UI):
- UI development blocked by backend
- Manual testing requires live server
- API changes require re-testing everything
- Network issues interfere with UI development

### Decision
Implement all data sources as **Mock implementations first**, then swap with real APIs.

### Mock Implementation Pattern

```dart
// Mock
class MockRideRepository {
  Future<Ride> requestRide(...) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Ride(...);
  }
}

// Real (later)
class RideRepositoryImpl implements RideRepository {
  final DioClient dio;
  Future<Ride> requestRide(...) async {
    final response = await dio.post('/rides', data: {...});
    return Ride.fromJson(response);
  }
}
```

### Rationale
✅ **Unblocked development**: UI team doesn't wait for backend  
✅ **Deterministic testing**: No network flakiness  
✅ **Rapid iteration**: Change scenarios instantly  
✅ **Mechanical swap**: Real API integration is straightforward  
✅ **Confidence**: Full UI flow can be tested end-to-end  

### Implementation Guidelines
- Mock implementations use `Future.delayed()` to simulate latency
- Each mock has predictable, hardcoded data
- Real implementations wrap network calls with error handling
- DI layer determines which implementation is used

### Trade-offs
❌ Mock data may not match real API exactly  
❌ Real error scenarios not caught until API integration  
❌ Manual syncing when API changes  
❌ Need to test with real API before release  

### Quality Assurance Checklist Before Launch
- [ ] All mock implementations replaced with real APIs
- [ ] API endpoints documented and tested
- [ ] Error scenarios tested (timeouts, 500s, etc.)
- [ ] Real data volume tested (performance)
- [ ] Network conditions tested (3G, offline)

---

## ADR-004: Platform-Specific Build Flavors

**Date**: April 2026  
**Status**: 📋 Planned (Post-MVP)

### Context
As the app grows to support multiple environments (dev, staging, production), we need:
- Different API endpoints per environment
- Environment-specific feature flags
- Staging data separate from production

### Decision (Future)
Implement Flutter build flavors (dev, staging, prod) with:
- Environment-specific `main_dev.dart`, `main_staging.dart`, `main_prod.dart`
- Configuration via `--flavor` flag in build commands
- Firebase project per environment

### Example Usage
```bash
flutter run --flavor dev       # Dev API + mock data
flutter run --flavor staging   # Staging API + real backend
flutter run --release --flavor prod  # Production API
```

---

## ADR-005: Offline-First Architecture

**Date**: April 2026  
**Status**: 📋 Planned (Phase 2)

### Context
Users may have spotty connectivity. We need graceful degradation and caching.

### Decision (Future)
- Use Hive for local caching of rides, user profile
- Implement sync queue for actions while offline
- Show cached data while fetching fresh data (stale-while-revalidate)

---

## ADR-006: Real-Time Driver Tracking with Streams

**Date**: April 2026  
**Status**: 🚧 In Development

### Context
During a ride, driver location must update in real-time without polling.

### Decision
Use Firestore Realtime or WebSockets:
- Driver sends location every 3 seconds
- Passenger receives updates via Stream<DriverLocation>
- Riverpod watches stream with `StreamProvider`

---

## Glossary

| Term | Definition |
|------|-----------|
| **Repository** | Interface-based abstraction over data sources |
| **Use Case** | Standalone function/class containing business logic |
| **Entity** | Domain model (no framework knowledge) |
| **DTO** | Data Transfer Object (matches API JSON) |
| **Provider** | Riverpod observable that provides state or data |
| **Notifier** | Mutable Riverpod provider with imperative updates |
| **Ref** | Reference to Riverpod container (like context) |

---

## Making New Decisions

When facing an architectural question:

1. **Document the context** and problem being solved
2. **List alternatives** and trade-offs
3. **Make a decision** with clear rationale
4. **Record it here** with status and date
5. **Communicate** to team via PR review

ADRs are not set in stone—update them as learnings emerge.
