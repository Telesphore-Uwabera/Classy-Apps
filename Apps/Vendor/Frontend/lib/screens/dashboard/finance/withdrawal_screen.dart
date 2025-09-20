import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/withdrawal_service.dart';
import '../../../services/payment_account_service.dart';
import '../../../models/withdrawal.dart';
import '../../../models/payment_account.dart';
import '../../../widgets/custom_button.dart';
import '../../../constants/app_theme.dart';
import '../../../constants/app_constants.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> with TickerProviderStateMixin {
  final WithdrawalService _withdrawalService = WithdrawalService.instance;
  final PaymentAccountService _paymentService = PaymentAccountService.instance;
  
  late TabController _tabController;
  
  double _availableBalance = 0.0;
  double _pendingAmount = 0.0;
  List<Withdrawal> _withdrawals = [];
  List<PaymentAccount> _paymentAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final vendorId = authService.currentUser?.id?.toString() ?? '';
      
      if (vendorId.isNotEmpty) {
        final balance = await _withdrawalService.getAvailableBalance(vendorId);
        final pending = await _withdrawalService.getPendingWithdrawalsAmount(vendorId);
        final withdrawals = await _withdrawalService.getWithdrawals(vendorId);
        final accounts = await _paymentService.getPaymentAccounts(vendorId);
        
        setState(() {
          _availableBalance = balance;
          _pendingAmount = pending;
          _withdrawals = withdrawals;
          _paymentAccounts = accounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _requestWithdrawal() async {
    if (_paymentAccounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a payment account first')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _WithdrawalRequestDialog(
        availableBalance: _availableBalance,
        paymentAccounts: _paymentAccounts,
      ),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final vendorId = authService.currentUser?.id ?? '';
        
        final withdrawal = Withdrawal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          vendorId: vendorId.toString(),
          paymentAccountId: result['accountId'],
          amount: result['amount'],
          status: 'pending',
          notes: result['notes'],
          requestedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final success = await _withdrawalService.createWithdrawal(withdrawal);
        
        if (success) {
          await _loadData(); // Reload data
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Withdrawal request submitted successfully')),
            );
          }
        } else {
          throw Exception('Failed to submit withdrawal request');
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawals'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Balance'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBalanceTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildBalanceTab() {
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
                colors: [AppTheme.primaryColor, AppTheme.primaryColorDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppConstants.currencySymbol}${_availableBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${AppConstants.currencySymbol}${_pendingAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${AppConstants.currencySymbol}${(_availableBalance + _pendingAmount).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Withdrawal Button
          CustomButton(
            text: 'Request Withdrawal',
            onPressed: _availableBalance > 0 ? _requestWithdrawal : null,
            icon: Icons.account_balance_wallet,
          ),
          
          if (_availableBalance <= 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Insufficient balance for withdrawal. Minimum amount is ${AppConstants.currencySymbol}10.00',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Payment Accounts
          if (_paymentAccounts.isNotEmpty) ...[
            const Text(
              'Payment Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._paymentAccounts.map((account) => Card(
              child: ListTile(
                leading: Text(
                  account.accountTypeIcon,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(account.accountName),
                subtitle: Text(account.accountTypeDisplayName),
                trailing: account.isDefault
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                      )
                    : null,
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return _withdrawals.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Withdrawals',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Your withdrawal history will appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _withdrawals.length,
            itemBuilder: (context, index) {
              final withdrawal = _withdrawals[index];
              return _buildWithdrawalCard(withdrawal);
            },
          );
  }

  Widget _buildWithdrawalCard(Withdrawal withdrawal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppConstants.currencySymbol}${withdrawal.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(int.parse(withdrawal.statusColor.replaceAll('#', '0xFF'))).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    withdrawal.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(int.parse(withdrawal.statusColor.replaceAll('#', '0xFF'))),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              withdrawal.methodDisplayName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              'Requested: ${_formatDate(withdrawal.requestedAt ?? withdrawal.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            
            if (withdrawal.processedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Processed: ${_formatDate(withdrawal.processedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
            
            if (withdrawal.notes != null && withdrawal.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${withdrawal.notes}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            if (withdrawal.canBeCancelled) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _cancelWithdrawal(withdrawal),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _cancelWithdrawal(Withdrawal withdrawal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Withdrawal'),
        content: Text('Are you sure you want to cancel this withdrawal of ${AppConstants.currencySymbol}${withdrawal.amount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _withdrawalService.cancelWithdrawal(withdrawal.id);
      if (success) {
        await _loadData(); // Reload data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Withdrawal cancelled successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to cancel withdrawal')),
          );
        }
      }
    }
  }
}

class _WithdrawalRequestDialog extends StatefulWidget {
  final double availableBalance;
  final List<PaymentAccount> paymentAccounts;

  const _WithdrawalRequestDialog({
    required this.availableBalance,
    required this.paymentAccounts,
  });

  @override
  State<_WithdrawalRequestDialog> createState() => _WithdrawalRequestDialogState();
}

class _WithdrawalRequestDialogState extends State<_WithdrawalRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedAccountId;
  String _selectedMethod = 'bank_transfer';

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Withdrawal'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid amount';
                  }
                  if (amount < 10) {
                    return 'Minimum amount is \$10';
                  }
                  if (amount > widget.availableBalance) {
                    return 'Amount exceeds available balance';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Payment Account
              DropdownButtonFormField<String>(
                value: _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Payment Account',
                  border: OutlineInputBorder(),
                ),
                items: widget.paymentAccounts.map((account) => DropdownMenuItem<String>(
                  value: account.id.toString(),
                  child: Text('${account.accountName} (${account.accountTypeDisplayName})'),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select payment account';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'amount': double.parse(_amountController.text),
                'accountId': _selectedAccountId,
                'method': _selectedMethod,
                'notes': _notesController.text,
              });
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
