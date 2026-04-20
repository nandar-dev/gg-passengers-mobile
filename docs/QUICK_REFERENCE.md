# GG TAXI Quick Reference

A quick lookup guide for common tasks and patterns in GG TAXI development.

## 🚀 Getting Started (First Time)

```bash
# 1. Clone and setup
git clone <repo>
cd gg

# 2. Install dependencies
flutter pub get

# 3. Generate code
dart run build_runner build -d

# 4. Run app
flutter run

# 5. (Recommended) Use watch mode for development
dart run build_runner watch -d
```

## 📁 I need to...

### ...Configure app environment

Config files are grouped in:

```
lib/config/
├── app_config.dart
├── app_environment.dart
├── api_config.dart
└── app_constants.dart
```

Run app with environment:

```bash
flutter run --dart-define=APP_ENV=dev
flutter run --dart-define=APP_ENV=staging
flutter run --dart-define=APP_ENV=prod
```

### ...Add a new screen (basic app structure)

1. Create screen file in `lib/screens/<module>/my_screen.dart`
2. Keep route mapping in `lib/core/routing/app_router.dart`
3. Keep reusable UI pieces in `lib/shared/widgets/`

Example:
```
lib/screens/
├── auth/login_screen.dart
├── booking/search_location_screen.dart
lib/shared/widgets/
└── auth_text_field.dart
```

### ...Create a new feature

1. Create folder structure:
```
lib/features/my_feature/
├── domain/
│   ├── entities/
│   │   └── my_entity.dart
│   ├── repositories/
│   │   └── my_repository.dart
│   └── use_cases/
│       └── my_use_case.dart
├── data/
│   ├── models/
│   │   └── my_model.dart
│   ├── repositories/
│   │   └── my_repository_impl.dart
│   └── data_sources/
│       └── mock_my_data_source.dart
└── presentation/
    ├── providers/
    │   └── my_provider.dart
    ├── screens/
    │   └── my_screen.dart
    └── widgets/
        └── my_widget.dart
```

2. Start with **domain** (entities, interfaces)
3. Add **mock data sources** in data/
4. Create **Riverpod providers** in presentation/
5. Build **UI screens** last

### ...Add a Riverpod provider

```dart
// Simple provider
final userProvider = FutureProvider<User>((ref) async {
  return fetchUser();
});

// State notifier (mutable)
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier(0);
});

// Family (parameterized)
final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
  return fetchUserById(userId);
});

// Watch in UI
@override
Widget build(BuildContext context, WidgetRef ref) {
  final asyncUser = ref.watch(userProvider);
  return asyncUser.when(
    data: (user) => Text(user.name),
    loading: () => const Loader(),
    error: (err, st) => Text('Error: $err'),
  );
}
```

### ...Create a mock data source

```dart
class MockMyRepository {
  static const Duration _networkDelay = Duration(milliseconds: 800);

  Future<MyEntity> getData() async {
    // Simulate network latency
    await Future.delayed(_networkDelay);
    
    // Return mock data
    return MyEntity(id: '1', name: 'Mock Data');
  }

  Stream<MyEntity> watchData(String id) async* {
    // For real-time data
    yield MyEntity(id: id, status: 'loading');
    await Future.delayed(_networkDelay);
    yield MyEntity(id: id, status: 'complete');
  }
}
```

### ...Handle errors

```dart
// Using Result type
try {
  final result = await repository.fetchData();
  return Success(result);
} catch (e, st) {
  return Failure('Failed to fetch data', exception: Exception(e));
}

// In provider
final dataProvider = FutureProvider<Data>((ref) async {
  final result = await repository.fetchData();
  return result.when(
    success: (data) => data,
    failure: (message) => throw Exception(message),
  );
});

// In UI
asyncValue.when(
  data: (data) => ShowData(data),
  loading: () => Loader(),
  error: (error, st) {
    print('Error: $error\n$st');
    return ErrorWidget(error.toString());
  },
);
```

### ...Navigate between screens

```dart
// From anywhere
import 'package:go_router/go_router.dart';

// Push new screen
context.push('/home/search-location');

// Replace current screen
context.go('/home');

// Pop back
context.pop();

// With parameters
context.push('/otp-verification', extra: '+1234567890');

// Named routes (type-safe)
context.pushNamed('rideReview', pathParameters: {'rideId': '123'});
```

### ...Style text

```dart
// Use theme styles
Text(
  'Welcome',
  style: Theme.of(context).textTheme.headlineLarge, // Pre-fab styles
)

// Or manual
Text(
  'Book Ride',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).primaryColor,
    letterSpacing: 0.15,
  ),
)
```

### ...Create a button

