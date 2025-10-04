import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/services/food_categories_api.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/views/pages/food/top_picks.page.dart';

class FoodCategoriesPage extends StatefulWidget {
  const FoodCategoriesPage({Key? key}) : super(key: key);

  @override
  _FoodCategoriesPageState createState() => _FoodCategoriesPageState();
}

class _FoodCategoriesPageState extends State<FoodCategoriesPage> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  
  final FoodCategoriesApiService _foodApiService = FoodCategoriesApiService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _foodApiService.getCategories();
      if (response.allGood && response.body != null && response.body!['data'] != null) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response.body!['data']);
        });
      } else {
        // Fallback to default categories if API fails
        setState(() {
          _categories = _getDefaultCategories();
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _categories = _getDefaultCategories();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDefaultCategories() {
    return [
    {
      'name': 'Burger',
      'icon': Icons.lunch_dining,
      'color': Colors.orange,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Pizza',
      'icon': Icons.local_pizza,
      'color': Colors.red,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Salad',
      'icon': Icons.eco,
      'color': Colors.green,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Sushi',
      'icon': Icons.set_meal,
      'color': Colors.blue,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Chicken',
      'icon': Icons.restaurant,
      'color': Colors.brown,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Seafood',
      'icon': Icons.set_meal,
      'color': Colors.cyan,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Desserts',
      'icon': Icons.cake,
      'color': Colors.pink,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Beverages',
      'icon': Icons.local_drink,
      'color': Colors.purple,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Fast Food',
      'icon': Icons.fastfood,
      'color': Colors.amber,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Healthy',
      'icon': Icons.favorite,
      'color': Colors.lightGreen,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Asian',
      'icon': Icons.ramen_dining,
      'color': Colors.deepOrange,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Italian',
      'icon': Icons.restaurant,
      'color': Colors.green,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Mexican',
      'icon': Icons.local_fire_department,
      'color': Colors.red,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Indian',
      'icon': Icons.spa,
      'color': Colors.orange,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'African',
      'icon': Icons.public,
      'color': Colors.brown,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Breakfast',
      'icon': Icons.free_breakfast,
      'color': Colors.yellow,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Lunch',
      'icon': Icons.lunch_dining,
      'color': Colors.blue,
      'image': 'assets/images/product.png',
    },
    {
      'name': 'Dinner',
      'icon': Icons.dinner_dining,
      'color': Colors.indigo,
      'image': 'assets/images/product.png',
    },
  ];
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Food Categories",
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, // Adjusted to prevent overflow
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(_categories[index]);
              },
            ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category items page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TopPicksPage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: VStack([
          // Category Icon/Image
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: (category['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                // Background Image (if available)
                if (category['image'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      category['image'],
                      width: double.infinity,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 80,
                          color: (category['color'] as Color).withOpacity(0.1),
                          child: Icon(
                            category['icon'],
                            size: 40,
                            color: category['color'],
                          ),
                        );
                      },
                    ),
                  ),
                
                // Icon overlay
                Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      category['icon'],
                      size: 24,
                      color: category['color'],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Category Info
          Padding(
            padding: EdgeInsets.all(12),
            child: VStack([
              category['name'].toString().text.bold.lg.make().centered(),
              UiSpacer.verticalSpace(space: 4),
              if (category['itemCount'] != null && category['itemCount'] > 0)
                "${category['itemCount']} items".text.gray600.sm.make().centered()
              else
                "Browse items".text.gray600.sm.make().centered(),
            ]),
          ),
        ]),
      ),
    );
  }
}
