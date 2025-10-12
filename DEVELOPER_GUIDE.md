# CodeCrave - Developer Quick Reference Guide

## Quick Start

### Adding a New Screen

1. **Determine the category**: Common, Admin, Vendor, or Rider
2. **Create the file** in the appropriate folder:
   ```
   screens/[category]/screen_name.dart
   ```
3. **Use the template**:
   ```dart
   import 'package:flutter/material.dart';
   import '../../constants/app_colors.dart';
   import '../../constants/app_strings.dart';
   import '../../constants/app_dimensions.dart';

   class ScreenName extends StatelessWidget {
     const ScreenName({super.key});

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: const Text('Screen Title'),
         ),
         body: Container(),
       );
     }
   }
   ```
4. **Add route** to `config/app_routes.dart`

### Adding a New Widget

1. **Create the file** in:
   - `widgets/common/` for shared widgets
   - `widgets/admin/` for admin-only widgets
   - `widgets/auth/` for authentication widgets

2. **Make it reusable**:
   ```dart
   import 'package:flutter/material.dart';
   import '../../constants/app_colors.dart';

   class CustomWidget extends StatelessWidget {
     final String title;
     final VoidCallback? onTap;

     const CustomWidget({
       super.key,
       required this.title,
       this.onTap,
     });

     @override
     Widget build(BuildContext context) {
       return GestureDetector(
         onTap: onTap,
         child: Container(
           // Your widget code
         ),
       );
     }
   }
   ```

### Using Constants

#### Colors
```dart
import '../../constants/app_colors.dart';

Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textLight),
  ),
)
```

#### Dimensions
```dart
import '../../constants/app_dimensions.dart';

Padding(
  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
  child: Container(
    height: AppDimensions.buttonHeightMedium,
  ),
)
```

#### Strings
```dart
import '../../constants/app_strings.dart';

Text(AppStrings.appName)
```

### Using the Theme

The theme is automatically applied. Access it via:
```dart
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

// Use theme colors
Container(
  color: theme.primaryColor,
  child: Text(
    'Text',
    style: theme.textTheme.headlineLarge,
  ),
)
```

### State Management with Provider

#### Consuming State
```dart
import 'package:provider/provider.dart';
import '../../models/cart_model.dart';

// In your widget
final cart = Provider.of<CartModel>(context);
// or
final cart = context.watch<CartModel>();
// or (no rebuild)
final cart = context.read<CartModel>();
```

#### Updating State
```dart
final cart = context.read<CartModel>();
cart.addItem(product);
```

### Navigation

#### Navigate to a screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ScreenName(),
  ),
);
```

#### Navigate back
```dart
Navigator.pop(context);
```

#### Replace current screen
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const NewScreen(),
  ),
);
```

### Database Operations

```dart
import '../../services/database_service.dart';

// Get instance
final db = DatabaseService.instance;

// Insert
await db.insert('table_name', data);

// Query
final results = await db.query('table_name');

// Update
await db.update('table_name', data, where: 'id = ?', whereArgs: [id]);

// Delete
await db.delete('table_name', where: 'id = ?', whereArgs: [id]);
```

## Common Patterns

### Loading State
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load data
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container();
  }
}
```

### Form Validation
```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process data
          }
        },
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

### Modal Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AppDimensions.radiusLarge),
    ),
  ),
  builder: (context) => const YourModalWidget(),
);
```

### Alert Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Title'),
    content: const Text('Message'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          // Action
          Navigator.pop(context);
        },
        child: const Text('Confirm'),
      ),
    ],
  ),
);
```

## File Naming Conventions

- **Screens**: `screen_name.dart` (e.g., `admin_dashboard.dart`)
- **Widgets**: `widget_name.dart` (e.g., `login_modal.dart`)
- **Models**: `model_name.dart` (e.g., `cart_model.dart`)
- **Services**: `service_name.dart` (e.g., `database_service.dart`)
- **Constants**: `app_*.dart` (e.g., `app_colors.dart`)

## Import Order

Follow this order for imports:
1. Dart SDK imports
2. Flutter imports
3. Package imports
4. Project imports (grouped by: models, services, widgets, screens, constants, config)

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/cart_model.dart';
import '../../services/database_service.dart';
import '../../widgets/auth/login_modal.dart';
import '../../constants/app_colors.dart';
import '../../config/app_theme.dart';
```

## Best Practices

1. **Use const constructors** when possible for better performance
2. **Extract complex widgets** into separate widget classes
3. **Keep business logic** in models and services, not in widgets
4. **Use meaningful names** for variables and functions
5. **Add comments** for complex logic
6. **Handle errors** gracefully with try-catch
7. **Use async/await** for asynchronous operations
8. **Follow DRY principle** - Don't Repeat Yourself
9. **Keep functions small** and focused on one task
10. **Use the theme system** instead of hardcoding colors

## Debugging Tips

### Print Debugging
```dart
debugPrint('Debug message: $value');
```

### Assert for Development
```dart
assert(value != null, 'Value should not be null');
```

### Check Widget Tree
```dart
debugDumpApp(); // Print entire widget tree
```

## Testing

### Widget Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/screens/common/home.dart';

void main() {
  testWidgets('Home screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    expect(find.text('CodeCrave'), findsOneWidget);
  });
}
```

## Common Issues & Solutions

### Issue: Import not found
**Solution**: Check the relative path based on your file location

### Issue: Provider not found
**Solution**: Ensure the Provider is added in `main.dart` MultiProvider

### Issue: Theme not applying
**Solution**: Make sure you're using `Theme.of(context)` or theme constants

### Issue: Navigation not working
**Solution**: Ensure you're within a MaterialApp widget tree

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)
- Project Structure: See `PROJECT_STRUCTURE.md`

## Getting Help

1. Check the documentation files
2. Review similar implementations in the codebase
3. Use Flutter DevTools for debugging
4. Check error messages carefully - they're usually helpful!
