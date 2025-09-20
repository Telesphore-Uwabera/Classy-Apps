import 'package:flutter/material.dart';
import '../../../services/order_service.dart';
import '../../../services/printer_service.dart';
import '../../../models/order.dart';
import '../../../widgets/custom_button.dart';
import '../../../constants/app_theme.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderService _orderService = OrderService.instance;
  final PrinterService _printerService = PrinterService.instance;
  late Order _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _updateOrderStatus(String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _orderService.updateOrderStatus(_order.id.toString(), status);
      if (success) {
        setState(() {
          _order = _order.copyWith(status: status);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order status updated to $status')),
          );
        }
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _printReceipt() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _printerService.printOrderReceipt(_order);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Receipt printed successfully!' : 'Failed to print receipt'),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing receipt: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _printOrderSummary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _printerService.printOrderSummary(_order);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Order summary printed successfully!' : 'Failed to print summary'),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing summary: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order.id.toString().substring(0, 8)}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'print_receipt':
                  _printReceipt();
                  break;
                case 'print_summary':
                  _printOrderSummary();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'print_receipt',
                child: Row(
                  children: [
                    Icon(Icons.receipt),
                    SizedBox(width: 8),
                    Text('Print Receipt'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print_summary',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text('Print Summary'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.print),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        _buildStatusChip(_order.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatusTimeline(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Customer Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Name', _order.customerName),
                    _buildInfoRow('Phone', _order.customerPhone),
                    _buildInfoRow('Email', _order.customerEmail),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Delivery Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Address', _order.deliveryAddress.toString()),
                    _buildInfoRow('City', _order.deliveryCity),
                    _buildInfoRow('Instructions', _order.deliveryInstructions.isNotEmpty 
                        ? _order.deliveryInstructions 
                        : 'No special instructions'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Order Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._order.items.map((item) => _buildOrderItem(item)),
                    const Divider(),
                    _buildTotalRow(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            if (_order.status != 'completed' && _order.status != 'cancelled')
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        statusText = 'Pending';
        break;
      case 'confirmed':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        statusText = 'Confirmed';
        break;
      case 'preparing':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        statusText = 'Preparing';
        break;
      case 'ready':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        statusText = 'Ready';
        break;
      case 'delivering':
        backgroundColor = Colors.teal[100]!;
        textColor = Colors.teal[800]!;
        statusText = 'Delivering';
        break;
      case 'completed':
        backgroundColor = Colors.green[200]!;
        textColor = Colors.green[800]!;
        statusText = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        statusText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        statusText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statuses = ['pending', 'confirmed', 'preparing', 'ready', 'delivering', 'completed'];
    final currentIndex = statuses.indexOf(_order.status);
    
    return Row(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              if (index < statuses.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$${_order.totalAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_order.status == 'pending')
          CustomButton(
            text: 'Confirm Order',
            onPressed: _isLoading ? null : () => _updateOrderStatus('confirmed'),
            isLoading: _isLoading,
          ),
        
        if (_order.status == 'confirmed')
          CustomButton(
            text: 'Start Preparing',
            onPressed: _isLoading ? null : () => _updateOrderStatus('preparing'),
            isLoading: _isLoading,
          ),
        
        if (_order.status == 'preparing')
          CustomButton(
            text: 'Mark as Ready',
            onPressed: _isLoading ? null : () => _updateOrderStatus('ready'),
            isLoading: _isLoading,
          ),
        
        if (_order.status == 'ready')
          CustomButton(
            text: 'Start Delivery',
            onPressed: _isLoading ? null : () => _updateOrderStatus('delivering'),
            isLoading: _isLoading,
          ),
        
        if (_order.status == 'delivering')
          CustomButton(
            text: 'Mark as Completed',
            onPressed: _isLoading ? null : () => _updateOrderStatus('completed'),
            isLoading: _isLoading,
          ),
      ],
    );
  }
}
