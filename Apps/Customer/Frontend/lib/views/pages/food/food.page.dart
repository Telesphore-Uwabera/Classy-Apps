import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/services/delivery_history.service.dart';
import 'package:Classy/services/food_api.service.dart';
import 'package:Classy/services/location.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/views/pages/food/order_confirmation.page.dart';
import 'package:Classy/views/pages/food/categories.page.dart';
import 'package:Classy/views/pages/food/top_picks.page.dart';
import 'package:Classy/views/pages/search/search.page.dart';
import 'package:Classy/views/pages/cart/cart.page.dart';
import 'package:Classy/services/cart.service.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class FoodPage extends StatefulWidget {
  const FoodPage(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;
  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  int _selectedCategoryIndex = 0;
  bool _isLoading = false;
  String _searchQuery = '';
  
  final DeliveryHistoryService _deliveryService = DeliveryHistoryService();
  final FoodApiService _foodApiService = FoodApiService();
  
  final List<String> _categories = [
    'All', 'Burger', 'Pizza', 'Salad', 'Sushi', 'Chicken', 'Seafood', 
    'Desserts', 'Beverages', 'Fast Food', 'Healthy', 'Asian', 'Italian', 
    'Mexican', 'Indian', 'African', 'Breakfast', 'Lunch', 'Dinner'
  ];
  
  List<Map<String, dynamic>> _vendors = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _filteredFoodItems = [];
  
  @override
  void initState() {
    super.initState();
    _loadVendors();
    _loadSearchResults();
  }
  
  Future<void> _loadVendors() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await _foodApiService.getVendors();
      if (response.allGood && response.body != null && response.body!['data'] != null) {
        setState(() {
          _vendors = List<Map<String, dynamic>>.from(response.body!['data']);
        });
      }
    } catch (e) {
      print('Error loading vendors: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadSearchResults() async {
    try {
      final response = await _foodApiService.searchFood(_searchQuery);
      if (response.allGood && response.body != null && response.body!['data'] != null) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(response.body!['data']);
          _filteredFoodItems = _searchResults;
        });
      }
    } catch (e) {
      print('Error loading search results: $e');
    }
  }
  

  
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    // Trigger API search when user types
    if (query.isNotEmpty) {
      _loadSearchResults();
    } else {
      // Show all items when search is empty
      _filteredFoodItems = _searchResults;
    }
  }
  
  void _onCategoryChanged(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    
    if (index == 0) {
      // All categories
      _filteredFoodItems = _searchResults;
    } else {
      // Filter by specific category
      final categoryName = _categories[index];
      _filteredFoodItems = _searchResults.where((item) {
        return item['category'].toString().toLowerCase() == categoryName.toLowerCase();
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: VStack([
              // Location Header
              _buildLocationHeader(),
              
              // Search Bar
              _buildSearchBar(),
              
              // Promotional Banner
              _buildPromoBanner(),
              
              // Service Categories
              _buildServiceCategories(),
              
              // Top Picks Section
              _buildTopPicksSection(),
              
              UiSpacer.verticalSpace(space: 20),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: HStack([
        // Back Button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          ),
        ),
        
        SizedBox(width: 16),
        
        // Location Icon and Text
        Expanded(
          child: GestureDetector(
            onTap: () async {
              // Open location picker
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlacePicker(
                    apiKey: "AIzaSyDUZsmIAdmseLvCaQhyZlGHr6YU6HGITJk",
                    onPlacePicked: (result) {
                      LocationService.setCurrentLocation(result.formattedAddress ?? "Selected Location");
                      Navigator.of(context).pop();
                      setState(() {}); // Refresh the UI
                    },
                    initialPosition: LatLng(0.3476, 32.5825), // Kampala coordinates
                    useCurrentLocation: true,
                    resizeToAvoidBottomInset: true,
                  ),
                ),
              );
            },
            child: HStack([
              Icon(Icons.location_on, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  LocationService.currentLocation,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            ]),
          ),
        ),
        
        // Compass Icon
        GestureDetector(
          onTap: () async {
            // Use current location
            try {
              await LocationService.prepareLocationListener(true);
              await Future.delayed(Duration(seconds: 2));
              
              final currentAddress = LocationService.currenctAddress;
              if (currentAddress != null) {
                final addressText = currentAddress.addressLine ?? currentAddress.featureName ?? "Current Location";
                LocationService.setCurrentLocation(addressText);
                setState(() {}); // Refresh the UI
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Location updated to: $addressText")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Unable to detect current location")),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Location detection failed")),
              );
            }
          },
          child: Icon(Icons.compass_calibration, color: Colors.grey.shade600, size: 24),
        ),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
      ),
      child: HStack([
        Icon(Icons.search, color: Colors.grey.shade600, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search Classy",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ),
        
        // Cart Icon with Badge
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CartPage()),
            );
          },
          child: StreamBuilder<int>(
            stream: CartServices.cartItemsCountStream.stream,
            initialData: CartServices.productsInCart.length,
            builder: (context, snapshot) {
              final cartCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : cartCount.toString(),
                          style: TextStyle(
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
        ),
      ]),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primaryColor, AppColor.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: HStack([
        // Promo Text
        Expanded(
          child: VStack([
            "Use code FIRST50 at checkout".text.white.bold.make(),
            "Hurry, offer ends soon!".text.white.sm.make(),
            UiSpacer.verticalSpace(space: 8),
            "Get 50% Off".text.white.xl2.bold.make(),
            "Your First Order!".text.white.lg.make(),
          ]),
        ),
        
        // Running Burger Icon
        Icon(Icons.restaurant, color: Colors.white, size: 60),
        
        SizedBox(width: 16),
        
        // Order Now Button
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => OrderConfirmationPage()),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(25),
            ),
            child: "Order Now".text.white.bold.make(),
          ),
        ),
      ]),
    );
  }

  Widget _buildServiceCategories() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          HStack([
            "Food Categories".text.bold.xl.make(),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => FoodCategoriesPage()),
                );
              },
              child: Text(
                "See all",
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ]),
          
          UiSpacer.verticalSpace(space: 16),
          
          // Horizontal Scrollable Categories
          Container(
            height: 50, // Fixed height for category chips
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (int i = 0; i < _categories.length; i++)
                    _buildCategoryChip(_categories[i], i == _selectedCategoryIndex, () {
                      _onCategoryChanged(i);
                    }),
                  SizedBox(width: 20), // Extra padding at the end
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTopPicksSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: VStack([
        // Section Header
        HStack([
          "Top picks on Classy".text.bold.xl.make(),
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TopPicksPage()),
              );
            },
            child: Text(
              "See all",
              style: TextStyle(
                color: AppColor.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]),
        
        UiSpacer.verticalSpace(space: 16),
        
        // Food Items Grid
        _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                ),
              )
            : _filteredFoodItems.isEmpty
                ? Center(
                    child: VStack([
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      UiSpacer.verticalSpace(space: 16),
                      "No food items found".text.gray600.xl.make(),
                      UiSpacer.verticalSpace(space: 8),
                      "Try adjusting your search or category".text.gray500.make(),
                    ]),
                  )
                : Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 40, // Account for margins
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _filteredFoodItems.length,
                      itemBuilder: (context, index) {
                        return _buildFoodItemCard(_filteredFoodItems[index]);
                      },
                    ),
                  ),
      ]),
    );
  }

  Widget _buildFoodItemCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _showProductDetail(context, item),
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
          // Image with Rating and Time
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                item['image'],
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.restaurant, size: 40, color: Colors.grey.shade600),
                  );
                },
              ),
            ),
            
            // Rating
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HStack([
                  Icon(Icons.star, color: Colors.yellow.shade600, size: 12),
                  SizedBox(width: 2),
                  "${item['rating']}".text.white.bold.xs.make(),
                ]),
              ),
            ),
            
            // Delivery Time
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HStack([
                  Icon(Icons.access_time, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  "${item['deliveryTime']}".text.white.bold.xs.make(),
                ]),
              ),
            ),
          ],
        ),
        
        // Content
        Padding(
          padding: EdgeInsets.all(12),
          child: VStack([
            // Item Name
            item['name'].toString().text.bold.make(),
            
            // Restaurant Name
            item['restaurant'].toString().text.gray600.sm.make(),
            
            UiSpacer.verticalSpace(space: 8),
            
            // Price and Add Button
            HStack([
              // Price
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: "\$${item['price']}".text.white.bold.make(),
              ),
              
              Spacer(),
              
              // Add Button
              GestureDetector(
                onTap: () => _addToCart(item),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ]),
            
            // Delivery Fee
            "${item['deliveryFee'] > 0 ? '\$${item['deliveryFee']}' : 'Free'} Delivery fee".text.gray500.xs.make(),
          ]),
        ),
      ]),
    ),
    );
  }
  
  void _showProductDetail(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Draggable handle
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Product Image
              Container(
                height: 200,
                width: double.infinity,
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    item['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.restaurant, size: 80, color: Colors.grey.shade600);
                    },
                  ),
                ),
              ),
              
              // Product Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: VStack([
                  // Title and Calories
                  HStack([
                    item['name'].toString().text.bold.xl2.make(),
                    Spacer(),
                    HStack([
                      Icon(Icons.local_fire_department, color: Colors.red, size: 20),
                      "271 Cal".text.color(Colors.red).bold.make(),
                    ]),
                  ]),
                  
                  UiSpacer.verticalSpace(space: 8),
                  
                  // Restaurant info
                  "Want More from this vendor".text.gray600.make(),
                  
                  UiSpacer.verticalSpace(space: 8),
                  
                  // View Vendor Button
                  GestureDetector(
                    onTap: () => _showVendorPage(context, item),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColor.primaryColor, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: "View Vendor".text.color(AppColor.primaryColor).bold.make().centered(),
                    ),
                  ),
                  
                  UiSpacer.verticalSpace(space: 20),
                  
                  // Ingredients Section
                  "Ingredients".text.bold.xl.make(),
                  UiSpacer.verticalSpace(space: 12),
                  
                  VStack([
                    _buildIngredientItem("1 Juicy beef"),
                    _buildIngredientItem("1 Slice of cheddar cheese"),
                    _buildIngredientItem("1 burger bun"),
                    _buildIngredientItem("Fresh lettuce"),
                    _buildIngredientItem("Ripe tomato slices"),
                    _buildIngredientItem("Pickles for crunch"),
                    _buildIngredientItem("Ketchup"),
                    _buildIngredientItem("Mustard"),
                    _buildIngredientItem("Onions and bacon"),
                  ]),
                  
                  UiSpacer.verticalSpace(space: 20),
                  
                  // Variation Section
                  "Variation".text.bold.xl.make(),
                  UiSpacer.verticalSpace(space: 12),
                  
                  HStack([
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                    SizedBox(width: 12),
                    "Small".text.bold.make(),
                    Spacer(),
                    "\$${item['price']}".text.bold.make(),
                  ]),
                  
                  Spacer(),
                  
                                          // Add to Cart Bar
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: HStack([
                            GestureDetector(
                              onTap: () => _addToCartFromDetail(item),
                              child: "Add to cart".text.white.bold.xl.make(),
                            ),
                            Spacer(),
                            // Quantity Selector
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: HStack([
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: IconButton(
                                    icon: Icon(Icons.remove, color: Colors.black),
                                    onPressed: () {},
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: "1".text.bold.make().centered(),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: IconButton(
                                    icon: Icon(Icons.add, color: Colors.black),
                                    onPressed: () {},
                                  ),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildIngredientItem(String ingredient) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: HStack([
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        ingredient.text.make(),
      ]),
    );
  }
  
                                            Future<void> _addToCart(Map<String, dynamic> item) async {
                try {
                  // Place order via API
                  final orderData = {
                    'vendor_id': item['vendor_id'],
                    'items': [
                      {
                        'food_id': item['id'],
                        'quantity': 1,
                        'variation': 'Medium', // Default variation
                      }
                    ],
                    'delivery_address': LocationService.currentLocation,
                    'payment_method': 'cash', // Default payment method
                    'special_instructions': '',
                  };
                  
                  final response = await _foodApiService.placeOrder(orderData);
                  
                  if (response.allGood && response.data.isNotEmpty) {
                    // Add to delivery history
                    _deliveryService.addFoodDelivery(
                      restaurantName: item['vendor_name'] ?? item['restaurant'] ?? 'Unknown Restaurant',
                      from: item['vendor_name'] ?? item['restaurant'] ?? 'Unknown Restaurant',
                      to: 'Kampala, Uganda',
                      items: '1 ${item['name']}',
                      cost: 'UGX ${(item['price'] ?? 0)}',
                    );
                    
                    // Navigate to order confirmation page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrderConfirmationPage(
                          orderDetails: {
                            'restaurant': item['vendor_name'] ?? item['restaurant'] ?? 'Unknown Restaurant',
                            'items': '1 ${item['name']}',
                            'cost': 'UGX ${(item['price'] ?? 0)}',
                            'order_id': response.data[0]['order_id'].toString(),
                          },
                        ),
                      ),
                    );
                  } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: "Failed to place order: ${response.message}".text.white.make(),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Error placing order: $e".text.white.make(),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
                              Future<void> _addToCartFromDetail(Map<String, dynamic> item) async {
                                try {
                  // Place order via API
                  final orderData = {
                    'vendor_id': item['vendor_id'],
                    'items': [
                      {
                        'food_id': item['id'],
                        'quantity': 1,
                        'variation': 'Medium', // Default variation
                      }
                    ],
                    'delivery_address': LocationService.currentLocation,
                    'payment_method': 'cash', // Default payment method
                    'special_instructions': '',
                  };
                  
                  final response = await _foodApiService.placeOrder(orderData);
                  
                  if (response.allGood && response.data.isNotEmpty) {
                    // Add to delivery history
                    _deliveryService.addFoodDelivery(
                      restaurantName: item['vendor_name'] ?? item['restaurant'] ?? 'Unknown Restaurant',
                      from: item['vendor_name'] ?? item['restaurant'] ?? 'Unknown Restaurant',
                      to: 'Kampala, Uganda',
                      items: '1 ${item['name']}',
                      cost: 'UGX ${(item['price'] ?? 0)}',
                    );
                    
                    // Close the modal
                    Navigator.of(context).pop();
                    
                    // Navigate to order confirmation page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrderConfirmationPage(
                          orderDetails: {
                            'restaurant': item['vendor_name'] ?? item['restaurant'] ?? 'Unknown Restaurant',
                            'items': '1 ${item['name']}',
                            'to': 'Kampala, Uganda',
                            'cost': 'UGX ${(item['price'] ?? 0)}',
                            'order_id': response.data[0]['order_id'].toString(),
                          },
                        ),
                      ),
                    );
                  } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: "Failed to place order: ${response.message}".text.white.make(),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Error placing order: $e".text.white.make(),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _showVendorPage(BuildContext context, Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _VendorPage(restaurantName: item['restaurant']),
      ),
    );
  }
}

