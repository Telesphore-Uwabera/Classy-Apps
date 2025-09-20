import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../../services/auth_service.dart';
import '../../../services/order_service.dart';
import '../../../constants/simple_app_colors.dart';
import '../../../constants/simple_app_strings.dart';
import '../../../widgets/custom_button.dart';
import 'finance_reports_screen.dart';
import 'withdrawal_screen.dart';

class ProfessionalFinanceScreen extends StatefulWidget {
  const ProfessionalFinanceScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalFinanceScreen> createState() => _ProfessionalFinanceScreenState();
}

class _ProfessionalFinanceScreenState extends State<ProfessionalFinanceScreen> with TickerProviderStateMixin {
  final OrderService _orderService = OrderService.instance;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFinanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFinanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final vendorId = authService.currentUser?.id?.toString() ?? '';
      
      if (vendorId.isNotEmpty) {
        final orderStats = await _orderService.getOrderStats(vendorId);
        setState(() {
          _stats = orderStats;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading finance data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: "Finance".text.xl.bold.make(),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFinanceData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Reports'),
            Tab(text: 'Withdraw'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildReportsTab(),
          _buildWithdrawTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primaryColor, AppColor.primaryColorDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    "Available Balance".text.white.lg.make(),
                  ],
                ),
                const SizedBox(height: 16),
                "${AppStrings.currencySymbol}${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(2)}".text.white.xl3.bold.make(),
                const SizedBox(height: 8),
                "Total earnings from all orders".text.white.make(),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Grid
          "Financial Overview".text.xl.bold.make().py8(),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                "Total Revenue",
                "${AppStrings.currencySymbol}${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(2)}",
                Icons.attach_money,
                AppColor.successColor,
              ),
              _buildStatCard(
                "Total Orders",
                "${_stats['totalOrders'] ?? 0}",
                Icons.shopping_cart,
                AppColor.infoColor,
              ),
              _buildStatCard(
                "Completed Orders",
                "${_stats['completedOrders'] ?? 0}",
                Icons.check_circle,
                AppColor.successColor,
              ),
              _buildStatCard(
                "Pending Orders",
                "${_stats['pendingOrders'] ?? 0}",
                Icons.pending,
                AppColor.warningColor,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          "Quick Actions".text.xl.bold.make().py8(),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: "View Reports",
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  backgroundColor: AppColor.primaryColor,
                  icon: Icons.analytics,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: "Withdraw Funds",
                  onPressed: () {
                    _tabController.animateTo(2);
                  },
                  backgroundColor: AppColor.successColor,
                  icon: Icons.account_balance,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return const FinanceReportsScreen();
  }

  Widget _buildWithdrawTab() {
    return const WithdrawalScreen();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Icon(Icons.trending_up, color: color.withOpacity(0.5), size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
