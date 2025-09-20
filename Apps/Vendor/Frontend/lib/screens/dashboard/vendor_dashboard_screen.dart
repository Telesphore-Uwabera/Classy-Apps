import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../services/order_service.dart';
import '../../constants/simple_app_colors.dart';
import '../../constants/simple_app_strings.dart';
import 'products/products_screen.dart';
import 'products/add_product_screen.dart';
import 'orders/orders_screen.dart';
import 'analytics/analytics_screen.dart';
import 'finance/finance_reports_screen.dart';
import 'notifications/notifications_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  final ProductService _productService = ProductService.instance;
  final OrderService _orderService = OrderService.instance;
  
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _hasData = false;
  String _loadingMessage = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
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
          'averageRating': 4.8,
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
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingWidget()
            : VStack([
                // Header with profile and app name
                _buildHeader(),
                
                // Balance Card
                _buildBalanceCard(),
                
                // Monthly Stats
                _buildStatsSection(),
                
                // Recent Activity
                _buildRecentActivitySection(),
                
                const SizedBox(height: 20),
              ]).scrollVertical(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: VStack([
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
        ),
        const SizedBox(height: 16),
        _loadingMessage.text.lg.gray600.make(),
      ]),
    );
  }

  Widget _buildHeader() {
    return HStack([
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.storefront,
          color: Colors.white,
          size: 30,
        ),
      ),
      VStack([
        Consumer<AuthService>(
          builder: (context, authService, child) {
            return (authService.currentUser?.name ?? "Vendor").text.xl.bold.make();
          },
        ),
        "Active now".text.sm.color(Colors.green).make(),
      ]).expand(),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _loadDashboardData,
        tooltip: 'Refresh Data',
      ),
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          );
        },
      ),
    ]).p20();
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: VStack([
        HStack([
          Icon(
            Icons.account_balance_wallet,
            color: AppColor.primaryColor,
            size: 20,
          ),
          "Balance".text.lg.make(),
        ]),
        "\$${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)}".text.xl2.bold.make().py8(),
        HStack([
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FinanceReportsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: HStack([
                const Icon(Icons.add, color: Colors.white, size: 20),
                "Withdraw".text.white.bold.make(),
              ]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FinanceReportsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: HStack([
                const Icon(Icons.refresh, color: Colors.grey, size: 20),
                "Transactions".text.gray600.bold.make(),
              ]),
            ),
          ),
        ]),
      ]),
    ).py12();
  }

  Widget _buildStatsSection() {
    return VStack([
      "Monthly Stats".text.xl.bold.make().px20().py12(),
      HStack([
        _buildStatCard("${_stats['totalOrders'] ?? 0} Orders", Icons.shopping_cart, Colors.blue),
        _buildStatCard("\$${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)} Sales", Icons.attach_money, Colors.green),
      ], spacing: 12).px20(),
      HStack([
        _buildStatCard("${_stats['totalProducts'] ?? 0} Products", Icons.inventory, Colors.orange),
        _buildStatCard("${_stats['averageRating'] ?? 0.0} Rating", Icons.star, AppColor.primaryColor),
      ], spacing: 12).px20().py8(),
    ]);
  }

  Widget _buildStatCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: VStack([
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          title.text.sm.gray600.make(),
        ], alignment: MainAxisAlignment.center),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return VStack([
      HStack([
        "Recent Activity".text.xl.bold.make(),
        "View All".text.color(AppColor.primaryColor).make(),
      ], alignment: MainAxisAlignment.spaceBetween).px20().py12(),

      _hasData ? _buildActivityList() : _buildNoActivityWidget(),
    ]);
  }

  Widget _buildActivityList() {
    return VStack([
      // Recent orders
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: VStack([
          HStack([
            Icon(Icons.shopping_cart, color: AppColor.primaryColor, size: 20),
            "Recent Orders".text.lg.bold.make(),
          ]),
          const SizedBox(height: 12),
          "You have ${_stats['totalOrders'] ?? 0} orders this month".text.sm.gray600.make(),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: "View Orders".text.white.make(),
          ),
        ]),
      ).py4(),
      
      // Quick actions
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: VStack([
          HStack([
            Icon(Icons.dashboard, color: AppColor.primaryColor, size: 20),
            "Quick Actions".text.lg.bold.make(),
          ]),
          const SizedBox(height: 12),
          HStack([
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: "Add Product".text.sm.make(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrdersScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.list, size: 16),
                label: "View Orders".text.sm.make(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ]),
        ]),
      ).py4(),
    ]);
  }

  Widget _buildNoActivityWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          "No recent activity".text.lg.gray600.make(),
          const SizedBox(height: 8),
          "Your recent orders and activities will appear here".text.sm.gray500.make(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: "Refresh".text.white.make(),
          ),
        ],
      ),
    );
  }
}
