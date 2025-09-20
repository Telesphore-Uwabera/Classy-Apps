import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/package_pricing_service.dart';
import '../../../models/package_pricing.dart';
import '../../../constants/app_theme.dart';
import '../../../constants/app_constants.dart';
import 'add_package_pricing_screen.dart';
import 'edit_package_pricing_screen.dart';

class PackagePricingScreen extends StatefulWidget {
  const PackagePricingScreen({super.key});

  @override
  State<PackagePricingScreen> createState() => _PackagePricingScreenState();
}

class _PackagePricingScreenState extends State<PackagePricingScreen> {
  final PackagePricingService _pricingService = PackagePricingService.instance;
  List<PackagePricing> _pricings = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadPricings();
  }

  Future<void> _loadPricings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final vendorId = authService.currentUser?.id ?? '';
      
      if (vendorId.toString().isNotEmpty) {
        final pricings = await _pricingService.getPackagePricings(vendorId.toString());
        setState(() {
          _pricings = pricings;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading package pricings: $e')),
        );
      }
    }
  }

  List<PackagePricing> get _filteredPricings {
    return _pricings.where((pricing) {
      final matchesSearch = pricing.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           pricing.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesFilter = true;
      switch (_selectedFilter) {
        case 'active':
          matchesFilter = pricing.isActive;
          break;
        case 'inactive':
          matchesFilter = !pricing.isActive;
          break;
        case 'all':
        default:
          matchesFilter = true;
      }
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _togglePricingStatus(PackagePricing pricing) async {
    final success = await _pricingService.togglePricingStatus(pricing.id, !pricing.isActive);
    if (success) {
      setState(() {
        final index = _pricings.indexWhere((p) => p.id == pricing.id);
        if (index != -1) {
          _pricings[index] = pricing.copyWith(isActive: !pricing.isActive);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pricing ${pricing.isActive ? 'deactivated' : 'activated'} successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update pricing status')),
        );
      }
    }
  }

  Future<void> _deletePricing(PackagePricing pricing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package Pricing'),
        content: Text('Are you sure you want to delete "${pricing.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _pricingService.deletePackagePricing(pricing.id);
      if (success) {
        setState(() {
          _pricings.removeWhere((p) => p.id == pricing.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Package pricing deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete package pricing')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Pricing'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPricings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search package pricings...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active', 'active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Inactive', 'inactive'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Pricings List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPricings.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_shipping, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No package pricings found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add your first package pricing to get started',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPricings.length,
                        itemBuilder: (context, index) {
                          final pricing = _filteredPricings[index];
                          return _buildPricingCard(pricing);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPackagePricingScreen(),
            ),
          ).then((_) => _loadPricings());
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildPricingCard(PackagePricing pricing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pricing.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pricing.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(pricing.isActive),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Pricing Details
            Row(
              children: [
                Expanded(
                  child: _buildPricingDetail(
                    'Base Price',
                    '${AppConstants.currencySymbol}${pricing.basePrice.toStringAsFixed(2)}',
                    Icons.attach_money,
                    AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _buildPricingDetail(
                    'Per Km',
                    '${AppConstants.currencySymbol}${pricing.pricePerKm.toStringAsFixed(2)}',
                    Icons.straighten,
                    AppTheme.infoColor,
                  ),
                ),
                Expanded(
                  child: _buildPricingDetail(
                    'Per Kg',
                    '${AppConstants.currencySymbol}${pricing.pricePerKg.toStringAsFixed(2)}',
                    Icons.fitness_center,
                    AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Price Range
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Price Range: ${AppConstants.currencySymbol}${pricing.minPrice.toStringAsFixed(2)} - ${AppConstants.currencySymbol}${pricing.maxPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPackagePricingScreen(pricing: pricing),
                        ),
                      ).then((_) => _loadPricings());
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _togglePricingStatus(pricing),
                    icon: Icon(
                      pricing.isActive ? Icons.pause : Icons.play_arrow,
                      size: 16,
                    ),
                    label: Text(pricing.isActive ? 'Deactivate' : 'Activate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: pricing.isActive ? AppTheme.warningColor : AppTheme.successColor,
                      side: BorderSide(
                        color: pricing.isActive ? AppTheme.warningColor : AppTheme.successColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _deletePricing(pricing),
                  icon: Icon(Icons.delete, color: AppTheme.errorColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.successColor.withValues(alpha: 0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? AppTheme.successColor : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildPricingDetail(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