class _VendorPage extends StatefulWidget {
  final String restaurantName;
  
  const _VendorPage({required this.restaurantName});
  
  @override
  _VendorPageState createState() => _VendorPageState();
}

class _VendorPageState extends State<_VendorPage> {
  final DeliveryHistoryService _deliveryService = DeliveryHistoryService();
  final FoodApiService _foodApiService = FoodApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: VStack([
            // Header with back button and favorite
            _buildHeader(),
            
            // Search bar
            _buildSearchBar(),
            
            // Store info card
            _buildStoreInfoCard(),
            
            // Food items grid
            _buildFoodItemsGrid(),
            
            UiSpacer.verticalSpace(space: 20),
          ]),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: HStack([
        // Back button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        
        Spacer(),
        
        // Favorite button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
        ),
      ]),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
      ),
      child: HStack([
        Icon(Icons.search, color: Colors.grey.shade600, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search on Classy",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ),
        
        // Cart Icon with Badge
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CartPage()),
            );
          },
          child: StreamBuilder<int>(
            stream: CartServices.cartItemsCountStream.stream,
            initialData: CartServices.productsInCart.length,
            builder: (context, snapshot) {
              final cartCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : cartCount.toString(),
                          style: TextStyle(
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
        ),
      ]),
    );
  }
  
  Widget _buildStoreInfoCard() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
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
        // Store logo and name
        HStack([
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant,
              color: Colors.orange,
              size: 30,
            ),
          ),
          
          SizedBox(width: 16),
          
          VStack([
            widget.restaurantName.text.bold.xl.make(),
            "All Items in ${widget.restaurantName}".text.bold.lg.make(),
            "A comprehensive list of the available item lists from this store".text.gray600.make(),
          ]),
        ]),
      ]),
    );
  }
  
  Widget _buildFoodItemsGrid() {
    final List<Map<String, dynamic>> vendorItems = [
      {
        'id': 1,
        'name': 'Cheeseburger',
        'rating': 4.8,
        'deliveryTime': '31 min',
        'price': 8.99,
        'deliveryFee': 3.0,
        'image': 'assets/images/service_food.jpeg',
      },
      {
        'id': 2,
        'name': 'Burger w/ Bacon',
        'rating': 4.7,
        'deliveryTime': '27 min',
        'price': 9.99,
        'deliveryFee': 0.0,
        'image': 'assets/images/service_food.jpeg',
      },
      {
        'id': 3,
        'name': 'Chicken Wings',
        'rating': 4.6,
        'deliveryTime': '25 min',
        'price': 12.99,
        'deliveryFee': 2.0,
        'image': 'assets/images/service_food.jpeg',
      },
      {
        'id': 4,
        'name': 'French Fries',
        'rating': 4.5,
        'deliveryTime': '20 min',
        'price': 4.99,
        'deliveryFee': 1.0,
        'image': 'assets/images/service_food.jpeg',
      },
    ];
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: vendorItems.length,
        itemBuilder: (context, index) {
          return _buildVendorFoodCard(vendorItems[index]);
        },
      ),
    );
  }
  
  Widget _buildVendorFoodCard(Map<String, dynamic> item) {
    return Container(
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
        // Image with Rating and Time
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                item['image'],
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.restaurant, size: 40, color: Colors.grey.shade600),
                  );
                },
              ),
            ),
            
            // Rating
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HStack([
                  Icon(Icons.star, color: Colors.yellow.shade600, size: 12),
                  SizedBox(width: 2),
                  "${item['rating']}".text.white.bold.xs.make(),
                ]),
              ),
            ),
            
            // Delivery Time
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HStack([
                  Icon(Icons.access_time, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  "${item['deliveryTime']}".text.white.bold.xs.make(),
                ]),
              ),
            ),
          ],
        ),
        
        // Content
        Padding(
          padding: EdgeInsets.all(12),
          child: VStack([
            // Item Name
            item['name'].toString().text.bold.make(),
            
            UiSpacer.verticalSpace(space: 8),
            
            // Price and Add Button
            HStack([
              // Price
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: "\$${item['price']}".text.white.bold.make(),
              ),
              
              Spacer(),
              
              // Add Button
              GestureDetector(
                onTap: () => _addToCartFromVendor(item),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ]),
            
            // Delivery Fee
            "${item['deliveryFee'] > 0 ? '\$${item['deliveryFee']}' : 'Free'} Delivery fee".text.gray500.xs.make(),
          ]),
        ),
      ]),
    );
  }
  
                Future<void> _addToCartFromVendor(Map<String, dynamic> item) async {
                                                try {
                  // Place order via API
                  final orderData = {
                    'vendor_id': item['vendor_id'],
                    'items': [
                      {
                        'food_id': item['id'],
                        'quantity': 1,
                        'variation': 'Medium', // Default variation
                      }
                    ],
                    'delivery_address': LocationService.currentLocation,
                    'payment_method': 'cash', // Default payment method
                    'special_instructions': '',
                  };
                  
                  final response = await _foodApiService.placeOrder(orderData);
                  
                  if (response.allGood && response.data.isNotEmpty) {
                    // Add to delivery history
                    _deliveryService.addFoodDelivery(
                      restaurantName: widget.restaurantName,
                      from: widget.restaurantName,
                      to: 'Kampala, Uganda',
                      items: '1 ${item['name']}',
                      cost: 'UGX ${(item['price'] ?? 0)}',
                    );
                    
                    // Navigate to order confirmation page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrderConfirmationPage(
                          orderDetails: {
                            'restaurant': widget.restaurantName,
                            'items': '1 ${item['name']}',
                            'cost': 'UGX ${(item['price'] ?? 0)}',
                            'order_id': response.data[0]['order_id'].toString(),
                          },
                        ),
                      ),
                    );
                  } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: "Failed to place order: ${response.message}".text.white.make(),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Error placing order: $e".text.white.make(),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}


