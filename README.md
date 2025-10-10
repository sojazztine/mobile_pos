# 🍕 CodeCrave - Point of Sale System

A modern, feature-rich Point of Sale (POS) Flutter application for food delivery and restaurant management. Built with clean architecture, role-based access control, and a beautiful Material Design 3 interface with animated splash screen.

![Flutter](https://img.shields.io/badge/Flutter-3.9+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.9+-blue.svg)
![Provider](https://img.shields.io/badge/State-Provider-green.svg)

## 📋 Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [User Roles & Navigation](#user-roles--navigation)
- [Customization Guide](#customization-guide)
- [Development Guide](#development-guide)
- [Database](#database)
- [Dependencies](#dependencies)
- [Troubleshooting](#troubleshooting)

## ✨ Features

### 🏪 Customer Features
- ✅ Browse menu and products with beautiful UI
- ✅ Advanced search and filtering
- ✅ Shopping cart management
- ✅ Secure checkout process
- ✅ Real-time order tracking
- ✅ Order history
- ✅ Profile management

### 👨‍💼 Admin Features
- ✅ Comprehensive dashboard with analytics
- ✅ Vendor management (CRUD operations)
- ✅ Rider management and assignment
- ✅ Sales reports with charts (fl_chart)
- ✅ Product inventory management
- ✅ User management by role
- ✅ System settings

### 🍳 Vendor Features
- ✅ Vendor-specific dashboard
- ✅ Menu and product management
- ✅ Add/edit/delete products with images
- ✅ Order processing and status updates
- ✅ Sales analytics and reports
- ✅ Profile customization

### 🚴 Rider Features
- ✅ Delivery dashboard
- ✅ Active delivery tracking
- ✅ Turn-by-turn navigation
- ✅ Earnings tracking and history
- ✅ Delivery status updates
- ✅ Profile and settings

### 🎨 UI/UX Features
- ✅ Material Design 3
- ✅ Light and Dark theme support
- ✅ Animated splash screen with gradient
- ✅ Responsive design
- ✅ Smooth page transitions
- ✅ Bottom navigation
- ✅ Modal dialogs and bottom sheets

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.9.2 or higher
- **Dart SDK**: 3.9.2 or higher
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Emulator/Device**: Android/iOS device or emulator

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pos_project.git
   cd pos_project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Check Flutter setup**
   ```bash
   flutter doctor
   ```

4. **Run the application**
   ```bash
   # Run on connected device
   flutter run

   # Run on specific device
   flutter devices  # List devices
   flutter run -d <device-id>

   # Run in debug mode
   flutter run --debug

   # Run in release mode
   flutter run --release
   ```

5. **Build for production**
   ```bash
   # Android APK
   flutter build apk --release

   # Android App Bundle (for Play Store)
   flutter build appbundle --release

   # iOS (requires Mac)
   flutter build ios --release

   # Web
   flutter build web --release
   ```

### First Time Setup

The app comes with a default admin account for testing:
- **Email**: admin@codecrave.com
- **Password**: admin123

## 📁 Project Structure

Our project follows a **clean, feature-based architecture** for maximum maintainability and scalability:

```
lib/
├── 📱 main.dart                    # App entry point
│
├── 📂 config/                      # App-wide configuration
│   ├── app_theme.dart              # Light/Dark themes (Material 3)
│   └── app_routes.dart             # Named route constants
│
├── 📂 constants/                   # Centralized constants
│   ├── app_colors.dart             # Color palette (primary, status, etc.)
│   ├── app_strings.dart            # All text strings
│   └── app_dimensions.dart         # Spacing, sizes, typography
│
├── 📂 models/                      # Data models (Provider state)
│   ├── auth_model.dart             # Authentication & user roles
│   ├── cart_model.dart             # Shopping cart state
│   ├── order_model.dart            # Order management
│   ├── product_model.dart          # Product data
│   ├── dish_model.dart             # Dish/menu items
│   └── user_model.dart             # User profiles
│
├── 📂 screens/                     # All UI screens (organized by role)
│   │
│   ├── 📂 common/                  # Shared across all users
│   │   ├── splash_screen.dart      # Animated splash (2.5s)
│   │   ├── home.dart               # Main landing page
│   │   ├── cart.dart               # Shopping cart
│   │   ├── checkout.dart           # Checkout process
│   │   ├── search.dart             # Product search
│   │   ├── profile.dart            # User profile
│   │   ├── edit_profile.dart       # Edit profile
│   │   ├── orders.dart             # Order list
│   │   ├── order_details.dart      # Single order view
│   │   ├── order_tracking.dart     # Real-time tracking
│   │   └── product_details.dart    # Product info
│   │
│   ├── 📂 admin/                   # Admin-only screens
│   │   ├── admin_dashboard.dart
│   │   ├── admin_vendor_management.dart
│   │   ├── admin_add_vendor.dart
│   │   ├── admin_vendor_users.dart
│   │   ├── admin_riders.dart
│   │   ├── admin_add_rider.dart
│   │   ├── admin_sales.dart
│   │   ├── admin_products.dart
│   │   └── admin_settings.dart
│   │
│   ├── 📂 vendor/                  # Vendor-only screens
│   │   ├── vendor_dashboard.dart
│   │   ├── vendor_menu_management.dart
│   │   ├── vendor_add_product.dart
│   │   ├── vendor_orders.dart
│   │   ├── vendor_reports.dart
│   │   └── vendor_profile.dart
│   │
│   └── 📂 rider/                   # Rider-only screens
│       ├── rider_dashboard.dart
│       ├── rider_deliveries.dart
│       ├── rider_delivery_details.dart
│       ├── rider_earnings.dart
│       ├── rider_navigation_map.dart
│       ├── rider_profile.dart
│       └── rider_settings.dart
│
├── 📂 widgets/                     # Reusable UI components
│   ├── 📂 auth/                    # Authentication widgets
│   │   ├── login_modal.dart        # Login modal dialog
│   │   ├── signup_modal.dart       # Registration modal
│   │   └── terms_modal.dart        # Terms & conditions
│   │
│   ├── 📂 admin/                   # Admin components
│   │   ├── admin_bottom_nav.dart   # Admin bottom navigation
│   │   └── admin_drawer.dart       # Admin drawer menu
│   │
│   └── 📂 common/                  # Shared widgets
│       └── nav_footer.dart         # Common footer
│
├── 📂 services/                    # Business logic & data
│   └── database_service.dart       # SQLite database operations
│
└── 📂 utils/                       # Utility functions
    └── (helpers, validators, formatters)
```

### 📚 Documentation Files

In the root directory, you'll find comprehensive documentation:

| File | Purpose |
|------|---------|
| **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** | Detailed architecture documentation |
| **[DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)** | Quick reference with code examples |
| **[REFACTORING_SUMMARY.md](REFACTORING_SUMMARY.md)** | Refactoring history and improvements |

## 👥 User Roles & Navigation

### App Flow

```
🚀 Splash Screen (2.5s animation)
           ↓
      Is Logged In?
           ↓
    ┌──────┴───────┐
   NO              YES
    ↓               ↓
  🏠 Home      Check Role
 (Customer)         ↓
              ┌─────┼─────┐
              ↓     ↓     ↓
          👨‍💼Admin 🍳Vendor 🚴Rider
```

### 1. 🛍️ Customer (Default Role)

**Access**: Public, no login required

**Navigation Flow**:
```
Home
 ├─ 🔍 Search → Product Listing
 ├─ 📦 Product Details → 🛒 Add to Cart
 ├─ 🛒 Cart → 💳 Checkout → ✅ Order Placed
 ├─ 📋 My Orders → 📄 Order Details → 🗺️ Track Order
 └─ 👤 Profile → ✏️ Edit Profile
```

**Features**:
- Browse products by category
- Add/remove items from cart
- Place orders
- Track deliveries
- View order history

### 2. 👨‍💼 Admin Role

**Access**: Requires admin login

**Navigation Flow**:
```
Admin Dashboard
 ├─ 🏪 Vendor Management
 │   ├─ ➕ Add New Vendor
 │   ├─ ✏️ Edit Vendor
 │   └─ 👥 Vendor Users
 │
 ├─ 🚴 Rider Management
 │   ├─ ➕ Add New Rider
 │   └─ ✏️ Edit Rider
 │
 ├─ 📊 Sales Reports (Charts & Analytics)
 ├─ 📦 Products (Global Product Management)
 └─ ⚙️ Settings
```

**Permissions**:
- Full system access
- Manage all vendors
- Manage all riders
- View global analytics
- Configure system settings

### 3. 🍳 Vendor Role

**Access**: Requires vendor login

**Navigation Flow**:
```
Vendor Dashboard
 ├─ 🍽️ Menu Management
 │   ├─ ➕ Add Product
 │   ├─ ✏️ Edit Product
 │   ├─ 🗑️ Delete Product
 │   └─ 📸 Upload Images
 │
 ├─ 📋 Orders
 │   ├─ View Incoming Orders
 │   └─ Update Order Status
 │
 ├─ 📊 Reports (Sales Analytics)
 └─ 👤 Profile
```

**Permissions**:
- Manage own menu/products
- Process incoming orders
- View own sales data
- Update profile

### 4. 🚴 Rider Role

**Access**: Requires rider login

**Navigation Flow**:
```
Rider Dashboard
 ├─ 🚚 Active Deliveries
 │   ├─ 📄 Delivery Details
 │   ├─ 🗺️ Navigation Map
 │   └─ ✅ Update Status
 │
 ├─ 💰 Earnings
 │   ├─ Today's Earnings
 │   ├─ Weekly Summary
 │   └─ History
 │
 ├─ 👤 Profile
 └─ ⚙️ Settings
```

**Permissions**:
- View assigned deliveries
- Update delivery status
- Navigate to destinations
- Track earnings

## 🎨 Customization Guide

### 1. Change Brand Colors

Edit [`lib/constants/app_colors.dart`](lib/constants/app_colors.dart):

```dart
class AppColors {
  // PRIMARY BRAND COLOR
  static const Color primary = Color(0xFFE91E63);  // Current: Pink
  // Change to:
  static const Color primary = Color(0xFF2196F3);  // Blue
  static const Color primary = Color(0xFF4CAF50);  // Green
  static const Color primary = Color(0xFFFF9800);  // Orange

  // OTHER COLORS
  static const Color success = Color(0xFF4CAF50);  // Green
  static const Color warning = Color(0xFFFFC107);  // Amber
  static const Color error = Color(0xFFF44336);    // Red
}
```

### 2. Change App Name & Branding

Edit [`lib/constants/app_strings.dart`](lib/constants/app_strings.dart):

```dart
class AppStrings {
  static const String appName = 'CodeCrave';        // Your app name
  static const String appTagline = 'Powered by Codecrave';  // Your tagline

  // Update other strings as needed
  static const String home = 'Home';
  static const String cart = 'Cart';
  // ... etc
}
```

### 3. Customize Splash Screen

Edit [`lib/screens/common/splash_screen.dart`](lib/screens/common/splash_screen.dart):

```dart
// CHANGE DURATION (milliseconds)
Timer(const Duration(milliseconds: 2500), () {  // Change 2500 to desired time

// CHANGE GRADIENT COLORS
gradient: LinearGradient(
  colors: [
    Color(0xFF3D1F3D),  // Top color
    Color(0xFF2D1528),  // Middle
    Color(0xFF1F0E1F),  // Bottom
  ],
)

// CHANGE ICON
Icon(
  Icons.restaurant_menu,  // Change to any Material icon
  size: 80,
  color: Color(0xFFE91E63),
)

// CHANGE TEXT
Text(
  'YourAppName',  // Change app name
  style: TextStyle(fontSize: 48, ...),
)
```

### 4. Adjust Spacing & Sizes

Edit [`lib/constants/app_dimensions.dart`](lib/constants/app_dimensions.dart):

```dart
class AppDimensions {
  // PADDING
  static const double paddingSmall = 8.0;   // Increase/decrease
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // BUTTON HEIGHTS
  static const double buttonHeightMedium = 48.0;

  // FONT SIZES
  static const double fontLarge = 16.0;
  static const double fontHeading = 24.0;
}
```

### 5. Customize Theme (Light/Dark)

Edit [`lib/config/app_theme.dart`](lib/config/app_theme.dart):

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      fontFamily: 'Roboto',  // Change font family

      // Customize button styles
      elevatedButtonTheme: ElevatedButtonThemeData(...),

      // Customize input fields
      inputDecorationTheme: InputDecorationTheme(...),
    );
  }
}
```

### 6. Add Your Own Screen

**Step 1**: Create file in appropriate folder
```
lib/screens/common/my_new_screen.dart  # For all users
lib/screens/admin/my_admin_screen.dart  # For admin only
```

**Step 2**: Use this template:
```dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class MyNewScreen extends StatelessWidget {
  const MyNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Screen'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Hello World!'),
            // Your UI here
          ],
        ),
      ),
    );
  }
}
```

**Step 3**: Add route to [`lib/config/app_routes.dart`](lib/config/app_routes.dart)

**Step 4**: Navigate to it:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MyNewScreen()),
);
```

