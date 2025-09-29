import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/services/food_categories_api.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class TopPicksPage extends StatefulWidget {
  const TopPicksPage({Key? key}) : super(key: key);

  @override
  _TopPicksPageState createState() => _TopPicksPageState();
}

class _TopPicksPageState extends State<TopPicksPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Popular', 'New', 'Rating', 'Price'];
  
  List<Map<String, dynamic>> _topPicks = [];
  bool _isLoading = false;
  
  final FoodCategoriesApiService _foodApiService = FoodCategoriesApiService();

  @override
  void initState() {
    super.initState();
    _loadTopPicks();
  }

  Future<void> _loadTopPicks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _foodApiService.getTopPicks(
        filter: _selectedFilter,
      );
      
      if (response.allGood && response.body != null && response.body!['data'] != null) {
        setState(() {
          _topPicks = List<Map<String, dynamic>>.from(response.body!['data']);
        });
      } else {
        setState(() {
          _topPicks = [];
        });
      }
    } catch (e) {
      print('Error loading top picks: $e');
      setState(() {
        _topPicks = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedFilter == 'All') {
      return _topPicks;
    } else if (_selectedFilter == 'Popular') {
      return _topPicks.where((item) => item['isPopular'] == true).toList();
    } else if (_selectedFilter == 'New') {
      return _topPicks.where((item) => item['isNew'] == true).toList();
    } else if (_selectedFilter == 'Rating') {
      return List.from(_topPicks)..sort((a, b) => b['rating'].compareTo(a['rating']));
    } else if (_selectedFilter == 'Price') {
      return List.from(_topPicks)..sort((a, b) => a['price'].compareTo(b['price']));
    }
    return _topPicks;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Top Picks",
      body: VStack([
        // Filter Chips with improved horizontal flow
        Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = filter == _selectedFilter;
              
                                   return GestureDetector(
                       onTap: () {
                         setState(() {
                           _selectedFilter = filter;
                         });
                         _loadTopPicks(); // Reload data with new filter
                       },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected ? AppColor.primaryColor : Colors.grey[300]!,
                      width: 1.5,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColor.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                      ],
                      Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        UiSpacer.verticalSpace(space: 16),
        
        // Food Items List
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                  ),
                )
              : _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No food items available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check back later for new items',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadTopPicks,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return _buildFoodItemCard(_filteredItems[index]);
                      },
                    ),
        ),
      ]),
    );
  }

  Widget _buildFoodItemCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: HStack([
        // Food Image
        ClipRRect(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
          child: Image.asset(
            item['image'],
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                color: Colors.grey.shade300,
                child: Icon(Icons.restaurant, color: Colors.grey.shade600),
              );
            },
          ),
        ),
        
        // Food Details
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: VStack([
              // Name and Badges
              HStack([
                Expanded(
                  child: item['name'].toString().text.bold.lg.make(),
                ),
                if (item['isPopular'])
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: "Popular".text.white.xs.bold.make(),
                  ),
                if (item['isNew'])
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: "New".text.white.xs.bold.make(),
                  ),
              ]),
              
              UiSpacer.verticalSpace(space: 4),
              
              // Restaurant
              item['restaurant'].toString().text.gray600.make(),
              
              UiSpacer.verticalSpace(space: 4),
              
              // Description
              item['description'].toString().text.gray500.sm.maxLines(2).make(),
              
              UiSpacer.verticalSpace(space: 8),
              
              // Rating and Delivery Time
              HStack([
                Icon(Icons.star, color: Colors.amber, size: 16),
                UiSpacer.horizontalSpace(space: 4),
                item['rating'].toString().text.bold.make(),
                UiSpacer.horizontalSpace(space: 16),
                Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
                UiSpacer.horizontalSpace(space: 4),
                item['deliveryTime'].toString().text.gray600.sm.make(),
              ]),
              
              UiSpacer.verticalSpace(space: 8),
              
              // Price and Add Button
              HStack([
                "\$${item['price'].toStringAsFixed(2)}".text.bold.xl.color(AppColor.primaryColor).make(),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    // TODO: Add to cart
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Added to cart!")),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: "Add".text.white.bold.make(),
                  ),
                ),
              ]),
            ], crossAlignment: CrossAxisAlignment.start),
          ),
        ),
      ]),
    );
  }
}
