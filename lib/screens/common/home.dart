import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/cart_model.dart';
import '../../models/auth_model.dart';
import 'product_details.dart';
import '../../models/dish_model.dart';
import '../../services/database_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';
  String searchQuery = '';
  List<Dish> filteredDishes = [];
  bool isLoading = true;

  final List<String> categories = [
    'All',
    'Popular',
    'Appetizers',
    'Main Courses',
    'Desserts',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _loadDishes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload dishes when screen becomes visible again
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    try {
      // Get vendor products from database
      final products = await DatabaseService.instance.getAllProducts();

      // Convert products to dishes
      final vendorDishes = products.map((product) => product.toDish()).toList();

      // Combine with default dishes
      if (mounted) {
        setState(() {
          filteredDishes = [...DishData.allDishes, ...vendorDishes];
          isLoading = false;
        });
        _updateFilteredDishes();
      }
    } catch (e) {
      print('Error loading dishes: $e');
      if (mounted) {
        setState(() {
          filteredDishes = DishData.allDishes;
          isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
      _updateFilteredDishes();
    });
  }

  Future<void> _updateFilteredDishes() async {
    // Get vendor products from database
    final products = await DatabaseService.instance.getAllProducts();
    final vendorDishes = products.map((product) => product.toDish()).toList();

    // Combine with default dishes
    final allDishes = [...DishData.allDishes, ...vendorDishes];

    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      if (searchQuery.isEmpty) {
        if (selectedCategory == 'All') {
          filteredDishes = allDishes;
        } else {
          filteredDishes = allDishes
              .where((dish) => dish.category == selectedCategory)
              .toList();
        }
      } else {
        final lowerQuery = searchQuery.toLowerCase();
        filteredDishes = allDishes.where((dish) {
          return dish.name.toLowerCase().contains(lowerQuery) ||
              dish.description.toLowerCase().contains(lowerQuery) ||
              dish.category.toLowerCase().contains(lowerQuery);
        }).toList();

        if (selectedCategory != 'All') {
          filteredDishes = filteredDishes
              .where((dish) => dish.category == selectedCategory)
              .toList();
        }
      }
    });
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      _updateFilteredDishes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 20,
                          color: Colors.white, // you can change this to match your theme
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'CodeCrave',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                  Consumer<CartModel>(
                    builder: (context, cart, child) {
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_bag_outlined),
                            onPressed: () {
                              // Don't navigate - user should use bottom nav bar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Use the Cart tab in the bottom navigation'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          if (cart.itemCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.pink,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '${cart.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for dishes',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Pills
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildCategoryPill('All'),
                  const SizedBox(width: 8),
                  _buildCategoryPill('Popular'),
                  const SizedBox(width: 8),
                  _buildCategoryPill('Appetizers'),
                  const SizedBox(width: 8),
                  _buildCategoryPill('Main Courses'),
                  const SizedBox(width: 8),
                  _buildCategoryPill('Desserts'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                searchQuery.isNotEmpty
                    ? 'Search Results (${filteredDishes.length})'
                    : selectedCategory == 'All'
                    ? 'All Dishes'
                    : selectedCategory == 'Popular'
                    ? 'Popular Dishes'
                    : selectedCategory,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.pink),
                    )
                  : filteredDishes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No dishes found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildDishesGroupedByStore(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishesGroupedByStore() {
    // Group dishes by store name
    Map<String, List<Dish>> dishesByStore = {};

    for (var dish in filteredDishes) {
      final storeName = dish.vendorName ?? 'CodeCrave Specials';
      if (!dishesByStore.containsKey(storeName)) {
        dishesByStore[storeName] = [];
      }
      dishesByStore[storeName]!.add(dish);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 80.0),
      itemCount: dishesByStore.keys.length,
      itemBuilder: (context, index) {
        final storeName = dishesByStore.keys.elementAt(index);
        final dishes = dishesByStore[storeName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store name header
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.store,
                      color: Colors.pink[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${dishes.length} ${dishes.length == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Grid of dishes for this store
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: dishes.length,
              itemBuilder: (context, dishIndex) {
                return _buildDishCard(dishes[dishIndex]);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildCategoryPill(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.pink : Colors.grey[300]!,
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDishCard(Dish dish) {
    final bgColor = Color(dish.colorValue);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                productName: dish.name,
                description: dish.description,
                basePrice: dish.price,
                imageType: dish.imageType,
                backgroundColor: Color(dish.colorValue),
                imagePath: dish.imagePath,
                hasCustomization: dish.hasCustomization,
              ),
            ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      image:
                          dish.imagePath != null && dish.imagePath!.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(File(dish.imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: dish.imagePath == null || dish.imagePath!.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.fastfood,
                              size: 48,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          )
                        : null,
                  ),
                  // Add to Cart Button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.pink,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(
                                productName: dish.name,
                                description: dish.description,
                                basePrice: dish.price,
                                imageType: dish.imageType,
                                backgroundColor: Color(dish.colorValue),
                                imagePath: dish.imagePath,
                                hasCustomization: dish.hasCustomization,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Dish Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish.description,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${dish.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'G';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  Widget _buildDrawer() {
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        final user = authModel.currentUser;

        return Drawer(
          backgroundColor: const Color(0xFFF5F5F5),
          child: SafeArea(
            child: Column(
              children: [
                // Profile Section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.pink[100],
                        backgroundImage: user?.profileImage != null
                            ? FileImage(File(user!.profileImage!))
                            : null,
                        child: user?.profileImage == null
                            ? Text(
                                _getInitials(user?.fullName ?? 'Guest User'),
                                style: TextStyle(
                                  color: Colors.pink[700],
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.fullName ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // Use bottom nav bar instead
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Use the Profile tab in the bottom navigation'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Text(
                          user?.email ?? 'View Profile',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        icon: Icons.home,
                        label: 'Home',
                        isSelected: true,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.restaurant_menu,
                        label: 'Menu',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.shopping_cart_outlined,
                        label: 'My Cart',
                        onTap: () {
                          Navigator.pop(context);
                          // Use bottom nav bar instead
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Use the Cart tab in the bottom navigation'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'Orders',
                        onTap: () {
                          Navigator.pop(context);
                          // Use bottom nav bar instead
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Use the Orders tab in the bottom navigation'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.favorite_outline,
                        label: 'Favorites',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to Favorites screen when created
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_outline,
                        label: 'Profile',
                        onTap: () {
                          Navigator.pop(context);
                          // Use bottom nav bar instead
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Use the Profile tab in the bottom navigation'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to settings when created
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to Help & Support screen when created
                        },
                      ),
                    ],
                  ),
                ),

                // Logout Button (only show if logged in)
                if (authModel.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await authModel.logout();
                                    if (!context.mounted) return;
                                    Navigator.pop(dialogContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Logged out successfully',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout,
                            color: Colors.black54,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCE4EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.pink : Colors.black54,
            size: 22,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isSelected ? Colors.pink : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
