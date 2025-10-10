import 'package:flutter/material.dart';
import 'home.dart';
import '../../models/dish_model.dart';
import 'product_details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = ['Pizza', 'Sushi', 'Burgers'];
  final List<String> popularSearches = [
    'Popular',
    'Appetizers',
    'Main Courses',
    'Burger',
    'Pizza',
    'Salad'
  ];
  List<Dish> searchResults = [];
  bool isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeRecentSearch(String search) {
    setState(() {
      recentSearches.remove(search);
    });
  }

  void _clearAllRecentSearches() {
    setState(() {
      recentSearches.clear();
    });
  }

  void _addToRecentSearches(String search) {
    if (search.trim().isEmpty) return;

    setState(() {
      // Remove if already exists
      recentSearches.remove(search);
      // Add to beginning of list
      recentSearches.insert(0, search);
      // Keep only last 5 searches
      if (recentSearches.length > 5) {
        recentSearches = recentSearches.sublist(0, 5);
      }
    });
  }

  void _performSearch(String query) {
    _addToRecentSearches(query);
    setState(() {
      isSearching = true;
      searchResults = DishData.searchDishes(query);
    });
  }

  void _clearSearch() {
    setState(() {
      isSearching = false;
      searchResults = [];
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          },
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for restaurants or food',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _performSearch(value);
                  } else {
                    _clearSearch();
                  }
                },
                onSubmitted: (value) {
                  _performSearch(value);
                },
              ),
            ),
          ),

          // Search Results or Recent/Popular Searches
          Expanded(
            child: isSearching
                ? searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final dish = searchResults[index];
                          return _buildDishCard(dish);
                        },
                      )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recent Searches Section
                        if (recentSearches.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Recent Searches',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _clearAllRecentSearches,
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: Colors.pink,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: recentSearches.map((search) {
                                return _buildRemovableChip(search);
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Popular Searches Section
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Popular Searches',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: popularSearches.map((search) {
                              return _buildPopularChip(search);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeRecentSearch(label),
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularChip(String label) {
    return GestureDetector(
      onTap: () => _performSearch(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.pink, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.pink,
            fontWeight: FontWeight.w500,
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
              backgroundColor: bgColor,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              // Category Badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(dish.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dish.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.pink,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            productName: dish.name,
                            description: dish.description,
                            basePrice: dish.price,
                            imageType: dish.imageType,
                            backgroundColor: bgColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dish.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '\$${dish.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Popular':
        return Colors.orange;
      case 'Appetizers':
        return Colors.green;
      case 'Main Courses':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
