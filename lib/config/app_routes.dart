class AppRoutes {
  // Common Routes
  static const String splash = '/';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String orderTracking = '/order-tracking';
  static const String productDetails = '/product-details';

  // Admin Routes
  static const String adminDashboard = '/admin';
  static const String adminVendorManagement = '/admin/vendors';
  static const String adminAddVendor = '/admin/vendors/add';
  static const String adminVendorUsers = '/admin/vendors/users';
  static const String adminRiders = '/admin/riders';
  static const String adminAddRider = '/admin/riders/add';
  static const String adminSales = '/admin/sales';
  static const String adminProducts = '/admin/products';
  static const String adminSettings = '/admin/settings';

  // Vendor Routes
  static const String vendorDashboard = '/vendor';
  static const String vendorAddProduct = '/vendor/products/add';
  static const String vendorMenuManagement = '/vendor/menu';
  static const String vendorOrders = '/vendor/orders';
  static const String vendorReports = '/vendor/reports';
  static const String vendorProfile = '/vendor/profile';

  // Rider Routes
  static const String riderDashboard = '/rider';
  static const String riderDeliveries = '/rider/deliveries';
  static const String riderDeliveryDetails = '/rider/deliveries/details';
  static const String riderEarnings = '/rider/earnings';
  static const String riderNavigation = '/rider/navigation';
  static const String riderProfile = '/rider/profile';
  static const String riderSettings = '/rider/settings';
}
