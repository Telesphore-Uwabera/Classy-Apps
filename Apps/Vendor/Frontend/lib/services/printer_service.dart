import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/order.dart';
import '../constants/app_constants.dart';

class PrinterService {
  static PrinterService? _instance;
  static PrinterService get instance => _instance ??= PrinterService._();
  
  PrinterService._();

  // Printer settings
  String _printerName = 'Default Printer';
  String _printerAddress = '';
  bool _isBluetoothEnabled = false;
  bool _isNetworkEnabled = true;
  int _paperWidth = 80; // mm
  String _fontSize = 'medium';

  // Getters
  String get printerName => _printerName;
  String get printerAddress => _printerAddress;
  bool get isBluetoothEnabled => _isBluetoothEnabled;
  bool get isNetworkEnabled => _isNetworkEnabled;
  int get paperWidth => _paperWidth;
  String get fontSize => _fontSize;

  // Update printer settings
  Future<bool> updatePrinterSettings({
    String? printerName,
    String? printerAddress,
    bool? isBluetoothEnabled,
    bool? isNetworkEnabled,
    int? paperWidth,
    String? fontSize,
  }) async {
    try {
      if (printerName != null) _printerName = printerName;
      if (printerAddress != null) _printerAddress = printerAddress;
      if (isBluetoothEnabled != null) _isBluetoothEnabled = isBluetoothEnabled;
      if (isNetworkEnabled != null) _isNetworkEnabled = isNetworkEnabled;
      if (paperWidth != null) _paperWidth = paperWidth;
      if (fontSize != null) _fontSize = fontSize;
      
      // In a real app, you would save these settings to SharedPreferences
      return true;
    } catch (e) {
      print('Error updating printer settings: $e');
      return false;
    }
  }

  // Print order receipt
  Future<bool> printOrderReceipt(Order order) async {
    try {
      final receiptContent = _generateReceiptContent(order);
      return await _printContent(receiptContent);
    } catch (e) {
      print('Error printing order receipt: $e');
      return false;
    }
  }

  // Generate receipt content
  String _generateReceiptContent(Order order) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('=' * _paperWidth);
    buffer.writeln('${AppConstants.companyName.toUpperCase()}');
    buffer.writeln('ORDER RECEIPT');
    buffer.writeln('=' * _paperWidth);
    buffer.writeln();
    
    // Order details
    buffer.writeln('Order ID: ${order.id}');
    buffer.writeln('Date: ${_formatDate(order.createdAt)}');
    buffer.writeln('Time: ${_formatTime(order.createdAt)}');
    buffer.writeln('Status: ${order.status.toUpperCase()}');
    buffer.writeln();
    
    // Customer details
    buffer.writeln('CUSTOMER DETAILS');
    buffer.writeln('-' * _paperWidth);
    buffer.writeln('Name: ${order.customerName}');
    buffer.writeln('Phone: ${order.customerPhone}');
    buffer.writeln('Email: ${order.customerEmail}');
    buffer.writeln();
    
    // Delivery address
    buffer.writeln('DELIVERY ADDRESS');
    buffer.writeln('-' * _paperWidth);
    buffer.writeln('${order.deliveryAddress?.address ?? ''}');
    buffer.writeln('${order.deliveryCity}');
    if (order.deliveryInstructions.isNotEmpty) {
      buffer.writeln('Instructions: ${order.deliveryInstructions}');
    }
    buffer.writeln();
    
    // Order items
    buffer.writeln('ORDER ITEMS');
    buffer.writeln('-' * _paperWidth);
    for (final item in order.items) {
      buffer.writeln('${item['productName'] ?? 'Unknown Product'}');
      buffer.writeln('  Qty: ${item['quantity'] ?? 1} x ${AppConstants.currencySymbol}${(item['price'] ?? 0.0).toStringAsFixed(2)}');
      buffer.writeln('  Subtotal: ${AppConstants.currencySymbol}${((item['quantity'] ?? 1) * (item['price'] ?? 0.0)).toStringAsFixed(2)}');
      buffer.writeln();
    }
    
    // Totals
    buffer.writeln('TOTALS');
    buffer.writeln('-' * _paperWidth);
    buffer.writeln('Subtotal: ${AppConstants.currencySymbol}${order.totalAmount.toStringAsFixed(2)}');
    buffer.writeln('Total: ${AppConstants.currencySymbol}${order.totalAmount.toStringAsFixed(2)}');
    buffer.writeln();
    
    // Payment info
    if (order.paymentInfo.isNotEmpty) {
      buffer.writeln('PAYMENT');
      buffer.writeln('-' * _paperWidth);
      buffer.writeln('Method: ${order.paymentInfo['method'] ?? 'N/A'}');
      buffer.writeln('Status: ${order.paymentInfo['status'] ?? 'N/A'}');
      buffer.writeln();
    }
    
    // Footer
    buffer.writeln('=' * _paperWidth);
    buffer.writeln('Thank you for your business!');
    buffer.writeln('=' * _paperWidth);
    
    return buffer.toString();
  }

  // Print content (simulated - in real app would use actual printer)
  Future<bool> _printContent(String content) async {
    try {
      // For demo purposes, save to file and open it
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(content);
      
      // Open the file (simulates printing)
      await OpenFile.open(file.path);
      
      return true;
    } catch (e) {
      print('Error printing content: $e');
      return false;
    }
  }

  // Format date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Format time
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Test printer connection
  Future<bool> testPrinterConnection() async {
    try {
      // Simulate printer test
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      print('Error testing printer connection: $e');
      return false;
    }
  }

  // Get available printers (simulated)
  Future<List<String>> getAvailablePrinters() async {
    // In a real app, this would scan for available printers
    return [
      'Default Printer',
      'Bluetooth Printer',
      'Network Printer',
      'USB Printer',
    ];
  }

  // Print order summary
  Future<bool> printOrderSummary(Order order) async {
    try {
      final summaryContent = _generateOrderSummary(order);
      return await _printContent(summaryContent);
    } catch (e) {
      print('Error printing order summary: $e');
      return false;
    }
  }

  // Generate order summary
  String _generateOrderSummary(Order order) {
    final buffer = StringBuffer();
    
    buffer.writeln('ORDER SUMMARY');
    buffer.writeln('=' * _paperWidth);
    buffer.writeln('Order ID: ${order.id}');
    buffer.writeln('Customer: ${order.customerName}');
    buffer.writeln('Total: ${AppConstants.currencySymbol}${order.totalAmount.toStringAsFixed(2)}');
    buffer.writeln('Status: ${order.status.toUpperCase()}');
    buffer.writeln('Items: ${order.items.length}');
    buffer.writeln('=' * _paperWidth);
    
    return buffer.toString();
  }
}