## 💻 Development Guide

### State Management (Provider)

This app uses **Provider** for state management. Here's how to use it:

#### Access State (Read)
```dart
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

// Watch for changes (rebuilds on update)
final cart = context.watch<CartModel>();
final itemCount = cart.items.length;

// Read once (no rebuild)
final cart = context.read<CartModel>();
```

#### Update State (Write)
```dart
// Add item to cart
context.read<CartModel>().addItem(product);

// Remove item
context.read<CartModel>().removeItem(productId);

// Clear cart
context.read<CartModel>().clear();
```

#### Available Models

| Model | Purpose | Key Methods |
|-------|---------|-------------|
| `AuthModel` | User authentication | `login()`, `logout()`, `isLoggedIn`, `isAdmin` |
| `CartModel` | Shopping cart | `addItem()`, `removeItem()`, `clear()` |
| `OrdersModel` | Order management | `addOrder()`, `getOrders()`, `updateStatus()` |

### Database Operations

Using SQLite through `DatabaseService`:

```dart
import '../services/database_service.dart';

final db = DatabaseService.instance;

// INSERT
await db.insert('products', {
  'name': 'Pizza',
  'price': 12.99,
  'vendorId': 1,
});

// QUERY ALL
final products = await db.query('products');

// QUERY WITH WHERE
final result = await db.query(
  'products',
  where: 'vendorId = ?',
  whereArgs: [vendorId],
);

// UPDATE
await db.update(
  'products',
  {'price': 14.99},
  where: 'id = ?',
  whereArgs: [productId],
);

// DELETE
await db.delete(
  'products',
  where: 'id = ?',
  whereArgs: [productId],
);
```

