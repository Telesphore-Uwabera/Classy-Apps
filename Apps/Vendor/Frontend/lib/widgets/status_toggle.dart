import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/vendor_status_service.dart';

class StatusToggle extends StatefulWidget {
  final String vendorId;
  final String currentStatus;
  final Function(String)? onStatusChanged;

  const StatusToggle({
    super.key,
    required this.vendorId,
    required this.currentStatus,
    this.onStatusChanged,
  });

  @override
  State<StatusToggle> createState() => _StatusToggleState();
}

class _StatusToggleState extends State<StatusToggle> {
  final VendorStatusService _statusService = VendorStatusService.instance;
  String _currentStatus = 'offline';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.currentStatus;
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final success = await _statusService.updateVendorStatus(widget.vendorId, newStatus);
      if (success) {
        setState(() {
          _currentStatus = newStatus;
        });
        widget.onStatusChanged?.call(newStatus);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update status')),
          );
        }
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
          _isUpdating = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return AppTheme.successColor;
      case 'busy':
        return AppTheme.warningColor;
      case 'offline':
      default:
        return AppTheme.errorColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'online':
        return 'Online';
      case 'busy':
        return 'Busy';
      case 'offline':
      default:
        return 'Offline';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'online':
        return Icons.circle;
      case 'busy':
        return Icons.pause_circle;
      case 'offline':
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(_currentStatus).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(_currentStatus),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isUpdating)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          else
            Icon(
              _getStatusIcon(_currentStatus),
              color: _getStatusColor(_currentStatus),
              size: 16,
            ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(_currentStatus),
            style: TextStyle(
              color: _getStatusColor(_currentStatus),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (status) => _updateStatus(status),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'online',
                child: Row(
                  children: [
                    Icon(Icons.circle, color: AppTheme.successColor, size: 16),
                    SizedBox(width: 8),
                    Text('Online'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'busy',
                child: Row(
                  children: [
                    Icon(Icons.pause_circle, color: AppTheme.warningColor, size: 16),
                    SizedBox(width: 8),
                    Text('Busy'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'offline',
                child: Row(
                  children: [
                    Icon(Icons.circle_outlined, color: AppTheme.errorColor, size: 16),
                    SizedBox(width: 8),
                    Text('Offline'),
                  ],
                ),
              ),
            ],
            child: Icon(
              Icons.arrow_drop_down,
              color: _getStatusColor(_currentStatus),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
