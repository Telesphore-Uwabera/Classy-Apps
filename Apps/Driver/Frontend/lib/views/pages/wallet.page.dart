import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: "My Wallet",
      body: Container(
        padding: EdgeInsets.all(20),
        child: VStack(
          [
            // Current Balance Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.backgroundCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: VStack(
                [
                  Text(
                    "Current Balance",
                    style: TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ).py8(),
                  
                  Text(
                    "UGX 245,000",
                    style: TextStyle(
                      color: AppColor.classyPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ).py16(),
                  
                  // Action Buttons
                  HStack(
                    [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle withdraw
                          },
                          icon: Icon(Icons.download, color: AppColor.textWhite),
                          label: Text("Withdraw"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.classyPrimary,
                            foregroundColor: AppColor.textWhite,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle history
                          },
                          icon: Icon(Icons.history, color: AppColor.classyPrimary),
                          label: Text("History"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.classyPrimary,
                            side: BorderSide(color: AppColor.classyPrimary),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).py16(),
            
            // Recent Transactions
            Text(
              "Recent Transactions",
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ).py16(),
            
            // Transaction List
            Container(
              decoration: BoxDecoration(
                color: AppColor.backgroundCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: VStack(
                [
                  _buildTransactionItem(
                    type: "Withdrawal",
                    date: "Apr 17, 2025",
                    amount: "UGX 50,000",
                    isPositive: false,
                  ),
                  _buildDivider(),
                  _buildTransactionItem(
                    type: "Ride Earnings",
                    date: "Apr 17, 2025",
                    amount: "+UGX 12,000",
                    isPositive: true,
                  ),
                  _buildDivider(),
                  _buildTransactionItem(
                    type: "Delivery Earnings",
                    date: "Apr 16, 2025",
                    amount: "+UGX 8,000",
                    isPositive: true,
                  ),
                  _buildDivider(),
                  _buildTransactionItem(
                    type: "Withdrawal",
                    date: "Apr 15, 2025",
                    amount: "UGX 100,000",
                    isPositive: false,
                  ),
                  _buildDivider(),
                  _buildTransactionItem(
                    type: "Bonus",
                    date: "Apr 14, 2025",
                    amount: "+UGX 30,000",
                    isPositive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String type,
    required String date,
    required String amount,
    required bool isPositive,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      child: HStack(
        [
          // Transaction Info
          Expanded(
            child: VStack(
              [
                Text(
                  type,
                  style: TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              crossAlignment: CrossAxisAlignment.start,
            ),
          ),
          
          // Amount
          Text(
            amount,
            style: TextStyle(
              color: isPositive ? AppColor.classySuccess : AppColor.classyError,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColor.textLight.withOpacity(0.2),
      margin: EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
