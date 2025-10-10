# CodeCrave - Project Structure

## Overview
This document describes the refactored project structure for the CodeCrave POS application.

## Directory Structure

```
lib/
├── config/                    # App-wide configuration
│   ├── app_theme.dart         # Theme configuration (light/dark themes)
│   └── app_routes.dart        # Route constants and navigation paths
│
├── constants/                 # App-wide constants
│   ├── app_colors.dart        # Color constants and palettes
│   ├── app_strings.dart       # String constants and labels
│   └── app_dimensions.dart    # Dimension constants (padding, margins, etc.)
│
├── models/                    # Data models
│   ├── auth_model.dart        # Authentication state management
│   ├── cart_model.dart        # Shopping cart state management
│   ├── order_model.dart       # Order data and state management
│   ├── dish_model.dart        # Dish/product data model
│   ├── product_model.dart     # Product data model
│   └── user_model.dart        # User data model
│
├── screens/                   # All screen widgets organized by role
│   ├── common/                # Screens shared across all user types
│   │   ├── splash_screen.dart
│   │   ├── home.dart
│   │   ├── cart.dart
│   │   ├── checkout.dart
│   │   ├── search.dart
│   │   ├── profile.dart
│   │   ├── edit_profile.dart
│   │   ├── orders.dart
│   │   ├── order_details.dart
│   │   ├── order_tracking.dart
│   │   └── product_details.dart
│   │
│   ├── admin/                 # Admin-specific screens
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
│   ├── vendor/                # Vendor-specific screens
│   │   ├── vendor_dashboard.dart
│   │   ├── vendor_add_product.dart
│   │   ├── vendor_menu_management.dart
│   │   ├── vendor_orders.dart
│   │   ├── vendor_reports.dart
│   │   └── vendor_profile.dart
│   │
│   └── rider/                 # Rider-specific screens
│       ├── rider_dashboard.dart
│       ├── rider_deliveries.dart
│       ├── rider_delivery_details.dart
│       ├── rider_earnings.dart
│       ├── rider_navigation_map.dart
│       ├── rider_profile.dart
│       └── rider_settings.dart
│
├── widgets/                   # Reusable widget components
│   ├── auth/                  # Authentication-related widgets
│   │   ├── login_modal.dart
│   │   ├── signup_modal.dart
│   │   └── terms_modal.dart
│   │
│   ├── admin/                 # Admin-specific widgets
│   │   ├── admin_bottom_nav.dart
│   │   └── admin_drawer.dart
│   │
│   └── common/                # Common reusable widgets
│       └── (shared widgets across the app)
│
├── services/                  # Business logic and data services
│   └── database_service.dart  # Database operations (SQLite/local storage)
│
├── utils/                     # Utility functions and helpers
│   └── (helper functions, validators, formatters)
│
└── main.dart                  # App entry point
```

## Architecture Overview

### 1. **Config Layer** (`config/`)
- **app_theme.dart**: Centralized theme configuration
  - Light and dark theme definitions
  - Material 3 design system
  - Consistent styling across the app

- **app_routes.dart**: Route constants
  - Named routes for navigation
  - Organized by user role (admin, vendor, rider, common)

### 2. **Constants Layer** (`constants/`)
- **app_colors.dart**: All color definitions
  - Primary, secondary, and accent colors
  - Status colors (success, warning, error)
  - Order status colors
  - Background and surface colors

- **app_strings.dart**: String constants
  - UI labels and text
  - Error messages
  - Navigation labels

- **app_dimensions.dart**: Size and spacing constants
  - Padding and margin values
  - Border radius values
  - Icon and font sizes
  - Button heights

### 3. **Models Layer** (`models/`)
State management using Provider pattern:
- **auth_model.dart**: User authentication and role management
- **cart_model.dart**: Shopping cart state
- **order_model.dart**: Order management
- **product_model.dart**, **dish_model.dart**: Product data
- **user_model.dart**: User data structure

### 4. **Screens Layer** (`screens/`)
Organized by user role for better maintainability:

#### Common Screens (`screens/common/`)
Accessible to all user types:
- Home, Cart, Checkout
- Product browsing and details
- Orders and tracking
- Profile management

#### Admin Screens (`screens/admin/`)
Administrative features:
- Dashboard and analytics
- Vendor and rider management
- Sales reports
- Product management

#### Vendor Screens (`screens/vendor/`)
Vendor-specific features:
- Menu management
- Order processing
- Sales reports
- Profile management

#### Rider Screens (`screens/rider/`)
Delivery rider features:
- Delivery management
- Navigation and tracking
- Earnings tracking
- Profile settings

### 5. **Widgets Layer** (`widgets/`)
Reusable components organized by purpose:
- **auth/**: Login, signup, terms modals
- **admin/**: Admin navigation and drawer
- **common/**: Shared components across the app

### 6. **Services Layer** (`services/`)
- **database_service.dart**: Database operations
  - CRUD operations
  - Data persistence
  - Query management

### 7. **Utils Layer** (`utils/`)
Helper functions and utilities:
- Validators
- Formatters
- Common functions

## Key Features

### Theme System
- Material 3 design
- Light and dark mode support
- Consistent color palette
- Reusable component themes

### Navigation
- Role-based routing
- Named routes
- Route constants for type safety

### State Management
- Provider pattern
- Separation of concerns
- Reactive UI updates

### Code Organization
- Feature-based structure
- Clear separation by user role
- Easy to navigate and maintain
- Scalable architecture

## Import Conventions

### Relative Imports
Use relative imports for better maintainability:

**From screens/common/**:
```dart
import '../../models/cart_model.dart';
import '../../widgets/auth/login_modal.dart';
import '../../services/database_service.dart';
```

**From screens/admin/**:
```dart
import '../../models/auth_model.dart';
import '../../widgets/admin/admin_drawer.dart';
import '../common/home.dart';
```

**From widgets/**:
```dart
import '../../models/auth_model.dart';
import '../../screens/common/home.dart';
```

## Benefits of This Structure

1. **Scalability**: Easy to add new features and screens
2. **Maintainability**: Clear organization makes code easy to find and update
3. **Reusability**: Shared components in widgets folder
4. **Consistency**: Centralized theming and constants
5. **Separation of Concerns**: Clear boundaries between UI, business logic, and data
6. **Team Collaboration**: Organized structure helps multiple developers work together
7. **Testing**: Easier to write unit and widget tests

## Next Steps for Development

1. Add more reusable widgets to `widgets/common/`
2. Implement utility functions in `utils/`
3. Add API service layer in `services/`
4. Implement proper routing with named routes
5. Add error handling and validation utilities
6. Implement caching and offline support
7. Add analytics and logging services

## Notes

- All screens follow consistent naming conventions
- Widgets are organized by feature/role
- Constants are used throughout for consistency
- Theme system supports future customization
- Structure supports future growth and features
