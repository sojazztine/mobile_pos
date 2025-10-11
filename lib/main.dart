import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/common/splash_screen.dart';
import 'screens/common/main_navigation.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/vendor/vendor_dashboard.dart';
import 'screens/rider/rider_dashboard.dart';

// Models
import 'models/cart_model.dart';
import 'models/order_model.dart';
import 'models/auth_model.dart';

// Config
import 'config/app_theme.dart';
import 'constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Disable debug painting to remove yellow/black debug borders
  debugPaintSizeEnabled = false;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => OrdersModel()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(child: AppInitializer()),
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize auth after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthModel>().init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        // Check user role and navigate to appropriate screen
        if (authModel.isLoggedIn) {
          if (authModel.isAdmin) {
            return const AdminDashboard();
          } else if (authModel.isVendor) {
            return const VendorDashboard();
          } else if (authModel.isRider) {
            return const RiderDashboard();
          }
        }
        // Default to main navigation for regular users or not logged in
        return const MainNavigation();
      },
    );
  }
}