```dart
// Primary (Elevated)
ElevatedButton(
  onPressed: () => bookRide(),
  child: const Text('Request Ride'),
)

// Secondary (Outlined)
OutlinedButton(
  onPressed: () => cancel(),
  child: const Text('Cancel'),
)

// Text only
TextButton(
  onPressed: () => showMore(),
  child: const Text('Learn More'),
)

// With icon
ElevatedButton.icon(
  onPressed: () {},
  icon: const Icon(Icons.location_on),
  label: const Text('Set Location'),
)
```

### ...Create a form

```dart
class MyForm extends StatefulWidget {
  const MyForm();

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Process form
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

### ...Show a dialog

```dart
// Alert
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Confirm'),
    content: const Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: const Text('Confirm'),
      ),
    ],
  ),
);

// Bottom sheet
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Select Ride Type'),
        // Options
      ],
    ),
  ),
);
```

### ...Format code

```bash
# Format lib and test folders
dart format lib/ test/

# Apply auto-fixes
dart fix --apply

# Analyze for issues
flutter analyze

# Run all checks before committing
dart format lib/ test/ && dart fix --apply && flutter analyze && flutter test
```

### ...Debug an issue

```dart
// Print values
print('User: ${user.name}, ID: ${user.id}');

// Inspect provider state
ref.watch(userProvider).whenData((user) => print(user));

// Use debugPrint for performance
debugPrint('This is logged to console');

// Breakpoint in VSCode
// Press F9 on a line, then run with `flutter run`

// Check widget tree
// Hot reload from error banner or press 'w' in terminal

// Verbose logging
flutter run -v
```

## 🧪 Testing

### Run tests
```bash
# All tests
flutter test

# Single file
flutter test test/features/ride/domain/use_cases/fare_calculator_test.dart

# Watch mode
flutter test --watch

# With coverage
flutter test --coverage
```

### Write a unit test
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FareCalculator', () {
    test('calculates fare correctly', () {
      final fare = FareCalculator.calculateFare(
        baseFare: 2.0,
        distanceKm: 10.0,
        perKmRate: 1.5,
        durationMinutes: 20,
        perMinRate: 0.25,
        surgeMultiplier: 1.0,
      );

      expect(fare, 22.0);
    });

    test('applies surge multiplier', () {
      expect(
        FareCalculator.calculateFare(
          baseFare: 2.0,
          distanceKm: 10.0,
          perKmRate: 1.5,
          durationMinutes: 20,
          perMinRate: 0.25,
          surgeMultiplier: 2.0,
        ),
        44.0,
      );
    });
  });
}
```

### Write a widget test
```dart
void main() {
  testWidgets('RideCard displays driver info', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RideCard(
            ride: mockRide,
            driver: mockDriver,
          ),
        ),
      ),
    );

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsWidgets);
    
    // Tap button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Communication sent'), findsOneWidget);
  });
}
```

## 🎨 Design Constants

```dart
// Colors
AppTheme.primaryColor        // #FE8C00
AppTheme.primaryDark         // #E07C00
AppTheme.secondary           // #00A85C
AppTheme.textPrimary         // #1F2937
AppTheme.textSecondary       // #6B7280

// Common spacing
16.0    // horizontal padding
24.0    // vertical padding
8.0     // item gap

// Border radius
BorderRadius.circular(12)    // standard
BorderRadius.circular(16)    // large
BorderRadius.circular(8)     // small
```

## 📚 Important Links

- [Riverpod Docs](https://riverpod.dev)
- [GoRouter Docs](https://pub.dev/packages/go_router)
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- [Material Design 3](https://m3.material.io)

## ⚡ Performance Tips

1. **Use `const`** for widgets that don't change:
   ```dart
   const Text('Hello')  // Better
   Text('Hello')        // OK but slower
   ```

2. **Rebuild optimization**:
   ```dart
   // Instead of rebuilding entire widget
   Consumer(
     builder: (context, ref, child) {
       final data = ref.watch(dataProvider);
       return MyWidget(data: data);
     },
     child: StaticPart(),  // Not rebuilt
   );
   ```

3. **Use `ListView.builder`** for long lists:
   ```dart
   ListView.builder(
     itemCount: items.length,
     itemBuilder: (context, index) => RideCard(item: items[index]),
   )
   ```

4. **Lazy load images**:
   ```dart
   CachedNetworkImage(
     imageUrl: url,
     placeholder: (context, url) => Shimmer.fromColors(...),
     errorWidget: (context, url, error) => Icon(Icons.error),
   )
   ```

---

**Quick questions? Check `.github/copilot-instructions.md` or `docs/ARCHITECTURE.md`**
