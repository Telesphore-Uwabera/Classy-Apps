import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/language.service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    // Responsive mobile design - adapts to actual screen size
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Wallet',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045, // 4.5% of screen width
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFE91E63),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.trending_up,
              color: Colors.white,
              size: screenWidth * 0.05, // 5% of screen width
            ),
            onPressed: () {
              // TODO: Navigate to analytics
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Analytics coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
          child: Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  
                  // Current Balance Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.05), // 5% of screen width
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04, // 4% of screen width
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.015), // 1.5% of screen height
                        
                        Text(
                          'UGX 245,000',
                          style: TextStyle(
                            fontSize: screenWidth * 0.08, // 8% of screen width
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: screenHeight * 0.06, // 6% of screen height
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Handle withdrawal
                                    _showWithdrawalDialog(context);
                                  },
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: screenWidth * 0.04, // 4% of screen width
                                  ),
                                  label: Text(
                                    'Withdraw',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035, // 3.5% of screen width
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFE91E63),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(width: screenWidth * 0.03), // 3% of screen width
                            
                            // History Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Transaction history coming soon!')),
                                  );
                                },
                                icon: Icon(Icons.history),
                                label: Text('History'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(width: screenWidth * 0.03),
                            
                            // Service History Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/service-history');
                                },
                                icon: Icon(Icons.directions_car),
                                label: Text('Trips'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFE91E63),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Recent Transactions
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // 5% of screen width
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  
                  // Transaction List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTransactionItem(
                          'Withdrawal',
                          'Apr 17, 2025',
                          'UGX 50,000',
                          Icons.keyboard_arrow_down,
                          Colors.red,
                          screenWidth,
                          screenHeight,
                        ),
                        _buildTransactionItem(
                          'Ride Earnings',
                          'Apr 17, 2025',
                          '+UGX 12,000',
                          Icons.keyboard_arrow_up,
                          Colors.green,
                          screenWidth,
                          screenHeight,
                        ),
                        _buildTransactionItem(
                          'Delivery Earnings',
                          'Apr 16, 2025',
                          '+UGX 8,000',
                          Icons.keyboard_arrow_up,
                          Colors.green,
                          screenWidth,
                          screenHeight,
                        ),
                        _buildTransactionItem(
                          'Withdrawal',
                          'Apr 15, 2025',
                          'UGX 100,000',
                          Icons.keyboard_arrow_down,
                          Colors.red,
                          screenWidth,
                          screenHeight,
                        ),
                        _buildTransactionItem(
                          'Bonus',
                          'Apr 14, 2025',
                          '+UGX 30,000',
                          Icons.keyboard_arrow_up,
                          Colors.green,
                          screenWidth,
                          screenHeight,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.05), // 5% of screen height
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFE91E63),
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 2, // Wallet is active
        onTap: (index) {
          // Handle navigation between main sections
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case 1:
              Navigator.of(context).pushNamed('/bookings');
              break;
            case 2:
              // Already on Wallet
              break;
            case 3:
              Navigator.of(context).pushNamed('/profile');
              break;
          }
        },
      ),
    );
  }
  
  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    IconData icon,
    Color color,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05, // 5% of screen width
        vertical: screenHeight * 0.02, // 2% of screen height
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.025), // 2.5% of screen width
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: screenWidth * 0.05, // 5% of screen width
            ),
          ),
          
          SizedBox(width: screenWidth * 0.04), // 4% of screen width
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // 4% of screen width
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005), // 0.5% of screen height
                Text(
                  date,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03, // 3% of screen width
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            amount,
            style: TextStyle(
              fontSize: screenWidth * 0.04, // 4% of screen width
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showWithdrawalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Withdraw Funds'),
        content: Text('How much would you like to withdraw?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Withdrawal request submitted!')),
              );
            },
            child: Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}
