import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/views/pages/home.page.dart';
import 'package:fuodz/views/pages/bookings.page.dart';
import 'package:fuodz/views/pages/wallet.page.dart';
import 'package:fuodz/views/pages/profile.page.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:velocity_x/velocity_x.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    HomePage(),
    BookingsPage(),
    WalletPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: false,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColor.backgroundCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home,
                  label: "Home",
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.calendar_today,
                  label: "Bookings",
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.account_balance_wallet,
                  label: "Wallet",
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person,
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.classyPrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: VStack(
          [
            Icon(
              icon,
              color: isSelected ? AppColor.classyPrimary : AppColor.textLight,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColor.classyPrimary : AppColor.textLight,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
