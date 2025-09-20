import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../services/order_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/status_toggle.dart';
import '../../widgets/expandable_bottom_nav.dart';
import '../../widgets/quick_sync_indicator.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'vendor_dashboard_screen.dart';
import 'products/professional_products_screen.dart';
import 'products/add_product_screen.dart';
import 'orders/professional_orders_screen.dart';
import 'inventory/inventory_screen.dart';
import 'analytics/analytics_screen.dart';
import 'customers/customers_screen.dart';
import 'delivery_zones/delivery_zones_screen.dart';
import 'finance/professional_finance_screen.dart';
import 'package_pricing/package_pricing_screen.dart';
import 'notifications/notifications_screen.dart';
import 'chat/chat_list_screen.dart';
import 'documents/documents_screen.dart';
import 'settings/professional_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const VendorDashboardScreen(),
    const ProfessionalProductsScreen(),
    const ProfessionalOrdersScreen(),
    const InventoryScreen(),
    const AnalyticsScreen(),
    const CustomersScreen(),
    const DeliveryZonesScreen(),
    const ProfessionalFinanceScreen(),
    const PackagePricingScreen(),
    const NotificationsScreen(),
    const ChatListScreen(),
    const DocumentsScreen(),
    const ProfessionalSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: ExpandableBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final ProductService _productService = ProductService.instance;
  final OrderService _orderService = OrderService.instance;
  
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _hasData = false;
  String _loadingMessage = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadDashboardDataQuick();
  }

  Future<void> _loadDashboardDataQuick() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Syncing data...';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final vendorId = authService.currentUser?.id?.toString() ?? '';
      
      if (vendorId.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasData = false;
        });
        return;
      }

      // Quick parallel data loading with timeout
      final futures = await Future.wait([
        _productService.getProducts(vendorId).timeout(const Duration(seconds: 3)),
        _orderService.getOrders(vendorId).timeout(const Duration(seconds: 3)),
        _orderService.getOrderStats(vendorId).timeout(const Duration(seconds: 3)),
      ]);

      final products = futures[0] as List;
      final orders = futures[1] as List;
      final orderStats = futures[2] as Map<String, dynamic>;

      setState(() {
        _stats = {
          'totalProducts': products.length,
          'totalOrders': orders.length,
          'totalRevenue': orderStats['totalRevenue'] ?? 0.0,
          'averageRating': 4.8, // This would come from reviews collection
          'pendingOrders': orderStats['pendingOrders'] ?? 0,
          'completedOrders': orderStats['completedOrders'] ?? 0,
        };
        _hasData = products.isNotEmpty || orders.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
        _hasData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<AuthService>(
            builder: (context, authService, child) {
              return StatusToggle(
                vendorId: authService.currentUser?.id?.toString() ?? '',
                currentStatus: 'online',
                onStatusChanged: (status) {
                  // Status updated
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardDataQuick,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications - this will be handled by parent widget
              final parentState = context.findAncestorStateOfType<_DashboardScreenState>();
              parentState?.setState(() {
                parentState._selectedIndex = 9; // Notifications index
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryColorDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your business efficiently',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats Cards
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            _isLoading
                ? QuickLoadingIndicator(message: _loadingMessage)
                : _hasData
                    ? GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      DashboardCard(
                        title: 'Total Orders',
                        value: '${_stats['totalOrders'] ?? 0}',
                        icon: Icons.shopping_cart,
                        color: AppTheme.successColor,
                        onTap: () {
                          final parentState = context.findAncestorStateOfType<_DashboardScreenState>();
                          parentState?.setState(() {
                            parentState._selectedIndex = 2; // Orders index
                          });
                        },
                      ),
                      DashboardCard(
                        title: 'Products',
                        value: '${_stats['totalProducts'] ?? 0}',
                        icon: Icons.inventory,
                        color: AppTheme.warningColor,
                        onTap: () {
                          final parentState = context.findAncestorStateOfType<_DashboardScreenState>();
                          parentState?.setState(() {
                            parentState._selectedIndex = 1; // Products index
                          });
                        },
                      ),
                      DashboardCard(
                        title: 'Revenue',
                        value: '\$${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: AppTheme.infoColor,
                        onTap: () {
                          final parentState = context.findAncestorStateOfType<_DashboardScreenState>();
                          parentState?.setState(() {
                            parentState._selectedIndex = 7; // Finance index
                          });
                        },
                      ),
                      DashboardCard(
                        title: 'Rating',
                        value: '${_stats['averageRating'] ?? 0.0}',
                        icon: Icons.star,
                        color: AppTheme.secondaryColor,
                        onTap: () {
                          final parentState = context.findAncestorStateOfType<_DashboardScreenState>();
                          parentState?.setState(() {
                            parentState._selectedIndex = 4; // Analytics index
                          });
                        },
                      ),
                    ],
                  )
                    : NoUpdatesIndicator(
                        message: 'No updates at the moment',
                        icon: Icons.check_circle_outline,
                        onAction: _loadDashboardDataQuick,
                        actionText: 'Refresh',
                      ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final parentState = context.findAncestorStateOfType<_DashboardScreenState>();
                      parentState?.setState(() {
                        parentState._selectedIndex = 1; // Products index
                      });
                      // Navigate to add product screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final parentState = context.findAncestorStateOfType<_DashboardScreenState>();
                      parentState?.setState(() {
                        parentState._selectedIndex = 2; // Orders index
                      });
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('View Orders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
