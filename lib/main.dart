import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'admin_dashboard.dart';
import 'vendor_dashboard.dart';
import 'models/cart_model.dart';
import 'models/order_model.dart';
import 'models/auth_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()..init()),
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => OrdersModel()),
      ],
      child: MaterialApp(
        title: 'CodeCrave',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          fontFamily: 'Roboto',
        ),
        home: const AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

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
          }
        }
        // Default to home screen for regular users or not logged in
        return const Home();
      },
    );
  }
}