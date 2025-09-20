import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../../services/auth_service.dart';
import '../../../services/order_service.dart';
import '../../../constants/simple_app_colors.dart';
import '../../../constants/simple_app_strings.dart';
import '../../../widgets/custom_button.dart';
import '../../../models/order.dart';
import 'order_details_screen.dart';

class ProfessionalOrdersScreen extends StatefulWidget {
  const ProfessionalOrdersScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalOrdersScreen> createState() => _ProfessionalOrdersScreenState();
}

class _ProfessionalOrdersScreenState extends State<ProfessionalOrdersScreen> with TickerProviderStateMixin {
  final OrderService _orderService = OrderService.instance;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final List<String> _statusTabs = ['All', 'Pending', 'Processing', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedStatus = _statusTabs[_tabController.index].toLowerCase();
      });
      _loadOrders();
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final vendorId = authService.currentUser?.id?.toString() ?? '';
      
      if (vendorId.isNotEmpty) {
        final orders = await _orderService.getOrders(vendorId);
        setState(() {
          _orders = List<Map<String, dynamic>>.from(orders);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    var filtered = _orders;
    
    if (_selectedStatus != 'all') {
      filtered = filtered.where((order) {
        final status = order['status']?.toString().toLowerCase() ?? '';
        return status == _selectedStatus;
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: "Orders".text.xl.bold.make(),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _statusTabs.map((status) => Tab(text: status)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Search orders...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          
          // Orders List
          Expanded(
            child: _isLoading
                ? _buildLoadingWidget()
                : _filteredOrders.isEmpty
                    ? _buildEmptyWidget()
                    : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: VStack([
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
        ),
        const SizedBox(height: 16),
        "Loading orders...".text.lg.gray600.make(),
      ]),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: VStack([
        Icon(
          Icons.shopping_cart_outlined,
          size: 80,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        "No orders found".text.xl.gray600.make(),
        const SizedBox(height: 8),
        _selectedStatus == 'all'
            ? "Orders will appear here when customers place them".text.gray500.make()
            : "No ${_selectedStatus} orders found".text.gray500.make(),
        const SizedBox(height: 24),
        CustomButton(
          text: "Refresh",
          onPressed: _loadOrders,
          backgroundColor: AppColor.primaryColor,
        ),
      ]),
    );
  }

  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? 'pending';
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: Order.fromJson(order)),
            ),
          ).then((_) => _loadOrders());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${order['id']?.toString().substring(0, 8) ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Customer Info
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    order['customerName'] ?? 'Unknown Customer',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Order Details
              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    "${order['items']?.length ?? 0} items",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    "${AppStrings.currencySymbol}${(order['totalAmount'] ?? 0.0).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Time and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(order['createdAt']),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColor.textHint,
                    ),
                  ),
                  Row(
                    children: [
                      if (status == 'pending') ...[
                        CustomButton(
                          text: "Accept",
                          onPressed: () => _updateOrderStatus(order['id'], 'processing'),
                          backgroundColor: AppColor.successColor,
                          isSmall: true,
                        ),
                        const SizedBox(width: 8),
                        CustomButton(
                          text: "Reject",
                          onPressed: () => _updateOrderStatus(order['id'], 'cancelled'),
                          backgroundColor: AppColor.errorColor,
                          isSmall: true,
                        ),
                      ] else if (status == 'processing') ...[
                        CustomButton(
                          text: "Complete",
                          onPressed: () => _updateOrderStatus(order['id'], 'completed'),
                          backgroundColor: AppColor.successColor,
                          isSmall: true,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColor.warningColor;
      case 'processing':
        return AppColor.infoColor;
      case 'completed':
        return AppColor.successColor;
      case 'cancelled':
        return AppColor.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown date';
    try {
      final DateTime dateTime = date is DateTime ? date : DateTime.parse(date.toString());
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _orderService.updateOrderStatus(orderId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $status'),
          backgroundColor: AppColor.successColor,
        ),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e'),
          backgroundColor: AppColor.errorColor,
        ),
      );
    }
  }
}
