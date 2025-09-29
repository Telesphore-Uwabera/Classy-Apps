import 'package:flutter/material.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/models/vendor.dart';

class VendorDashboardViewModel extends MyBaseViewModel {
  //
  VendorDashboardViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  VendorRequest vendorRequest = VendorRequest();
  Vendor? currentVendor;
  
  // Dashboard stats
  double balance = 0.0;
  int totalOrders = 0;
  double totalSales = 0.0;
  int totalProducts = 0;
  double rating = 0.0;
  
  // Recent activities
  List<Map<String, dynamic>> recentActivities = [];

  void initialise() {
    loadDashboardData();
  }

  //
  loadDashboardData() async {
    setBusy(true);
    
    try {
      // Get current vendor data
      currentVendor = AuthServices.currentVendor;
      
      // Load vendor statistics
      await loadVendorStats();
      
      // Load recent activities
      await loadRecentActivities();
      
      clearErrors();
    } catch (error) {
      print("Dashboard Error ==> $error");
      setError(error);
    }
    
    setBusy(false);
  }

  //
  loadVendorStats() async {
    try {
      final stats = await vendorRequest.getVendorStats();
      
      balance = (stats['balance'] ?? 0.0).toDouble();
      totalOrders = stats['total_orders'] ?? 0;
      totalSales = (stats['total_sales'] ?? 0.0).toDouble();
      totalProducts = stats['total_products'] ?? 0;
      rating = (stats['rating'] ?? 0.0).toDouble();
      
      notifyListeners();
    } catch (error) {
      print("Stats Error ==> $error");
      // Set default values if API fails
      balance = 0.0;
      totalOrders = 0;
      totalSales = 0.0;
      totalProducts = 0;
      rating = 0.0;
      notifyListeners();
    }
  }

  //
  loadRecentActivities() async {
    try {
      final activities = await vendorRequest.getRecentActivities();
      
      recentActivities = activities.map((activity) => {
        'title': activity['title'] ?? '',
        'subtitle': activity['subtitle'] ?? '',
        'status': activity['status'] ?? '',
        'statusColor': _getStatusColor(activity['status'] ?? ''),
        'icon': _getStatusIcon(activity['status'] ?? ''),
      }).toList();
      
      notifyListeners();
    } catch (error) {
      print("Activities Error ==> $error");
      recentActivities = [];
      notifyListeners();
    }
  }

  //
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  //
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'cancelled':
      case 'refunded':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  //
  refreshDashboard() {
    loadDashboardData();
  }
}