### Common Patterns

#### 1. Loading State
```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch data
      final data = await fetchData();
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return YourWidget();
  }
}
```

#### 2. Form Validation
```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        decoration: InputDecoration(labelText: 'Email'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter email';
          }
          if (!value.contains('@')) {
            return 'Invalid email';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process form
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

#### 3. Show Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirm'),
    content: Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          // Perform action
          Navigator.pop(context);
        },
        child: Text('Confirm'),
      ),
    ],
  ),
);
```

## 📦 Dependencies

This project uses the following packages:

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.1 | State management |
| `sqflite` | ^2.3.0 | Local SQLite database |
| `shared_preferences` | ^2.2.2 | Simple data persistence |
| `crypto` | ^3.0.3 | Password hashing |
| `image_picker` | ^1.0.7 | Pick images from gallery/camera |
| `file_picker` | ^10.3.3 | Pick files |
| `path_provider` | ^2.1.2 | Get device file paths |
| `fl_chart` | ^0.69.0 | Beautiful charts for analytics |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

### Adding New Dependencies

1. Edit `pubspec.yaml`:
```yaml
dependencies:
  your_package: ^1.0.0
```

2. Run:
```bash
flutter pub get
```

3. Import in your code:
```dart
import 'package:your_package/your_package.dart';
```

