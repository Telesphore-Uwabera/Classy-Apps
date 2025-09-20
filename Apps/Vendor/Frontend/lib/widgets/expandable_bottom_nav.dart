import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class ExpandableBottomNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ExpandableBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<ExpandableBottomNav> createState() => _ExpandableBottomNavState();
}

class _ExpandableBottomNavState extends State<ExpandableBottomNav>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', color: AppTheme.primaryColor),
    NavItem(icon: Icons.inventory_2_outlined, label: 'Products', color: Colors.orange),
    NavItem(icon: Icons.shopping_cart_outlined, label: 'Orders', color: Colors.green),
    NavItem(icon: Icons.warehouse_outlined, label: 'Inventory', color: Colors.blue),
    NavItem(icon: Icons.analytics_outlined, label: 'Analytics', color: Colors.purple),
    NavItem(icon: Icons.people_outline, label: 'Customers', color: Colors.teal),
    NavItem(icon: Icons.location_on_outlined, label: 'Zones', color: Colors.red),
    NavItem(icon: Icons.account_balance_wallet_outlined, label: 'Finance', color: Colors.indigo),
    NavItem(icon: Icons.local_shipping_outlined, label: 'Pricing', color: Colors.brown),
    NavItem(icon: Icons.notifications_outlined, label: 'Notifications', color: Colors.pink),
    NavItem(icon: Icons.chat_bubble_outline, label: 'Messages', color: Colors.cyan),
    NavItem(icon: Icons.folder_outlined, label: 'Documents', color: Colors.amber),
    NavItem(icon: Icons.settings_outlined, label: 'Settings', color: Colors.grey),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expanded Navigation Grid
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _expandAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final item = _navItems[index];
                        final isSelected = widget.selectedIndex == index;
                        
                        return GestureDetector(
                          onTap: () {
                            widget.onItemSelected(index);
                            _toggleExpansion();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? item.color.withValues(alpha: 0.1)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? item.color 
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  color: isSelected ? item.color : Colors.grey[600],
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? item.color : Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Main Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Dashboard (Always visible)
                _buildMainNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
                
                // Expandable Menu Button
                GestureDetector(
                  onTap: _toggleExpansion,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isExpanded ? AppTheme.primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.apps,
                        color: _isExpanded ? Colors.white : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                // Quick Actions
                _buildMainNavItem(1, Icons.shopping_cart_outlined, 'Orders'),
                _buildMainNavItem(2, Icons.people_outline, 'Customers'),
                _buildMainNavItem(3, Icons.settings_outlined, 'Settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainNavItem(int index, IconData icon, String label) {
    final isSelected = widget.selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        widget.onItemSelected(index);
        if (_isExpanded) {
          _toggleExpansion();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final Color color;

  NavItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
