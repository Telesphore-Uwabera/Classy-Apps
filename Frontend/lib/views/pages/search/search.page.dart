import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/services/food_categories_api.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, this.search}) : super(key: key);
  
  final dynamic search;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _recentSearches = [];
  List<Map<String, dynamic>> _popularSearches = [];
  bool _isSearching = false;
  
  final FoodCategoriesApiService _foodApiService = FoodCategoriesApiService();

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadPopularSearches();
  }

  void _loadRecentSearches() {
    // Load recent searches from storage
    setState(() {
      _recentSearches = [
        {'query': 'Burger', 'type': 'food'},
        {'query': 'Pizza', 'type': 'food'},
        {'query': 'KFC', 'type': 'restaurant'},
        {'query': 'McDonald\'s', 'type': 'restaurant'},
        {'query': 'Salad', 'type': 'food'},
      ];
    });
  }

  void _loadPopularSearches() {
    // Load popular searches from API
    setState(() {
      _popularSearches = [
        {'query': 'Chicken', 'type': 'food', 'count': 1250},
        {'query': 'Pizza', 'type': 'food', 'count': 980},
        {'query': 'Burger', 'type': 'food', 'count': 850},
        {'query': 'Sushi', 'type': 'food', 'count': 720},
        {'query': 'Pasta', 'type': 'food', 'count': 650},
        {'query': 'Tacos', 'type': 'food', 'count': 580},
        {'query': 'Salad', 'type': 'food', 'count': 520},
        {'query': 'Dessert', 'type': 'food', 'count': 480},
      ];
    });
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await _foodApiService.searchFood(query: query);
      
      if (response.allGood && response.body != null && response.body!['data'] != null) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(response.body!['data']);
        });
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      print('Error searching food: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _performSearch(query);
  }

  void _selectSearchSuggestion(String query) {
    _searchController.text = query;
    setState(() {
      _searchQuery = query;
    });
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
        return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Search",
          body: SafeArea(
        child: VStack([
          // Search Header
          _buildSearchHeader(),
          
          // Search Content
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildSearchSuggestions()
                : _buildSearchResults(),
          ),
        ]),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: HStack([
        // Back Button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back, color: Colors.black87, size: 24),
        ),
        
        UiSpacer.horizontalSpace(space: 16),
        
        // Search Field
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Search for food, restaurants...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        
        UiSpacer.horizontalSpace(space: 16),
        
        // Clear Button
        if (_searchQuery.isNotEmpty)
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _searchResults = [];
              });
            },
            child: Icon(Icons.clear, color: Colors.grey.shade600, size: 24),
          ),
      ]),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: VStack([
        // Recent Searches
        if (_recentSearches.isNotEmpty) ...[
          "Recent Searches".text.bold.xl.make(),
          UiSpacer.verticalSpace(space: 16),
          
          for (var search in _recentSearches)
            _buildSearchSuggestion(search['query'], search['type'], true),
          
          UiSpacer.verticalSpace(space: 24),
        ],
        
        // Popular Searches
        "Popular Searches".text.bold.xl.make(),
        UiSpacer.verticalSpace(space: 16),
        
        for (var search in _popularSearches)
          _buildSearchSuggestion(search['query'], search['type'], false, search['count']),
      ]),
    );
  }

  Widget _buildSearchSuggestion(String query, String type, bool isRecent, [int? count]) {
    return GestureDetector(
      onTap: () => _selectSearchSuggestion(query),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: HStack([
          Icon(
            isRecent ? Icons.history : Icons.trending_up,
            color: isRecent ? Colors.grey.shade600 : AppColor.primaryColor,
            size: 20,
          ),
          
          UiSpacer.horizontalSpace(space: 12),
          
          Expanded(
            child: VStack([
              query.text.bold.make(),
              if (count != null)
                "${count} searches".text.gray600.sm.make(),
            ], crossAlignment: CrossAxisAlignment.start),
          ),
          
          Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
        ]),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(
        child: VStack([
          CircularProgressIndicator(),
          UiSpacer.verticalSpace(space: 16),
          "Searching...".text.gray600.make(),
        ]),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: VStack([
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          UiSpacer.verticalSpace(space: 16),
          "No results found".text.xl.bold.gray600.make(),
          UiSpacer.verticalSpace(space: 8),
          "Try searching for something else".text.gray500.make(),
        ]),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
        return _buildSearchResultItem(_searchResults[index]);
      },
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: HStack([
        // Image
        ClipRRect(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
          child: Image.asset(
            item['image'],
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade300,
                child: Icon(
                  item['type'] == 'restaurant' ? Icons.restaurant : Icons.fastfood,
                  color: Colors.grey.shade600,
                ),
              );
            },
          ),
        ),
        
        // Details
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: VStack([
              item['name'].toString().text.bold.lg.make(),
              UiSpacer.verticalSpace(space: 4),
              
              if (item['type'] == 'food') ...[
                item['restaurant'].toString().text.gray600.make(),
                UiSpacer.verticalSpace(space: 4),
                item['description'].toString().text.gray500.sm.maxLines(2).make(),
                UiSpacer.verticalSpace(space: 8),
                HStack([
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  UiSpacer.horizontalSpace(space: 4),
                  item['rating'].toString().text.bold.make(),
                  Spacer(),
                  "\$${item['price'].toStringAsFixed(2)}".text.bold.color(AppColor.primaryColor).make(),
                ]),
              ] else ...[
                item['description'].toString().text.gray500.sm.maxLines(2).make(),
                UiSpacer.verticalSpace(space: 8),
                HStack([
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  UiSpacer.horizontalSpace(space: 4),
                  item['rating'].toString().text.bold.make(),
                  UiSpacer.horizontalSpace(space: 16),
                  Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
                  UiSpacer.horizontalSpace(space: 4),
                  item['deliveryTime'].toString().text.gray600.sm.make(),
                ]),
              ],
            ], crossAlignment: CrossAxisAlignment.start),
          ),
        ),
      ]),
    );
  }
}