## 🧪 Testing

### Run Tests
```bash
# All tests
flutter test

# Specific file
flutter test test/models/cart_model_test.dart

# With coverage
flutter test --coverage
```

### Example Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_project/models/cart_model.dart';

void main() {
  test('Cart adds items correctly', () {
    final cart = CartModel();
    final product = Product(id: 1, name: 'Pizza', price: 12.99);

    cart.addItem(product);

    expect(cart.items.length, 1);
    expect(cart.total, 12.99);
  });
}
```

## 🐛 Troubleshooting

### Common Issues

**Problem**: Import errors after refactoring
```bash
flutter clean
flutter pub get
```

**Problem**: Hot reload not working
- Press `R` (capital R) for hot restart
- Or stop and rerun the app

**Problem**: Database not updating
- Uninstall the app
- Reinstall to reset database

**Problem**: "Module not found" errors
```bash
flutter pub get
flutter run
```

**Problem**: Build errors
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### Debugging

```dart
// Print to console
debugPrint('Value: $myVariable');

// Assert (development only)
assert(value != null, 'Value cannot be null');

// Try-catch
try {
  await riskyOperation();
} catch (e) {
  debugPrint('Error: $e');
}
```

## 📱 Platform Configuration

### Android App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="YourAppName">
```

### iOS App Name
Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleName</key>
<string>YourAppName</string>
```

### App Icon
The app uses `flutter_launcher_icons`. Icon is configured in `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  image_path: "assets/icon/codeCraveLogo.png"
```

Generate icons:
```bash
flutter pub run flutter_launcher_icons
```

## 📖 Learning Resources

- **[Flutter Docs](https://flutter.dev/docs)** - Official Flutter documentation
- **[Dart Language](https://dart.dev/)** - Dart programming language
- **[Provider](https://pub.dev/packages/provider)** - State management
- **[Material Design 3](https://m3.material.io/)** - UI design guidelines
- **[SQLite](https://www.sqlite.org/)** - Database documentation

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Support

For help:
- Check documentation in this repo
- Open an issue on GitHub
- Review the [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)

---

**Built with ❤️ using Flutter**

*Version 1.0.0 • Last Updated: October 2025*
