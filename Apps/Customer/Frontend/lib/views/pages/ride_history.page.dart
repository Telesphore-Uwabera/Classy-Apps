import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/services/delivery_history.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({super.key});

  @override
  _RideHistoryPageState createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  final DeliveryHistoryService _deliveryService = DeliveryHistoryService();

  List<Map<String, dynamic>> _rides = [];
  bool _isLoadingRides = false;

  List<Map<String, dynamic>> get _deliveries => _deliveryService.getDeliveryHistory();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _loadRideHistory();
  }

  Future<void> _loadRideHistory() async {
    setState(() {
      _isLoadingRides = true;
    });

    try {
      // Load real ride history from API
      final response = await _deliveryService.getRideHistory();
      if (response.allGood && response.body != null && response.body!['data'] != null) {
        setState(() {
          _rides = List<Map<String, dynamic>>.from(response.body!['data']);
        });
      }
    } catch (e) {
      print('Error loading ride history: $e');
      // Keep empty list for real data
      setState(() {
        _rides = [];
      });
    } finally {
      setState(() {
        _isLoadingRides = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'History'.tr(),
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Tabs
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentTabIndex = 0;
                        });
                        _tabController.animateTo(0);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentTabIndex == 0 ? AppColor.primaryColor : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          'Rides'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _currentTabIndex == 0 ? Colors.black87 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentTabIndex = 1;
                        });
                        _tabController.animateTo(1);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentTabIndex == 1 ? AppColor.primaryColor : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          'Deliveries'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _currentTabIndex == 1 ? Colors.black87 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Rides Tab
                    _buildRidesTab(),
                    // Deliveries Tab
                    _buildDeliveriesTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Method to refresh delivery history
  void _refreshDeliveryHistory() {
    setState(() {
      // This will trigger a rebuild and fetch fresh data from the service
    });
  }
  
  // Show delivery status update dialog
  void _showDeliveryStatusUpdate(Map<String, dynamic> delivery) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: "Update Delivery Status".text.bold.make(),
          content: VStack([
            "Current Status: ${delivery['status']}".text.make(),
            UiSpacer.verticalSpace(space: 16),
            "Select new status:".text.make(),
            UiSpacer.verticalSpace(space: 12),
            _buildStatusOption(delivery, 'Pending'),
            _buildStatusOption(delivery, 'In Progress'),
            _buildStatusOption(delivery, 'Completed'),
            _buildStatusOption(delivery, 'Cancelled'),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: "Cancel".text.make(),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildStatusOption(Map<String, dynamic> delivery, String status) {
    final isCurrentStatus = delivery['status'] == status;
    return GestureDetector(
      onTap: () {
        _deliveryService.updateDeliveryStatus(delivery['id'], status);
        Navigator.of(context).pop();
        _refreshDeliveryHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: "Status updated to $status".text.white.make(),
            backgroundColor: AppColor.primaryColor,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isCurrentStatus ? AppColor.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentStatus ? AppColor.primaryColor : Colors.grey.shade300,
            width: isCurrentStatus ? 2 : 1,
          ),
        ),
        child: HStack([
          if (isCurrentStatus)
            Icon(Icons.check_circle, color: AppColor.primaryColor, size: 20),
          status.text.bold.color(isCurrentStatus ? AppColor.primaryColor : Colors.black87).make(),
        ]),
      ),
    );
  }

  Widget _buildRidesTab() {
    if (_isLoadingRides) {
      return Center(
        child: VStack([
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
          ),
          UiSpacer.verticalSpace(space: 16),
          "Loading ride history...".text.gray600.make(),
        ]),
      );
    }

    if (_rides.isEmpty) {
      return Center(
        child: VStack([
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          UiSpacer.verticalSpace(space: 16),
          "No rides yet".text.gray600.xl.make(),
          UiSpacer.verticalSpace(space: 8),
          "Your ride history will appear here".text.gray500.make(),
          UiSpacer.verticalSpace(space: 20),
          ElevatedButton(
            onPressed: _loadRideHistory,
            child: "Refresh".text.white.make(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ]),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadRideHistory,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: VStack([
          for (var ride in _rides)
            _buildRideCard(ride),
        ]),
      ),
    );
  }

  Widget _buildDeliveriesTab() {
    if (_deliveries.isEmpty) {
      return Center(
        child: VStack([
          Icon(
            Icons.local_shipping,
            size: 64,
            color: Colors.grey.shade400,
          ),
          UiSpacer.verticalSpace(space: 16),
          "No deliveries yet".text.gray600.xl.make(),
          UiSpacer.verticalSpace(space: 8),
          "Your delivery history will appear here".text.gray500.make(),
        ]),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        _refreshDeliveryHistory();
      },
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: VStack([
          for (var delivery in _deliveries)
            _buildDeliveryCard(delivery),
        ]),
      ),
    );
  }

  Widget _buildRideCard(Map<String, dynamic> ride) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: VStack([
        // Header
        HStack([
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ride['iconColor'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              ride['icon'],
              color: ride['iconColor'],
              size: 20,
            ),
          ),
          
          UiSpacer.horizontalSpace(space: 12),
          
          Expanded(
            child: VStack([
              ride['type'].toString().text.bold.make(),
              UiSpacer.verticalSpace(space: 4),
              "${ride['date']} • ${ride['time']}".text.gray600.sm.make(),
            ]),
          ),
          
          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(ride['status']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ride['status'].toString().text.color(_getStatusColor(ride['status'])).sm.bold.make(),
          ),
        ]),
        
        UiSpacer.verticalSpace(space: 16),
        
        // Route Details
        HStack([
          Expanded(
            child: VStack([
              "From".text.gray600.xs.make(),
              UiSpacer.verticalSpace(space: 4),
              HStack([
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 6,
                  ),
                ),
                UiSpacer.horizontalSpace(space: 8),
                Flexible(
                  child: ride['from'].toString().text.overflow(TextOverflow.ellipsis).make(),
                ),
              ]),
            ]),
          ),
          
          // Dotted Line
          Container(
            width: 1,
            height: 40,
            child: CustomPaint(
              painter: DottedLinePainter(),
            ),
          ),
          
          Expanded(
            child: VStack([
              "To".text.gray600.xs.make(),
              UiSpacer.verticalSpace(space: 4),
              HStack([
                Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 16,
                ),
                UiSpacer.horizontalSpace(space: 8),
                Flexible(
                  child: ride['to'].toString().text.overflow(TextOverflow.ellipsis).make(),
                ),
              ]),
            ]),
          ),
        ]),
        
        UiSpacer.verticalSpace(space: 16),
        
        // Summary Details
        HStack([
          HStack([
            Icon(
              Icons.access_time,
              color: Colors.grey.shade600,
              size: 16,
            ),
            UiSpacer.horizontalSpace(space: 4),
            ride['duration'].toString().text.gray600.make(),
          ]),
          
          UiSpacer.horizontalSpace(space: 16),
          
          HStack([
            Icon(
              Icons.route,
              color: Colors.grey.shade600,
              size: 16,
            ),
            UiSpacer.horizontalSpace(space: 4),
            ride['distance'].toString().text.gray600.make(),
          ]),
          
          Spacer(),
          
          Flexible(
            child: ride['cost'].toString().text.bold.overflow(TextOverflow.ellipsis).make(),
          ),
        ]),
      ]),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    return GestureDetector(
      onTap: () => _showDeliveryStatusUpdate(delivery),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
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
        child: VStack([
        // Header
        HStack([
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: delivery['iconColor'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              delivery['icon'],
              color: delivery['iconColor'],
              size: 20,
            ),
          ),
          
          UiSpacer.horizontalSpace(space: 12),
          
          Expanded(
            child: VStack([
              delivery['type'].toString().text.bold.make(),
              UiSpacer.verticalSpace(space: 4),
              "${delivery['date']} • ${delivery['time']}".text.gray600.sm.make(),
            ]),
          ),
          
          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(delivery['status']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: delivery['status'].toString().text.color(_getStatusColor(delivery['status'])).sm.bold.make(),
          ),
        ]),
        
        UiSpacer.verticalSpace(space: 16),
        
        // Restaurant Details (for food delivery)
        if (delivery['type'] == 'Food Delivery') ...[
          HStack([
            "Restaurant".text.gray600.xs.make(),
            UiSpacer.horizontalSpace(space: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                delivery['restaurantIcon'],
                color: Colors.orange,
                size: 16,
              ),
            ),
            UiSpacer.horizontalSpace(space: 8),
            Flexible(
              child: delivery['restaurant'].toString().text.overflow(TextOverflow.ellipsis).make(),
            ),
          ]),
          UiSpacer.verticalSpace(space: 16),
        ],
        
        // Route Details
        HStack([
          Expanded(
            child: VStack([
              "From".text.gray600.xs.make(),
              UiSpacer.verticalSpace(space: 4),
              HStack([
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 6,
                  ),
                ),
                UiSpacer.horizontalSpace(space: 8),
                Flexible(
                  child: delivery['from'].toString().text.overflow(TextOverflow.ellipsis).make(),
                ),
              ]),
            ]),
          ),
          
          // Dotted Line
          Container(
            width: 1,
            height: 40,
            child: CustomPaint(
              painter: DottedLinePainter(),
            ),
          ),
          
          Expanded(
            child: VStack([
              "To".text.gray600.xs.make(),
              UiSpacer.verticalSpace(space: 4),
              HStack([
                Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 16,
                ),
                UiSpacer.horizontalSpace(space: 8),
                Flexible(
                  child: delivery['to'].toString().text.overflow(TextOverflow.ellipsis).make(),
                ),
              ]),
            ]),
          ),
        ]),
        
        UiSpacer.verticalSpace(space: 16),
        
        // Summary Details
        HStack([
          delivery['items'].toString().text.gray600.make(),
          
          Spacer(),
          
          Flexible(
            child: delivery['cost'].toString().text.bold.overflow(TextOverflow.ellipsis).make(),
          ),
        ]),
              ]),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4;
    const dashSpace = 4;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
