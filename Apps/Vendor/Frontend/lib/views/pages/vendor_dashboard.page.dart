import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'widgets/base.page.dart';
import 'services/auth.service.dart';
import 'view_models/vendor_dashboard.vm.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class VendorDashboardPage extends StatelessWidget {
  const VendorDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VendorDashboardViewModel>.reactive(
      viewModelBuilder: () => VendorDashboardViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showAppBar: false,
          isLoading: model.isBusy,
          body: SafeArea(
            child: VStack([
              // Header with profile and app name
              HStack([
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                VStack([
                  (model.currentVendor?.name ?? "Vendor").text.xl.bold.make(),
                  "Active now".text.sm.color(Colors.green).make(),
                ]).expand(),
                const Icon(
                  Icons.notifications,
                  size: 30,
                  color: Color(0xFFE91E63),
                ),
              ]).p20(),

          // Balance Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
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
            child: VStack([
              HStack([
                const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFFE91E63),
                  size: 20,
                ),
                "Balance".text.lg.make(),
              ]),
              "UGX ${model.balance.toStringAsFixed(0)}".text.xl2.bold.make().py8(),
              HStack([
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement withdraw functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: HStack([
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      "Withdraw".text.white.bold.make(),
                    ]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to transactions
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: HStack([
                      const Icon(Icons.refresh, color: Colors.grey, size: 20),
                      "Transactions".text.gray600.bold.make(),
                    ]),
                  ),
                ),
              ]),
            ]),
          ).py12(),

          // Monthly Stats
          "Monthly Stats".text.xl.bold.make().px20().py12(),
          HStack([
            _buildStatCard("${model.totalOrders} Orders", Icons.shopping_cart, Colors.blue),
            _buildStatCard("UGX ${(model.totalSales / 1000000).toStringAsFixed(1)}M Sales", Icons.attach_money, Colors.green),
          ], spacing: 12).px20(),
          HStack([
            _buildStatCard("${model.totalProducts} Products", Icons.inventory, Colors.orange),
            _buildStatCard("${model.rating.toStringAsFixed(1)} Rating", Icons.star, const Color(0xFFE91E63)),
          ], spacing: 12).px20().py8(),

          // Recent Activity
          HStack([
            "Recent Activity".text.xl.bold.make(),
            "View All".text.color(const Color(0xFFE91E63)).make(),
          ], alignment: MainAxisAlignment.spaceBetween).px20().py12(),

          model.recentActivities.isEmpty 
            ? Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    "No recent activities".text.lg.color(Colors.grey.shade600).make(),
                    "Your recent orders and activities will appear here".text.sm.color(Colors.grey.shade500).make().py4(),
                  ],
                ),
              )
            : VStack(
                model.recentActivities.map((activity) => 
                  _buildActivityItem(
                    activity['title'] ?? '',
                    activity['subtitle'] ?? '',
                    activity['status'] ?? '',
                    activity['statusColor'] ?? Colors.grey,
                    activity['icon'] ?? Icons.info,
                  )
                ).toList(),
              ).px20(),
        ]).scrollVertical(),
      ),
    );
      },
    );
  }

  Widget _buildStatCard(String text, IconData icon, Color color) {
    return Expanded(
      child: Container(
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
        child: VStack([
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          text.text.lg.bold.make(),
        ], crossAlignment: CrossAxisAlignment.center),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String status, Color statusColor, IconData statusIcon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: HStack([
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
        ),
        VStack([
          title.text.lg.bold.make(),
          subtitle.text.sm.gray600.make(),
        ]).expand().px12(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: status.text.sm.color(statusColor).bold.make(),
        ),
      ]),
    );
  }
}
