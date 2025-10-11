class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category; // 'Popular', 'Appetizers', 'Main Courses'
  final String imageType;
  final int colorValue;
  final String? imagePath; // Path to product image file

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageType,
    required this.colorValue,
    this.imagePath,
  });
}

class DishData {
  static final List<Dish> allDishes = [
    // Popular Dishes
    Dish(
      id: 'margherita_pizza',
      name: 'Margherita Pizza',
      description: 'Fresh mozzarella, basil, tomato sauce',
      price: 12.50,
      category: 'Popular',
      imageType: 'pizza',
      colorValue: 0xFFE0E0E0,
    ),
    Dish(
      id: 'classic_cheeseburger',
      name: 'Classic Cheeseburger',
      description: 'Beef patty, cheddar cheese, lettuce, tomato',
      price: 10.00,
      category: 'Popular',
      imageType: 'burger',
      colorValue: 0xFFFFCC80,
    ),

    // Appetizers
    Dish(
      id: 'chicken_caesar_salad',
      name: 'Chicken Caesar Salad',
      description: 'Fresh romaine, grilled chicken, parmesan, caesar dressing',
      price: 14.00,
      category: 'Appetizers',
      imageType: 'salad',
      colorValue: 0xFFE0E0E0,
    ),
    Dish(
      id: 'garlic_bread',
      name: 'Garlic Bread',
      description: 'Toasted bread with garlic butter and herbs',
      price: 5.50,
      category: 'Appetizers',
      imageType: 'bread',
      colorValue: 0xFFFFE082,
    ),
    Dish(
      id: 'mozzarella_sticks',
      name: 'Mozzarella Sticks',
      description: 'Crispy fried mozzarella with marinara sauce',
      price: 7.00,
      category: 'Appetizers',
      imageType: 'cheese',
      colorValue: 0xFFFFCC80,
    ),
    Dish(
      id: 'crispy_fries',
      name: 'Crispy Fries',
      description: 'Golden crispy french fries with sea salt',
      price: 3.50,
      category: 'Appetizers',
      imageType: 'fries',
      colorValue: 0xFFFFE082,
    ),

    // Main Courses
    Dish(
      id: 'grilled_salmon',
      name: 'Grilled Salmon',
      description: 'Fresh Atlantic salmon with lemon butter sauce',
      price: 18.50,
      category: 'Main Courses',
      imageType: 'salmon',
      colorValue: 0xFF424242,
    ),
    Dish(
      id: 'vegetarian_stir_fry',
      name: 'Vegetarian Stir-Fry',
      description: 'Mixed vegetables in savory sauce with rice',
      price: 13.00,
      category: 'Main Courses',
      imageType: 'vegetables',
      colorValue: 0xFFE0E0E0,
    ),
    Dish(
      id: 'chocolate_lava_cake',
      name: 'Chocolate Lava Cake',
      description: 'Warm chocolate cake with molten center',
      price: 9.00,
      category: 'Main Courses',
      imageType: 'dessert',
      colorValue: 0xFF424242,
    ),
    Dish(
      id: 'beef_steak',
      name: 'Beef Steak',
      description: 'Premium ribeye steak cooked to perfection',
      price: 25.00,
      category: 'Main Courses',
      imageType: 'steak',
      colorValue: 0xFF6D4C41,
    ),
    Dish(
      id: 'chicken_alfredo',
      name: 'Chicken Alfredo',
      description: 'Creamy alfredo pasta with grilled chicken',
      price: 16.00,
      category: 'Main Courses',
      imageType: 'pasta',
      colorValue: 0xFFFFE082,
    ),
    Dish(
      id: 'fish_tacos',
      name: 'Fish Tacos',
      description: 'Grilled fish tacos with fresh salsa',
      price: 14.50,
      category: 'Main Courses',
      imageType: 'tacos',
      colorValue: 0xFFFFCC80,
    ),
  ];

  static List<Dish> getDishesByCategory(String category) {
    if (category == 'Popular') {
      return allDishes.where((dish) => dish.category == 'Popular').toList();
    }
    return allDishes.where((dish) => dish.category == category).toList();
  }

  static List<Dish> searchDishes(String query) {
    if (query.isEmpty) return allDishes;

    final lowerQuery = query.toLowerCase();
    return allDishes.where((dish) {
      return dish.name.toLowerCase().contains(lowerQuery) ||
             dish.description.toLowerCase().contains(lowerQuery) ||
             dish.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
